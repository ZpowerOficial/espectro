import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/atlas_models.dart';
import '../../theme.dart';

/// Modo de projeção do gráfico bidimensional.
enum NolanChartMode {
  /// Losango original de David Nolan (1969), rotacionado 45°.
  diamond,

  /// Plano cartesiano 2D (bússola política): Esquerda ↔ Direita econômica ×
  /// Autoritário ↔ Libertário civil.
  compass;

  String get label => switch (this) {
    NolanChartMode.diamond => 'Losango de Nolan',
    NolanChartMode.compass => 'Bússola 2D',
  };
}

/// Diagrama de Nolan interativo com alternância para a bússola cartesiana 2D.
///
/// - Marcador do usuário com halo de incerteza de 95% (`±1,96·SE`);
/// - Ponto de referência anterior opcional com vetor de deslocamento `A → B`;
/// - Pinos de referência (correntes, personalidades, partidos, períodos)
///   selecionáveis ao toque, com cartão de inspeção abaixo do gráfico.
class NolanDiagramChart extends StatefulWidget {
  const NolanDiagramChart({
    this.coordinates,
    this.baselineCoordinates,
    this.referencePins = const <NolanReferencePin>[],
    this.pinColor,
    this.initialMode = NolanChartMode.diamond,
    this.showModeSwitch = true,
    this.maxSize = 380,
    this.userLabel = 'Você',
    this.baselineLabel = 'Anterior',
    super.key,
  });

  final NolanCoordinates? coordinates;
  final NolanCoordinates? baselineCoordinates;
  final List<NolanReferencePin> referencePins;
  final Color? pinColor;
  final NolanChartMode initialMode;
  final bool showModeSwitch;
  final double maxSize;
  final String userLabel;
  final String baselineLabel;

  @override
  State<NolanDiagramChart> createState() => _NolanDiagramChartState();
}

class _NolanDiagramChartState extends State<NolanDiagramChart> {
  late NolanChartMode _mode = widget.initialMode;
  NolanReferencePin? _selected;

  @override
  void didUpdateWidget(covariant NolanDiagramChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selected != null &&
        !widget.referencePins.any((p) => p.id == _selected!.id)) {
      _selected = null;
    }
  }

  void _handleTap(Offset local, double side) {
    final _NolanGeometry geo = _NolanGeometry(side: side, mode: _mode);
    NolanReferencePin? best;
    var bestDist = 24.0;
    for (final NolanReferencePin pin in widget.referencePins) {
      final Offset pos = geo.map(pin.economicFreedom, pin.personalFreedom);
      final double d = (pos - local).distance;
      if (d < bestDist) {
        bestDist = d;
        best = pin;
      }
    }
    setState(() => _selected = (best?.id == _selected?.id) ? null : best);
  }

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final Color pinColor = widget.pinColor ?? p.triadColor(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.showModeSwitch) ...<Widget>[
          SegmentedButton<NolanChartMode>(
            showSelectedIcon: false,
            segments: <ButtonSegment<NolanChartMode>>[
              for (final NolanChartMode m in NolanChartMode.values)
                ButtonSegment<NolanChartMode>(
                  value: m,
                  label: Text(
                    m.label,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 12.5,
                    ),
                  ),
                  icon: Icon(
                    m == NolanChartMode.diamond
                        ? Icons.diamond_outlined
                        : Icons.grid_4x4_rounded,
                    size: 16,
                  ),
                ),
            ],
            selected: <NolanChartMode>{_mode},
            onSelectionChanged: (Set<NolanChartMode> s) =>
                setState(() => _mode = s.first),
          ),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double side = math.min(
              widget.maxSize,
              constraints.maxWidth.isFinite ? constraints.maxWidth : 320,
            );
            return Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (TapUpDetails d) => _handleTap(d.localPosition, side),
                child: CustomPaint(
                  size: Size.square(side),
                  painter: _NolanPainter(
                    mode: _mode,
                    palette: p,
                    coordinates: widget.coordinates,
                    baseline: widget.baselineCoordinates,
                    pins: widget.referencePins,
                    pinColor: pinColor,
                    selectedPinId: _selected?.id,
                    userLabel: widget.userLabel,
                    baselineLabel: widget.baselineLabel,
                  ),
                ),
              ),
            );
          },
        ),
        if (_selected != null) ...<Widget>[
          const SizedBox(height: 12),
          _PinInspectionCard(
            pin: _selected!,
            user: widget.coordinates,
            color: pinColor,
            onClose: () => setState(() => _selected = null),
          ),
        ] else if (widget.referencePins.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            'Toque em qualquer ponto para identificar a referência.',
            textAlign: TextAlign.center,
            style: text.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _PinInspectionCard extends StatelessWidget {
  const _PinInspectionCard({
    required this.pin,
    required this.user,
    required this.color,
    required this.onClose,
  });

  final NolanReferencePin pin;
  final NolanCoordinates? user;
  final Color color;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final double? dist = user == null
        ? null
        : math.sqrt(
            math.pow(user!.economicFreedom - pin.economicFreedom, 2) +
                math.pow(user!.personalFreedom - pin.personalFreedom, 2),
          );
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: p.isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(pin.label, style: text.titleMedium),
                const SizedBox(height: 2),
                Text(pin.category, style: text.bodySmall),
                const SizedBox(height: 6),
                Text(
                  'Lib. econômica ${pin.economicFreedom.round()}% · '
                  'Lib. pessoal ${pin.personalFreedom.round()}%'
                  '${dist == null ? '' : ' · distância ${dist.toStringAsFixed(0)} pts'}',
                  style: text.bodySmall?.copyWith(
                    color: p.inkSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pin.quadrantLabel,
                  style: text.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Fechar',
            icon: Icon(Icons.close_rounded, size: 18, color: p.muted),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

/// Geometria compartilhada entre pintura e detecção de toque.
class _NolanGeometry {
  _NolanGeometry({required this.side, required this.mode})
    : margin = mode == NolanChartMode.diamond ? 30.0 : 34.0;

  final double side;
  final NolanChartMode mode;
  final double margin;

  double get half => (side - 2 * margin) / 2;
  Offset get center => Offset(side / 2, side / 2);

  /// Converte (Liberdade Econômica %, Liberdade Pessoal %) em pixels.
  Offset map(double econ, double personal) {
    final double u = (econ / 100.0).clamp(0.0, 1.0);
    final double v = (personal / 100.0).clamp(0.0, 1.0);
    return mapUnit(u, v);
  }

  Offset mapUnit(double u, double v) {
    if (mode == NolanChartMode.diamond) {
      return center + Offset((u - v) * half, -(u + v - 1.0) * half);
    }
    return center + Offset((2 * u - 1) * half, -(2 * v - 1) * half);
  }

  Path polygon(List<(double, double)> unitPoints) {
    final Path path = Path();
    for (var i = 0; i < unitPoints.length; i++) {
      final Offset o = mapUnit(unitPoints[i].$1, unitPoints[i].$2);
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    return path..close();
  }
}

class _NolanPainter extends CustomPainter {
  _NolanPainter({
    required this.mode,
    required this.palette,
    required this.coordinates,
    required this.baseline,
    required this.pins,
    required this.pinColor,
    required this.selectedPinId,
    required this.userLabel,
    required this.baselineLabel,
  });

  final NolanChartMode mode;
  final EspectroPalette palette;
  final NolanCoordinates? coordinates;
  final NolanCoordinates? baseline;
  final List<NolanReferencePin> pins;
  final Color pinColor;
  final String? selectedPinId;
  final String userLabel;
  final String baselineLabel;

  static const double _lo = 0.30;
  static const double _hi = 0.70;

  @override
  void paint(Canvas canvas, Size size) {
    final _NolanGeometry geo = _NolanGeometry(side: size.width, mode: mode);
    final EspectroPalette p = palette;
    final double a = p.isDark ? 0.20 : 0.12;

    final Color cLib = p.triadColor(3);
    final Color cProg = p.poleLeft;
    final Color cCons = p.poleRight;
    final Color cStat = p.triadColor(4);
    final Color cCenter = p.muted;

    // Regiões (quadrantes do quadrado unitário u×v).
    void fillRegion(List<(double, double)> pts, Color c) {
      canvas.drawPath(
        geo.polygon(pts),
        Paint()..color = c.withValues(alpha: a),
      );
    }

    fillRegion(<(double, double)>[
      (0.5, 0.5),
      (1, 0.5),
      (1, 1),
      (0.5, 1),
    ], cLib);
    fillRegion(<(double, double)>[
      (0, 0.5),
      (0.5, 0.5),
      (0.5, 1),
      (0, 1),
    ], cProg);
    fillRegion(<(double, double)>[
      (0.5, 0),
      (1, 0),
      (1, 0.5),
      (0.5, 0.5),
    ], cCons);
    fillRegion(<(double, double)>[
      (0, 0),
      (0.5, 0),
      (0.5, 0.5),
      (0, 0.5),
    ], cStat);

    final Path centerPath = geo.polygon(<(double, double)>[
      (_lo, _lo),
      (_hi, _lo),
      (_hi, _hi),
      (_lo, _hi),
    ]);
    canvas.drawPath(centerPath, Paint()..color = p.surface);
    canvas.drawPath(
      centerPath,
      Paint()..color = cCenter.withValues(alpha: a * 0.9),
    );

    // Grade 25/50/75%.
    final Paint grid = Paint()
      ..color = p.line
      ..strokeWidth = 1.0;
    for (final double t in <double>[0.25, 0.5, 0.75]) {
      canvas.drawLine(geo.mapUnit(t, 0), geo.mapUnit(t, 1), grid);
      canvas.drawLine(geo.mapUnit(0, t), geo.mapUnit(1, t), grid);
    }
    canvas.drawPath(
      centerPath,
      Paint()
        ..color = cCenter.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    // Contorno externo.
    canvas.drawPath(
      geo.polygon(<(double, double)>[(0, 0), (1, 0), (1, 1), (0, 1)]),
      Paint()
        ..color = p.inkSoft.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Rótulos das 5 regiões.
    _regionLabel(canvas, geo.mapUnit(0.84, 0.84), 'LIBERTÁRIO', cLib);
    _regionLabel(canvas, geo.mapUnit(0.16, 0.84), 'PROGRESSISTA', cProg);
    _regionLabel(canvas, geo.mapUnit(0.84, 0.16), 'CONSERVADOR', cCons);
    _regionLabel(canvas, geo.mapUnit(0.16, 0.16), 'ESTATISTA', cStat);
    _regionLabel(canvas, geo.mapUnit(0.5, 0.5), 'CENTRO', p.inkSoft);

    _axisLabels(canvas, geo);

    // Pinos de referência.
    NolanReferencePin? selected;
    for (final NolanReferencePin pin in pins) {
      if (pin.id == selectedPinId) {
        selected = pin;
        continue;
      }
      final Offset pos = geo.map(pin.economicFreedom, pin.personalFreedom);
      canvas.drawCircle(pos, 4.2, Paint()..color = p.surface);
      canvas.drawCircle(
        pos,
        3.4,
        Paint()..color = pinColor.withValues(alpha: 0.85),
      );
    }

    // Avaliação anterior e vetor de deslocamento.
    final NolanCoordinates? user = coordinates;
    final NolanCoordinates? base = baseline;
    if (base != null) {
      final Offset bPos = geo.map(base.economicFreedom, base.personalFreedom);
      if (user != null) {
        final Offset uPos = geo.map(user.economicFreedom, user.personalFreedom);
        _arrow(canvas, bPos, uPos, p.ink.withValues(alpha: 0.75));
      }
      canvas.drawCircle(bPos, 7, Paint()..color = p.surface);
      canvas.drawCircle(
        bPos,
        7,
        Paint()
          ..color = p.inkSoft
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _tag(canvas, bPos + const Offset(0, 16), baselineLabel, p.inkSoft);
    }

    if (user != null) {
      final Offset uPos = geo.map(user.economicFreedom, user.personalFreedom);
      // Halo de incerteza 95%.
      final Path halo = Path();
      const int n = 48;
      for (var i = 0; i <= n; i++) {
        final double t = 2 * math.pi * i / n;
        final double e =
            user.economicFreedom + 1.96 * user.economicSe * math.cos(t);
        final double q =
            user.personalFreedom + 1.96 * user.personalSe * math.sin(t);
        final Offset o = geo.map(e, q);
        if (i == 0) {
          halo.moveTo(o.dx, o.dy);
        } else {
          halo.lineTo(o.dx, o.dy);
        }
      }
      halo.close();
      canvas.drawPath(halo, Paint()..color = p.accent.withValues(alpha: 0.16));
      canvas.drawPath(
        halo,
        Paint()
          ..color = p.accent.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
      canvas.drawCircle(uPos, 9.5, Paint()..color = p.surface);
      canvas.drawCircle(uPos, 7.5, Paint()..color = p.accent);
      canvas.drawCircle(uPos, 2.6, Paint()..color = p.surface);
      _tag(canvas, uPos - const Offset(0, 18), userLabel, p.accent);
    }

    if (selected != null) {
      final Offset pos = geo.map(
        selected.economicFreedom,
        selected.personalFreedom,
      );
      canvas.drawCircle(pos, 8.5, Paint()..color = p.surface);
      canvas.drawCircle(pos, 6.5, Paint()..color = pinColor);
      canvas.drawCircle(
        pos,
        11,
        Paint()
          ..color = pinColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      _tag(canvas, pos + const Offset(0, 18), selected.label, pinColor);
    }
  }

  void _axisLabels(Canvas canvas, _NolanGeometry geo) {
    final EspectroPalette p = palette;
    final TextStyle style = TextStyle(
      fontFamily: 'IBMPlexMono',
      fontSize: 9.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
      color: p.muted,
    );
    if (mode == NolanChartMode.diamond) {
      // Eixo de Liberdade Econômica: aresta inferior direita (base → direita).
      final Offset bottom = geo.mapUnit(0, 0);
      final Offset right = geo.mapUnit(1, 0);
      final Offset left = geo.mapUnit(0, 1);
      _rotatedText(
        canvas,
        'LIBERDADE ECONÔMICA →',
        Offset.lerp(bottom, right, 0.5)! + const Offset(9, 9),
        -math.pi / 4,
        style,
      );
      _rotatedText(
        canvas,
        '← LIBERDADE PESSOAL',
        Offset.lerp(left, bottom, 0.5)! + const Offset(-9, 9),
        math.pi / 4,
        style,
      );
    } else {
      final double s = geo.side;
      _centeredText(canvas, 'LIBERTÁRIO', Offset(s / 2, geo.margin / 2), style);
      _centeredText(
        canvas,
        'AUTORITÁRIO',
        Offset(s / 2, s - geo.margin / 2),
        style,
      );
      _rotatedText(
        canvas,
        'ESQUERDA',
        Offset(geo.margin / 2, s / 2),
        -math.pi / 2,
        style,
      );
      _rotatedText(
        canvas,
        'DIREITA',
        Offset(s - geo.margin / 2, s / 2),
        math.pi / 2,
        style,
      );
    }
  }

  void _regionLabel(Canvas canvas, Offset at, String label, Color color) {
    _centeredText(
      canvas,
      label,
      at,
      TextStyle(
        fontFamily: 'IBMPlexMono',
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: color.withValues(alpha: 0.9),
      ),
    );
  }

  void _centeredText(Canvas canvas, String s, Offset at, TextStyle style) {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  void _rotatedText(
    Canvas canvas,
    String s,
    Offset at,
    double angle,
    TextStyle style,
  ) {
    final TextPainter tp = TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  void _tag(Canvas canvas, Offset at, String label, Color color) {
    final String text = label.length > 28
        ? '${label.substring(0, 27)}…'
        : label;
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'IBMPlexMono',
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: palette.isDark ? const Color(0xFF061318) : Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final double w = tp.width + 12;
    final double h = tp.height + 5;
    double left = at.dx - w / 2;
    left = left.clamp(2.0, math.max(2.0, 2 * at.dx - left - w));
    final RRect r = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, at.dy - h / 2, w, h),
      const Radius.circular(99),
    );
    canvas.drawRRect(r, Paint()..color = color);
    tp.paint(canvas, Offset(left + 6, at.dy - tp.height / 2));
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color color) {
    final Offset d = to - from;
    final double len = d.distance;
    if (len < 12) return;
    final Offset unit = d / len;
    final Offset start = from + unit * 8;
    final Offset end = to - unit * 11;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
    final Offset normal = Offset(-unit.dy, unit.dx);
    final Path head = Path()
      ..moveTo(end.dx + unit.dx * 2, end.dy + unit.dy * 2)
      ..lineTo(
        end.dx - unit.dx * 8 + normal.dx * 5,
        end.dy - unit.dy * 8 + normal.dy * 5,
      )
      ..lineTo(
        end.dx - unit.dx * 8 - normal.dx * 5,
        end.dy - unit.dy * 8 - normal.dy * 5,
      )
      ..close();
    canvas.drawPath(head, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _NolanPainter old) =>
      old.mode != mode ||
      old.palette != palette ||
      old.coordinates != coordinates ||
      old.baseline != baseline ||
      old.pins != pins ||
      old.pinColor != pinColor ||
      old.selectedPinId != selectedPinId;
}
