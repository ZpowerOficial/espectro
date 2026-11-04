import 'dart:async';

import 'package:flutter/material.dart' hide Axis;
import 'package:flutter/services.dart';

import '../../../data/models.dart';
import '../../../domain/models/political_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../view_models/app_view_model.dart';
import '../../view_models/quiz_view_model.dart';
import '../results/espectro_result_screen.dart';

/// Tela unificada de aplicação do questionário Espectro (Eixos + Tríades).
class EspectroQuizScreen extends StatefulWidget {
  const EspectroQuizScreen({
    required this.appViewModel,
    required this.quizViewModel,
    super.key,
  });

  final AppViewModel appViewModel;
  final QuizViewModel quizViewModel;

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
    await widget.appViewModel.refreshDraft();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _onSelectAnswer(LikertAnswer option) {
    _advanceTimer?.cancel();
    HapticFeedback.selectionClick();
    _vm.selectAnswer(option);
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
            title: const Text('Afirmações não visitadas'),
            content: Text(
              'Restam ${_vm.untouchedCount} afirmações sem resposta nem pulo. '
              'Deseja ir para a primeira pendente ou calcular o resultado agora '
              '(tratando as restantes como puladas)?',
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
                child: const Text('Calcular resultado'),
              ),
            ],
          );
        },
      );
      if (finishAnyway != true) return;
    }

    final EvaluationRecord record = _vm.buildCompletedRecord();
    await widget.appViewModel.recordCompletedEvaluation(record);
    if (!mounted) return;
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
            AppButton(
              label: 'Concluir avaliação agora',
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

    if (q.kind == UnifiedQuestionKind.bipolar) {
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
          final terms = q.kind == UnifiedQuestionKind.bipolar
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
          return Scaffold(
            body: SafeArea(
              child: ResponsiveContentFrame(
                maxWidth: 760,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(23, 14, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Eyebrow(
                              'ESPECTRO / ${widget.quizViewModel.suite == TestSuite.espectroIntegrated ? 'INTEGRADO' : (q.kind == UnifiedQuestionKind.bipolar ? '12 EIXOS' : '6 TRÍADES')}',
                              color: p.accent,
                            ),
                          ),
                          Text(
                            '${_vm.currentIndex + 1} / ${_vm.totalCount}',
                            style: text.labelLarge?.copyWith(
                              fontFamily: 'IBMPlexMono',
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Opções da avaliação',
                            onSelected: (value) {
                              switch (value) {
                                case 'pause':
                                  _exitSavingDraft();
                                case 'map':
                                  _showQuestionMap();
                                case 'swap':
                                  _onSwap();
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'pause',
                                child: Text('Pausar e salvar progresso'),
                              ),
                              PopupMenuItem(
                                value: 'map',
                                child: Text('Mapa de perguntas'),
                              ),
                              PopupMenuItem(
                                value: 'swap',
                                child: Text('Trocar afirmação'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(23, 8, 23, 0),
                      child: ProgressRail(value: _vm.progress),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        child: ListView(
                          key: ValueKey(q.uid),
                          padding: const EdgeInsets.fromLTRB(23, 28, 23, 20),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: p.accentSoft,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Eyebrow(
                                  _vm.currentAxis?.label ??
                                      _vm.currentTriadCategory!.label,
                                  color:
                                      _vm.currentAxis?.leftColor ??
                                      _vm.currentTriadCategory!.color,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TermText(
                              text: q.text,
                              terms: terms,
                              onTermTap: _showTerm,
                              style: text.headlineLarge?.copyWith(
                                fontSize: 27,
                                height: 1.22,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Qual é seu grau de concordância?',
                              style: text.bodySmall?.copyWith(color: p.inkSoft),
                            ),
                            const SizedBox(height: 18),
                            for (final option in LikertAnswer.values) ...[
                              AnswerTile(
                                label: option.label,
                                icon: Icons.circle,
                                selected: selected == option,
                                onTap: () => _onSelectAnswer(option),
                              ),
                              const SizedBox(height: 10),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: _showStatementHelp,
                                      icon: const Icon(
                                        Icons.help_outline_rounded,
                                        size: 16,
                                      ),
                                      label: const Text('Entender a pergunta'),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _onSkip,
                                  child: Text(
                                    'Pular',
                                    style: TextStyle(color: p.inkSoft),
                                  ),
                                ),
                              ],
                            ),
                            if (_vm.isCurrentSkipped)
                              Text(
                                'Pergunta pulada',
                                style: text.bodySmall?.copyWith(
                                  color: p.warning,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: DecoratedBox(
              decoration: BoxDecoration(color: p.surface),
              child: SafeArea(
                top: false,
                child: ResponsiveContentFrame(
                  maxWidth: 760,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 22, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            heightFactor: 1,
                            child: TextButton.icon(
                              onPressed: _vm.isFirst ? null : _vm.previous,
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                              ),
                              label: const Text('Anterior'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 159,
                          child: AppButton(
                            label: _vm.isLast ? 'Concluir' : 'Próxima',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _vm.isLast
                                ? _tryFinish
                                : ((selected != null || _vm.isCurrentSkipped)
                                      ? _vm.next
                                      : null),
                          ),
                        ),
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
          const SizedBox(height: 4),
          Text(
            'Ex.: $example',
            style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
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
