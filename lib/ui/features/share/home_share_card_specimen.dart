import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models.dart' as data show Axis;
import '../../../domain/engine/atlas_and_nolan_engine.dart';
import '../../../domain/models/atlas_models.dart';
import '../../../domain/models/study_media.dart';
import '../../../domain/models/study_models.dart';
import '../../../theme.dart';
import '../../../widgets/espectro_brand_mark.dart';
import '../atlas/current_emblem.dart';
import '../../charts/axis_colors.dart';
import '../../shared/resilient_image.dart';
import '../atlas/study_identity.dart';
import '../atlas/study_taxonomy.dart';

/// Espécime colecionável e interativo do Cartão de Resultado (Story 9:16 ou
/// Post 1:1) exibido diretamente na Tela Inicial usando dados reais do catálogo
/// ou da avaliação do visitante.
class HomeShareCardSpecimen extends StatelessWidget {
  const HomeShareCardSpecimen({
    required this.subject,
    required this.axesMeta,
    this.portrait,
    this.emblemSubject,
    this.storyFormat = true,
    this.badgeLabel = 'Exemplo real',
    this.footerCtaLabel = 'Gerar o meu',
    this.subtitleMetric,
    this.onTapCard,
    this.onPrimaryAction,
    this.compact = false,
    super.key,
  });

  final StudySubject subject;
  final List<data.Axis> axesMeta;
  final StudyPortrait? portrait;
  final StudySubject? emblemSubject;
  final bool storyFormat;
  final String badgeLabel;
  final String footerCtaLabel;
  final String? subtitleMetric;
  final VoidCallback? onTapCard;
  final VoidCallback? onPrimaryAction;
  final bool compact;

  static const List<({String id, String label})> _canonicalRadarAxes =
      <({String id, String label})>[
        (id: 'estrutura', label: 'Estrutura'),
        (id: 'representacao', label: 'Democ.'),
        (id: 'poder', label: 'Poder'),
        (id: 'imigracao', label: 'Imigr.'),
        (id: 'diplomacia', label: 'Diplo.'),
        (id: 'intervencao', label: 'Interv.'),
        (id: 'economia', label: 'Economia'),
        (id: 'controle', label: 'Controle'),
        (id: 'comercio', label: 'Comércio'),
        (id: 'religiao', label: 'Religião'),
        (id: 'moral', label: 'Moral'),
        (id: 'tecnologia', label: 'Tecnol.'),
      ];

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final StudySubject visualSubject = emblemSubject ?? subject;
    final StudySpectrum? spectrum =
        spectrumOf(visualSubject) ?? spectrumOf(subject);
    final Color traditionColor = spectrum?.color ?? const Color(0xFFE5A64B);
    final Color traditionInk = spectrum?.ink(true) ?? const Color(0xFFE5A64B);
    final double scale = MediaQuery.textScalerOf(context).scale(16) / 16.0;

    final Map<String, double> sourceAxes = subject.displayAxes;
    final List<double> radarValues = <double>[
      for (final ({String id, String label}) ax in _canonicalRadarAxes)
        ((sourceAxes[ax.id] ?? 0.0).clamp(-1.0, 1.0) + 1.0) / 2.0,
    ];
    final NolanCoordinates? nolan = EspectroNolanEngine.fromRawMaps(
      axes: subject.axes,
      triangles: subject.triangles,
    );
    final List<
      ({String axisId, String label, String pole, int pct, double mag, Color color, Color ink})
    >
    topTraits = _topDominantTraits(
      sourceAxes,
      axesMeta,
      fallbackAccent: traditionColor,
      limit: (compact && storyFormat) ? 1 : 2,
    );

    const Color bgObsidian = Color(0xFF0B101A);
    const Color inkLight = Color(0xFFF7F4EC);
    const Color ruleBorder = Color(0xFF232D3F);
    const Color brassAccent = Color(0xFFE5A64B);

    final double padH = compact ? 12 : 20;
    final double padV = compact ? 10 : 18;
    final double avatarSize = compact ? 34 : 52;
    final double radarSize = storyFormat
        ? (compact ? 104 : 184)
        : (compact ? 92 : 158);

    final Widget identityEmblem = _SpecimenEmblem(
      subject: visualSubject,
      portrait: portrait,
      accent: traditionColor,
      size: avatarSize,
    );

    final Widget headerBand = Row(
      children: <Widget>[
        const SizedBox(
          width: 17,
          height: 17,
          child: FittedBox(child: EspectroBrandMark()),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            storyFormat ? 'ESPECTRO · STORY 9:16' : 'ESPECTRO · POST 1:1',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.65,
              color: inkLight,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: traditionColor.withValues(alpha: 0.50),
            ),
          ),
          child: Text(
            badgeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: traditionInk,
            ),
          ),
        ),
      ],
    );

    final String specEyebrow =
        subtitleMetric ??
        (spectrum?.name ??
            (subject.family.isNotEmpty ? subject.family : subject.kindLabel));

    final Widget identityBand = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        identityEmblem,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                specEyebrow,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: compact ? 9.5 : 11.5,
                  fontWeight: FontWeight.w700,
                  color: traditionInk,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subject.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: compact ? 14.5 : 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.45,
                  height: 1.08,
                  color: inkLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final Widget radarVisual = SizedBox(
      width: radarSize,
      height: radarSize,
      child: CustomPaint(
        painter: _SpecimenRadarPainter(
          values: radarValues,
          labels: <String>[
            for (final ({String id, String label}) ax in _canonicalRadarAxes)
              ax.label,
          ],
          accent: traditionColor,
          showLabels: scale <= 1.35 && !compact,
        ),
      ),
    );

    final Widget nolanAndTraitsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (nolan != null)
          Row(
            children: <Widget>[
              SizedBox(
                width: 24,
                height: 24,
                child: CustomPaint(
                  painter: _SpecimenNolanPainter(
                    econPct: nolan.economicFreedom / 100.0,
                    civilPct: nolan.personalFreedom / 100.0,
                    accent: traditionColor,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Econ. ${nolan.economicFreedom.round()}% · Civil ${nolan.personalFreedom.round()}%',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: inkLight,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        if (topTraits.isNotEmpty) ...<Widget>[
          SizedBox(height: nolan != null ? 8 : 0),
          for (int i = 0; i < topTraits.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 6),
            _SpecimenTraitRow(
              axisId: topTraits[i].axisId,
              label: '${topTraits[i].label} · ${topTraits[i].pole}',
              percent: topTraits[i].pct,
              accent: topTraits[i].color,
              accentInk: topTraits[i].ink,
            ),
          ],
        ],
      ],
    );

    final Widget footerBand = Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Qual é o seu mapa?',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: inkLight,
                ),
              ),
              Text(
                'espectro-politico.web.app',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: compact ? 8.0 : 8.5,
                  fontWeight: FontWeight.w700,
                  color: brassAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        if (onPrimaryAction != null)
          FilledButton(
            onPressed: onPrimaryAction,
            style: FilledButton.styleFrom(
              backgroundColor: brassAccent,
              foregroundColor: const Color(0xFF140D03),
              elevation: 0,
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 10,
                vertical: 5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              textStyle: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: Text('$footerCtaLabel →'),
          ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: bgObsidian,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: traditionColor.withValues(alpha: p.isDark ? 0.48 : 0.42),
          width: 1.1,
        ),
        boxShadow: p.isDark
            ? const <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF141819).withValues(alpha: 0.10),
                  blurRadius: 12,
                  spreadRadius: -3,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapCard,
          hoverColor: traditionColor.withValues(alpha: 0.05),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: _SpecimenPlatePainter(accent: traditionColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(padH, padV, padH, padV),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 11.5,
                    color: inkLight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      headerBand,
                      SizedBox(height: compact ? 9 : 11),
                      identityBand,
                      SizedBox(height: compact ? 8 : 10),
                      Container(height: 1, color: ruleBorder),
                      SizedBox(height: compact ? 8 : 10),
                      if (!storyFormat && scale <= 1.35)
                        LayoutBuilder(
                          builder: (context, innerBox) {
                            if (innerBox.maxWidth >= 295) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  radarVisual,
                                  SizedBox(width: compact ? 10 : 16),
                                  Expanded(child: nolanAndTraitsColumn),
                                ],
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Center(child: radarVisual),
                                const SizedBox(height: 10),
                                nolanAndTraitsColumn,
                              ],
                            );
                          },
                        )
                      else ...<Widget>[
                        Center(child: radarVisual),
                        SizedBox(height: compact ? 6 : 12),
                        nolanAndTraitsColumn,
                      ],
                      SizedBox(height: compact ? 9 : 11),
                      Container(height: 1, color: ruleBorder),
                      SizedBox(height: compact ? 8 : 9),
                      footerBand,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<
    ({
      String axisId,
      String label,
      String pole,
      int pct,
      double mag,
      Color color,
      Color ink,
    })
  >
  _topDominantTraits(
    Map<String, double> axes,
    List<data.Axis> axesMeta, {
    required Color fallbackAccent,
    required int limit,
  }) {
    final list = <
      ({
        String axisId,
        String label,
        String pole,
        int pct,
        double mag,
        Color color,
        Color ink,
      })
    >[];
    for (final data.Axis ax in axesMeta) {
      final double? raw = axes[ax.id];
      if (raw == null) continue;
      final double score = raw.clamp(-1.0, 1.0);
      final double mag = score.abs();
      final (Color lCol, Color rCol) =
          AxisColors.pairs[ax.id] ?? (fallbackAccent, fallbackAccent);
      final Color rawCol = score <= 0 ? lCol : rCol;
      final Color inkCol = AxisColors.readableInk(
        rawCol,
        isDark: true,
        background: const Color(0xFF0B101A),
      );
      list.add((
        axisId: ax.id,
        label: ax.label,
        pole: score >= 0 ? ax.rightPole : ax.leftPole,
        pct: ((0.5 + mag / 2.0) * 100).round().clamp(50, 100),
        mag: mag,
        color: rawCol,
        ink: inkCol,
      ));
    }
    list.sort((a, b) => b.mag.compareTo(a.mag));
    return list.take(limit).toList();
  }
}

class _SpecimenEmblem extends StatelessWidget {
  const _SpecimenEmblem({
    required this.subject,
    required this.portrait,
    required this.accent,
    required this.size,
  });

  final StudySubject subject;
  final StudyPortrait? portrait;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (subject.kind == 'current' || subject.key.startsWith('current:')) {
      final String id =
          subject.current?.id ?? subject.key.replaceFirst('current:', '');
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.1),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(size * 0.25),
          border: Border.all(color: accent.withValues(alpha: 0.58), width: 1.1),
        ),
        child: buildResilientAssetImage(
          'assets/currents/$id.png',
          fit: BoxFit.contain,
          fallback: CurrentHeraldicEmblem(subject: subject, size: size * 0.8),
        ),
      );
    }

    final String? assetPath = portrait?.assetPath ?? subject.photoUrl;
    final String initials = subject.name
        .split(' ')
        .where((String w) => w.isNotEmpty)
        .take(2)
        .map((String w) => w.characters.first.toUpperCase())
        .join();
    final Widget fallback = Container(
      color: accent.withValues(alpha: 0.24),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: size * 0.34,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFF7F4EC),
        ),
      ),
    );

    if (subject.kind == 'personality') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: accent.withValues(alpha: 0.65), width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: ClipOval(
          child: assetPath != null && assetPath.startsWith('assets/')
              ? buildResilientAssetImage(
                  assetPath,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.42),
                  fallback: fallback,
                )
              : fallback,
        ),
      );
    }

    return StudyIdentityAvatar(subject: subject, portrait: portrait, size: size);
  }
}

class _SpecimenTraitRow extends StatelessWidget {
  const _SpecimenTraitRow({
    required this.axisId,
    required this.label,
    required this.percent,
    required this.accent,
    required this.accentInk,
  });

  final String axisId;
  final String label;
  final int percent;
  final Color accent;
  final Color accentInk;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              AxisColors.iconFor(axisId),
              size: 11,
              color: accentInk,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC5CFDF),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$percent%',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: accentInk,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3.5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 4,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                const ColoredBox(color: Color(0xFF232D3F)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (percent / 100.0).clamp(0.5, 1.0),
                  child: ColoredBox(color: accentInk),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecimenPlatePainter extends CustomPainter {
  const _SpecimenPlatePainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.65;
    const double step = 26.0;
    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 8), Offset(x, size.height - 8), gridPaint);
    }
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(8, y), Offset(size.width - 8, y), gridPaint);
    }

    const double inset = 6.5;
    final Rect frame = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    canvas.drawRect(
      frame,
      Paint()
        ..color = accent.withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    final Paint tickPaint = Paint()
      ..color = accent.withValues(alpha: 0.55)
      ..strokeWidth = 1.0;
    const double mark = 4.0;
    for (final Offset corner in <Offset>[
      frame.topLeft,
      frame.topRight,
      frame.bottomLeft,
      frame.bottomRight,
    ]) {
      canvas.drawLine(
        corner - const Offset(mark, 0),
        corner + const Offset(mark, 0),
        tickPaint,
      );
      canvas.drawLine(
        corner - const Offset(0, mark),
        corner + const Offset(0, mark),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpecimenPlatePainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class _SpecimenNolanPainter extends CustomPainter {
  const _SpecimenNolanPainter({
    required this.econPct,
    required this.civilPct,
    required this.accent,
  });

  final double econPct;
  final double civilPct;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.04)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      r,
      Paint()
        ..color = const Color(0xFF2B374D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85,
    );
    final Paint crossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 0.65;
    canvas.drawLine(
      Offset(size.width / 2, 2),
      Offset(size.width / 2, size.height - 2),
      crossPaint,
    );
    canvas.drawLine(
      Offset(2, size.height / 2),
      Offset(size.width - 2, size.height / 2),
      crossPaint,
    );
    final double px = 2.5 + econPct.clamp(0.0, 1.0) * (size.width - 5);
    final double py = (size.height - 2.5) - civilPct.clamp(0.0, 1.0) * (size.height - 5);
    canvas.drawCircle(
      Offset(px, py),
      4.0,
      Paint()
        ..color = accent.withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(Offset(px, py), 2.1, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _SpecimenNolanPainter oldDelegate) =>
      oldDelegate.econPct != econPct ||
      oldDelegate.civilPct != civilPct ||
      oldDelegate.accent != accent;
}

class _SpecimenRadarPainter extends CustomPainter {
  const _SpecimenRadarPainter({
    required this.values,
    required this.labels,
    required this.accent,
    required this.showLabels,
  });

  final List<double> values;
  final List<String> labels;
  final Color accent;
  final bool showLabels;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxR = size.shortestSide / 2 - (showLabels ? 20 : 4);
    if (maxR <= 6) return;

    final Paint ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final double f in const <double>[0.33, 1.0]) {
      canvas.drawCircle(center, maxR * f, ringPaint);
    }

    final double midR = maxR * 0.5;
    final Paint neutralRing = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;
    const int dashCount = 24;
    const double arcSpan = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: midR),
        i * arcSpan,
        arcSpan * 0.55,
        false,
        neutralRing,
      );
    }

    final int n = values.length;
    final Path poly = Path();
    final List<Offset> pts = <Offset>[];
    for (int i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / n;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center, center + dir * maxR, ringPaint);
      final double norm = values[i].clamp(0.10, 0.98);
      final Offset pt = center + dir * (maxR * norm);
      pts.add(pt);
      if (i == 0) {
        poly.moveTo(pt.dx, pt.dy);
      } else {
        poly.lineTo(pt.dx, pt.dy);
      }

      if (showLabels && i < labels.length && i.isEven) {
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: const TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA7B2C4),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final Offset lblCenter = center + dir * (maxR + 12);
        tp.paint(
          canvas,
          Offset(lblCenter.dx - tp.width / 2, lblCenter.dy - tp.height / 2),
        );
      }
    }
    poly.close();

    canvas.drawPath(poly, Paint()..color = accent.withValues(alpha: 0.26));
    canvas.drawPath(
      poly,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9,
    );
    final Paint dotRing = Paint()..color = accent;
    final Paint dotCore = Paint()..color = const Color(0xFFF7F4EC);
    for (final Offset pt in pts) {
      canvas.drawCircle(pt, 2.2, dotRing);
      canvas.drawCircle(pt, 1.0, dotCore);
    }
  }

  @override
  bool shouldRepaint(covariant _SpecimenRadarPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.values != values ||
      oldDelegate.showLabels != showLabels;
}
