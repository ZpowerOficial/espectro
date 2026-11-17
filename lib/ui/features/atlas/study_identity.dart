import 'package:flutter/material.dart';

import '../../../domain/models/study_models.dart';
import '../../../domain/models/study_media.dart';
import '../../../theme.dart';
import 'current_emblem.dart';
import 'study_taxonomy.dart';

class StudyIdentityAvatar extends StatelessWidget {
  const StudyIdentityAvatar({
    required this.subject,
    this.portrait,
    this.size = 56,
    this.rectangular = false,
    this.heroTag,
    super.key,
  });
  final StudySubject subject;
  final StudyPortrait? portrait;
  final double size;
  final bool rectangular;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final spectrum = spectrumOf(subject);
    final color = spectrum?.color ?? p.accent;

    if (subject.kind == 'spectrum' || subject.key.startsWith('spectrum:')) {
      return SpectrumBar(color: color, height: size, width: 4);
    }

    if (subject.kind == 'current' || subject.key.startsWith('current:')) {
      final currentId =
          subject.current?.id ?? subject.key.replaceFirst('current:', '');
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final targetPx = (size * dpr).round().clamp(64, 256);
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.08),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(rectangular ? 14 : size * 0.28),
          color: color.withValues(alpha: p.isDark ? 0.14 : 0.08),
          border: Border.all(
            color: color.withValues(alpha: 0.42),
            width: 1.3,
          ),
        ),
        child: Image.asset(
          'assets/currents/$currentId.png',
          fit: BoxFit.contain,
          cacheWidth: targetPx,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) =>
              CurrentHeraldicEmblem(subject: subject, size: size),
        ),
      );
    }

    final hasAsset = portrait != null ||
        (subject.photoUrl != null && subject.photoUrl!.startsWith('assets/'));
    final assetPath = portrait?.assetPath ??
        (subject.photoUrl != null && subject.photoUrl!.startsWith('assets/')
            ? subject.photoUrl!
            : null);
    final hasNetwork = !hasAsset &&
        subject.photoUrl != null &&
        (subject.photoUrl!.startsWith('http://') ||
            subject.photoUrl!.startsWith('https://'));
    final hasImage = hasAsset || hasNetwork;

    final isBook = subject.kind == 'book';
    final isCountry = subject.kind == 'country';

    final double width = isCountry ? size * 1.25 : size;
    final double height = rectangular
        ? (isBook ? size * 1.35 : (isCountry ? size * 0.9 : size * 1.22))
        : (isCountry ? size * 0.85 : size);
    final radius = BorderRadius.circular(
      rectangular ? 14 : (isCountry ? 8 : (isBook ? 10 : size / 2)),
    );

    final fallback = switch (subject.kind) {
      'book' => _buildBookCoverFallback(color, p.isDark),
      _ => ColoredBox(
          color: color.withValues(alpha: p.isDark ? .14 : .08),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: switch (subject.kind) {
                  'personality' => Text(
                      subject.name
                          .split(' ')
                          .where((s) => s.isNotEmpty)
                          .take(2)
                          .map((s) => s.characters.first)
                          .join(),
                      style: TextStyle(
                        fontSize: size * .32,
                        fontWeight: FontWeight.w700,
                        color: spectrum?.ink(p.isDark) ?? color,
                      ),
                    ),
                  'country' => _buildCountryFallback(color),
                  'party' => Icon(
                      Icons.groups_rounded,
                      size: size * 0.46,
                      color: color,
                    ),
                  'history' => Icon(
                      Icons.account_balance_rounded,
                      size: size * 0.46,
                      color: color,
                    ),
                  _ => SpectrumBar(
                      color: color,
                      height: size * 0.6,
                      width: 4,
                    ),
                },
              ),
            ),
          ),
        ),
    };

    final String semanticsLabel = hasImage
        ? switch (subject.kind) {
            'personality' => 'Retrato de ${subject.name}',
            'book' => 'Capa de ${subject.name}',
            'country' => 'Bandeira de ${subject.name}',
            'party' => 'Emblema de ${subject.name}',
            'history' => 'Registro visual de ${subject.name}',
            _ => subject.name,
          }
        : subject.name;

    final Widget avatar = Semantics(
      image: hasImage,
      label: semanticsLabel,
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: color.withValues(alpha: .5), width: 1.5),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: color.withValues(alpha: .5), width: 1.5),
        ),
        child: hasAsset
            ? Image.asset(
                assetPath!,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -.5),
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => fallback,
              )
            : (hasNetwork
                ? Image.network(
                    subject.photoUrl!,
                    fit: BoxFit.cover,
                    alignment: isBook ? Alignment.topCenter : const Alignment(0, -.4),
                    excludeFromSemantics: true,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                    errorBuilder: (_, _, _) => fallback,
                  )
                : fallback),
      ),
    );

    if (heroTag != null && hasImage) {
      return Hero(
        tag: heroTag!,
        flightShuttleBuilder: (_, animation, _, _, toHeroContext) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, _) => toHeroContext.widget,
          );
        },
        child: avatar,
      );
    }
    return avatar;
  }

  Widget _buildCountryFallback(Color color) {
    final origin = subject.entry?.origin ?? '';
    final emojiMatch = RegExp(r'[\u{1F1E6}-\u{1F1FF}]{2}', unicode: true).firstMatch(origin);
    if (emojiMatch != null) {
      return Text(
        emojiMatch.group(0)!,
        style: TextStyle(fontSize: size * 0.52),
      );
    }
    return Icon(
      Icons.public_rounded,
      size: size * 0.48,
      color: color,
    );
  }

  Widget _buildBookCoverFallback(Color color, bool isDark) {
    final initials = subject.name
        .split(' ')
        .where((w) => w.length > 2)
        .take(2)
        .map((w) => w.characters.first.toUpperCase())
        .join();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isDark ? 0.36 : 0.22),
            color.withValues(alpha: isDark ? 0.16 : 0.10),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 5,
            top: 0,
            bottom: 0,
            width: 1.5,
            child: ColoredBox(color: color.withValues(alpha: 0.45)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 6, 5, 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: size * 0.34,
                  color: color,
                ),
                Text(
                  initials.isEmpty ? 'OB' : initials,
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

/// Um recorte editorial identificável, com cor de tradição e retrato real.
class StudyIdentityHero extends StatelessWidget {
  const StudyIdentityHero({
    required this.subject,
    this.portrait,
    this.footer,
    super.key,
  });
  final StudySubject subject;
  final StudyPortrait? portrait;
  final Widget? footer;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final spectrum = spectrumOf(subject);
    final accent = spectrum?.color ?? p.accent;
    final ink = spectrum?.ink(p.isDark) ?? p.accent;
    final bool compactHero = MediaQuery.sizeOf(context).width < 600;
    final title = Text(
      subject.name,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
        fontSize: compactHero ? 22 : 34,
        height: 1.14,
        letterSpacing: -.5,
      ),
    );
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (spectrum != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: p.isDark ? 0.18 : 0.11),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  spectrum.name.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ink,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            Text(
              subject.kindLabel,
              style: TextStyle(color: p.inkSoft, fontSize: 12),
            ),
            if (subject.coveredDimensions > 0)
              Text(
                '· ${subject.coveredDimensions}/18 dim.',
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 10.5,
                  color: p.muted,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        title,
        const SizedBox(height: 10),
        Text(subject.subtitle, style: TextStyle(color: p.inkSoft, height: 1.4)),
        if (footer != null) ...[
          const SizedBox(height: 14),
          footer!,
        ],
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: EspectroElevation.cardShadows(p),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  accent.withValues(alpha: p.isDark ? .10 : .055),
                  p.surface,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 4, child: ColoredBox(color: accent)),
                  Padding(
                    padding: EdgeInsets.all(compactHero ? 15 : 22),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final largeText =
                            MediaQuery.textScalerOf(context).scale(1) > 1.4;
                        final hasImage = portrait != null ||
                            subject.kind == 'current' ||
                            (subject.photoUrl != null &&
                                subject.photoUrl!.isNotEmpty);
                        if (subject.kind != 'personality' && !hasImage) {
                          return identity;
                        }
                        if (largeText) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StudyIdentityAvatar(
                                subject: subject,
                                portrait: portrait,
                                size: 96,
                                rectangular: true,
                                heroTag: 'avatar_${subject.key}',
                              ),
                              const SizedBox(height: 16),
                              identity,
                            ],
                          );
                        }
                        final double avatarSize = c.maxWidth < 460 ? 72 : 154;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StudyIdentityAvatar(
                              subject: subject,
                              portrait: portrait,
                              size: avatarSize,
                              rectangular: true,
                              heroTag: 'avatar_${subject.key}',
                            ),
                            SizedBox(width: c.maxWidth < 460 ? 14 : 26),
                            Expanded(child: identity),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: accent.withValues(alpha: .36)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
