import 'package:flutter/material.dart';

import '../../../domain/models/study_models.dart';
import '../../../domain/models/study_media.dart';
import '../../../theme.dart';
import 'study_taxonomy.dart';

class StudyIdentityAvatar extends StatelessWidget {
  const StudyIdentityAvatar({
    required this.subject,
    this.portrait,
    this.size = 56,
    this.rectangular = false,
    super.key,
  });
  final StudySubject subject;
  final StudyPortrait? portrait;
  final double size;
  final bool rectangular;
  @override
  Widget build(BuildContext context) {
    final spectrum = spectrumOf(subject);
    final color = spectrum?.color ?? context.palette.accent;
    if (subject.kind != 'personality') {
      return SpectrumBar(color: color, height: size, width: 4);
    }
    final radius = BorderRadius.circular(rectangular ? 14 : size / 2);
    final fallback = ColoredBox(
      color: color.withValues(alpha: .12),
      child: Center(
        child: subject.kind == 'personality'
            ? Text(
                subject.name
                    .split(' ')
                    .where((s) => s.isNotEmpty)
                    .take(2)
                    .map((s) => s.characters.first)
                    .join(),
                style: TextStyle(
                  fontSize: size * .29,
                  fontWeight: FontWeight.w700,
                  color: spectrum?.ink(context.palette.isDark) ?? color,
                ),
              )
            : SpectrumBar(color: color, height: size),
      ),
    );
    return Semantics(
      image: portrait != null,
      label: portrait != null ? 'Retrato de ${subject.name}' : subject.name,
      child: Container(
        width: size,
        height: rectangular ? size * 1.22 : size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: color.withValues(alpha: .5), width: 2),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: color.withValues(alpha: .5), width: 2),
        ),
        child: portrait == null
            ? fallback
            : Image.asset(
                portrait!.assetPath,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -.5),
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

/// Um recorte editorial identificável, com cor de tradição e retrato real.
class StudyIdentityHero extends StatelessWidget {
  const StudyIdentityHero({required this.subject, this.portrait, super.key});
  final StudySubject subject;
  final StudyPortrait? portrait;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final spectrum = spectrumOf(subject);
    final accent = spectrum?.color ?? p.accent;
    final ink = spectrum?.ink(p.isDark) ?? p.accent;
    final title = Text(
      subject.name,
      style: Theme.of(context).textTheme.displayLarge
          ?.copyWith(fontSize: 34, height: 1.12, letterSpacing: -.6),
    );
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (spectrum != null)
              Text(
                spectrum.name.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
            Text(
              subject.kindLabel,
              style: TextStyle(color: p.inkSoft, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 18),
        title,
        const SizedBox(height: 12),
        Text(subject.subtitle, style: TextStyle(color: p.inkSoft, height: 1.4)),
      ],
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withValues(alpha: p.isDark ? .10 : .06),
          p.surface,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: .36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 5, color: accent),
          Padding(
            padding: const EdgeInsets.all(22),
            child: LayoutBuilder(
              builder: (context, c) {
                final largeText =
                    MediaQuery.textScalerOf(context).scale(1) > 1.4;
                if (subject.kind != 'personality') {
                  return identity;
                }
                if (c.maxWidth < 430 || largeText) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StudyIdentityAvatar(
                        subject: subject,
                        portrait: portrait,
                        size: 116,
                        rectangular: true,
                      ),
                      const SizedBox(height: 20),
                      identity,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StudyIdentityAvatar(
                      subject: subject,
                      portrait: portrait,
                      size: 154,
                      rectangular: true,
                    ),
                    const SizedBox(width: 26),
                    Expanded(child: identity),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
