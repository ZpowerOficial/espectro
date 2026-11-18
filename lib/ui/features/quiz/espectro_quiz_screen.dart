import 'dart:async';

import 'package:flutter/material.dart' hide Axis;
import 'package:flutter/services.dart';

import '../../../data/models.dart';
import '../../../domain/models/political_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../ads/espectro_banner_ad.dart';
import '../../view_models/app_view_model.dart';
import '../../view_models/quiz_view_model.dart';
import '../results/espectro_result_screen.dart';

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
          if (_vm.milestoneSteps.length > 1) ...<Widget>[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                for (var i = 0; i < _vm.milestoneSteps.length; i++)
                  () {
                    final int target = _vm.milestoneSteps[i];
                    final bool isCompleted = _vm.answeredCount >= target;
                    final bool isCurrent = i == _vm.currentMilestoneStepIndex;
                    final String name = switch (i) {
                      0 => 'Base',
                      1 => 'Fina',
                      2 => 'Alta',
                      _ => 'Total',
                    };
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? p.success.withValues(alpha: 0.12)
                            : (isCurrent ? p.accentSoft : p.surfaceMuted),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$target $name',
                        style: TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 10.5,
                          fontWeight: (isCompleted || isCurrent)
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isCompleted
                              ? p.success
                              : (isCurrent ? p.accent : p.inkSoft),
                        ),
                      ),
                    );
                  }(),
              ],
            ),
            const SizedBox(height: 14),
          ],
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
      case LikertAnswer.agree:
        return p.isDark ? const Color(0xFF34D399) : const Color(0xFF0E7C58);
      case LikertAnswer.neutral:
        return p.accent;
      case LikertAnswer.disagree:
      case LikertAnswer.stronglyDisagree:
        return p.isDark ? const Color(0xFFF58D62) : const Color(0xFFC94B14);
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

          final String dimensionContext = _vm.currentAxis != null
              ? '12 Eixos'
              : '6 Tríades';
          final String categoryOverline = () {
            if (_vm.currentAxis != null && _vm.currentTriadCategory != null) {
              return '${_vm.currentAxis!.label} · ${_vm.currentTriadCategory!.label}';
            }
            if (_vm.currentAxis != null) {
              return _vm.currentAxis!.label;
            }
            if (_vm.currentTriadCategory != null) {
              return _vm.currentTriadCategory!.label;
            }
            return dimensionContext;
          }();

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
                body: SafeArea(
                  child: ResponsiveContentFrame(
                    maxWidth: 680,
                    child: Column(
                      children: [
                        // Header minimalista (Zen)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: 'Pausar',
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 20,
                                  color: p.inkSoft,
                                ),
                                visualDensity: VisualDensity.compact,
                                onPressed: _exitSavingDraft,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Espectro',
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexSans',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                          color: p.ink,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '  ·  $dimensionContext · Item $itemNumber/${_vm.totalCount}',
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexSans',
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                          color: p.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Alternar tema (claro/escuro)',
                                icon: Icon(
                                  p.isDark
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_outlined,
                                  size: 19,
                                  color: p.inkSoft,
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
                              PopupMenuButton<String>(
                                tooltip: 'Opções da avaliação',
                                icon: Icon(
                                  Icons.more_horiz_rounded,
                                  size: 21,
                                  color: p.inkSoft,
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
                                    case 'help':
                                      _showStatementHelp();
                                    case 'auto':
                                      widget.appViewModel.setAutoAdvance(
                                        !widget.appViewModel.autoAdvance,
                                      );
                                      setState(() {});
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'map',
                                    child: Text('Mapa de perguntas'),
                                  ),
                                  if (_vm.canPreview)
                                    PopupMenuItem(
                                      value: 'preview',
                                      child: Text(
                                        'Ver prévia (${_vm.answeredCount}/${_vm.totalCount})',
                                      ),
                                    ),
                                  const PopupMenuItem(
                                    value: 'help',
                                    child: Text('Como pontua esta afirmação?'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'swap',
                                    child: Text('Trocar afirmação'),
                                  ),
                                  PopupMenuItem(
                                    value: 'auto',
                                    child: Text(
                                      widget.appViewModel.autoAdvance
                                          ? 'Desativar avanço automático'
                                          : 'Ativar avanço automático',
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'pause',
                                    child: Text('Pausar e salvar progresso'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Barra de progresso discreta e contínua (sem chips de telemetria)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                          child: Container(
                            width: double.infinity,
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: p.line.withValues(
                                alpha: p.isDark ? 0.45 : 0.60,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _vm.progress <= 0
                                ? const SizedBox.shrink()
                                : FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _vm.progress.clamp(0.02, 1.0),
                                    child: ColoredBox(color: p.accent),
                                  ),
                          ),
                        ),

                        // Card Central Zen + Rodapé Simplificado
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: EspectroMotion.medium,
                            transitionBuilder: (child, animation) {
                              final inAnimation =
                                  Tween<Offset>(
                                    begin: const Offset(0.03, 0.0),
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
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    decoration:
                                        EspectroElevation.cardDecoration(
                                          p,
                                          radius: 16,
                                        ),
                                    padding: const EdgeInsets.fromLTRB(
                                      22,
                                      20,
                                      22,
                                      22,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                categoryOverline.toUpperCase(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'IBMPlexSans',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 1.1,
                                                  color: p.accent,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'Como pontua?',
                                              onPressed: _showStatementHelp,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              constraints: const BoxConstraints(
                                                minWidth: 32,
                                                minHeight: 32,
                                              ),
                                              padding: EdgeInsets.zero,
                                              icon: Icon(
                                                Icons.help_outline_rounded,
                                                size: 17,
                                                color: p.muted,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        TermText(
                                          text: q.text,
                                          terms: terms,
                                          onTermTap: _showTerm,
                                          style: text.headlineSmall?.copyWith(
                                            fontFamily: 'IBMPlexSans',
                                            fontSize: 21,
                                            height: 1.42,
                                            fontWeight: FontWeight.w600,
                                            color: p.ink,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        if (_vm.isCurrentSkipped) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: p.warning.withValues(
                                                alpha: 0.10,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Esta afirmação foi pulada e não pontuará a avaliação.',
                                              style: text.bodySmall?.copyWith(
                                                color: p.warning,
                                              ),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 22),
                                        for (var idx = 0;
                                            idx < LikertAnswer.values.length;
                                            idx++) ...[
                                          () {
                                            final option =
                                                LikertAnswer.values[idx];
                                            return AnswerTile(
                                              label: switch (option) {
                                                LikertAnswer.stronglyAgree =>
                                                  'Concordo totalmente',
                                                LikertAnswer.agree =>
                                                  'Concordo',
                                                LikertAnswer.neutral =>
                                                  'Neutro ou Depende',
                                                LikertAnswer.disagree =>
                                                  'Discordo',
                                                LikertAnswer.stronglyDisagree =>
                                                  'Discordo totalmente',
                                              },
                                              icon: _likertIcon(option),
                                              accent: _likertColor(option, p),
                                              tintedUnselected: false,
                                              showRadio: true,
                                              selected: selected == option,
                                              onTap: () =>
                                                  _onSelectAnswer(option),
                                            );
                                          }(),
                                          if (idx <
                                              LikertAnswer.values.length - 1)
                                            const SizedBox(height: 8),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Rodapé Simplificado
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 12,
                                    runSpacing: 10,
                                    children: [
                                      TextButton.icon(
                                        onPressed: _onSkip,
                                        icon: Icon(
                                          Icons.skip_next_rounded,
                                          size: 17,
                                          color: p.muted,
                                        ),
                                        label: Text(
                                          'Pular afirmação',
                                          style: TextStyle(
                                            fontFamily: 'IBMPlexSans',
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: p.inkSoft,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          OutlinedButton(
                                            onPressed: _vm.isFirst
                                                ? null
                                                : _vm.previous,
                                            style: OutlinedButton.styleFrom(
                                              minimumSize: const Size(0, 44),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              side: BorderSide(
                                                color: _vm.isFirst
                                                    ? p.line.withValues(
                                                        alpha: 0.5,
                                                      )
                                                    : p.line,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text('Anterior'),
                                          ),
                                          const SizedBox(width: 10),
                                          FilledButton.icon(
                                            onPressed: _vm.isLast
                                                ? _tryFinish
                                                : ((selected != null ||
                                                          _vm.isCurrentSkipped)
                                                      ? _vm.next
                                                      : null),
                                            style: FilledButton.styleFrom(
                                              minimumSize: const Size(0, 44),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 18,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            icon: Icon(
                                              _vm.isLast
                                                  ? Icons.check_rounded
                                                  : Icons.arrow_forward_rounded,
                                              size: 17,
                                            ),
                                            label: Text(
                                              _vm.isLast
                                                  ? 'Concluir'
                                                  : 'Próxima',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (MediaQuery.sizeOf(context).width >=
                                      820) ...[
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Text(
                                        'Atalhos: teclas 1–5 respondem · ←/→ navegam · Esc pausa',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexSans',
                                          fontSize: 11.5,
                                          color: p.muted,
                                        ),
                                      ),
                                    ),
                                  ],
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
