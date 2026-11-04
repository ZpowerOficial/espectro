import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Axis;

import '../data/models.dart';
import '../engine/six_triangles_engine.dart';
import '../engine/twelve_axes_engine.dart';
import '../theme.dart';

/// Doze barras verticais, uma por eixo — usado no cartão da home.
class MiniAxesChart extends StatelessWidget {
  const MiniAxesChart({required this.axes, super.key});

  final List<Axis> axes;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MiniAxesPainter(axes),
      size: const Size(78, 64),
    );
  }
}

class _MiniAxesPainter extends CustomPainter {
  _MiniAxesPainter(this.axes);

  final List<Axis> axes;

  @override
  void paint(Canvas canvas, Size size) {
    if (axes.isEmpty || size.width <= 0 || size.height <= 0) return;
    final double gap = 2.4;
    final double width = (size.width - gap * (axes.length - 1)) / axes.length;
    for (var i = 0; i < axes.length; i++) {
      final double factor = 0.35 + 0.65 * ((i * 7 + 3) % 10) / 9;
      final double height = size.height * factor;
      final Rect rect = Rect.fromLTWH(
        i * (width + gap),
        size.height - height,
        width,
        height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()..color = axes[i].leftColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniAxesPainter oldDelegate) =>
      !listEquals(oldDelegate.axes, axes);
}

/// Mapa radial do resultado: cada raio é um eixo, a barra vai do centro para
/// fora conforme a intensidade e recebe a cor do polo dominante.
class AxisRadialChart extends StatelessWidget {
  const AxisRadialChart({required this.scores, super.key, this.size = 232});

  final List<AxisScore> scores;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AxisRadialPainter(scores),
      size: Size(size, size),
    );
  }
}

class _AxisRadialPainter extends CustomPainter {
  _AxisRadialPainter(this.scores);

  final List<AxisScore> scores;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;
    final double radius = size.shortestSide / 2 - 6;
    if (radius <= 0) return;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Paint grid = Paint()
      ..color = AppColors.line.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final double ring in <double>[0.33, 0.66, 1]) {
      canvas.drawCircle(center, radius * ring, grid);
    }

    final int count = scores.length;
    for (var i = 0; i < count; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / count;
      final Offset direction = Offset(math.cos(angle), math.sin(angle));
      final Offset start = center + direction * (radius * 0.14);
      canvas.drawLine(start, center + direction * radius, grid);

      final AxisScore score = scores[i];
      final double factor = (score.distanceFromCenter / 50).clamp(0.05, 1.0);
      final Offset end = start + direction * (radius * 0.86 * factor);
      final Color color = score.leansLeft
          ? score.axis.leftColor
          : score.axis.rightColor;

      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = color
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        center + direction * (radius * 0.14),
        2.4,
        Paint()..color = color,
      );
    }

    canvas.drawCircle(
      center,
      15,
      Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(center, 15, grid);
    canvas.drawCircle(center, 3, Paint()..color = AppColors.ink);
  }

  @override
  bool shouldRepaint(covariant _AxisRadialPainter oldDelegate) =>
      !listEquals(oldDelegate.scores, scores);
}

/// Roda com os seis triângulos do Six Triangles, cada um com o ponto calculado
/// pelos três vértices.
class SixWheel extends StatelessWidget {
  const SixWheel({
    required this.triangles,
    super.key,
    this.size = 300,
    this.showDots = true,
    this.gapColor = AppColors.dark,
  });

  final List<TriangleScore> triangles;
  final double size;
  final bool showDots;
  final Color gapColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SixWheelPainter(
        triangles: triangles,
        showDots: showDots,
        gapColor: gapColor,
      ),
      size: Size(size, size),
    );
  }
}

class _SixWheelPainter extends CustomPainter {
  _SixWheelPainter({
    required this.triangles,
    required this.showDots,
    required this.gapColor,
  });

  final List<TriangleScore> triangles;
  final bool showDots;
  final Color gapColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (triangles.isEmpty) return;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double outer = size.shortestSide / 2 - 4;
    final double inner = outer * 0.40;
    final double halfWidth = outer * 0.30;

    for (var i = 0; i < triangles.length; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / triangles.length;
      final Offset direction = Offset(math.cos(angle), math.sin(angle));
      final Offset perpendicular = Offset(-direction.dy, direction.dx);
      final Offset apex = center + direction * outer;
      final Offset base = center + direction * inner;
      final Offset right = base + perpendicular * halfWidth;
      final Offset left = base - perpendicular * halfWidth;

      final Path path = Path()
        ..moveTo(apex.dx, apex.dy)
        ..lineTo(right.dx, right.dy)
        ..lineTo(left.dx, left.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = triangles[i].category.color);
      canvas.drawPath(
        path,
        Paint()
          ..color = gapColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      if (showDots) {
        final List<int> weights = triangles[i].points;
        if (weights.length >= 3) {
          final double total = weights.fold<double>(
            0,
            (sum, value) => sum + value,
          );
          final Offset dot = total == 0
              ? (apex + right + left) / 3
              : (apex * weights[2].toDouble() +
                        right * weights[1].toDouble() +
                        left * weights[0].toDouble()) /
                    total;
          canvas.drawCircle(dot, 4.6, Paint()..color = AppColors.surface);
          canvas.drawCircle(
            dot,
            4.6,
            Paint()
              ..color = AppColors.dark
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SixWheelPainter oldDelegate) {
    return oldDelegate.showDots != showDots ||
        oldDelegate.gapColor != gapColor ||
        !listEquals(oldDelegate.triangles, triangles);
  }
}

/// Triângulo pequeno com o ponto do resultado, para os cartões de detalhe.
class TriangleMini extends StatelessWidget {
  const TriangleMini({required this.triangle, super.key, this.size = 74});

  final TriangleScore triangle;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TriangleMiniPainter(triangle),
      size: Size(size, size),
    );
  }
}

class _TriangleMiniPainter extends CustomPainter {
  _TriangleMiniPainter(this.triangle);

  final TriangleScore triangle;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset apex = Offset(size.width / 2, 4);
    final Offset left = Offset(6, size.height - 6);
    final Offset right = Offset(size.width - 6, size.height - 6);
    final Path path = Path()
      ..moveTo(apex.dx, apex.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = triangle.category.color.withValues(alpha: 0.9),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final List<int> weights = triangle.points;
    if (weights.length >= 3) {
      final double total = weights.fold<double>(0, (sum, value) => sum + value);
      final Offset dot = total == 0
          ? (apex + left + right) / 3
          : (apex * weights[2].toDouble() +
                    right * weights[1].toDouble() +
                    left * weights[0].toDouble()) /
                total;
      canvas.drawCircle(dot, 4, Paint()..color = AppColors.ink);
      canvas.drawCircle(
        dot,
        4,
        Paint()
          ..color = AppColors.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TriangleMiniPainter oldDelegate) =>
      oldDelegate.triangle != triangle;
}
