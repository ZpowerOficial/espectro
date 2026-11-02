import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../engine/twelve_axes_engine.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/quiz_chrome.dart';
import 'twelve_result_screen.dart';

class TwelveArchetypeScreen extends StatefulWidget {
  const TwelveArchetypeScreen({required this.session, super.key});

  final TwelveAxesSession session;

  @override
  State<TwelveArchetypeScreen> createState() => _TwelveArchetypeScreenState();
}

class _TwelveArchetypeScreenState extends State<TwelveArchetypeScreen> {
  late final Map<String, int> _choices = <String, int>{
    ...widget.session.archetypeChoices,
  };

  List<ArchetypeQuestion> get _questions => widget.session.data.archetypeQuestions;

  int get _remaining => _questions.length - _choices.length;

  void _choose(String questionId, int optionIndex) {
    setState(() => _choices[questionId] = optionIndex);
  }

  void _finish() {
    if (_remaining > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Responda as escolhas restantes.')),
      );
      return;
    }
    for (final MapEntry<String, int> entry in _choices.entries) {
      widget.session.setArchetypeChoice(entry.key, entry.value);
    }
    final TwelveAxesResult? result = widget.session.result();
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ainda faltam respostas no questionário.')),
      );
      return;
    }

    final List<({String label, String answer})> archetype =
        <({String label, String answer})>[
      for (final ArchetypeQuestion question in _questions)
        (
          label: question.label,
          answer: (_choices[question.id] != null &&
                  _choices[question.id]! >= 0 &&
                  _choices[question.id]! < question.options.length)
              ? question.options[_choices[question.id]!].text
              : '',
        ),
    ];

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => TwelveResultScreen(
          result: result,
          archetype: archetype,
          variantLabel: widget.session.variant.label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final int answered = _choices.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: QuizTopBar(
                onBack: () => Navigator.of(context).pop(),
                progress: _questions.isEmpty ? 0 : answered / _questions.length,
                counter: 'Perfil · $answered de ${_questions.length}',
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: <Widget>[
                  const Eyebrow('Etapa final'),
                  const SizedBox(height: 12),
                  Text('Cinco escolhas\npara fechar o retrato.', style: text.displayMedium),
                  const SizedBox(height: 12),
                  Text(
                    'Estas perguntas não somam eixos: elas descrevem o seu ponto de '
                    'partida — sociedade, poder, economia, diplomacia e religião.',
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  for (var i = 0; i < _questions.length; i++) ...<Widget>[
                    _ArchetypeCard(
                      index: i,
                      question: _questions[i],
                      selected: _choices[_questions[i].id],
                      onSelect: (int optionIndex) => _choose(_questions[i].id, optionIndex),
                    ),
                    if (i != _questions.length - 1) const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: AppButton(
                label: _remaining == 0
                    ? 'Ver resultado'
                    : 'Faltam $_remaining ${_remaining == 1 ? 'escolha' : 'escolhas'}',
                icon: Icons.arrow_forward_rounded,
                onPressed: _remaining == 0 ? _finish : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchetypeCard extends StatelessWidget {
  const _ArchetypeCard({
    required this.index,
    required this.question,
    required this.selected,
    required this.onSelect,
  });

  final int index;
  final ArchetypeQuestion question;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '${index + 1}'.padLeft(2, '0'),
                style: text.labelSmall?.copyWith(color: AppColors.accent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.label.toUpperCase(),
                  style: text.labelSmall?.copyWith(color: AppColors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(question.text, style: text.titleLarge),
          const SizedBox(height: 12),
          for (var i = 0; i < question.options.length; i++) ...<Widget>[
            AnswerTile(
              label: question.options[i].text,
              badge: String.fromCharCode(65 + i),
              selected: selected == i,
              accent: AppColors.ink,
              onTap: () => onSelect(i),
            ),
            if (i != question.options.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
