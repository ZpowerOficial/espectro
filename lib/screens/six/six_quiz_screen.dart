import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/app_data.dart';
import '../../data/models.dart';
import '../../engine/six_triangles_engine.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/quiz_chrome.dart';
import 'six_result_screen.dart';

class SixQuizScreen extends StatefulWidget {
  const SixQuizScreen({required this.data, required this.variant, super.key});

  final AppData data;
  final SixVariant variant;

  @override
  State<SixQuizScreen> createState() => _SixQuizScreenState();
}

class _SixQuizScreenState extends State<SixQuizScreen> {
  late final SixTrianglesSession _session;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _session = SixTrianglesSession(
      data: widget.data.sixTriangles,
      variant: widget.variant,
    );
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  Color get _accent {
    final Color base =
        widget
            .data
            .sixTriangles
            .categoryById[_session.current.category]
            ?.color ??
        AppColors.ink;
    return Color.lerp(base, AppColors.ink, 0.4) ?? AppColors.ink;
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

  void _goBack() {
    _advanceTimer?.cancel();
    if (_session.isFirst) {
      Navigator.of(context).pop();
      return;
    }
    setState(_session.previous);
  }

  void _goNext() {
    _advanceTimer?.cancel();
    if (_session.currentAnswer == null) {
      _snack('Escolha uma resposta para continuar.');
      return;
    }
    if (_session.isLast) {
      _finish();
      return;
    }
    setState(_session.next);
  }

  void _finish() {
    if (_session.answers.any((answer) => answer == null)) {
      _snack('Ainda faltam respostas.');
      return;
    }
    final SixTrianglesResult? result = _session.result();
    if (result == null) {
      _snack('Não foi possível calcular o resultado.');
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SixResultScreen(
          result: result,
          variantLabel: _session.variant.label,
        ),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final SixQuestion question = _session.current;
    final category = widget.data.sixTriangles.categoryById[question.category];
    if (category == null) {
      return const Scaffold(
        body: Center(child: Text('Categoria não encontrada.')),
      );
    }
    final Color accent = _accent;

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
                accent: accent,
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 170),
                child: ListView(
                  key: ValueKey<int>(question.id),
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  children: <Widget>[
                    CategoryChip(category: category),
                    const SizedBox(height: 14),
                    SectionCard(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Eyebrow('Afirmação'),
                          const SizedBox(height: 12),
                          Text(question.text, style: text.headlineSmall),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              final subcategoryLabel =
                                  (question.subcategory >= 0 &&
                                      question.subcategory <
                                          category.subcategories.length)
                                  ? category.subcategories[question.subcategory]
                                  : '';
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  question.agreeRaisesWeight
                                      ? 'Concordar fortalece $subcategoryLabel'
                                      : 'Concordar enfraquece $subcategoryLabel',
                                  style: text.bodySmall?.copyWith(
                                    color: AppColors.inkSoft,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
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
                      i < agreementLabels.length;
                      i++
                    ) ...<Widget>[
                      AnswerTile(
                        label: agreementLabels[i],
                        icon: _answerIcon(i),
                        selected: _session.currentAnswer == i,
                        accent: accent,
                        onTap: () => _selectAnswer(i),
                      ),
                      if (i != agreementLabels.length - 1)
                        const SizedBox(height: 9),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      'Cada resposta pesa de forma diferente conforme a força da pergunta. '
                      'Não existe resposta neutra "errada".',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: <Widget>[
                  Opacity(
                    opacity: _session.isFirst ? 0.35 : 1,
                    child: CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: _session.isFirst ? null : _goBack,
                      tooltip: 'Pergunta anterior',
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: _session.isLast ? 'Ver resultado' : 'Avançar',
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
