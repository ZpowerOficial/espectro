import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/political_models.dart';
import '../../theme.dart';
import 'axis_colors.dart';

/// Mapa radial de múltiplos eixos bipolares com faixa de incerteza (±1 SE),
/// sobreposição comparativa e adaptação completa aos temas claro e escuro.
class MultidimensionalRadarChart extends StatelessWidget {
  const MultidimensionalRadarChart({
    required this.axes,
    this.baselineAxes,
    this.size = 248,
    this.showLabels = true,
    this.showUncertaintyBand = true,
    this.showScaleTicks = true,
    this.colorStrategy,
    super.key,
  });

  final List<BipolarDimensionScore> axes;
  final List<BipolarDimensionScore>? baselineAxes;
  final double size;
  final bool showLabels;
  final bool showUncertaintyBand;
  final bool showScaleTicks;
  final AxisColorStrategy? colorStrategy;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final AxisColorStrategy strategy =
        colorStrategy ?? AxisColorStrategyScope.of(context);
    return Semantics(
      label: 'Mapa radial com ${axes.length} eixos bipolares.',
      child: CustomPaint(
        size: Size(size, size),
        painter: _RadarPainter(
          axes: axes,
          baselineAxes: baselineAxes,
          palette: p,
          showLabels: showLabels,
          showUncertaintyBand: showUncertaintyBand,
          showScaleTicks: showScaleTicks,
          colorStrategy: strategy,
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({
    required this.axes,
    required this.baselineAxes,
    required this.palette,
    required this.showLabels,
    required this.showUncertaintyBand,
    required this.showScaleTicks,
    required this.colorStrategy,
  });

  final List<BipolarDimensionScore> axes;
  final List<BipolarDimensionScore>? baselineAxes;
  final EspectroPalette palette;
  final bool showLabels;
  final bool showUncertaintyBand;
  final bool showScaleTicks;
  final AxisColorStrategy colorStrategy;

  @override
  void paint(Canvas canvas, Size size) {
    if (axes.isEmpty) return;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final bool drawAxisLabels = showLabels && size.shortestSide >= 170;
    final double labelPad = drawAxisLabels
        ? (size.shortestSide >= 340
              ? 64.0
              : (size.shortestSide >= 260 ? 58.0 : 44.0))
        : 8.0;
    final double maxR = size.shortestSide / 2 - labelPad;
    if (maxR <= 10) return;

    final Paint ringPaint = Paint()
      ..color = palette.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Anéis concêntricos: 25%, 50% (neutro tracejado), 75%, 100%.
    for (final double f in const <double>[0.25, 0.75, 1.0]) {
      canvas.drawCircle(center, maxR * f, ringPaint);
    }
    final Paint neutralDashPaint = Paint()
      ..color = palette.muted.withValues(alpha: 0.56)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;
    final Rect ring50Rect = Rect.fromCircle(center: center, radius: maxR * 0.5);
    const int dashCount = 32;
    const double stepAngle = (math.pi * 2) / dashCount;
    for (int d = 0; d < dashCount; d++) {
      canvas.drawArc(
        ring50Rect,
        d * stepAngle,
        stepAngle * 0.55,
        false,
        neutralDashPaint,
      );
    }

    final int n = axes.length;
    final int maxChars = size.shortestSide >= 340
        ? 15
        : (size.shortestSide >= 260 ? 12 : 9);
    for (var i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / n;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center, center + dir * maxR, ringPaint);

      if (!drawAxisLabels) {
        final Color tipColor = AxisColors.dominantColor(
          axes[i].axisId,
          leansLeft: axes[i].leansLeft,
          palette: palette,
          strategy: colorStrategy,
        );
        canvas.drawCircle(
          center + dir * maxR,
          1.9,
          Paint()..color = tipColor.withValues(alpha: 0.55),
        );
        continue;
      }

      final String shortLabel = axes[i].label.length > maxChars
          ? '${axes[i].label.substring(0, maxChars - 1)}.'
          : axes[i].label;
      final bool isMeasured = !axes[i].isIndeterminate;
      final Color labelColor = isMeasured ? palette.ink : palette.muted;
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: shortLabel,
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: size.shortestSide >= 340
                ? 11.5
                : (size.shortestSide >= 260 ? 10.5 : 9.5),
            fontWeight: isMeasured ? FontWeight.w700 : FontWeight.w500,
            color: labelColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final double halfExtentAlongDir =
          (tp.width / 2) * dir.dx.abs() + (tp.height / 2) * dir.dy.abs();
      final double radialGap = size.shortestSide >= 340 ? 11.0 : 8.5;
      final Offset labelCenter =
          center + dir * (maxR + radialGap + halfExtentAlongDir);
      final double dx = (labelCenter.dx - tp.width / 2).clamp(
        2.0,
        size.width - tp.width - 2.0,
      );
      final double dy = (labelCenter.dy - tp.height / 2).clamp(
        2.0,
        size.height - tp.height - 2.0,
      );
      tp.paint(canvas, Offset(dx, dy));
    }

    // Marcações de escala (-1, 0, +1) no setor superior entre raios 0 e 1.
    if (showScaleTicks && size.shortestSide >= 260) {
      const double tickAngle = -math.pi / 2 + 0.24;
      final Offset tickDir = Offset(math.cos(tickAngle), math.sin(tickAngle));
      for (final (double frac, String label) in const <(double, String)>[
        (0.16, '−1'),
        (0.50, '0'),
        (0.96, '+1'),
      ]) {
        final Offset pos = center + tickDir * (maxR * frac);
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: palette.muted.withValues(alpha: 0.85),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
      }
    }

    // Faixa anelar de dispersão estimada (±1 SE) atrás dos polígonos.
    if (showUncertaintyBand) {
      _drawUncertaintyBand(canvas, center: center, maxR: maxR, items: axes);
    }

    // Polígono comparativo anterior (se presente).
    if (baselineAxes != null && baselineAxes!.length == n) {
      _drawPolygon(
        canvas,
        center: center,
        maxR: maxR,
        items: baselineAxes!,
        fill: palette.muted.withValues(alpha: 0.10),
        stroke: palette.muted.withValues(alpha: 0.65),
        drawDots: false,
      );
    }

    // Polígono principal: raio = rightPercent / 100 (0.5 é o círculo central neutro).
    _drawPolygon(
      canvas,
      center: center,
      maxR: maxR,
      items: axes,
      fill: palette.accent.withValues(alpha: palette.isDark ? 0.20 : 0.14),
      stroke: palette.accent,
      drawDots: true,
    );
  }

  void _drawUncertaintyBand(
    Canvas canvas, {
    required Offset center,
    required double maxR,
    required List<BipolarDimensionScore> items,
  }) {
    final int n = items.length;
    if (n < 3) return;
    final bool anySpread = items.any(
      (a) => !a.isIndeterminate && a.standardError > 0.01,
    );
    if (!anySpread) return;

    final List<Offset> outerPts = <Offset>[];
    final List<Offset> innerPts = <Offset>[];
    for (var i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / n;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      final double se = items[i].isIndeterminate ? 0.0 : items[i].standardError;
      final double lowNorm = items[i].isIndeterminate
          ? 0.5
          : (((items[i].score - se).clamp(-1.0, 1.0) + 1.0) / 2.0).clamp(
              0.04,
              0.98,
            );
      final double highNorm = items[i].isIndeterminate
          ? 0.5
          : (((items[i].score + se).clamp(-1.0, 1.0) + 1.0) / 2.0).clamp(
              0.04,
              0.98,
            );
      innerPts.add(center + dir * (maxR * lowNorm));
      outerPts.add(center + dir * (maxR * highNorm));
    }

    final Path bandPath = Path()..fillType = PathFillType.evenOdd;
    bandPath.moveTo(outerPts.first.dx, outerPts.first.dy);
    for (var i = 1; i < n; i++) {
      bandPath.lineTo(outerPts[i].dx, outerPts[i].dy);
    }
    bandPath.close();

    final Path innerPath = Path()..moveTo(innerPts.first.dx, innerPts.first.dy);
    for (var i = 1; i < n; i++) {
      innerPath.lineTo(innerPts[i].dx, innerPts[i].dy);
    }
    innerPath.close();
    bandPath.addPath(innerPath, Offset.zero);

    canvas.drawPath(
      bandPath,
      Paint()
        ..color = palette.accent.withValues(alpha: palette.isDark ? 0.16 : 0.11)
        ..style = PaintingStyle.fill,
    );

    final Path outerContour = Path()..moveTo(outerPts.first.dx, outerPts.first.dy);
    for (var i = 1; i < n; i++) {
      outerContour.lineTo(outerPts[i].dx, outerPts[i].dy);
    }
    outerContour.close();
    canvas.drawPath(
      outerContour,
      Paint()
        ..color = palette.accent.withValues(alpha: palette.isDark ? 0.44 : 0.36)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
  }

  void _drawPolygon(
    Canvas canvas, {
    required Offset center,
    required double maxR,
    required List<BipolarDimensionScore> items,
    required Color fill,
    required Color stroke,
    required bool drawDots,
  }) {
    final int n = items.length;
    final Path poly = Path();
    final List<Offset> pts = <Offset>[];

    for (var i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / n;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      final double norm = items[i].isIndeterminate
          ? 0.5
          : ((items[i].score + 1.0) / 2.0).clamp(0.06, 0.98);
      final Offset pt = center + dir * (maxR * norm);
      pts.add(pt);
      if (i == 0) {
        poly.moveTo(pt.dx, pt.dy);
      } else {
        poly.lineTo(pt.dx, pt.dy);
      }
    }
    poly.close();

    canvas.drawPath(poly, Paint()..color = fill);
    canvas.drawPath(
      poly,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    if (drawDots) {
      for (var i = 0; i < n; i++) {
        final Color dotColor = AxisColors.dominantColor(
          items[i].axisId,
          leansLeft: items[i].leansLeft,
          palette: palette,
          strategy: colorStrategy,
        );
        final Color tipDotColor = items[i].isIndeterminate
            ? palette.muted
            : dotColor;
        final Offset tip = center +
            Offset(
              math.cos(-math.pi / 2 + i * 2 * math.pi / n),
              math.sin(-math.pi / 2 + i * 2 * math.pi / n),
            ) *
                maxR;
        canvas.drawCircle(tip, 2.3, Paint()..color = tipDotColor);
        if (items[i].isIndeterminate) {
          canvas.drawCircle(pts[i], 4.0, Paint()..color = palette.surface);
          canvas.drawCircle(
            pts[i],
            4.0,
            Paint()
              ..color = palette.muted
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        } else {
          canvas.drawCircle(pts[i], 4.4, Paint()..color = dotColor);
          canvas.drawCircle(
            pts[i],
            4.4,
            Paint()
              ..color = palette.surface
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.axes != axes ||
        oldDelegate.baselineAxes != baselineAxes ||
        oldDelegate.palette != palette ||
        oldDelegate.showLabels != showLabels ||
        oldDelegate.showUncertaintyBand != showUncertaintyBand ||
        oldDelegate.showScaleTicks != showScaleTicks ||
        oldDelegate.colorStrategy != colorStrategy;
  }
}
