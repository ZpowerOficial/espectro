import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../data/models.dart' as app_models;
import '../../domain/models/study_models.dart';
import '../../theme.dart';

/// Mapa radial comparativo de 12 eixos que sobrepõe múltiplos perfis de estudo
/// (correntes, personalidades, países ou avaliações) na mesma escala de teia.
class StudyComparativeRadarChart extends StatelessWidget {
  const StudyComparativeRadarChart({
    required this.axes,
    required this.subjects,
    this.colors,
    this.size = 280,
    super.key,
  });

  final List<app_models.Axis> axes;
  final List<StudySubject> subjects;
  final List<Color>? colors;
  final double size;

  Widget _buildLegendItem(
    StudySubject s,
    Color c,
    int index,
    EspectroPalette p,
  ) {
    final hasPhoto = s.photoUrl != null && s.photoUrl!.isNotEmpty;
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: c.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(color: c, width: 1.2),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: hasPhoto
                ? (s.photoUrl!.startsWith('http://') || s.photoUrl!.startsWith('https://')
                    ? Image.network(
                        s.photoUrl!,
                        width: 18,
                        height: 18,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildFallbackInitial(index, name: s.name),
                      )
                    : Image.asset(
                        s.photoUrl!,
                        width: 18,
                        height: 18,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildFallbackInitial(index, name: s.name),
                      ))
                : _buildFallbackInitial(index, name: s.name),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${s.name} (${s.kindLabel})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: p.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFallbackInitial(int index, {String? name}) {
    if (index == 0 || name == 'Você') {
      return const Icon(
        Icons.person_rounded,
        size: 11.5,
        color: Colors.white,
      );
    }
    final initials = (name != null && name.isNotEmpty)
        ? name
            .split(' ')
            .where((s) => s.isNotEmpty)
            .take(2)
            .map((s) => s.characters.first)
            .join()
        : '$index';
    return Text(
      initials,
      style: TextStyle(
        fontSize: initials.length > 1 ? 8.0 : 9.5,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        height: 1.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final List<Color> resolvedColors = colors ?? [
      for (var i = 0; i < subjects.length; i++)
        i == 0
            ? p.accent
            : (i == 1
                ? const Color(0xFF10B981)
                : (i == 2
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF8B5CF6))),
    ];

    return Semantics(
      label:
          'Teia comparativa com 12 eixos e ${subjects.length} perfis sobrepostos.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ComparativeRadarPainter(
              axes: axes,
              subjects: subjects,
              colors: resolvedColors,
              palette: p,
            ),
          ),
          const SizedBox(height: 16),
          // Interactive Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < subjects.length; i++)
                _buildLegendItem(
                  subjects[i],
                  i < resolvedColors.length ? resolvedColors[i] : p.accent,
                  i + 1,
                  p,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComparativeRadarPainter extends CustomPainter {
  const _ComparativeRadarPainter({
    required this.axes,
    required this.subjects,
    required this.colors,
    required this.palette,
  });

  final List<app_models.Axis> axes;
  final List<StudySubject> subjects;
  final List<Color> colors;
  final EspectroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    if (axes.isEmpty) return;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxR = size.shortestSide / 2 - 28;
    if (maxR <= 10) return;

    final Paint ringPaint = Paint()
      ..color = palette.line.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Concentric web rings (25%, 75%, 100%)
    for (final double f in const <double>[0.25, 0.75, 1.0]) {
      canvas.drawCircle(center, maxR * f, ringPaint);
    }

    // 50% neutral center ring (dashed style indicator)
    canvas.drawCircle(
      center,
      maxR * 0.5,
      Paint()
        ..color = palette.muted.withValues(alpha: 0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final int n = axes.length;
    for (var i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / n;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center, center + dir * maxR, ringPaint);

      // Short label around circumference
      final String rawLabel = axes[i].label;
      final String shortLabel = rawLabel.length > 7
          ? '${rawLabel.substring(0, 6)}.'
          : rawLabel;

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

      final Offset labelCenter = center + dir * (maxR + 14);
      tp.paint(
        canvas,
        Offset(labelCenter.dx - tp.width / 2, labelCenter.dy - tp.height / 2),
      );
    }

    // Draw polygons for each subject in reverse order so series 1 is on top
    for (var sIdx = subjects.length - 1; sIdx >= 0; sIdx--) {
      final subject = subjects[sIdx];
      final color = sIdx < colors.length ? colors[sIdx] : palette.accent;
      _drawSubjectPolygon(
        canvas,
        center: center,
        maxR: maxR,
        subject: subject,
        color: color,
        seriesNumber: sIdx + 1,
      );
    }
  }

  void _drawSubjectPolygon(
    Canvas canvas, {
    required Offset center,
    required double maxR,
    required StudySubject subject,
    required Color color,
    required int seriesNumber,
  }) {
    final int n = axes.length;
    final Path poly = Path();
    final List<Offset> pts = <Offset>[];

    for (var i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / n;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      final double? score = subject.axes[axes[i].id];
      final double norm = score == null
          ? 0.5
          : ((score.clamp(-1.0, 1.0) + 1.0) / 2.0).clamp(0.06, 0.96);
      final Offset pt = center + dir * (maxR * norm);
      pts.add(pt);

      if (i == 0) {
        poly.moveTo(pt.dx, pt.dy);
      } else {
        poly.lineTo(pt.dx, pt.dy);
      }
    }
    poly.close();

    // Fill with soft translucent tint
    canvas.drawPath(
      poly,
      Paint()..color = color.withValues(alpha: palette.isDark ? 0.20 : 0.14),
    );

    // Crisp outline stroke
    canvas.drawPath(
      poly,
      Paint()
        ..color = color.withValues(alpha: 0.90)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Glowing vertex dots
    for (var i = 0; i < n; i++) {
      final hasData = subject.axes[axes[i].id] != null;
      if (!hasData) continue;

      canvas.drawCircle(
        pts[i],
        4.0,
        Paint()..color = color,
      );
      canvas.drawCircle(
        pts[i],
        4.0,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ComparativeRadarPainter oldDelegate) {
    return oldDelegate.subjects != subjects ||
        oldDelegate.colors != colors ||
        oldDelegate.palette != palette;
  }
}
