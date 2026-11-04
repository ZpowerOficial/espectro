import 'dart:async';

import 'package:flutter/material.dart' hide Axis;

import '../../data/app_data.dart';
import '../../data/models.dart';
import '../../engine/twelve_axes_engine.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/quiz_chrome.dart';
import 'twelve_archetype_screen.dart';

class TwelveQuizScreen extends StatefulWidget {
  const TwelveQuizScreen({
    required this.data,
    required this.variant,
    super.key,
  });

  final AppData data;
  final TwelveVariant variant;

  @override
  State<TwelveQuizScreen> createState() => _TwelveQuizScreenState();
}

class _TwelveQuizScreenState extends State<TwelveQuizScreen> {
  late final TwelveAxesSession _session;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _session = TwelveAxesSession(
      data: widget.data.twelveAxes,
      variant: widget.variant,
    );
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _selectAnswer(int optionIndex) {
    _advanceTimer?.cancel();
    setState(() => _session.select(optionIndex));
    if (_session.isLast) return;
    _advanceTimer = Timer(const Duration(milliseconds: 230), () {
      if (!mounted) return;
      setState(_session.next);
    });
  }

  void _goNext() {
    _advanceTimer?.cancel();
    if (_session.currentAnswer == null) {
      _snack('Escolha uma resposta para continuar.');
      return;
    }
    if (_session.isLast) {
      _openArchetype();
      return;
    }
    setState(_session.next);
  }

  void _goBack() {
    _advanceTimer?.cancel();
    if (_session.isFirst) {
      Navigator.of(context).pop();
      return;
    }
    setState(_session.previous);
  }

  void _swapQuestion() {
    _advanceTimer?.cancel();
    final bool swapped = _session.swapCurrent();
    setState(() {});
    if (!swapped) {
      _snack('Não há outra pergunta deste eixo disponível.');
    }
  }

  void _openArchetype() {
    if (!_session.isComplete) {
      _snack('Ainda faltam respostas.');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            TwelveArchetypeScreen(session: _session),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showHelp() {
    final AxisQuestion question = _session.current;
    final Axis axis = _session.currentAxis;
    final String agreePole = question.agreeIsLeft
        ? axis.leftPole
        : axis.rightPole;
    final String disagreePole = question.agreeIsLeft
        ? axis.rightPole
        : axis.leftPole;
    showInfoSheet(
      context,
      title: 'Entenda a afirmação',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(question.text, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          _HelpBlock(
            title: 'Se você concorda',
            subtitle: 'Aproxima você de $agreePole',
            color: question.agreeIsLeft ? axis.leftColor : axis.rightColor,
            text: question.help.agree,
            example: question.help.agreeExample,
          ),
          const SizedBox(height: 18),
          _HelpBlock(
            title: 'Se você discorda',
            subtitle: 'Aproxima você de $disagreePole',
            color: question.agreeIsLeft ? axis.rightColor : axis.leftColor,
            text: question.help.disagree,
            example: question.help.disagreeExample,
          ),
          if (question.help.note != null) ...<Widget>[
            const SizedBox(height: 20),
            SectionCard(
              color: AppColors.surfaceAlt,
              borderColor: AppColors.surfaceAlt,
              padding: const EdgeInsets.all(16),
              child: Text(
                question.help.note!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ],
      ),
    );
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
    final TextTheme text = Theme.of(context).textTheme;
    final AxisQuestion question = _session.current;
    final Axis axis = _session.currentAxis;
    final List<({int start, int end, String term, String definition})> terms =
        <({int start, int end, String term, String definition})>[
          for (final QuestionTerm term in question.terms)
            (
              start: term.start,
              end: term.end,
              term: term.term,
              definition: term.definition,
            ),
        ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: QuizTopBar(
                onBack: _goBack,
                progress: _session.progress,
                counter:
                    'Pergunta ${_session.index + 1} de ${_session.questions.length}',
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 170),
                child: ListView(
                  key: ValueKey<String>(question.id),
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  children: <Widget>[
                    AxisChip(axis: axis),
                    const SizedBox(height: 14),
                    SectionCard(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Eyebrow('Afirmação'),
                          const SizedBox(height: 12),
                          TermText(
                            text: question.text,
                            terms: terms,
                            onTermTap: _showTerm,
                          ),
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: _showHelp,
                            icon: const Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                            ),
                            label: const Text('Entenda esta afirmação'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.inkSoft,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              textStyle: text.labelLarge?.copyWith(
                                fontSize: 12.5,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: <Widget>[
                        Text('Sua resposta', style: text.titleMedium),
                        const Spacer(),
                        Text(
                          _session.currentAnswer == null
                              ? 'toque para escolher'
                              : 'respondida',
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (
                      var i = 0;
                      i < widget.data.twelveAxes.answerOptions.length;
                      i++
                    ) ...<Widget>[
                      AnswerTile(
                        label: widget.data.twelveAxes.answerOptions[i].label,
                        icon: _answerIcon(i),
                        selected: _session.currentAnswer == i,
                        accent: AppColors.ink,
                        onTap: () => _selectAnswer(i),
                      ),
                      if (i != widget.data.twelveAxes.answerOptions.length - 1)
                        const SizedBox(height: 9),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      'Os termos sublinhados abrem a definição. Trocar sorteia outra '
                      'pergunta do mesmo eixo.',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 20, 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: <Widget>[
                  TextButton.icon(
                    onPressed: _swapQuestion,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: const Text('Trocar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.inkSoft,
                    ),
                  ),
                  const Spacer(),
                  Opacity(
                    opacity: _session.isFirst ? 0.35 : 1,
                    child: CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: _session.isFirst ? null : _goBack,
                      tooltip: 'Pergunta anterior',
                    ),
                  ),
                  const SizedBox(width: 9),
                  AppButton(
                    label: _session.isLast ? 'Continuar' : 'Avançar',
                    icon: _session.isLast
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    expand: false,
                    onPressed: _session.currentAnswer == null ? null : _goNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _answerIcon(int index) {
    return switch (index) {
      0 => Icons.keyboard_double_arrow_up_rounded,
      1 => Icons.keyboard_arrow_up_rounded,
      2 => Icons.remove_rounded,
      3 => Icons.keyboard_arrow_down_rounded,
      _ => Icons.keyboard_double_arrow_down_rounded,
    };
  }
}

class _HelpBlock extends StatelessWidget {
  const _HelpBlock({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.text,
    required this.example,
  });

  final String title;
  final String subtitle;
  final Color color;
  final String text;
  final String example;

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    return Column(
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
            Text(title, style: theme.titleMedium),
            const SizedBox(width: 8),
            Flexible(child: Text(subtitle, style: theme.bodySmall)),
          ],
        ),
        const SizedBox(height: 6),
        Text(text, style: theme.bodyMedium),
        const SizedBox(height: 6),
        Text(
          'Ex.: $example',
          style: theme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
