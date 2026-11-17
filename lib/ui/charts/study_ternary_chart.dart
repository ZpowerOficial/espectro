import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';

/// A composition from an editorial profile, not a set of questionnaire answers.
class StudyTernarySeries {
  const StudyTernarySeries(
    this.label,
    this.values,
    this.color, {
    this.photoUrl,
  });
  final String label;
  final List<double>? values;
  final Color color;
  final String? photoUrl;
}

abstract final class StudyTernaryGeometry {
  static List<Offset> vertices(Size size) {
    final edge = math.min(
      size.width - 56,
      (size.height - 48) * 2 / math.sqrt(3),
    );
    final h = edge * math.sqrt(3) / 2;
    return [
      Offset((size.width - edge) / 2, 24 + h),
      Offset((size.width + edge) / 2, 24 + h),
      Offset(size.width / 2, 24),
    ];
  }

  static bool valid(List<double>? values) =>
      values != null &&
      values.length == 3 &&
      values.every((v) => v.isFinite && v >= 0) &&
      (values.reduce((a, b) => a + b) - 1).abs() < .015;

  static Offset? project(List<double>? values, Size size) {
    if (!valid(values)) return null;
    final vs = vertices(size);
    final sum = values!.reduce((a, b) => a + b);
    return (vs[0] * values[0] + vs[1] * values[1] + vs[2] * values[2]) / sum;
  }

  static List<double>? probe(Offset p, Size size) {
    final v = vertices(size);
    final c = (v[0].dy - p.dy) / (v[0].dy - v[2].dy);
    final b = (p.dx - v[0].dx - c * (v[2].dx - v[0].dx)) / (v[1].dx - v[0].dx);
    final a = 1 - b - c;
    if ([a, b, c].any((x) => x < -1e-8 || x > 1 + 1e-8)) return null;
    return [a.clamp(0, 1), b.clamp(0, 1), c.clamp(0, 1)];
  }
}

/// Shared Atlas/comparison chart. Missing evidence never produces a center pin,
/// engagement ring or error halo. Probing the plane never edits profile values.
class StudyTernaryChart extends StatefulWidget {
  const StudyTernaryChart({
    required this.vertices,
    required this.series,
    this.isOverlaid = false,
    super.key,
  });

  final List<String> vertices;
  final List<StudyTernarySeries> series;
  final bool isOverlaid;

  @override
  State<StudyTernaryChart> createState() => _StudyTernaryChartState();
}

class _StudyTernaryChartState extends State<StudyTernaryChart> {
  List<double>? _probe;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    String composition(List<double> values) => List.generate(
      3,
      (i) => '${widget.vertices[i]} ${(values[i] * 100).round()}%',
    ).join(' · ');

    final present = widget.series
        .where((s) => StudyTernaryGeometry.valid(s.values))
        .toList();

    // Identify dominant vertex for the primary series
    int? dominantIdx;
    int? dominantPct;
    if (present.isNotEmpty && present.first.values != null) {
      final vals = present.first.values!;
      dominantIdx = vals[0] >= vals[1] && vals[0] >= vals[2]
          ? 0
          : (vals[1] >= vals[2] ? 1 : 2);
      dominantPct = (vals[dominantIdx] * 100).round();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dominant pill header (when present and valid)
        if (dominantIdx != null && dominantPct != null && present.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  present.length > 1
                      ? '${present.first.label} (predominante)'
                      : 'Predominância',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: p.inkSoft,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: present.first.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: present.first.color.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Text(
                    '$dominantPct% ${widget.vertices[dominantIdx]}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: present.first.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(
                  constraints.maxWidth,
                  math.min(240, constraints.maxWidth * .8),
                );
                void inspect(Offset point) => setState(
                  () => _probe = StudyTernaryGeometry.probe(point, size),
                );

                return Semantics(
                  image: true,
                  label:
                      'Triângulo: A ${widget.vertices[0]}, B ${widget.vertices[1]}, C ${widget.vertices[2]}. ${present.isEmpty ? 'Sem composição documentada; nenhum ponto atribuído.' : present.map((s) => '${s.label}: ${composition(s.values!)}').join('; ')}',
                  child: GestureDetector(
                    onTapDown: (details) => inspect(details.localPosition),
                    onHorizontalDragUpdate: (details) =>
                        inspect(details.localPosition),
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _StudyTernaryPainter(
                                widget.series,
                                p.line,
                                p.inkSoft,
                                _probe,
                                p.isDark,
                                isOverlaid: widget.isOverlaid,
                              ),
                            ),
                          ),
                          // Overlaid photo/badge knobs on points
                          for (var i = 0; i < widget.series.length; i++)
                            () {
                              final s = widget.series[i];
                              final pt = StudyTernaryGeometry.project(s.values, size);
                              if (pt == null) return const SizedBox.shrink();
                              const markerSize = 22.0;
                              return Positioned(
                                left: pt.dx - markerSize / 2,
                                top: pt.dy - markerSize / 2,
                                child: IgnorePointer(
                                  child: Container(
                                    width: markerSize,
                                    height: markerSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: s.color,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: s.color.withValues(alpha: 0.45),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1.5),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    alignment: Alignment.center,
                                    child: _buildTernaryAvatar(
                                      i,
                                      s.color,
                                      s.photoUrl,
                                      markerSize,
                                      label: s.label,
                                    ),
                                  ),
                                ),
                              );
                            }(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Modern 3-Vertex Proportion Chips
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 320;
            final isMultiOverlaid =
                widget.isOverlaid && widget.series.length > 1;

            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < 3; i++)
                  SizedBox(
                    width: isNarrow
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12) / 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (!isMultiOverlaid &&
                                dominantIdx == i &&
                                present.isNotEmpty)
                            ? present.first.color.withValues(alpha: 0.12)
                            : p.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (!isMultiOverlaid &&
                                  dominantIdx == i &&
                                  present.isNotEmpty)
                              ? present.first.color.withValues(alpha: 0.6)
                              : p.line.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (!isMultiOverlaid &&
                                          dominantIdx == i &&
                                          present.isNotEmpty)
                                      ? present.first.color
                                      : p.inkSoft.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${String.fromCharCode(65 + i)} · ${widget.vertices[i]}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: (!isMultiOverlaid &&
                                            dominantIdx == i)
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: (!isMultiOverlaid &&
                                            dominantIdx == i &&
                                            present.isNotEmpty)
                                        ? present.first.color
                                        : p.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (isMultiOverlaid) ...[
                            // Multi-series breakdown per vertex
                            for (var sIdx = 0;
                                sIdx < widget.series.length;
                                sIdx++) ...[
                              Builder(
                                builder: (_) {
                                  final s = widget.series[sIdx];
                                  final val =
                                      StudyTernaryGeometry.valid(s.values)
                                          ? (s.values![i] * 100).round()
                                          : null;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 15,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            color: s.color,
                                            shape: BoxShape.circle,
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          alignment: Alignment.center,
                                          child: _buildTernaryAvatar(
                                            sIdx,
                                            s.color,
                                            s.photoUrl,
                                            15,
                                            label: s.label,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            val != null ? '$val%' : '—',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: s.color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                            if (widget.series.length == 2 &&
                                StudyTernaryGeometry.valid(
                                    widget.series[0].values) &&
                                StudyTernaryGeometry.valid(
                                    widget.series[1].values)) ...[
                              Builder(
                                builder: (_) {
                                  final d = ((widget.series[1].values![i] -
                                              widget.series[0].values![i]) *
                                          100)
                                      .round();
                                  return Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: p.line.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Δ ${d >= 0 ? '+' : ''}$d pp',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: p.inkSoft,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ] else ...[
                            Text(
                              present.isNotEmpty && present.first.values != null
                                  ? '${(present.first.values![i] * 100).round()}%'
                                  : '—',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: dominantIdx == i && present.isNotEmpty
                                    ? present.first.color
                                    : p.inkSoft,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        const SizedBox(height: 10),

        // Multi-series legend or absence notice
        if (present.isEmpty || widget.series.any((s) => !StudyTernaryGeometry.valid(s.values)) || widget.series.length > 1)
          for (final s in widget.series)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  () {
                    final isUser = widget.series.indexOf(s) == 0 || s.label == 'Você';
                    final hasPhoto = s.photoUrl != null && s.photoUrl!.isNotEmpty;
                    if (hasPhoto || isUser) {
                      return Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.only(right: 8, top: 1),
                        decoration: BoxDecoration(
                          color: s.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: s.color, width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.center,
                        child: _buildTernaryAvatar(
                          widget.series.indexOf(s),
                          s.color,
                          s.photoUrl,
                          26,
                          label: s.label,
                        ),
                      );
                    }
                    return Container(
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(right: 8, top: 1),
                      decoration: BoxDecoration(
                        color: s.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: s.color, width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: _buildFallbackInitial(
                        widget.series.indexOf(s),
                        s.color,
                        26,
                        label: s.label,
                      ),
                    );
                  }(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          StudyTernaryGeometry.valid(s.values)
                              ? composition(s.values!)
                              : 'Sem composição documentada',
                          style: TextStyle(color: p.inkSoft, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

        const SizedBox(height: 4),

        Text(
          _probe == null
              ? 'Toque no triângulo para entender suas proporções.'
              : 'Área explorada: ${composition(_probe!)}. Esta exploração não altera o perfil.',
          style: TextStyle(color: p.inkSoft, fontSize: 11),
        ),
      ],
    );
  }

  static Widget _buildTernaryAvatar(
    int idx,
    Color col,
    String? photoUrl,
    double size, {
    String? label,
  }) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: photoUrl.startsWith('http://') || photoUrl.startsWith('https://')
            ? Image.network(
                photoUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallbackInitial(
                  idx,
                  col,
                  size,
                  label: label,
                ),
              )
            : Image.asset(
                photoUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallbackInitial(
                  idx,
                  col,
                  size,
                  label: label,
                ),
              ),
      );
    }
    return _buildFallbackInitial(idx, col, size, label: label);
  }

  static Widget _buildFallbackInitial(
    int idx,
    Color col,
    double size, {
    String? label,
  }) {
    if (idx == 0 || label == 'Você') {
      return Icon(
        Icons.person_rounded,
        size: size * 0.65,
        color: Colors.white,
      );
    }
    final initials = (label != null && label.isNotEmpty)
        ? label
            .split(' ')
            .where((s) => s.isNotEmpty)
            .take(2)
            .map((s) => s.characters.first)
            .join()
        : '';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: col,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: initials.length > 1 ? size * 0.44 : size * 0.52,
          fontWeight: FontWeight.w900,
          height: 1.0,
        ),
      ),
    );
  }
}

class _StudyTernaryPainter extends CustomPainter {
  _StudyTernaryPainter(
    this.series,
    this.line,
    this.ink,
    this.probe,
    this.isDark, {
    this.isOverlaid = false,
  });

  final List<StudyTernarySeries> series;
  final Color line, ink;
  final List<double>? probe;
  final bool isDark;
  final bool isOverlaid;

  @override
  void paint(Canvas canvas, Size size) {
    final v = StudyTernaryGeometry.vertices(size);
    final outline = Path()
      ..moveTo(v[0].dx, v[0].dy)
      ..lineTo(v[1].dx, v[1].dy)
      ..lineTo(v[2].dx, v[2].dy)
      ..close();

    // Soft tinted triangle surface
    final fillPaint = Paint()
      ..color = (isDark ? const Color(0xFF131D27) : const Color(0xFFF1F5F9))
          .withValues(alpha: 0.55);
    canvas.drawPath(outline, fillPaint);

    // Subtle interior grid lines
    final grid = Paint()
      ..color = line.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 1; i < 5; i++) {
      final t = i / 5;
      for (var axis = 0; axis < 3; axis++) {
        canvas.drawLine(
          Offset.lerp(v[axis], v[(axis + 1) % 3], t)!,
          Offset.lerp(v[axis], v[(axis + 2) % 3], t)!,
          grid,
        );
      }
    }

    // Outer crisp triangle border
    canvas.drawPath(
      outline,
      Paint()
        ..color = line.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Modern vertex badges: A, B, C
    for (var i = 0; i < 3; i++) {
      final badgeCenter = v[i] + Offset(0, i == 2 ? -13 : 13);
      final badgeBg = Paint()
        ..color = (isDark ? const Color(0xFF1E293B) : Colors.white)
            .withValues(alpha: 0.90);
      canvas.drawCircle(badgeCenter, 9, badgeBg);
      canvas.drawCircle(
        badgeCenter,
        9,
        Paint()
          ..color = line.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      final text = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(65 + i),
          style: TextStyle(
            color: ink,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(
        canvas,
        badgeCenter - Offset(text.width / 2, text.height / 2),
      );
    }

    // When overlaid with multiple series, draw connecting spans/area
    if (isOverlaid && series.length > 1) {
      final validPoints = <(Offset, StudyTernarySeries)>[];
      for (final s in series) {
        final pt = StudyTernaryGeometry.project(s.values, size);
        if (pt != null) {
          validPoints.add((pt, s));
        }
      }

      if (validPoints.length == 2) {
        final p0 = validPoints[0].$1;
        final p1 = validPoints[1].$1;

        // Elegant connector line between subjects
        final bridgePaint = Paint()
          ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.35)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p0, p1, bridgePaint);

        // Center delta dot
        final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
        canvas.drawCircle(
          mid,
          3.5,
          Paint()
            ..color = (isDark ? Colors.white70 : Colors.black54),
        );
      } else if (validPoints.length == 3) {
        final p0 = validPoints[0].$1;
        final p1 = validPoints[1].$1;
        final p2 = validPoints[2].$1;
        final poly = Path()
          ..moveTo(p0.dx, p0.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..close();

        canvas.drawPath(
          poly,
          Paint()
            ..color = (isDark ? Colors.cyanAccent : Colors.blueAccent)
                .withValues(alpha: 0.08)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          poly,
          Paint()
            ..color = (isDark ? Colors.white : Colors.black)
                .withValues(alpha: 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }

    // Series Points with glow halo, colored body, and markers
    for (var i = 0; i < series.length; i++) {
      final s = series[i];
      final point = StudyTernaryGeometry.project(s.values, size);
      if (point == null) continue;

      // Glow halo
      canvas.drawCircle(
        point,
        13,
        Paint()..color = s.color.withValues(alpha: .28),
      );
      // Outer colored disk
      canvas.drawCircle(
        point,
        9.5,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.fill,
      );
      // Crisp white ring
      canvas.drawCircle(
        point,
        9.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      if (series.length > 1) {
        if (i == 0 || s.label == 'Você') {
          canvas.drawCircle(point, 3.5, Paint()..color = Colors.white);
        } else {
          final initial = s.label.isNotEmpty
              ? s.label
                  .split(' ')
                  .where((p) => p.isNotEmpty)
                  .take(1)
                  .map((p) => p.characters.first.toUpperCase())
                  .join()
              : '';
          if (initial.isNotEmpty) {
            final textPainter = TextPainter(
              text: TextSpan(
                text: initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              textDirection: TextDirection.ltr,
            )..layout();
            textPainter.paint(
              canvas,
              point - Offset(textPainter.width / 2, textPainter.height / 2),
            );
          } else {
            canvas.drawCircle(point, 3.5, Paint()..color = Colors.white);
          }
        }
      } else {
        canvas.drawCircle(point, 3.5, Paint()..color = Colors.white);
      }
    }

    // Probe point indicator
    if (StudyTernaryGeometry.project(probe, size) case final point?) {
      canvas.drawCircle(
        point,
        5,
        Paint()..color = ink.withValues(alpha: 0.2),
      );
      canvas.drawLine(
        point - const Offset(8, 0),
        point + const Offset(8, 0),
        Paint()
          ..color = ink
          ..strokeWidth = 1.5,
      );
      canvas.drawLine(
        point - const Offset(0, 8),
        point + const Offset(0, 8),
        Paint()
          ..color = ink
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StudyTernaryPainter oldDelegate) => true;
}
