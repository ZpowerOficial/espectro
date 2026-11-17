import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/political_models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// Pino opcional sobreposto no gráfico triangular (ex.: corrente ideológica).
class TriadOverlayPin {
  const TriadOverlayPin({
    required this.id,
    required this.label,
    required this.composition,
  }) : assert(composition.length == 3);

  final String id;
  final String label;
  final List<double> composition;
}

/// Gráfico baricêntrico interativo de uma tríade política.
///
/// Diferenciais:
/// - **Interativo ao toque e arraste**: tocar em qualquer ponto do triângulo
///   inspeciona as coordenadas baricêntricas exatas daquela região e destaca a
///   corrente ideológica mais próxima quando a camada de correntes está ativa.
/// - **Anel de engajamento (`I`)**: codifica o nível de apoio absoluto médio,
///   diferenciando visualmente "apoio amplo" de "ceticismo / rejeição" mesmo no centroide.
/// - **Halo de incerteza**: raio proporcional ao erro-padrão baricêntrico.
/// - **Sobreposição comparativa**: exibe o ponto anterior e o vetor de deslocamento.
class InteractiveTriadChart extends StatefulWidget {
  const InteractiveTriadChart({
    required this.triad,
    this.accentColor,
    this.baselineComposition,
    this.overlayPins = const <TriadOverlayPin>[],
    this.size = 268,
    super.key,
  });

  final TriadDimensionScore triad;
  final Color? accentColor;
  final List<double>? baselineComposition;
  final List<TriadOverlayPin> overlayPins;
  final double size;

  @override
  State<InteractiveTriadChart> createState() => _InteractiveTriadChartState();
}

class _InteractiveTriadChartState extends State<InteractiveTriadChart> {
  List<double>? _probedComposition;
  TriadOverlayPin? _selectedPin;

  // Geometria canônica:
  // v0 = inferior esquerdo, v1 = inferior direito, v2 = topo.
  static ({Offset v0, Offset v1, Offset v2}) _verticesFor(Size size) {
    const double padX = 28.0;
    const double topY = 26.0;
    final double usableW = math.max(40.0, size.width - 2 * padX);
    final double eqHeight = usableW * math.sqrt(3) / 2.0;
    final double maxH = math.max(40.0, size.height - topY - 26.0);
    final double h = math.min(eqHeight, maxH);
    final double w = h * 2.0 / math.sqrt(3);
    final double cx = size.width / 2;
    return (
      v0: Offset(cx - w / 2, topY + h),
      v1: Offset(cx + w / 2, topY + h),
      v2: Offset(cx, topY),
    );
  }

  static Offset _barycentricToPoint(
    List<double> comp,
    ({Offset v0, Offset v1, Offset v2}) tri,
  ) {
    final double sum = comp[0] + comp[1] + comp[2];
    if (sum <= 1e-9) {
      return (tri.v0 + tri.v1 + tri.v2) / 3.0;
    }
    return (tri.v0 * comp[0] + tri.v1 * comp[1] + tri.v2 * comp[2]) / sum;
  }

  static List<double>? _pointToBarycentric(
    Offset pt,
    ({Offset v0, Offset v1, Offset v2}) tri,
  ) {
    final double det =
        (tri.v1.dy - tri.v2.dy) * (tri.v0.dx - tri.v2.dx) +
        (tri.v2.dx - tri.v1.dx) * (tri.v0.dy - tri.v2.dy);
    if (det.abs() < 1e-6) return null;
    double l0 =
        ((tri.v1.dy - tri.v2.dy) * (pt.dx - tri.v2.dx) +
            (tri.v2.dx - tri.v1.dx) * (pt.dy - tri.v2.dy)) /
        det;
    double l1 =
        ((tri.v2.dy - tri.v0.dy) * (pt.dx - tri.v2.dx) +
            (tri.v0.dx - tri.v2.dx) * (pt.dy - tri.v2.dy)) /
        det;
    double l2 = 1.0 - l0 - l1;

    // Permite pequena tolerância de toque nas bordas e projeta no simplex.
    if (l0 < -0.12 || l1 < -0.12 || l2 < -0.12) return null;
    l0 = math.max(0.0, l0);
    l1 = math.max(0.0, l1);
    l2 = math.max(0.0, l2);
    final double sum = l0 + l1 + l2;
    if (sum <= 1e-9) return const <double>[1 / 3, 1 / 3, 1 / 3];
    return <double>[l0 / sum, l1 / sum, l2 / sum];
  }

  void _handleTouch(Offset localPos, Size paintSize) {
    final ({Offset v0, Offset v1, Offset v2}) tri = _verticesFor(paintSize);
    final List<double>? comp = _pointToBarycentric(localPos, tri);
    if (comp == null) return;

    TriadOverlayPin? nearest;
    var bestDist = 28.0; // raio de captura em pixels
    for (final TriadOverlayPin pin in widget.overlayPins) {
      final Offset pinPos = _barycentricToPoint(pin.composition, tri);
      final double d = (pinPos - localPos).distance;
      if (d < bestDist) {
        bestDist = d;
        nearest = pin;
      }
    }

    setState(() {
      _selectedPin = nearest;
      _probedComposition = nearest?.composition ?? comp;
    });
  }

  void _clearProbe() {
    setState(() {
      _probedComposition = null;
      _selectedPin = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final Color accent =
        widget.accentColor ?? p.triadColor(widget.triad.categoryId);

    final List<double> activeComp =
        _probedComposition ?? widget.triad.composition;
    final List<String> verts = widget.triad.vertices;
    int dominantIndex = 0;
    if (activeComp.length >= 3) {
      if (activeComp[1] > activeComp[dominantIndex]) dominantIndex = 1;
      if (activeComp[2] > activeComp[dominantIndex]) dominantIndex = 2;
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxAvailable =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : widget.size;
        final double effectiveSize = math.min(widget.size, maxAvailable);
        final Size canvasSize = Size(effectiveSize, effectiveSize * 0.88);

        return Semantics(
          label:
              'Gráfico triangular de ${widget.triad.label}: ${widget.triad.classification}. '
              'Composição: ${verts[0]} ${(widget.triad.composition[0] * 100).round()}%, '
              '${verts[1]} ${(widget.triad.composition[1] * 100).round()}%, '
              '${verts[2]} ${(widget.triad.composition[2] * 100).round()}%. '
              'Apoio absoluto médio ${(widget.triad.engagement * 100).round()}%. '
              'Cobertura ${(widget.triad.coverage * 100).round()}%, '
              'confiança ${widget.triad.confidenceLabel.toLowerCase()}.'
              '${widget.triad.isIndeterminate ? ' Dimensão indeterminada: a posição é provisória.' : ''}',
          child: Column(
            children: <Widget>[
              if (!widget.triad.isIndeterminate && verts.length >= 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(
                          alpha: p.isDark ? 0.20 : 0.10,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: accent.withValues(
                            alpha: p.isDark ? 0.40 : 0.25,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${(activeComp[dominantIndex] * 100).round()}% ${verts[dominantIndex]}',
                        style: TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTapDown: (TapDownDetails d) =>
                    _handleTouch(d.localPosition, canvasSize),
                onPanUpdate: (DragUpdateDetails d) =>
                    _handleTouch(d.localPosition, canvasSize),
                child: CustomPaint(
                  size: canvasSize,
                  painter: _InteractiveTriadPainter(
                    triad: widget.triad,
                    accent: accent,
                    palette: p,
                    baselineComposition: widget.baselineComposition,
                    overlayPins: widget.overlayPins,
                    selectedPin: _selectedPin,
                    probedComposition: _probedComposition,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: p.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      _probedComposition != null
                          ? Icons.touch_app_rounded
                          : Icons.my_location_rounded,
                      size: 15,
                      color: accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedPin != null
                            ? '${_selectedPin!.label}: '
                                  '${verts[0]} ${(activeComp[0] * 100).round()}% · '
                                  '${verts[1]} ${(activeComp[1] * 100).round()}% · '
                                  '${verts[2]} ${(activeComp[2] * 100).round()}%'
                            : (_probedComposition != null
                                  ? 'Ponto inspecionado: '
                                        '${verts[0]} ${(activeComp[0] * 100).round()}% · '
                                        '${verts[1]} ${(activeComp[1] * 100).round()}% · '
                                        '${verts[2]} ${(activeComp[2] * 100).round()}%'
                                  : 'Você: '
                                        '${verts[0]} ${(activeComp[0] * 100).round()}% · '
                                        '${verts[1]} ${(activeComp[1] * 100).round()}% · '
                                        '${verts[2]} ${(activeComp[2] * 100).round()}%'),
                        style: text.bodySmall?.copyWith(
                          color: p.ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    if (_probedComposition != null)
                      GestureDetector(
                        onTap: _clearProbe,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: p.muted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (verts.length >= 3) ...<Widget>[
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    for (var i = 0; i < 3; i++) ...<Widget>[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: PolePill(
                          label: verts[i],
                          color: accent,
                          isActive: dominantIndex == i && !widget.triad.isIndeterminate,
                          badge: '${(activeComp[i] * 100).round()}%',
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InteractiveTriadPainter extends CustomPainter {
  const _InteractiveTriadPainter({
    required this.triad,
    required this.accent,
    required this.palette,
    required this.baselineComposition,
    required this.overlayPins,
    required this.selectedPin,
    required this.probedComposition,
  });

  final TriadDimensionScore triad;
  final Color accent;
  final EspectroPalette palette;
  final List<double>? baselineComposition;
  final List<TriadOverlayPin> overlayPins;
  final TriadOverlayPin? selectedPin;
  final List<double>? probedComposition;

  @override
  void paint(Canvas canvas, Size size) {
    final ({Offset v0, Offset v1, Offset v2}) tri =
        _InteractiveTriadChartState._verticesFor(size);
    final Path outer = Path()
      ..moveTo(tri.v2.dx, tri.v2.dy)
      ..lineTo(tri.v1.dx, tri.v1.dy)
      ..lineTo(tri.v0.dx, tri.v0.dy)
      ..close();

    // Preenchimento sutil do triângulo.
    canvas.drawPath(
      outer,
      Paint()..color = accent.withValues(alpha: palette.isDark ? 0.11 : 0.07),
    );

    // Malha baricêntrica interna (25%, 50%, 75%) e medianas de divisão regional.
    final Paint gridPaint = Paint()
      ..color = palette.line.withValues(alpha: palette.isDark ? 0.55 : 0.75)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (final double t in const <double>[0.25, 0.5, 0.75]) {
      canvas.drawLine(
        Offset.lerp(tri.v0, tri.v2, t)!,
        Offset.lerp(tri.v1, tri.v2, t)!,
        gridPaint,
      );
      canvas.drawLine(
        Offset.lerp(tri.v0, tri.v1, t)!,
        Offset.lerp(tri.v2, tri.v1, t)!,
        gridPaint,
      );
      canvas.drawLine(
        Offset.lerp(tri.v1, tri.v0, t)!,
        Offset.lerp(tri.v2, tri.v0, t)!,
        gridPaint,
      );
    }

    // Centroide e divisórias das 3 zonas de predomínio.
    final Offset centroid = (tri.v0 + tri.v1 + tri.v2) / 3.0;
    final Paint medianPaint = Paint()
      ..color = accent.withValues(alpha: 0.25)
      ..strokeWidth = 1.1;
    canvas.drawLine(centroid, (tri.v0 + tri.v1) / 2.0, medianPaint);
    canvas.drawLine(centroid, (tri.v1 + tri.v2) / 2.0, medianPaint);
    canvas.drawLine(centroid, (tri.v2 + tri.v0) / 2.0, medianPaint);

    // Contorno principal.
    canvas.drawPath(
      outer,
      Paint()
        ..color = accent.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Pinos opcionais de correntes ideológicas.
    for (final TriadOverlayPin pin in overlayPins) {
      final Offset pos = _InteractiveTriadChartState._barycentricToPoint(
        pin.composition,
        tri,
      );
      final bool isSelected = selectedPin?.id == pin.id;
      canvas.drawCircle(
        pos,
        isSelected ? 5.5 : 3.4,
        Paint()
          ..color = isSelected
              ? palette.poleRight
              : palette.muted.withValues(alpha: 0.65),
      );
      if (isSelected) {
        canvas.drawCircle(
          pos,
          8.5,
          Paint()
            ..color = palette.poleRight
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
    }

    // Ponto comparativo anterior (baseline), se houver.
    final Offset userPos = _InteractiveTriadChartState._barycentricToPoint(
      triad.composition,
      tri,
    );
    if (baselineComposition != null) {
      final Offset basePos = _InteractiveTriadChartState._barycentricToPoint(
        baselineComposition!,
        tri,
      );
      canvas.drawLine(
        basePos,
        userPos,
        Paint()
          ..color = palette.muted
          ..strokeWidth = 1.6,
      );
      canvas.drawCircle(basePos, 4.5, Paint()..color = palette.surface);
      canvas.drawCircle(
        basePos,
        4.5,
        Paint()
          ..color = palette.muted
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }

    // Ponto do usuário: anel de apoio absoluto apenas quando a tríade está
    // determinada; caso contrário, marcador vazado sinaliza composição provisória.
    if (!triad.isIndeterminate) {
      final double sideLen = (tri.v1 - tri.v0).distance;
      final double haloRadius = (triad.standardError * sideLen * 0.55).clamp(
        9.0,
        44.0,
      );
      canvas.drawCircle(
        userPos,
        haloRadius,
        Paint()..color = accent.withValues(alpha: palette.isDark ? 0.20 : 0.15),
      );

      // Anel externo proporcional ao engajamento I (0..1):
      // engajamento alto -> arco completo espesso; baixo -> arco curto e tênue.
      final double ringRadius = 10.5;
      final double sweep = (2 * math.pi * triad.engagement.clamp(0.12, 1.0));
      canvas.drawArc(
        Rect.fromCircle(center: userPos, radius: ringRadius),
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.5 + 2.2 * triad.engagement,
      );

      canvas.drawCircle(userPos, 5.6, Paint()..color = accent);
      canvas.drawCircle(
        userPos,
        5.6,
        Paint()
          ..color = palette.surface
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    } else if (triad.answeredCount > 0) {
      canvas.drawCircle(userPos, 5.6, Paint()..color = palette.surface);
      canvas.drawCircle(
        userPos,
        5.6,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }

    // Mira de inspeção por toque.
    if (probedComposition != null && selectedPin == null) {
      final Offset probePos = _InteractiveTriadChartState._barycentricToPoint(
        probedComposition!,
        tri,
      );
      canvas.drawCircle(
        probePos,
        5.0,
        Paint()
          ..color = palette.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }

    // Rótulos dos 3 vértices (vértices não avaliados são explicitamente marcados).
    _drawLabel(
      canvas,
      text: _vertexLabel(2),
      anchor: Offset(tri.v2.dx, tri.v2.dy - 14),
      align: TextAlign.center,
      maxWidth: size.width * 0.6,
      muted: _isUnobserved(2),
    );
    _drawLabel(
      canvas,
      text: _vertexLabel(0),
      anchor: Offset(tri.v0.dx + 18, tri.v0.dy + 13),
      align: TextAlign.left,
      maxWidth: size.width * 0.44,
      muted: _isUnobserved(0),
    );
    _drawLabel(
      canvas,
      text: _vertexLabel(1),
      anchor: Offset(tri.v1.dx - 18, tri.v1.dy + 13),
      align: TextAlign.right,
      maxWidth: size.width * 0.44,
      muted: _isUnobserved(1),
    );
  }

  bool _isUnobserved(int index) =>
      triad.vertexBreakdownAvailable && !triad.vertexObserved[index];

  String _vertexLabel(int index) => _isUnobserved(index)
      ? '${triad.vertices[index]} (não avaliado)'
      : triad.vertices[index];

  void _drawLabel(
    Canvas canvas, {
    required String text,
    required Offset anchor,
    required TextAlign align,
    required double maxWidth,
    bool muted = false,
  }) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'IBMPlexMono',
          fontSize: 11.5,
          fontWeight: muted ? FontWeight.w500 : FontWeight.w700,
          color: muted ? palette.muted : palette.ink,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    final double dx = switch (align) {
      TextAlign.center => anchor.dx - tp.width / 2,
      TextAlign.right => anchor.dx - tp.width,
      _ => anchor.dx - 18,
    };
    tp.paint(canvas, Offset(dx, anchor.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _InteractiveTriadPainter oldDelegate) {
    return oldDelegate.triad != triad ||
        oldDelegate.accent != accent ||
        oldDelegate.palette != palette ||
        oldDelegate.baselineComposition != baselineComposition ||
        oldDelegate.selectedPin != selectedPin ||
        oldDelegate.probedComposition != probedComposition ||
        oldDelegate.overlayPins.length != overlayPins.length;
  }
}
