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

    Widget buildMainColumn(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(eyebrow, color: p.accent),
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: p.ink,
            fontSize: 34,
            height: 1.12,
            letterSpacing: -0.8,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 10),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: p.inkSoft,
              height: 1.46,
            ),
          ),
        ],
        if (badges.isNotEmpty) ...[
          const SizedBox(height: 14),
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
                    color: p.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: p.line),
                  ),
                  child: Text(
                    b,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: p.inkSoft,
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (footer != null) ...[const SizedBox(height: 20), footer!],
      ],
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: EspectroElevation.cardDecoration(
        p,
        color: p.surface,
        radius: 14,
        elevated: false,
      ),
      child: LayoutBuilder(
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
    );
  }
}
