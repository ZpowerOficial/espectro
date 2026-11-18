import 'dart:async';

import 'package:flutter/material.dart' hide Axis;
import 'package:flutter/services.dart';

import '../../../data/models.dart';
import '../../../domain/models/political_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/espectro_brand_mark.dart';
import '../../ads/espectro_banner_ad.dart';
import '../../view_models/app_view_model.dart';
import '../../view_models/quiz_view_model.dart';
import '../results/espectro_result_screen.dart';

/// Cores de categoria são pastéis editoriais. Em texto sobre superfície clara,
/// elas podem ficar ilegíveis (por exemplo, amarelo claro sobre branco), então
/// escurecemos apenas a tinta, preservando o matiz de identificação.
Color _readablePoleColor(Color color, bool dark) {
  final HSLColor hsl = HSLColor.fromColor(color);
  if (dark) {
    return color.computeLuminance() < 0.30
        ? hsl.withLightness(0.72).toColor()
        : color;
  }
  return color.computeLuminance() > 0.22
      ? hsl.withLightness(0.26).toColor()
      : color;
}

/// Tela unificada de aplicação do questionário Espectro (Eixos + Tríades).
class EspectroQuizScreen extends StatefulWidget {
  const EspectroQuizScreen({
    required this.appViewModel,
    required this.quizViewModel,
    this.returnCompletedRecord = false,
    super.key,
  });

  final AppViewModel appViewModel;
  final QuizViewModel quizViewModel;
  final bool returnCompletedRecord;

  @override
  State<EspectroQuizScreen> createState() => _EspectroQuizScreenState();
}

class _EspectroQuizScreenState extends State<EspectroQuizScreen> {
  Timer? _advanceTimer;

  QuizViewModel get _vm => widget.quizViewModel;

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  Future<void> _exitSavingDraft() async {
    _advanceTimer?.cancel();
    await _vm.saveDraftAsync();
    await widget.appViewModel.refreshDraft();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _onSelectAnswer(LikertAnswer option) {
    _advanceTimer?.cancel();
    HapticFeedback.selectionClick();
    final bool wasAlreadyAnswered = _vm.currentAnswer != null;
    _vm.selectAnswer(option);
    // Revisar uma resposta existente não deve expulsar a pessoa da pergunta:
    // ela precisa ver o efeito da troca antes de decidir avançar.
    if (wasAlreadyAnswered) return;
    if (!widget.appViewModel.autoAdvance || _vm.isLast) return;
    _advanceTimer = Timer(const Duration(milliseconds: 210), () {
      if (!mounted) return;
      _vm.next();
    });
  }

  void _onSkip() {
    _advanceTimer?.cancel();
    HapticFeedback.lightImpact();
    final bool wasLast = _vm.isLast;
    _vm.skipCurrent();
    if (wasLast) {
      _tryFinish();
    }
  }

  Future<void> _viewPreliminaryResult() async {
    _advanceTimer?.cancel();
    if (!_vm.canPreview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Responda a pelo menos 4 afirmações para visualizar a prévia do resultado.',
          ),
        ),
      );
      return;
    }

    final EvaluationRecord record = _vm.buildPreliminaryRecord();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EspectroResultScreen(
          appViewModel: widget.appViewModel,
          record: record,
          quizViewModel: _vm,
          isPreliminary: true,
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _onSwap() {
    _advanceTimer?.cancel();
    final bool ok = _vm.swapCurrentQuestion();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não há outra afirmação disponível nesta subdimensão.'),
        ),
      );
    }
  }

  Future<void> _tryFinish() async {
    _advanceTimer?.cancel();
    if (_vm.answeredCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Responda a pelo menos algumas afirmações antes de concluir.',
          ),
        ),
      );
      return;
    }

    final int? firstUntouched = _vm.firstUntouchedIndex();
    if (firstUntouched != null) {
      final EspectroPalette p = context.palette;
      final bool? finishAnyway = await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            backgroundColor: p.surface,
            title: const Text('Afirmações pendentes'),
            content: Text(
              'Restam ${_vm.untouchedCount} afirmações sem resposta nem pulo. '
              'Deseja revisar as pendentes ou ver seu resultado preliminar agora '
              'podendo continuar respondendo depois para refinar?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                  _vm.jumpTo(firstUntouched);
                },
                child: const Text('Revisar pendentes'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Ver resultado preliminar'),
              ),
            ],
          );
        },
      );
      if (finishAnyway != true) return;
      await _viewPreliminaryResult();
      return;
    }

    final EvaluationRecord record = _vm.buildCompletedRecord();
    await widget.appViewModel.recordCompletedEvaluation(record);
    if (!mounted) return;
    if (widget.returnCompletedRecord) {
      Navigator.of(context).pop(record);
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EspectroResultScreen(
          appViewModel: widget.appViewModel,
          record: record,
        ),
      ),
    );
  }

  void _showQuestionMap() {
    final EspectroPalette p = context.palette;
    showInfoSheet(
      context,
      title:
          'Mapa da bateria (${_vm.answeredCount}/${_vm.totalCount} respondidas)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: <Widget>[
              _LegendDot(
                color: p.accent,
                label: 'Respondida (${_vm.answeredCount})',
              ),
              _LegendDot(
                color: p.warning,
                label: 'Pulada (${_vm.skippedCount})',
              ),
              _LegendDot(
                color: p.surfaceMuted,
                label: 'Pendente (${_vm.untouchedCount})',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              for (var i = 0; i < _vm.totalCount; i++)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _vm.jumpTo(i);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _vm.answerAt(i) != null
                          ? p.accent
                          : (_vm.isSkippedAt(i)
                                ? p.warning.withValues(alpha: 0.22)
                                : p.surfaceMuted),
                      borderRadius: BorderRadius.circular(10),
                      border: i == _vm.currentIndex
                          ? Border.all(color: p.ink, width: 2)
                          : null,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _vm.answerAt(i) != null
                            ? (p.isDark
                                  ? const Color(0xFF061318)
                                  : Colors.white)
                            : p.ink,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_vm.answeredCount > 0) ...<Widget>[
            const SizedBox(height: 20),
            if (_vm.canPreview) ...<Widget>[
              AppButton(
                label:
                    'Ver resultado preliminar (${_vm.answeredCount}/${_vm.totalCount})',
                kind: AppButtonKind.filled,
                icon: Icons.insights_rounded,
                onPressed: () {
                  Navigator.of(context).pop();
                  _viewPreliminaryResult();
                },
              ),
              const SizedBox(height: 8),
            ],
            AppButton(
              label: 'Concluir bateria e arquivar',
              kind: AppButtonKind.outline,
              icon: Icons.assessment_outlined,
              onPressed: () {
                Navigator.of(context).pop();
                _tryFinish();
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showStatementHelp() {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final UnifiedQuestion q = _vm.currentQuestion;

    if (q.axisQuestion != null && q.sixQuestion != null) {
      final AxisQuestion aq = q.axisQuestion!;
      final SixQuestion sq = q.sixQuestion!;
      final Axis axis = _vm.currentAxis!;
      final SixCategory cat = _vm.currentTriadCategory!;
      final String agreePole = aq.agreeIsLeft ? axis.leftPole : axis.rightPole;
      final String disagreePole = aq.agreeIsLeft
          ? axis.rightPole
          : axis.leftPole;
      final String vertex = cat.subcategories[sq.subcategory];

      showInfoSheet(
        context,
        title: 'Como esta afirmação pontua (Eixo & Tríade)',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(q.text, style: text.bodyLarge),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.accentSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.hub_rounded, size: 18, color: p.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta pergunta afeta simultaneamente o Eixo ${axis.label} '
                      'e a Tríade ${cat.label}.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _HelpSection(
              title: 'No Eixo ${axis.label}: Concordar aproxima de $agreePole',
              color: aq.agreeIsLeft ? axis.leftColor : axis.rightColor,
              description: aq.help.agree,
              example: aq.help.agreeExample,
            ),
            const SizedBox(height: 14),
            _HelpSection(
              title:
                  'No Eixo ${axis.label}: Discordar aproxima de $disagreePole',
              color: aq.agreeIsLeft ? axis.rightColor : axis.leftColor,
              description: aq.help.disagree,
              example: aq.help.disagreeExample,
            ),
            const SizedBox(height: 14),
            SectionCard(
              color: p.surfaceMuted,
              borderColor: p.surfaceMuted,
              child: Text(
                sq.agreeRaisesWeight
                    ? 'Na Tríade ${cat.label}: concordar apoia o vértice "$vertex" '
                          '(peso ${q.weight.toStringAsFixed(2)}).'
                    : 'Na Tríade ${cat.label}: item invertido — concordar reduz o apoio ao vértice "$vertex" '
                          'sem obrigar adesão a um vértice específico.',
                style: text.bodyMedium,
              ),
            ),
            if (aq.help.note != null) ...<Widget>[
              const SizedBox(height: 14),
              SectionCard(
                color: p.surfaceMuted,
                borderColor: p.surfaceMuted,
                padding: const EdgeInsets.all(14),
                child: Text(
                  aq.help.note!,
                  style: text.bodySmall?.copyWith(color: p.inkSoft),
                ),
              ),
            ],
          ],
        ),
      );
    } else if (q.kind == UnifiedQuestionKind.bipolar ||
        q.axisQuestion != null) {
      final AxisQuestion aq = q.axisQuestion!;
      final Axis axis = _vm.currentAxis!;
      final String agreePole = aq.agreeIsLeft ? axis.leftPole : axis.rightPole;
      final String disagreePole = aq.agreeIsLeft
          ? axis.rightPole
          : axis.leftPole;
      showInfoSheet(
        context,
        title: 'Contexto da afirmação',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(aq.text, style: text.bodyLarge),
            const SizedBox(height: 18),
            _HelpSection(
              title: 'Concordar aproxima de $agreePole',
              color: aq.agreeIsLeft ? axis.leftColor : axis.rightColor,
              description: aq.help.agree,
              example: aq.help.agreeExample,
            ),
            const SizedBox(height: 16),
            _HelpSection(
              title: 'Discordar aproxima de $disagreePole',
              color: aq.agreeIsLeft ? axis.rightColor : axis.leftColor,
              description: aq.help.disagree,
              example: aq.help.disagreeExample,
            ),
            if (aq.help.note != null) ...<Widget>[
              const SizedBox(height: 16),
              SectionCard(
                color: p.surfaceMuted,
                borderColor: p.surfaceMuted,
                padding: const EdgeInsets.all(14),
                child: Text(
                  aq.help.note!,
                  style: text.bodySmall?.copyWith(color: p.inkSoft),
                ),
              ),
            ],
          ],
        ),
      );
    } else {
      final SixQuestion sq = q.sixQuestion!;
      final SixCategory cat = _vm.currentTriadCategory!;
      final String vertex = cat.subcategories[sq.subcategory];
      showInfoSheet(
        context,
        title: 'Como este item pontua na tríade',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(sq.text, style: text.bodyLarge),
            const SizedBox(height: 16),
            SectionCard(
              color: p.surfaceMuted,
              borderColor: p.surfaceMuted,
              child: Text(
                sq.agreeRaisesWeight
                    ? 'Concordar aumenta o apoio absoluto ao vértice "$vertex" '
                          'na tríade ${cat.label} (peso ${q.weight.toStringAsFixed(2)}).'
                    : 'Item invertido: concordar reduz o apoio absoluto ao vértice "$vertex" '
                          'na tríade ${cat.label} sem obrigar adesão automática a um único outro vértice.',
                style: text.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }
  }

  Color _likertColor(LikertAnswer option, EspectroPalette p) {
    switch (option) {
      case LikertAnswer.stronglyAgree:
        return p.isDark ? const Color(0xFF10B981) : const Color(0xFF059669);
      case LikertAnswer.agree:
        return p.isDark ? const Color(0xFF14B8A6) : const Color(0xFF0D9488);
      case LikertAnswer.neutral:
        return p.isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
      case LikertAnswer.disagree:
        return p.isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C);
      case LikertAnswer.stronglyDisagree:
        return p.isDark ? const Color(0xFFF43F5E) : const Color(0xFFE11D48);
    }
  }

  IconData _likertIcon(LikertAnswer option) {
    switch (option) {
      case LikertAnswer.stronglyAgree:
        return Icons.check_rounded;
      case LikertAnswer.agree:
        return Icons.check_rounded;
      case LikertAnswer.neutral:
        return Icons.remove_rounded;
      case LikertAnswer.disagree:
        return Icons.close_rounded;
      case LikertAnswer.stronglyDisagree:
        return Icons.close_rounded;
    }
  }

  void _showTerm(String term, String definition) {
    showInfoSheet(
      context,
      title: term,
      child: Text(definition, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitSavingDraft();
      },
      child: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          final q = _vm.currentQuestion;
          final selected = _vm.currentAnswer;
          final terms = q.axisQuestion != null
              ? [
                  for (final t in q.axisQuestion!.terms)
                    (
                      start: t.start,
                      end: t.end,
                      term: t.term,
                      definition: t.definition,
                    ),
                ]
              : <({int start, int end, String term, String definition})>[];

          String? targetPoleLabel;
          Color? targetPoleColor;
          String? secondaryPoleLabel;
          Color? secondaryPoleColor;

          if (q.axisQuestion != null && _vm.currentAxis != null) {
            final Axis axis = _vm.currentAxis!;
            final bool agreeLeft = q.axisQuestion!.agreeIsLeft;
            final String pole = agreeLeft ? axis.leftPole : axis.rightPole;
            targetPoleLabel = pole.toUpperCase();
            targetPoleColor = _readablePoleColor(
              agreeLeft ? axis.leftColor : axis.rightColor,
              p.isDark,
            );
          }

          if (q.sixQuestion != null && _vm.currentTriadCategory != null) {
            final SixCategory cat = _vm.currentTriadCategory!;
            final String vertex = cat.subcategories[q.sixQuestion!.subcategory];
            if (targetPoleLabel == null) {
              targetPoleLabel = vertex.toUpperCase();
              targetPoleColor = _readablePoleColor(cat.color, p.isDark);
            } else {
              secondaryPoleLabel = vertex.toUpperCase();
              secondaryPoleColor = _readablePoleColor(cat.color, p.isDark);
            }
          }

          final String itemNumber = (_vm.currentIndex + 1).toString().padLeft(
            2,
            '0',
          );

          return CallbackShortcuts(
            bindings: <ShortcutActivator, VoidCallback>{
              const SingleActivator(LogicalKeyboardKey.digit1): () =>
                  _onSelectAnswer(LikertAnswer.values[0]),
              const SingleActivator(LogicalKeyboardKey.numpad1): () =>
                  _onSelectAnswer(LikertAnswer.values[0]),
              const SingleActivator(LogicalKeyboardKey.digit2): () =>
                  _onSelectAnswer(LikertAnswer.values[1]),
              const SingleActivator(LogicalKeyboardKey.numpad2): () =>
                  _onSelectAnswer(LikertAnswer.values[1]),
              const SingleActivator(LogicalKeyboardKey.digit3): () =>
                  _onSelectAnswer(LikertAnswer.values[2]),
              const SingleActivator(LogicalKeyboardKey.numpad3): () =>
                  _onSelectAnswer(LikertAnswer.values[2]),
              const SingleActivator(LogicalKeyboardKey.digit4): () =>
                  _onSelectAnswer(LikertAnswer.values[3]),
              const SingleActivator(LogicalKeyboardKey.numpad4): () =>
                  _onSelectAnswer(LikertAnswer.values[3]),
              const SingleActivator(LogicalKeyboardKey.digit5): () =>
                  _onSelectAnswer(LikertAnswer.values[4]),
              const SingleActivator(LogicalKeyboardKey.numpad5): () =>
                  _onSelectAnswer(LikertAnswer.values[4]),
              const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
                if (!_vm.isFirst) _vm.previous();
              },
              const SingleActivator(LogicalKeyboardKey.arrowRight): () {
                if (_vm.isLast) {
                  _tryFinish();
                } else if (selected != null || _vm.isCurrentSkipped) {
                  _vm.next();
                }
              },
              const SingleActivator(LogicalKeyboardKey.escape):
                  _exitSavingDraft,
            },
            child: Focus(
              autofocus: true,
              child: Scaffold(
                backgroundColor: p.canvas,
            body: Container(
              decoration: BoxDecoration(
                color: p.canvas,
                gradient: RadialGradient(
                  center: const Alignment(0.85, -0.9),
                  radius: 1.35,
                  colors: [
                    p.accent.withValues(alpha: p.isDark ? 0.08 : 0.025),
                    p.canvas.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: SafeArea(
                child: ResponsiveContentFrame(
                  maxWidth: 720,
                  child: Column(
                    children: [
                      // Top App Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final bool showBadge = constraints.maxWidth > 580;
                            final bool isCompact = constraints.maxWidth < 420;
                            return Row(
                              children: [
                                IconButton(
                                  tooltip: 'Pausar e salvar',
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 20,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: _exitSavingDraft,
                                ),
                                const SizedBox(width: 4),
                                const EspectroBrandMark(size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Espectro',
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: p.ink,
                                  ),
                                ),
                                if (showBadge) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: p.accentSoft,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: p.accent.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    child: Text(
                                      widget.quizViewModel.suite ==
                                              TestSuite.espectroIntegrated
                                          ? 'AVALIAÇÃO INTEGRADA'
                                          : (q.kind ==
                                                    UnifiedQuestionKind.bipolar
                                                ? '12 EIXOS'
                                                : '6 TRÍADES'),
                                      style: TextStyle(
                                        fontFamily: 'IBMPlexMono',
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        color: p.accent,
                                      ),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                IconButton(
                                  tooltip: 'Alternar tema (claro/escuro)',
                                  icon: Icon(
                                    p.isDark
                                        ? Icons.light_mode_rounded
                                        : Icons.dark_mode_outlined,
                                    size: 19,
                                    color: p.ink,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    final isDark =
                                        Theme.of(context).brightness ==
                                        Brightness.dark;
                                    widget.appViewModel.setThemeMode(
                                      isDark ? ThemeMode.light : ThemeMode.dark,
                                    );
                                  },
                                ),
                                if (_vm.canPreview) ...[
                                  const SizedBox(width: 2),
                                  Tooltip(
                                    message: 'Ver coordenadas e tendências parciais com as afirmações respondidas',
                                    child: InkWell(
                                      onTap: _viewPreliminaryResult,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: p.accentSoft,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: p.accent.withValues(
                                              alpha: 0.40,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.auto_graph_rounded,
                                              size: 12,
                                              color: p.accent,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isCompact
                                                  ? '${_vm.answeredCount}/${_vm.totalCount}'
                                                  : 'Prévia (${_vm.answeredCount}/${_vm.totalCount})',
                                              style: TextStyle(
                                                fontFamily: 'IBMPlexMono',
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: p.accent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 2),
                                PopupMenuButton<String>(
                                  tooltip: 'Opções da avaliação',
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    size: 20,
                                  ),
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'preview':
                                        _viewPreliminaryResult();
                                      case 'pause':
                                        _exitSavingDraft();
                                      case 'map':
                                        _showQuestionMap();
                                      case 'swap':
                                        _onSwap();
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    if (_vm.canPreview)
                                      PopupMenuItem(
                                        value: 'preview',
                                        child: Text(
                                          'Ver resultado preliminar (${_vm.answeredCount}/${_vm.totalCount})',
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: 'pause',
                                      child: Text('Pausar e salvar progresso'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'map',
                                      child: Text('Mapa de perguntas'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'swap',
                                      child: Text('Trocar afirmação'),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Progress & Milestone Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'ITEM ${_vm.currentIndex + 1} DE ${_vm.totalCount}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'IBMPlexMono',
                                        letterSpacing: 0.4,
                                        color: p.ink,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '· ${_vm.currentStageTitle}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: p.inkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${(_vm.progress * 100).round()}%',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'IBMPlexMono',
                                    color: p.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              height: 6,
                              decoration: BoxDecoration(
                                color: p.line.withValues(
                                  alpha: p.isDark ? 0.55 : 0.7,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _vm.progress <= 0
                                  ? const SizedBox.shrink()
                                  : FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _vm.progress.clamp(
                                        0.015,
                                        1.0,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              p.accent,
                                              p.poleRight,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            if (_vm.milestoneSteps.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (
                                    var i = 0;
                                    i < _vm.milestoneSteps.length;
                                    i++
                                  ) ...[
                                    () {
                                      final int target = _vm.milestoneSteps[i];
                                      final bool isCompleted =
                                          _vm.answeredCount >= target;
                                      final bool isCurrent =
                                          i == _vm.currentMilestoneStepIndex;
                                      final String name = switch (i) {
                                        0 => 'Base',
                                        1 => 'Fina',
                                        2 => 'Alta',
                                        _ => 'Total',
                                      };

                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? const Color(0xFF10B981)
                                                    .withValues(alpha: 0.12)
                                              : (isCurrent
                                                    ? p.accentSoft
                                                    : p.surfaceMuted.withValues(
                                                        alpha: 0.4,
                                                      )),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: isCompleted
                                                ? const Color(0xFF10B981)
                                                      .withValues(alpha: 0.4)
                                                : (isCurrent
                                                      ? p.accent.withValues(
                                                          alpha: 0.4,
                                                        )
                                                      : p.line.withValues(
                                                          alpha: 0.4,
                                                        )),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isCompleted) ...[
                                              const Icon(
                                                Icons.check_rounded,
                                                size: 11,
                                                color: Color(0xFF10B981),
                                              ),
                                              const SizedBox(width: 3),
                                            ] else if (isCurrent) ...[
                                              Container(
                                                width: 5,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  color: p.accent,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                            ],
                                            Text(
                                              '$target $name',
                                              style: TextStyle(
                                                fontFamily: 'IBMPlexMono',
                                                fontSize: 10,
                                                fontWeight:
                                                    (isCompleted || isCurrent)
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isCompleted
                                                    ? const Color(0xFF10B981)
                                                    : (isCurrent
                                                          ? p.accent
                                                          : p.inkSoft),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }(),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Scrollable Area: Central Espectro Card + Controls
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: EspectroMotion.medium,
                          transitionBuilder: (child, animation) {
                            final inAnimation =
                                Tween<Offset>(
                                  begin: const Offset(0.035, 0.0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: EspectroMotion.easeOut,
                                  ),
                                );
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: inAnimation,
                                child: child,
                              ),
                            );
                          },
                          child: SingleChildScrollView(
                            key: ValueKey(q.uid),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // The Single Unified Espectro Card
                                Container(
                                  decoration: EspectroElevation.cardDecoration(
                                    p,
                                    radius: 17,
                                    borderWidth: 1.1,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        height: 3.5,
                                        color: targetPoleColor ?? p.accent,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          18,
                                          16,
                                          18,
                                          18,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                        // Top row inside card: Badges on left, Technical Index on right
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Wrap(
                                                spacing: 8,
                                                runSpacing: 6,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  if (targetPoleLabel != null)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 9,
                                                            vertical: 4.5,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            (targetPoleColor ??
                                                                    p.accent)
                                                                .withValues(
                                                                  alpha:
                                                                      p.isDark
                                                                      ? 0.22
                                                                      : 0.12,
                                                                ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              (targetPoleColor ??
                                                                      p.accent)
                                                                  .withValues(
                                                                    alpha: 0.35,
                                                                  ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 8,
                                                            height: 8,
                                                            decoration:
                                                                BoxDecoration(
                                                                  color:
                                                                      targetPoleColor ??
                                                                      p.accent,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              targetPoleLabel,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontFamily: 'IBMPlexMono',
                                                                fontSize: 10.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    targetPoleColor ??
                                                                    p.accent,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  if (secondaryPoleLabel !=
                                                      null)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 9,
                                                            vertical: 4.5,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            (secondaryPoleColor ??
                                                                    p.accent)
                                                                .withValues(
                                                                  alpha:
                                                                      p.isDark
                                                                      ? 0.22
                                                                      : 0.12,
                                                                ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              (secondaryPoleColor ??
                                                                      p.accent)
                                                                  .withValues(
                                                                    alpha: 0.35,
                                                                  ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .change_history_rounded,
                                                            size: 11,
                                                            color:
                                                                secondaryPoleColor ??
                                                                p.accent,
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              secondaryPoleLabel,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontFamily: 'IBMPlexMono',
                                                                fontSize: 10.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    secondaryPoleColor ??
                                                                    p.accent,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: p.surfaceMuted,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: p.line.withValues(
                                                    alpha: 0.6,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                '#$itemNumber // ${_vm.totalCount}',
                                                style: TextStyle(
                                                  fontFamily: 'IBMPlexMono',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: p.inkSoft,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        // Statement text
                                        TermText(
                                          text: q.text,
                                          terms: terms,
                                          onTermTap: _showTerm,
                                          style: text.headlineSmall?.copyWith(
                                            fontFamily: 'IBMPlexSans',
                                            fontSize: 20,
                                            height: 1.35,
                                            fontWeight: FontWeight.w700,
                                            color: p.ink,
                                            letterSpacing: -0.25,
                                          ),
                                        ),
                                        if (_vm.isCurrentSkipped) ...[
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: p.warning.withValues(
                                                alpha: 0.12,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Esta afirmação foi pulada e não pontuará a avaliação.',
                                              style: text.bodySmall?.copyWith(
                                                color: p.warning,
                                              ),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 14),
                                        // 5 Likert options inside the card (sem pontuação numérica visual)
                                        for (final option
                                            in LikertAnswer.values) ...[
                                          AnswerTile(
                                            label: switch (option) {
                                              LikertAnswer.stronglyAgree =>
                                                'Concordo totalmente',
                                              LikertAnswer.agree => 'Concordo',
                                              LikertAnswer.neutral =>
                                                'Neutro ou Depende',
                                              LikertAnswer.disagree =>
                                                'Discordo',
                                              LikertAnswer.stronglyDisagree =>
                                                'Discordo totalmente',
                                            },
                                            icon: _likertIcon(option),
                                            accent: _likertColor(option, p),
                                            showRadio: true,
                                            selected: selected == option,
                                            onTap: () =>
                                                _onSelectAnswer(option),
                                          ),
                                          const SizedBox(height: 6),
                                        ],

                                        // Rodapé do card: Ações contextuais da afirmação (Entender / Trocar / Pular)
                                        const SizedBox(height: 6),
                                        Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: p.line.withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          alignment: WrapAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          runSpacing: 4,
                                          children: [
                                            TextButton.icon(
                                              onPressed: _showStatementHelp,
                                              icon: Icon(
                                                Icons.help_outline_rounded,
                                                size: 15,
                                                color: p.accent,
                                              ),
                                              label: Text(
                                                'Entender afirmação',
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: p.accent,
                                                ),
                                              ),
                                              style: TextButton.styleFrom(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 4,
                                                    ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: _onSwap,
                                                  icon: Icon(
                                                    Icons.swap_horiz_rounded,
                                                    size: 15,
                                                    color: p.inkSoft,
                                                  ),
                                                  label: Text(
                                                    'Trocar',
                                                    style: TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: p.inkSoft,
                                                    ),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 4,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                TextButton(
                                                  onPressed: _onSkip,
                                                  style: TextButton.styleFrom(
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'Pular',
                                                    style: TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: p.inkSoft,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                                const SizedBox(height: 16),

                                // Navegação primária com AppButton oficial do Espectro
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: AppButton(
                                        label: 'Anterior',
                                        icon: Icons.arrow_back_rounded,
                                        kind: AppButtonKind.outline,
                                        onPressed: _vm.isFirst
                                            ? null
                                            : _vm.previous,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 3,
                                      child: AppButton(
                                        label: _vm.isLast
                                            ? 'Concluir'
                                            : 'Próxima',
                                        icon: _vm.isLast
                                            ? Icons.check_circle_rounded
                                            : Icons.arrow_forward_rounded,
                                        kind: AppButtonKind.filled,
                                        onPressed: _vm.isLast
                                            ? _tryFinish
                                            : ((selected != null ||
                                                      _vm.isCurrentSkipped)
                                                  ? _vm.next
                                                  : null),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Controle sutil de auto-avanço centralizado
                                Center(
                                  child: InkWell(
                                    onTap: () {
                                      widget.appViewModel.setAutoAdvance(
                                        !widget.appViewModel.autoAdvance,
                                      );
                                      setState(() {});
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 24,
                                            child: Switch.adaptive(
                                              value: widget
                                                  .appViewModel
                                                  .autoAdvance,
                                              onChanged: (val) {
                                                widget.appViewModel
                                                    .setAutoAdvance(val);
                                                setState(() {});
                                              },
                                              activeThumbColor: p.accent,
                                              activeTrackColor: p.accent
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              'Avançar ao responder',
                                              style: TextStyle(
                                                fontFamily: 'IBMPlexSans',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: p.inkSoft,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (MediaQuery.sizeOf(context).width >= 820) ...[
                                  const SizedBox(height: 8),
                                  Center(
                                    child: Text(
                                      'Atalhos: teclas 1–5 respondem · ←/→ navegam · Esc pausa',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'IBMPlexMono',
                                        fontSize: 10.5,
                                        color: p.muted,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const EspectroFloatingAdBar(),
                    ],
                  ),
                ),
              ),
            ),
          ),
            ),
          );
        },
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({
    required this.title,
    required this.color,
    required this.description,
    required this.example,
  });

  final String title;
  final Color color;
  final String description;
  final String example;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final p = context.palette;
    return SectionCard(
      color: Color.alphaBlend(
        color.withValues(alpha: p.isDark ? .14 : .08),
        p.surface,
      ),
      borderColor: Colors.transparent,
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: text.titleMedium)),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: text.bodyMedium),
          if (example.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Ex.: $example',
              style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
