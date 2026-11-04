import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/political_models.dart';
import '../../theme.dart';

/// Mapa radial de múltiplos eixos bipolares com suporte a sobreposição comparativa
/// e adaptação completa aos temas claro e escuro.
class MultidimensionalRadarChart extends StatelessWidget {
  const MultidimensionalRadarChart({
    required this.axes,
    this.baselineAxes,
    this.size = 248,
    super.key,
  });

  final List<BipolarDimensionScore> axes;
  final List<BipolarDimensionScore>? baselineAxes;
  final double size;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    return Semantics(
      label: 'Mapa radial com ${axes.length} eixos bipolares.',
      child: CustomPaint(
        size: Size(size, size),
        painter: _RadarPainter(
          axes: axes,
          baselineAxes: baselineAxes,
          palette: p,
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
  });

  final List<BipolarDimensionScore> axes;
  final List<BipolarDimensionScore>? baselineAxes;
  final EspectroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    if (axes.isEmpty) return;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxR = size.shortestSide / 2 - 26;
    if (maxR <= 10) return;

    final Paint ringPaint = Paint()
      ..color = palette.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Anéis concêntricos: 25%, 50% (centro neutro em tracejado/destaque), 75%, 100%.
    for (final double f in const <double>[0.25, 0.75, 1.0]) {
      canvas.drawCircle(center, maxR * f, ringPaint);
    }
    canvas.drawCircle(
      center,
      maxR * 0.5,
      Paint()
        ..color = palette.muted.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    final int n = axes.length;
    for (var i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / n;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center, center + dir * maxR, ringPaint);

      // Rótulo curto na borda externa.
      final String shortLabel = axes[i].label.length > 6
          ? '${axes[i].label.substring(0, 5)}.'
          : axes[i].label;
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: shortLabel,
          style: TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: palette.muted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final Offset labelCenter = center + dir * (maxR + 15);
      tp.paint(
        canvas,
        Offset(labelCenter.dx - tp.width / 2, labelCenter.dy - tp.height / 2),
      );
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
      fill: palette.accent.withValues(alpha: palette.isDark ? 0.22 : 0.15),
      stroke: palette.accent,
      drawDots: true,
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
        final Color dotColor = items[i].leansLeft
            ? palette.poleLeft
            : palette.poleRight;
        canvas.drawCircle(pts[i], 3.8, Paint()..color = dotColor);
        canvas.drawCircle(
          pts[i],
          3.8,
          Paint()
            ..color = palette.surface
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.axes != axes ||
        oldDelegate.baselineAxes != baselineAxes ||
        oldDelegate.palette != palette;
  }
}
