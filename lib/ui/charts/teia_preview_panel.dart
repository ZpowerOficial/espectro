import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/study_models.dart';
import '../../theme.dart';
import '../features/atlas/study_identity.dart';
import '../features/atlas/study_taxonomy.dart';
import 'study_constellation.dart';
import 'teia_cartographic_layer.dart';

/// Painel vivo e interativo da Teia (projeção Nolan das 289 correntes) com
/// envoltórias convexas, retículo calibrado e placa de inspeção ao toque.
class TeiaInteractivePreviewPanel extends StatelessWidget {
  const TeiaInteractivePreviewPanel({
    required this.subjects,
    required this.selected,
    required this.height,
    required this.onSelect,
    required this.onOpenSubject,
    required this.onOpenTeia,
    this.borderColor,
    this.showFooter = true,
    this.headerHint,
    super.key,
  });

  final List<StudySubject> subjects;
  final StudySubject? selected;
  final double height;
  final ValueChanged<StudySubject> onSelect;
  final ValueChanged<String> onOpenSubject;
  final VoidCallback onOpenTeia;
  final Color? borderColor;
  final bool showFooter;
  final String? headerHint;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final Color lineCol = borderColor ?? p.line;
    final Color compassInk =
        p.isDark ? const Color(0xFFE5A64B) : p.accent;
    final List<(StudySubject, Offset)> points = <(StudySubject, Offset)>[
      for (final StudySubject s in subjects)
        if (StudyConstellationGeometry.position(s) case final Offset pt
            when pt.dx <= 800)
          (s, pt),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: lineCol),
            borderRadius: (showFooter && selected != null)
                ? const BorderRadius.vertical(top: Radius.circular(10))
                : BorderRadius.circular(10),
            color: p.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(12, 5, 8, 5),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: lineCol)),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 2,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Projeção Nolan (${points.length} correntes)',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: p.inkSoft,
                          ),
                        ),
                        if (headerHint != null)
                          Text(
                            headerHint!,
                            style: TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontSize: 10.5,
                              color: p.muted,
                            ),
                          ),
                      ],
                    ),
                    TextButton(
                      onPressed: onOpenTeia,
                      style: TextButton.styleFrom(
                        foregroundColor: compassInk,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                      ),
                      child: const Text(
                        'Abrir Teia completa',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: math.max(180.0, height - 56.0),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints box) {
                    final Size size = Size(box.maxWidth, box.maxHeight);
                    return Semantics(
                      label:
                          'Mapa interativo da Teia de Ideias em projeção Nolan com ${points.length} correntes. Toque para inspecionar.',
                      container: true,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (TapDownDetails d) {
                            final double scale = math.min(
                              size.width /
                                  StudyConstellationGeometry.canvasSize.width,
                              size.height /
                                  StudyConstellationGeometry.canvasSize.height,
                            );
                            final Offset offset = Offset(
                              (size.width -
                                      StudyConstellationGeometry
                                              .canvasSize
                                              .width *
                                          scale) /
                                  2,
                              (size.height -
                                      StudyConstellationGeometry
                                              .canvasSize
                                              .height *
                                          scale) /
                                  2,
                            );
                            final Offset scenePos =
                                (d.localPosition - offset) / scale;
                            StudySubject? nearest;
                            double bestDist = 28 / scale;
                            for (final (StudySubject s, Offset pt) in points) {
                              final double dist = (pt - scenePos).distance;
                              if (dist < bestDist) {
                                bestDist = dist;
                                nearest = s;
                              }
                            }
                            if (nearest != null) onSelect(nearest);
                          },
                          child: CustomPaint(
                            painter: TeiaPreviewPainter(
                              points: points,
                              selected: selected,
                              palette: p,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (showFooter && selected != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: lineCol),
                right: BorderSide(color: lineCol),
                bottom: BorderSide(color: lineCol),
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(10),
              ),
              color: p.surfaceMuted.withValues(alpha: p.isDark ? 0.55 : 0.45),
            ),
            child: Row(
              children: <Widget>[
                StudyIdentityAvatar(subject: selected!, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        selected!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: p.ink,
                        ),
                      ),
                      Text(
                        spectrumOf(selected!)?.name ?? selected!.family,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: p.inkSoft),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onOpenSubject(selected!.key),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text('Ver ficha'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Painter compartilhado para prévias estáticas/interativas da Teia fora do
/// `InteractiveViewer` completo (Home e Laboratório de Direção Artística).
class TeiaPreviewPainter extends CustomPainter {
  const TeiaPreviewPainter({
    required this.points,
    required this.selected,
    required this.palette,
  });

  final List<(StudySubject, Offset)> points;
  final StudySubject? selected;
  final EspectroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = math.min(
      size.width / StudyConstellationGeometry.canvasSize.width,
      size.height / StudyConstellationGeometry.canvasSize.height,
    );
    final Offset offset = Offset(
      (size.width - StudyConstellationGeometry.canvasSize.width * scale) / 2,
      (size.height - StudyConstellationGeometry.canvasSize.height * scale) / 2,
    );
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    final List<SpectrumTerritory> territories =
        TeiaCartographicLayer.computeTerritories(
          points,
          isDark: palette.isDark,
        );
    TeiaCartographicLayer.paintGraticule(
      canvas,
      palette,
      scale: 0.95,
      showScaleTicks: true,
    );
    TeiaCartographicLayer.paintTerritories(
      canvas,
      territories,
      palette,
      opacityMultiplier: selected == null ? 1.0 : 0.84,
      showLabels: true,
      zoomScale: 1.0,
      labelOpacity: selected == null ? 1.0 : 0.45,
    );

    final (StudySubject, Offset)? selectedEntry = selected == null
        ? null
        : points.where((e) => e.$1.key == selected!.key).firstOrNull;

    if (selectedEntry != null) {
      final List<(StudySubject, Offset)> sorted = List.of(points)
        ..sort((a, b) => (a.$2 - selectedEntry.$2).distance.compareTo(
              (b.$2 - selectedEntry.$2).distance,
            ));
      final Paint edgePaint = Paint()
        ..color = (spectrumOf(selectedEntry.$1)?.color ?? palette.accent)
            .withValues(alpha: 0.50)
        ..strokeWidth = 1.4;
      for (final (StudySubject, Offset) nb in sorted.skip(1).take(6)) {
        canvas.drawLine(selectedEntry.$2, nb.$2, edgePaint);
      }
    }

    for (final (StudySubject s, Offset pt) in points) {
      final bool isSel = selectedEntry?.$1.key == s.key;
      final Color col = spectrumOf(s)?.color ?? palette.accent;
      canvas.drawCircle(
        pt,
        isSel ? 6.8 : 3.5,
        Paint()..color = isSel ? col : col.withValues(alpha: 0.88),
      );
      if (isSel) {
        canvas.drawCircle(
          pt,
          12.0,
          Paint()
            ..color = col.withValues(alpha: 0.72)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
    }

    if (selectedEntry != null) {
      TeiaCartographicLayer.paintNodeFocusLabel(
        canvas,
        selectedEntry.$2,
        selectedEntry.$1.name,
        spectrumOf(selectedEntry.$1)?.color ?? palette.accent,
        palette,
      );
    }

    canvas.restore();

    // Estende discretamente a linha equatorial e desenha rótulos direcionais
    // legíveis nos 4 polos para eliminar qualquer ambiguidade de polaridade Y.
    final double midY =
        offset.dy + StudyConstellationGeometry.center.dy * scale;
    final double midX =
        offset.dx + StudyConstellationGeometry.center.dx * scale;
    if (offset.dx >= 56) {
      final double leftPlot = offset.dx + 100 * scale;
      final double rightPlot =
          offset.dx +
          (StudyConstellationGeometry.canvasSize.width - 100) * scale;
      final Paint extLine = Paint()
        ..color = palette.line.withValues(alpha: palette.isDark ? 0.34 : 0.48)
        ..strokeWidth = 0.8;
      canvas.drawLine(Offset(14, midY), Offset(leftPlot, midY), extLine);
      canvas.drawLine(
        Offset(rightPlot, midY),
        Offset(size.width - 14, midY),
        extLine,
      );
      _paintAxisEdgeCue(canvas, '← ESQUERDA', Offset(14, midY - 15), 0.0);
      _paintAxisEdgeCue(
        canvas,
        'DIREITA →',
        Offset(size.width - 14, midY - 15),
        1.0,
      );
    } else {
      _paintAxisEdgeCue(canvas, '← ESQ', Offset(8, midY - 14), 0.0);
      _paintAxisEdgeCue(canvas, 'DIR →', Offset(size.width - 8, midY - 14), 1.0);
    }
    _paintAxisEdgeCue(canvas, 'AUTORITARISMO ↑', Offset(midX, 5), 0.5);
    _paintAxisEdgeCue(
      canvas,
      'ANARQUISMO ↓',
      Offset(midX, size.height - 17),
      0.5,
    );
  }

  void _paintAxisEdgeCue(
    Canvas canvas,
    String label,
    Offset anchor,
    double alignFactor,
  ) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 10.5,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w600,
          color: palette.inkSoft.withValues(alpha: 0.82),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final double x = (anchor.dx - tp.width * alignFactor).clamp(
      6.0,
      math.max(6.0, anchor.dx),
    );
    tp.paint(canvas, Offset(x, anchor.dy));
  }

  @override
  bool shouldRepaint(covariant TeiaPreviewPainter oldDelegate) =>
      oldDelegate.selected?.key != selected?.key ||
      oldDelegate.palette != palette ||
      oldDelegate.points.length != points.length;
}
