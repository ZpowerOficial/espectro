import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/study_models.dart';
import '../../theme.dart';
import '../features/atlas/study_taxonomy.dart';

/// Envoltória convexa cartográfica de uma família ideológica na projeção 2D.
class SpectrumTerritory {
  const SpectrumTerritory({
    required this.id,
    required this.label,
    required this.color,
    required this.hull,
    required this.centroid,
    required this.count,
  });

  final String id;
  final String label;
  final Color color;
  final List<Offset> hull;
  final Offset centroid;
  final int count;
}

/// Geometria e pintura cartográfica compartilhada entre a prévia da Teia na Home
/// e o estudo completo de constelação (`StudyConstellation`).
abstract final class TeiaCartographicLayer {
  static const double gridMin = 100.0;
  static const double gridMax = 780.0;
  static const double gridSpan = gridMax - gridMin; // 680.0
  static const double centerCoord = 440.0;

  // Vértices do simplex ternário equilátero (base = 680px, altura = 680*sqrt(3)/2 = 588.9px).
  static const Offset triadV0 = Offset(100.0, 730.0);
  static const Offset triadV1 = Offset(780.0, 730.0);
  static const Offset triadV2 = Offset(440.0, 141.1);
  static const Offset triadCentroid = Offset(440.0, 533.7);

  /// Envoltória convexa via Andrew's Monotone Chain (`O(n log n)`).
  /// Nunca altera as coordenadas analíticas originais; apenas calcula a fronteira
  /// territorial visual dos pontos plotados.
  static List<Offset> convexHull(List<Offset> raw) {
    if (raw.length <= 2) return List<Offset>.of(raw);
    final List<Offset> pts = List<Offset>.of(raw)
      ..sort((Offset a, Offset b) {
        final int dx = a.dx.compareTo(b.dx);
        return dx != 0 ? dx : a.dy.compareTo(b.dy);
      });

    double cross(Offset o, Offset a, Offset b) =>
        (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);

    final List<Offset> lower = <Offset>[];
    for (final Offset p in pts) {
      while (lower.length >= 2 &&
          cross(lower[lower.length - 2], lower[lower.length - 1], p) <= 0) {
        lower.removeLast();
      }
      lower.add(p);
    }
    final List<Offset> upper = <Offset>[];
    for (int i = pts.length - 1; i >= 0; i--) {
      final Offset p = pts[i];
      while (upper.length >= 2 &&
          cross(upper[upper.length - 2], upper[upper.length - 1], p) <= 0) {
        upper.removeLast();
      }
      upper.add(p);
    }
    lower.removeLast();
    upper.removeLast();
    return <Offset>[...lower, ...upper];
  }

  /// Agrupa os pontos já projetados (dentro da área analítica `dx <= 800`) por
  /// espectro editorial e constrói polígonos territoriais expandidos levemente em
  /// torno dos pontos para evitar recortes colados aos marcadores.
  static List<SpectrumTerritory> computeTerritories(
    List<(StudySubject, Offset)> placedPoints, {
    bool isDark = true,
  }) {
    final Map<String, ({String label, Color color, List<Offset> pts})> groups =
        <String, ({String label, Color color, List<Offset> pts})>{};

    for (final (StudySubject subject, Offset pt) in placedPoints) {
      if (pt.dx > 800 || pt.dx < 40 || pt.dx > 840 || pt.dy < 40 || pt.dy > 840) {
        continue;
      }
      final spec = spectrumOf(subject);
      if (spec == null) continue;
      final existing = groups[spec.id];
      if (existing == null) {
        groups[spec.id] = (
          label: spec.name,
          color: spec.color,
          pts: <Offset>[pt],
        );
      } else {
        existing.pts.add(pt);
      }
    }

    final List<SpectrumTerritory> result = <SpectrumTerritory>[];
    for (final MapEntry<String, ({String label, Color color, List<Offset> pts})> entry
        in groups.entries) {
      final List<Offset> pts = entry.value.pts;
      if (pts.length < 3) continue;
      final Offset centroid =
          pts.reduce((Offset a, Offset b) => a + b) / pts.length.toDouble();
      final List<Offset> hull = convexHull(pts);
      // Expande levemente a envoltória (~18px) para conter todos os pontos e
      // compensar o arredondamento suave nos vértices convexos.
      final List<Offset> padded = hull.map((Offset v) {
        final Offset delta = v - centroid;
        final double len = delta.distance;
        if (len < 1e-3) return v;
        return v + (delta / len) * 18.0;
      }).toList(growable: false);

      result.add(
        SpectrumTerritory(
          id: entry.key,
          label: entry.value.label,
          color: entry.value.color,
          hull: padded,
          centroid: centroid,
          count: pts.length,
        ),
      );
    }
    return result;
  }

  /// Pinta as envoltórias territoriais sem neblina difusa (`Gate 29`), preservando
  /// legibilidade tanto no papel claro quanto no fundo escuro de observatório.
  static void paintTerritories(
    Canvas canvas,
    List<SpectrumTerritory> territories,
    EspectroPalette p, {
    double opacityMultiplier = 1.0,
    bool showLabels = true,
    double zoomScale = 1.0,
    double labelOpacity = 1.0,
    bool isTriad = false,
    String? focusSpectrumId,
  }) {
    final bool dark = p.isDark;
    final List<Rect> drawnTerritoryLabels = <Rect>[];
    for (final SpectrumTerritory t in territories) {
      if (t.hull.length < 3) continue;
      final Path path = _buildSmoothClosedPath(t.hull);
      final bool isFocused = focusSpectrumId == null || t.id == focusSpectrumId;

      final double fillAlpha;
      final double strokeAlpha;
      final double strokeWidth;
      if (isTriad) {
        if (focusSpectrumId != null) {
          fillAlpha = (isFocused ? (dark ? 0.12 : 0.095) : 0.015) * opacityMultiplier;
          strokeAlpha = (isFocused ? (dark ? 0.54 : 0.56) : 0.12) * opacityMultiplier;
          strokeWidth = ((isFocused ? 1.45 : 0.85) / math.sqrt(zoomScale)).clamp(0.55, 1.8);
        } else {
          // Em projeções triangulares as envoltórias se concentram no mesmo miolo;
          // mantemos preenchimento quase aéreo e traço fino para não embarrar pontos.
          fillAlpha = (dark ? 0.036 : 0.028) * opacityMultiplier;
          strokeAlpha = (dark ? 0.22 : 0.24) * opacityMultiplier;
          strokeWidth = (0.95 / math.sqrt(zoomScale)).clamp(0.55, 1.3);
        }
      } else {
        final double dim = isFocused ? 1.0 : 0.42;
        fillAlpha = (dark ? 0.105 : 0.085) * opacityMultiplier * dim;
        strokeAlpha = (dark ? 0.34 : 0.38) * opacityMultiplier * (isFocused ? 1.0 : 0.52);
        strokeWidth = (1.25 / math.sqrt(zoomScale)).clamp(0.65, 1.5);
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = t.color.withValues(alpha: fillAlpha)
          ..style = PaintingStyle.fill,
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = t.color.withValues(alpha: strokeAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );

      final bool allowLabel = showLabels &&
          t.count >= 6 &&
          zoomScale <= 2.2 &&
          (!isTriad || (focusSpectrumId != null && isFocused));
      if (allowLabel) {
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: t.label,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: 10.5 / math.sqrt(zoomScale),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: Color.lerp(
                t.color,
                p.ink,
                dark ? 0.34 : 0.25,
              )!
                  .withValues(
                    alpha: (dark ? 0.72 : 0.76) *
                        opacityMultiplier *
                        labelOpacity,
                  ),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final Offset topLeft = t.centroid - Offset(tp.width / 2, tp.height / 2);
        final Rect candidateRect = (topLeft - const Offset(6, 4)) &
            Size(tp.width + 12, tp.height + 8);
        if (!drawnTerritoryLabels.any((r) => r.overlaps(candidateRect))) {
          drawnTerritoryLabels.add(candidateRect);
          tp.paint(canvas, topLeft);
        }
      }
    }
  }

  static Path _buildSmoothClosedPath(List<Offset> hull) {
    final Path path = Path();
    if (hull.length < 3) return path;
    final int n = hull.length;
    const double corner = 0.16;
    final Offset firstStart = Offset.lerp(hull[0], hull[n - 1], corner)!;
    path.moveTo(firstStart.dx, firstStart.dy);
    for (int i = 0; i < n; i++) {
      final Offset curr = hull[i];
      final Offset next = hull[(i + 1) % n];
      final Offset exit = Offset.lerp(curr, next, corner)!;
      final Offset nextEntry = Offset.lerp(next, curr, corner)!;
      path.quadraticBezierTo(curr.dx, curr.dy, exit.dx, exit.dy);
      path.lineTo(nextEntry.dx, nextEntry.dy);
    }
    path.close();
    return path;
  }

  /// Desenha o retículo cartográfico calibrado (`100..780 × 100..780` ou simplex
  /// ternário equilátero) com eixos principais e graduações discretas.
  static void paintGraticule(
    Canvas canvas,
    EspectroPalette p, {
    double scale = 1.0,
    bool showScaleTicks = true,
    bool isTriad = false,
    bool fillAnalyticalPlate = false,
  }) {
    final double invSqrt = (1.0 / math.sqrt(scale)).clamp(0.45, 1.2);

    if (isTriad) {
      final Path triPath = Path()
        ..moveTo(triadV0.dx, triadV0.dy)
        ..lineTo(triadV1.dx, triadV1.dy)
        ..lineTo(triadV2.dx, triadV2.dy)
        ..close();

      if (fillAnalyticalPlate) {
        canvas.drawPath(
          triPath,
          Paint()
            ..color = p.surface.withValues(alpha: p.isDark ? 0.68 : 0.88)
            ..style = PaintingStyle.fill,
        );
      }

      final Paint subtleGrid = Paint()
        ..color = p.line.withValues(alpha: p.isDark ? 0.22 : 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.72 * invSqrt;
      final Paint midGrid = Paint()
        ..color = p.line.withValues(alpha: p.isDark ? 0.40 : 0.48)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.95 * invSqrt;

      // Grade baricêntrica paralela às 3 arestas (iso-proporções em 25%, 50%, 75%)
      for (final double t in const <double>[0.25, 0.50, 0.75]) {
        final Paint gridPaint = t == 0.50 ? midGrid : subtleGrid;
        canvas.drawLine(
          Offset.lerp(triadV0, triadV2, t)!,
          Offset.lerp(triadV1, triadV2, t)!,
          gridPaint,
        );
        canvas.drawLine(
          Offset.lerp(triadV1, triadV0, t)!,
          Offset.lerp(triadV2, triadV0, t)!,
          gridPaint,
        );
        canvas.drawLine(
          Offset.lerp(triadV2, triadV1, t)!,
          Offset.lerp(triadV0, triadV1, t)!,
          gridPaint,
        );
      }

      // Cruz discreta no baricentro (33% · 33% · 33%)
      final Paint centroidPaint = Paint()
        ..color = p.inkSoft.withValues(alpha: p.isDark ? 0.42 : 0.38)
        ..strokeWidth = 1.0 * invSqrt;
      final double crossArm = 7.0 * invSqrt;
      canvas.drawLine(
        triadCentroid - Offset(crossArm, 0),
        triadCentroid + Offset(crossArm, 0),
        centroidPaint,
      );
      canvas.drawLine(
        triadCentroid - Offset(0, crossArm),
        triadCentroid + Offset(0, crossArm),
        centroidPaint,
      );

      // Moldura equilátera externa + marcadores de vértice
      canvas.drawPath(
        triPath,
        Paint()
          ..color = p.line.withValues(alpha: p.isDark ? 0.78 : 0.92)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.45 * invSqrt,
      );
      final Paint vertexFill = Paint()..color = p.surface;
      final Paint vertexStroke = Paint()
        ..color = p.inkSoft.withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3 * invSqrt;
      for (final Offset v in const <Offset>[triadV0, triadV1, triadV2]) {
        canvas.drawCircle(v, 3.8 * invSqrt, vertexFill);
        canvas.drawCircle(v, 3.8 * invSqrt, vertexStroke);
      }

      if (showScaleTicks) {
        for (final (Offset midPt, Offset outward) in <(Offset, Offset)>[
          (Offset.lerp(triadV0, triadV2, 0.5)!, Offset(-22.0 * invSqrt, -4.0 * invSqrt)),
          (Offset.lerp(triadV1, triadV2, 0.5)!, Offset(22.0 * invSqrt, -4.0 * invSqrt)),
        ]) {
          final TextPainter tp = TextPainter(
            text: TextSpan(
              text: '50%',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 8.0 * invSqrt,
                fontWeight: FontWeight.w600,
                color: p.muted.withValues(alpha: 0.72),
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          final Offset c = midPt + outward;
          tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
        }
      }
      return;
    }

    if (fillAnalyticalPlate) {
      canvas.drawRect(
        const Rect.fromLTWH(gridMin, gridMin, gridSpan, gridSpan),
        Paint()
          ..color = p.surface.withValues(alpha: p.isDark ? 0.68 : 0.88)
          ..style = PaintingStyle.fill,
      );
    }

    // Moldura externa calibrada do quadrante analítico
    canvas.drawRect(
      const Rect.fromLTWH(gridMin, gridMin, gridSpan, gridSpan),
      Paint()
        ..color = p.line.withValues(alpha: p.isDark ? 0.38 : 0.48)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9 * invSqrt,
    );

    // Linhas secundárias em ±25%, ±50%, ±75%
    final Paint subGrid = Paint()
      ..color = p.line.withValues(alpha: p.isDark ? 0.24 : 0.32)
      ..strokeWidth = 0.75 * invSqrt;
    final Paint midGrid = Paint()
      ..color = p.line.withValues(alpha: p.isDark ? 0.40 : 0.48)
      ..strokeWidth = 0.95 * invSqrt;

    for (final double frac in const <double>[-0.75, -0.5, -0.25, 0.25, 0.5, 0.75]) {
      final double offset = centerCoord + frac * 340.0;
      final Paint paint = frac.abs() == 0.5 ? midGrid : subGrid;
      canvas.drawLine(Offset(gridMin, offset), Offset(gridMax, offset), paint);
      canvas.drawLine(Offset(offset, gridMin), Offset(offset, gridMax), paint);
    }

    // Eixos ortogonais centrais x=0, y=0
    final Paint mainAxis = Paint()
      ..color = p.inkSoft.withValues(alpha: p.isDark ? 0.48 : 0.44)
      ..strokeWidth = 1.25 * invSqrt;
    canvas.drawLine(
      const Offset(gridMin, centerCoord),
      const Offset(gridMax, centerCoord),
      mainAxis,
    );
    canvas.drawLine(
      const Offset(centerCoord, gridMin),
      const Offset(centerCoord, gridMax),
      mainAxis,
    );

    if (fillAnalyticalPlate) {
      canvas.drawCircle(
        const Offset(centerCoord, centerCoord),
        3.5 * invSqrt,
        Paint()
          ..color = p.inkSoft.withValues(alpha: p.isDark ? 0.42 : 0.36)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 * invSqrt,
      );
    }

    if (!showScaleTicks) return;

    // Marcações decimais discretas no perímetro superior/esquerdo (-50, 0, +50)
    const List<(double frac, String label)> marks = <(double, String)>[
      (-0.5, '−50'),
      (0.0, '0'),
      (0.5, '+50'),
    ];
    for (final (double frac, String label) in marks) {
      final double pos = centerCoord + frac * 340.0;
      canvas.drawLine(
        Offset(pos, gridMin),
        Offset(pos, gridMin + 6 * invSqrt),
        mainAxis,
      );
      canvas.drawLine(
        Offset(gridMin, pos),
        Offset(gridMin + 6 * invSqrt, pos),
        mainAxis,
      );
      if (frac != 0.0) {
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 8.5 * invSqrt,
              fontWeight: FontWeight.w600,
              color: p.muted.withValues(alpha: 0.78),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(pos - tp.width / 2, gridMin - tp.height - 3));
      }
    }
  }

  /// Pinta o rótulo do nó em foco com placa cartográfica de alto contraste sem
  /// ofuscar o ponto analítico nem sobrepor o marcador em si.
  static void paintNodeFocusLabel(
    Canvas canvas,
    Offset pt,
    String text,
    Color accentColor,
    EspectroPalette p,
  ) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: p.ink,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 190);

    final bool placeAbove = pt.dy > 200;
    final double dy = placeAbove ? pt.dy - tp.height - 18 : pt.dy + 14;
    final double dx = (pt.dx - tp.width / 2).clamp(112.0, 770.0 - tp.width);
    final RRect pill = RRect.fromRectAndRadius(
      Rect.fromLTWH(dx - 8, dy - 4, tp.width + 16, tp.height + 8),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      pill,
      Paint()
        ..color = (p.isDark ? const Color(0xFF0F1724) : const Color(0xFFFAF9F5))
            .withValues(alpha: 0.94),
    );
    canvas.drawRRect(
      pill,
      Paint()
        ..color = accentColor.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    tp.paint(canvas, Offset(dx, dy));
  }
}
