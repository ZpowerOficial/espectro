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
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(eyebrow, color: context.palette.accent),
        SizedBox(height: compact ? 6 : 12),
        Text(
          title,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: compact ? 24 : 36,
            height: 1.15,
            letterSpacing: compact ? -0.5 : -0.7,
          ),
        ),
        if (description != null) ...[
          SizedBox(height: compact ? 6 : 10),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: compact ? 13 : null,
              height: 1.38,
            ),
          ),
        ],
      ],
    );
  }
}

class EditorialHero extends StatelessWidget {
  const EditorialHero({
    required this.eyebrow,
    required this.title,
    this.description,
    this.badges = const <String>[],
    this.footer,
    this.showcase,
    super.key,
  });
  final String eyebrow;
  final String title;
  final String? description;
  final List<String> badges;
  final Widget? footer;
  final Widget? showcase;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final Color heroStart = p.heroBackground;
    final Color heroEnd = Color.alphaBlend(
      const Color(0xFF4E3FA5).withValues(alpha: p.isDark ? 0.24 : 0.20),
      p.heroBackground,
    );

    Widget buildMainColumn(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE5A64B),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Eyebrow(eyebrow, color: const Color(0xFFEBC07A)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: p.heroForeground,
            fontSize: 34,
            height: 1.14,
            letterSpacing: -0.8,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 12),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: p.heroMuted,
              height: 1.46,
            ),
          ),
        ],
        if (badges.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final b in badges)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: p.heroForeground.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: p.heroForeground.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    b,
                    style: TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: p.heroForeground.withValues(alpha: 0.90),
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (footer != null) ...[const SizedBox(height: 22), footer!],
      ],
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[heroStart, heroEnd],
          stops: const <double>[0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF7B6CE0).withValues(alpha: 0.26),
        ),
        boxShadow: EspectroElevation.cardShadows(
          p,
          tint: const Color(0xFF4E3FA5),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -120,
            right: -85,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    const Color(0xFF7B6CE0).withValues(alpha: 0.18),
                    const Color(0xFF4E3FA5).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -95,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    const Color(0xFFE5A64B).withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool splitHero =
                  showcase != null && constraints.maxWidth >= 740;
              if (splitHero) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(28, 28, 26, 26),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: buildMainColumn(context)),
                      const SizedBox(width: 24),
                      Expanded(flex: 5, child: showcase!),
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildMainColumn(context),
                    if (showcase != null) ...[
                      const SizedBox(height: 20),
                      showcase!,
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
