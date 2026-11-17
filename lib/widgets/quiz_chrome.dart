import 'package:flutter/material.dart' hide Axis;

import '../data/models.dart';
import '../theme.dart';
import 'common.dart';

/// Cabeçalho padrão dos quizzes: sair, progresso e contador de perguntas.
class QuizTopBar extends StatelessWidget {
  const QuizTopBar({
    required this.onBack,
    required this.progress,
    required this.counter,
    this.accent,
    super.key,
  });

  final VoidCallback onBack;
  final double progress;
  final String counter;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    return Row(
      children: <Widget>[
        CircleIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: onBack,
          tooltip: 'Sair do teste',
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ProgressRail(value: progress, color: accent ?? p.accent),
              const SizedBox(height: 8),
              Text(
                counter.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Etiqueta do eixo da pergunta atual, com os dois polos e suas cores.
class AxisChip extends StatelessWidget {
  const AxisChip({required this.axis, super.key});

  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: EspectroElevation.cardDecoration(
        p,
        radius: 14,
        elevated: false,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: axis.leftColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            axis.label.toUpperCase(),
            style: text.labelSmall?.copyWith(color: p.ink, letterSpacing: 1.3),
          ),
          const Spacer(),
          Text(
            axis.leftPole,
            style: text.bodySmall?.copyWith(
              color: axis.leftColor,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('·', style: text.bodySmall?.copyWith(color: p.muted)),
          ),
          Text(
            axis.rightPole,
            style: text.bodySmall?.copyWith(
              color: axis.rightColor,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta da categoria do Six Triangles atual.
class CategoryChip extends StatelessWidget {
  const CategoryChip({required this.category, super.key});

  final SixCategory category;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          category.color.withValues(alpha: p.isDark ? 0.22 : 0.30),
          p.surface,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: category.color.withValues(alpha: p.isDark ? 0.35 : 0.28),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: Color.lerp(category.color, p.ink, 0.35),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category.label.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: p.ink, letterSpacing: 1.3),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              category.subcategories.join(' · '),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 11.5, color: p.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}
