import 'package:flutter/material.dart';

import '../theme.dart';
import 'common.dart';

/// Hierarquia editorial compartilhada pelos fluxos do Figma.
class EditorialHeading extends StatelessWidget {
  const EditorialHeading({
    required this.eyebrow,
    required this.title,
    this.description,
    super.key,
  });
  final String eyebrow;
  final String title;
  final String? description;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Eyebrow(eyebrow, color: context.palette.accent),
      const SizedBox(height: 22),
      Text(
        title,
        style: Theme.of(context).textTheme.displayLarge
            ?.copyWith(fontSize: 38, height: 1.24),
      ),
      if (description != null) ...[
        const SizedBox(height: 10),
        Text(
          description!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.3),
        ),
      ],
    ],
  );
}

class EditorialHero extends StatelessWidget {
  const EditorialHero({
    required this.eyebrow,
    required this.title,
    this.description,
    this.badges = const <String>[],
    this.footer,
    super.key,
  });
  final String eyebrow;
  final String title;
  final String? description;
  final List<String> badges;
  final Widget? footer;
  @override
  Widget build(BuildContext context) => SectionCard(
    color: context.palette.heroBackground,
    borderColor: context.palette.heroBackground,
    radius: 21,
    padding: const EdgeInsets.all(23),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        Eyebrow(eyebrow, color: const Color(0xFF6AE0CB)),
        const SizedBox(height: 28),
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium
              ?.copyWith(color: Colors.white, fontSize: 34, height: 1.24),
        ),
        if (description != null) ...[
          const SizedBox(height: 18),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: const Color(0xFFB9CFD1), height: 1.3),
          ),
        ],
        if (badges.isNotEmpty) ...[
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final b in badges)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    b,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      color: Color(0xFF86D9C8),
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (footer != null) ...[const SizedBox(height: 24), footer!],
      ],
    ),
  );
}
