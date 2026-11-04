import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/engine/comparison_engine.dart';
import '../../theme.dart';

/// Gráfico interativo de evolução temporal (`0..100%`) de uma dimensão ao longo
/// do histórico de avaliações, com faixa de incerteza (`±1.96·SE`) e seleção por toque.
class EvolutionLineChart extends StatefulWidget {
  const EvolutionLineChart({
    required this.points,
    required this.topLabel,
    required this.bottomLabel,
    this.height = 190,
    super.key,
  });

  final List<EvolutionPoint> points;
  final String topLabel;
  final String bottomLabel;
  final double height;

  @override
  State<EvolutionLineChart> createState() => _EvolutionLineChartState();
}

class _EvolutionLineChartState extends State<EvolutionLineChart> {
  int? _selectedIndex;

  void _handleTouch(Offset local, double width) {
    if (widget.points.isEmpty) return;
    const double padL = 36.0;
    const double padR = 16.0;
    final double plotW = math.max(1.0, width - padL - padR);
    if (widget.points.length == 1) {
      setState(() => _selectedIndex = 0);
      return;
    }
    final double ratio = ((local.dx - padL) / plotW).clamp(0.0, 1.0);
    final int idx = (ratio * (widget.points.length - 1)).round();
    setState(() => _selectedIndex = idx);
  }

  String _formatDate(DateTime dt) {
    final String d = dt.day.toString().padLeft(2, '0');
    final String m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final int effectiveIndex =
        (_selectedIndex != null && _selectedIndex! < widget.points.length)
        ? _selectedIndex!
        : (widget.points.isEmpty ? -1 : widget.points.length - 1);

    return Semantics(
      label:
          'Gráfico de evolução histórica com ${widget.points.length} avaliações.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '100% ${widget.topLabel}',
                style: text.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: p.poleRight,
                ),
              ),
              if (effectiveIndex >= 0)
                Text(
                  '${_formatDate(widget.points[effectiveIndex].timestamp)} · '
                  '${widget.points[effectiveIndex].label}',
                  style: text.bodySmall?.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return GestureDetector(
                onTapDown: (TapDownDetails d) =>
                    _handleTouch(d.localPosition, constraints.maxWidth),
                onHorizontalDragUpdate: (DragUpdateDetails d) =>
                    _handleTouch(d.localPosition, constraints.maxWidth),
                child: SizedBox(
                  height: widget.height,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _EvolutionPainter(
                      points: widget.points,
                      selectedIndex: effectiveIndex,
                      palette: p,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            '0% ${widget.topLabel} (100% ${widget.bottomLabel})',
            style: text.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: p.poleLeft,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvolutionPainter extends CustomPainter {
  const _EvolutionPainter({
    required this.points,
    required this.selectedIndex,
    required this.palette,
  });

  final List<EvolutionPoint> points;
  final int selectedIndex;
  final EspectroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    const double padL = 34.0;
    const double padR = 14.0;
    const double padT = 10.0;
    const double padB = 14.0;
    final Rect plot = Rect.fromLTRB(
      padL,
      padT,
      size.width - padR,
      size.height - padB,
    );
    if (plot.width <= 0 || plot.height <= 0) return;

    // Linhas horizontais de referência (0%, 50%, 100%).
    for (final int pct in const <int>[0, 50, 100]) {
      final double y = plot.bottom - (pct / 100.0) * plot.height;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        Paint()
          ..color = pct == 50
              ? palette.muted.withValues(alpha: 0.45)
              : palette.line
          ..strokeWidth = pct == 50 ? 1.3 : 1.0,
      );
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: '$pct%',
          style: TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 9.5,
            color: palette.muted,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(2, y - tp.height / 2));
    }

    if (points.isEmpty) return;

    Offset pointAt(int i, double val) {
      final double x = points.length == 1
          ? plot.center.dx
          : plot.left + (i / (points.length - 1)) * plot.width;
      final double y =
          plot.bottom - (val.clamp(0.0, 100.0) / 100.0) * plot.height;
      return Offset(x, y);
    }

    // Faixa de incerteza (±1.96·SE).
    if (points.length >= 2) {
      final Path band = Path();
      for (var i = 0; i < points.length; i++) {
        final double hi = points[i].value + 1.96 * points[i].standardError;
        final Offset pHi = pointAt(i, hi);
        if (i == 0) {
          band.moveTo(pHi.dx, pHi.dy);
        } else {
          band.lineTo(pHi.dx, pHi.dy);
        }
      }
      for (var i = points.length - 1; i >= 0; i--) {
        final double lo = points[i].value - 1.96 * points[i].standardError;
        final Offset pLo = pointAt(i, lo);
        band.lineTo(pLo.dx, pLo.dy);
      }
      band.close();
      canvas.drawPath(
        band,
        Paint()
          ..color = palette.accent.withValues(
            alpha: palette.isDark ? 0.18 : 0.13,
          ),
      );

      final Path line = Path();
      for (var i = 0; i < points.length; i++) {
        final Offset pt = pointAt(i, points[i].value);
        if (i == 0) {
          line.moveTo(pt.dx, pt.dy);
        } else {
          line.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(
        line,
        Paint()
          ..color = palette.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (var i = 0; i < points.length; i++) {
      final Offset pt = pointAt(i, points[i].value);
      final bool isSel = i == selectedIndex;
      if (isSel) {
        canvas.drawLine(
          Offset(pt.dx, plot.top),
          Offset(pt.dx, plot.bottom),
          Paint()
            ..color = palette.accent.withValues(alpha: 0.35)
            ..strokeWidth = 1.2,
        );
      }
      canvas.drawCircle(pt, isSel ? 5.8 : 4.0, Paint()..color = palette.accent);
      canvas.drawCircle(
        pt,
        isSel ? 5.8 : 4.0,
        Paint()
          ..color = palette.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EvolutionPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.palette != palette;
  }
}
