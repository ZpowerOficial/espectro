import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../domain/engine/atlas_and_nolan_engine.dart';
import '../../domain/models/study_models.dart';
import '../../data/models.dart' as data;
import '../../theme.dart';
import '../features/atlas/study_taxonomy.dart';

/// Stable analytical positions. Animation affects only a faint decorative halo;
/// the plotted point, connections, labels and hit targets never move.
abstract final class StudyConstellationGeometry {
  static const Size canvasSize = Size(880, 880);
  static const Offset center = Offset(440, 440);

  /// Unplaced entries occupy a separate tray outside the analytical square.
  /// Tray positions are UI layout, never coordinates or proximity evidence.
  static List<(StudySubject, Offset)> layout(
    List<StudySubject> subjects, {
    StudyMapProjection projection = const StudyMapProjection(),
  }) {
    final placed = <(StudySubject, Offset)>[];
    final missing = <StudySubject>[];
    for (final subject in subjects) {
      final point = position(subject, projection: projection);
      if (point == null) {
        missing.add(subject);
      } else {
        placed.add((subject, point));
      }
    }
    missing.sort((a, b) => a.key.compareTo(b.key));
    final columns = math.max(1, (missing.length / 30).ceil());
    for (var i = 0; i < missing.length; i++) {
      placed.add((
        missing[i],
        Offset(
          812 + (i % columns + .5) * 64 / columns,
          150 + (i ~/ columns) * 20,
        ),
      ));
    }
    return placed;
  }

  static final Map<String, Offset?> _nolanPosCache = <String, Offset?>{};

  /// Missing economic or civil evidence is omitted rather than placed at 50%.
  static Offset? position(
    StudySubject subject, {
    StudyMapProjection projection = const StudyMapProjection(),
  }) {
    if (projection.isTriad) {
      final comp = subject.triangles[projection.triadId!];
      if (comp == null || comp.length != 3) return null;
      // Barycentric projection onto equilateral triangle
      const v0 = Offset(140, 710);
      const v1 = Offset(740, 710);
      const v2 = Offset(440, 150);
      final sum = comp[0] + comp[1] + comp[2];
      if (sum <= 1e-9) return const Offset(440, 520);
      return (v0 * comp[0] + v1 * comp[1] + v2 * comp[2]) / sum;
    }
    if (!projection.isNolan) {
      final x = subject.axes[projection.xAxisId];
      final y = subject.axes[projection.yAxisId];
      if (x == null || y == null || !x.isFinite || !y.isFinite) return null;
      return center + Offset(x * 340, -y * 340);
    }
    if (subject.record == null && _nolanPosCache.containsKey(subject.key)) {
      return _nolanPosCache[subject.key];
    }
    final hasEconomy =
        const [
          'economia',
          'controle',
          'comercio',
        ].any(subject.axes.containsKey) ||
        const [0, 5].any(subject.triangles.containsKey);
    final hasCivil =
        const [
          'poder',
          'representacao',
          'moral',
          'religiao',
          'diplomacia',
          'imigracao',
          'estrutura',
        ].any(subject.axes.containsKey) ||
        const [1, 2, 4].any(subject.triangles.containsKey);
    if (!hasEconomy || !hasCivil) {
      if (subject.record == null) _nolanPosCache[subject.key] = null;
      return null;
    }
    final coordinates = EspectroNolanEngine.fromRawMaps(
      axes: subject.axes,
      triangles: subject.triangles,
    );
    if (coordinates == null) {
      if (subject.record == null) _nolanPosCache[subject.key] = null;
      return null;
    }
    final economic = coordinates.economicFreedom / 100;
    final civil = coordinates.personalFreedom / 100;
    final pos = center + Offset((economic * 2 - 1) * 340, (civil * 2 - 1) * 340);
    if (subject.record == null) _nolanPosCache[subject.key] = pos;
    return pos;
  }

  static Color familyColor(String family, {required bool dark}) {
    // FNV-like stable hash, independent of process, list order or current filters.
    var hash = 2166136261;
    for (final code in family.codeUnits) {
      hash = ((hash ^ code) * 16777619) & 0x7fffffff;
    }
    return HSLColor.fromAHSL(
      1,
      (hash % 360).toDouble(),
      dark ? .53 : .58,
      dark ? .68 : .38,
    ).toColor();
  }
}

/// Nolan keeps its two composite dimensions. An alternate view projects any
/// two of the twelve observed axes without imputing missing evidence, or
/// projects barycentrically onto one of the six triangles (Tríades).
class StudyMapProjection {
  const StudyMapProjection({
    this.xAxisId,
    this.yAxisId,
    this.triadId,
    this.triadLabel,
    this.triadVertices = const [],
    this.xLabel = 'Liberdade econômica',
    this.yLabel = 'Liberdade civil',
    this.xLow = 'Menor',
    this.xHigh = 'Maior',
    this.yLow = 'Menor',
    this.yHigh = 'Maior',
  });
  factory StudyMapProjection.axes(data.Axis x, data.Axis y) =>
      StudyMapProjection(
        xAxisId: x.id,
        yAxisId: y.id,
        xLabel: x.label,
        yLabel: y.label,
        xLow: x.leftPole,
        xHigh: x.rightPole,
        yLow: y.leftPole,
        yHigh: y.rightPole,
      );
  factory StudyMapProjection.triad({
    required int triadId,
    required String triadLabel,
    required List<String> triadVertices,
  }) =>
      StudyMapProjection(
        triadId: triadId,
        triadLabel: triadLabel,
        triadVertices: triadVertices,
        xLabel: triadVertices.isNotEmpty ? triadVertices[0] : '',
        yLabel: triadVertices.length > 1 ? triadVertices[1] : '',
        xLow: triadVertices.isNotEmpty ? triadVertices[0] : '',
        xHigh: triadVertices.length > 1 ? triadVertices[1] : '',
        yLow: '',
        yHigh: triadVertices.length > 2 ? triadVertices[2] : '',
      );
  final String? xAxisId, yAxisId;
  final int? triadId;
  final String? triadLabel;
  final List<String> triadVertices;
  final String xLabel, yLabel, xLow, xHigh, yLow, yHigh;
  bool get isTriad => triadId != null;
  bool get isNolan => !isTriad && xAxisId == null && yAxisId == null;
}

List<(StudySubject, Offset)> _nearbyPoints(
  List<(StudySubject, Offset)> points,
  String? selectedKey,
) {
  final selected = points.where((p) => p.$1.key == selectedKey).firstOrNull;
  if (selected == null || selected.$2.dx > 800) return [];
  final neighbours =
      points.where((p) => p.$1.key != selectedKey && p.$2.dx <= 800).toList()
        ..sort((a, b) {
          final distance = (a.$2 - selected.$2).distance.compareTo(
            (b.$2 - selected.$2).distance,
          );
          return distance == 0 ? a.$1.key.compareTo(b.$1.key) : distance;
        });
  return neighbours.take(6).toList();
}

/// Claims pointer sequences inside the graph before an ancestor scroll view.
/// Unlike a separate pan detector, one scale recognizer keeps two-finger pinch
/// and trackpad pan/zoom in the same gesture sequence.
class _MapScaleGestureRecognizer extends ScaleGestureRecognizer {
  @override
  void handleEvent(PointerEvent event) {
    super.handleEvent(event);
    if (event is PointerDownEvent || event is PointerPanZoomStartEvent) {
      resolve(GestureDisposition.accepted);
    }
  }
}

class StudyConstellation extends StatefulWidget {
  const StudyConstellation({
    required this.subjects,
    required this.selected,
    required this.onSelected,
    this.onOpen,
    this.expanded = false,
    this.projection = const StudyMapProjection(),
    super.key,
  });

  final List<StudySubject> subjects;
  final StudySubject? selected;
  final ValueChanged<StudySubject> onSelected;
  final ValueChanged<StudySubject>? onOpen;
  final bool expanded;
  final StudyMapProjection projection;

  @override
  State<StudyConstellation> createState() => _StudyConstellationState();
}

class _StudyConstellationState extends State<StudyConstellation>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _breathing = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );
  final TransformationController _camera = TransformationController();
  late final AnimationController _flight =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 420),
      )..addListener(() {
        if (_cameraTween case final Matrix4Tween tween) {
          _camera.value = tween.transform(
            Curves.easeOutCubic.transform(_flight.value),
          );
        }
      });
  Matrix4Tween? _cameraTween;
  ScrollPosition? _scroll;
  Size? _viewport;
  bool _motionPaused = false;
  bool _appVisible = true;
  StudySubject? _hovered;
  final Map<int, Offset> _pointerStarts = {};
  bool _tapCandidate = false;
  double _gestureScale = 1;
  Offset _gestureAnchor = Offset.zero;

  double get _minimumScale => _viewport == null
      ? .2
      : math.min(_viewport!.width / 880, _viewport!.height / 880) * .7;

  void _interruptFlight() {
    _flight.stop();
    _cameraTween = null;
  }

  Matrix4 _cameraAt(double scale, Offset translation) {
    final viewport = _viewport;
    if (viewport == null) return Matrix4.identity();
    // Wide bounds let a pointer move the square at fit scale too; reset is always available.
    final x = translation.dx.clamp(-880 * scale, viewport.width);
    final y = translation.dy.clamp(-880 * scale, viewport.height);
    return Matrix4.identity()
      ..translateByDouble(x, y, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  void _gestureStart(ScaleStartDetails details) {
    _interruptFlight();
    _gestureScale = _camera.value.getMaxScaleOnAxis();
    _gestureAnchor = _camera.toScene(details.localFocalPoint);
  }

  void _gestureUpdate(ScaleUpdateDetails details) {
    final scale = (_gestureScale * details.scale).clamp(_minimumScale, 4.0);
    _camera.value = _cameraAt(
      scale,
      details.localFocalPoint - _gestureAnchor * scale,
    );
  }

  void _pointerDown(PointerDownEvent event) {
    _interruptFlight();
    _tapCandidate = _pointerStarts.isEmpty;
    _pointerStarts[event.pointer] = event.localPosition;
  }

  void _pointerMove(PointerMoveEvent event) {
    final start = _pointerStarts[event.pointer];
    if (start != null && (event.localPosition - start).distance > kTouchSlop) {
      _tapCandidate = false;
    }
  }

  void _pointerUp(PointerUpEvent event) {
    if (_tapCandidate && _pointerStarts.length == 1) {
      _tap(_camera.toScene(event.localPosition));
    }
    _pointerStarts.remove(event.pointer);
    if (_pointerStarts.isEmpty) _tapCandidate = false;
  }

  void _pointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      _interruptFlight();
      final anchor = _camera.toScene(event.localPosition);
      final scale =
          (_camera.value.getMaxScaleOnAxis() *
                  math.exp(-event.scrollDelta.dy / 240))
              .clamp(_minimumScale, 4.0);
      _camera.value = _cameraAt(scale, event.localPosition - anchor * scale);
    });
  }

  late List<(StudySubject, Offset)> _points;
  late List<(Offset, Offset)> _staticEdges;
  late List<_NebulaClusterData> _nebulaClusters;
  bool _geometryInitialized = false;
  bool? _lastGeometryDark;

  void _updateGeometry([bool? isDark]) {
    _points = StudyConstellationGeometry.layout(
      widget.subjects,
      projection: widget.projection,
    );
    final placed = _points.where((p) => p.$2.dx <= 800).toList();
    _staticEdges = _ConstellationPainter.computeStaticEdges(placed);
    final dark = isDark ?? (mounted ? context.palette.isDark : false);
    _nebulaClusters = _ConstellationPainter.computeNebulaClusters(placed, dark);
    _geometryInitialized = true;
    _lastGeometryDark = dark;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dark = context.palette.isDark;
    if (!_geometryInitialized) {
      _updateGeometry(dark);
    } else if (_lastGeometryDark != dark) {
      final placed = _points.where((p) => p.$2.dx <= 800).toList();
      _nebulaClusters = _ConstellationPainter.computeNebulaClusters(placed, dark);
      _lastGeometryDark = dark;
    }
    final scroll = Scrollable.maybeOf(context)?.position;
    if (_scroll != scroll) {
      _scroll?.removeListener(_onScroll);
      _scroll = scroll;
      _scroll?.addListener(_onScroll);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncMotion());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appVisible = state == AppLifecycleState.resumed;
    _syncMotion();
  }

  void _onScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncMotion());
  }

  void _syncMotion() {
    if (!mounted) return;
    final render = context.findRenderObject();
    var visible = true;
    if (render is RenderBox && render.hasSize) {
      final rect = render.localToGlobal(Offset.zero) & render.size;
      visible = rect.overlaps(Offset.zero & MediaQuery.sizeOf(context));
    }
    final hasActive = widget.selected != null || _hovered != null;
    final enabled =
        hasActive &&
        !_motionPaused &&
        _appVisible &&
        visible &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (enabled && !_breathing.isAnimating) {
      _breathing.repeat();
    } else if (!enabled && _breathing.isAnimating) {
      _breathing.stop();
    }
  }

  @override
  void didUpdateWidget(covariant StudyConstellation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subjects != widget.subjects ||
        oldWidget.projection.xAxisId != widget.projection.xAxisId ||
        oldWidget.projection.yAxisId != widget.projection.yAxisId ||
        oldWidget.projection.triadId != widget.projection.triadId) {
      _updateGeometry();
      _interruptFlight();
      if (_viewport case final Size viewport) _fit(viewport);
    }
    if (oldWidget.selected?.key != widget.selected?.key) {
      _syncMotion();
      if (widget.selected != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || widget.selected == null || _viewport == null) return;
          if (!_points.any((p) => p.$1.key == widget.selected!.key)) return;
          final point = StudyConstellationGeometry.position(
            widget.selected!,
            projection: widget.projection,
          );
          if (point == null) return;
          final scale = _camera.value.getMaxScaleOnAxis();
          _flyTo(
            Matrix4.identity()
              ..translateByDouble(
                _viewport!.width / 2 - point.dx * scale,
                _viewport!.height / 2 - point.dy * scale,
                0,
                1,
              )
              ..scaleByDouble(scale, scale, scale, 1),
          );
        });
      }
    }
  }

  void _flyTo(Matrix4 target) {
    _flight.stop();
    if (MediaQuery.disableAnimationsOf(context)) {
      _camera.value = target;
      return;
    }
    _cameraTween = Matrix4Tween(begin: _camera.value.clone(), end: target);
    _flight.forward(from: 0);
  }

  void _fit(Size viewport) {
    _flight.stop();
    _cameraTween = null;
    final scale = math.min(viewport.width / 880, viewport.height / 880);
    final dx = (viewport.width - 880 * scale) / 2;
    final dy = (viewport.height - 880 * scale) / 2;
    _camera.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  void _zoom(double factor) {
    final viewport = _viewport;
    if (viewport == null) return;
    final oldScale = _camera.value.getMaxScaleOnAxis();
    final fit = math.min(viewport.width / 880, viewport.height / 880);
    final scale = (oldScale * factor).clamp(fit * .7, 4.0);
    final anchor = _camera.toScene(
      Offset(viewport.width / 2, viewport.height / 2),
    );
    _flyTo(
      _cameraAt(
        scale,
        Offset(viewport.width / 2, viewport.height / 2) - anchor * scale,
      ),
    );
  }

  void _tap(Offset point) {
    final points = _points;
    final scale = _camera.value.getMaxScaleOnAxis();
    final hits =
        points.where((p) => (p.$2 - point).distance < 24 / scale).toList()
          ..sort(
            (a, b) =>
                (a.$2 - point).distance.compareTo((b.$2 - point).distance),
          );
    if (hits.isEmpty) return;
    // Identical projected coordinates remain individually reachable on repeat taps.
    final nearest = hits.first;
    final coincident = hits
        .where((p) => (p.$2 - nearest.$2).distance < .5)
        .toList();
    final previous = coincident.indexWhere(
      (p) => p.$1.key == widget.selected?.key,
    );
    widget.onSelected(coincident[(previous + 1) % coincident.length].$1);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll?.removeListener(_onScroll);
    _flight.dispose();
    _camera.dispose();
    _breathing.dispose();
    super.dispose();
  }

  Future<void> _choosePoint() async {
    var query = '';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) {
          final normalized = StudyCatalog.normalize(query);
          final subjects = _points
              .map((p) => p.$1)
              .where(
                (s) => StudyCatalog.normalize(
                  '${s.name} ${s.family} ${s.kindLabel}',
                ).contains(normalized),
              )
              .toList();
          return SafeArea(
            child: SizedBox(
              height: math.min(MediaQuery.sizeOf(context).height * .75, 620),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escolher um ponto',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buscar um perfil na teia',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => update(() => query = value),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return ListTile(
                            key: ValueKey('study-map-choice:${subject.key}'),
                            title: Text(subject.name),
                            subtitle: Text(
                              '${subject.kindLabel} · ${subject.family}',
                            ),
                            selected: subject.key == widget.selected?.key,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              widget.onSelected(subject);
                            },
                          );
                        },
                      ),
                    ),
                    if (subjects.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Nenhum ponto encontrado nesta seleção.'),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _legend(BuildContext context, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SpectrumBar(color: color, width: 18, height: 4),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          softWrap: true,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.palette.inkSoft),
        ),
      ),
    ],
  );

  Widget _buildCardinalBadge(String label, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: context.palette.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.palette.line.withValues(alpha: 0.85),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: context.palette.isDark ? 0.35 : 0.06,
                ),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: context.palette.inkSoft,
            ),
          ),
        ),
      ),
    );
  }

  Widget _canvas() => LayoutBuilder(
    builder: (context, constraints) {
      final viewport = constraints.biggest;
      if (_viewport != viewport) {
        _viewport = viewport;
        _fit(viewport);
      }
      final viewer = InteractiveViewer(
        key: const ValueKey('study-constellation-viewer'),
        transformationController: _camera,
        constrained: false,
        boundaryMargin: const EdgeInsets.all(300),
        minScale: _minimumScale,
        maxScale: 4,
        panEnabled: false,
        scaleEnabled: false,
        child: Semantics(
          image: true,
          label:
              'Teia de ideias. Use Buscar e filtrar para selecionar qualquer perfil, inclusive pontos sobrepostos. A área Sem posição não representa coordenadas políticas.',
          child: CustomPaint(
            size: StudyConstellationGeometry.canvasSize,
            painter: _ConstellationPainter(
              points: _points,
              staticEdges: _staticEdges,
              nebulaClusters: _nebulaClusters,
              selectedKey: widget.selected?.key,
              hoveredKey: _hovered?.key,
              palette: context.palette,
              animation: _breathing,
              camera: _camera,
              projection: widget.projection,
              viewportSize: viewport,
            ),
          ),
        ),
      );
      final gestures = MouseRegion(
        cursor: _hovered != null ? SystemMouseCursors.click : SystemMouseCursors.grab,
        onHover: (event) {
          final local = _camera.toScene(event.localPosition);
          final scale = _camera.value.getMaxScaleOnAxis();
          final hit = _points
              .where((p) => (p.$2 - local).distance < 20 / scale)
              .firstOrNull
              ?.$1;
          if (hit?.key != _hovered?.key) {
            setState(() => _hovered = hit);
            _syncMotion();
          }
        },
        onExit: (_) {
          if (_hovered != null) {
            setState(() => _hovered = null);
            _syncMotion();
          }
        },
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _pointerDown,
          onPointerMove: _pointerMove,
          onPointerUp: _pointerUp,
          onPointerCancel: (event) {
            _pointerStarts.remove(event.pointer);
            _tapCandidate = false;
          },
          onPointerSignal: _pointerSignal,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: <Type, GestureRecognizerFactory>{
              _MapScaleGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                    _MapScaleGestureRecognizer
                  >(_MapScaleGestureRecognizer.new, (recognizer) {
                    recognizer.onStart = _gestureStart;
                    recognizer.onUpdate = _gestureUpdate;
                  }),
            },
            child: viewer,
          ),
        ),
      );

      return Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(child: gestures),
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  if (widget.projection.isTriad &&
                      widget.projection.triadVertices.length == 3) ...[
                    _buildCardinalBadge(
                      '${widget.projection.triadVertices[2].toUpperCase()} ↑',
                      Alignment.topCenter,
                    ),
                    _buildCardinalBadge(
                      '← ${widget.projection.triadVertices[0].toUpperCase()}',
                      Alignment.bottomLeft,
                    ),
                    _buildCardinalBadge(
                      '${widget.projection.triadVertices[1].toUpperCase()} →',
                      Alignment.bottomRight,
                    ),
                  ] else ...[
                    _buildCardinalBadge(
                      widget.projection.isNolan
                          ? 'AUTORITARISMO ↑'
                          : '${widget.projection.yHigh.toUpperCase()} ↑',
                      Alignment.topCenter,
                    ),
                    _buildCardinalBadge(
                      widget.projection.isNolan
                          ? 'ANARQUISMO ↓'
                          : '${widget.projection.yLow.toUpperCase()} ↓',
                      Alignment.bottomCenter,
                    ),
                    _buildCardinalBadge(
                      widget.projection.isNolan
                          ? '← ESQUERDA'
                          : '← ${widget.projection.xLow.toUpperCase()}',
                      Alignment.centerLeft,
                    ),
                    _buildCardinalBadge(
                      widget.projection.isNolan
                          ? 'DIREITA →'
                          : '${widget.projection.xHigh.toUpperCase()} →',
                      Alignment.centerRight,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final points = _points;
    final omitted = points.where((p) => p.$2.dx > 800).length;
    final neighbours = _nearbyPoints(points, widget.selected?.key);
    final selectedSubject = points
        .where((p) => p.$1.key == widget.selected?.key)
        .firstOrNull
        ?.$1;
    final visibleSpectra = studySpectra
        .where(
          (spectrum) =>
              points.any((p) => spectrumOf(p.$1)?.name == spectrum.name),
        )
        .toList();
    final hasOther = points.any((p) => spectrumOf(p.$1) == null);
    if (widget.expanded) {
      return Stack(
        key: const ValueKey('study-map-full-canvas'),
        children: [
          Positioned.fill(child: _canvas()),
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              decoration: BoxDecoration(
                color: palette.surface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.line),
                boxShadow: EspectroElevation.cardShadows(palette),
              ),
              child: Material(
                type: MaterialType.transparency,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Aumentar zoom',
                      onPressed: () => _zoom(1.4),
                      icon: const Icon(Icons.add),
                    ),
                    IconButton(
                      tooltip: 'Diminuir zoom',
                      onPressed: () => _zoom(1 / 1.4),
                      icon: const Icon(Icons.remove),
                    ),
                    IconButton(
                      tooltip: 'Reenquadrar teia',
                      onPressed: () {
                        if (_viewport case final Size v) _fit(v);
                      },
                      icon: const Icon(Icons.center_focus_strong),
                    ),
                    IconButton(
                      tooltip: _motionPaused
                          ? 'Ativar movimento sutil'
                          : 'Pausar movimento',
                      onPressed: () {
                        setState(() => _motionPaused = !_motionPaused);
                        _syncMotion();
                      },
                      icon: Icon(_motionPaused ? Icons.play_arrow : Icons.pause),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: palette.surface,
            border: Border.all(color: palette.line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'TEIA DE IDEIAS',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: palette.inkSoft),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Diminuir zoom',
                      onPressed: () => _zoom(1 / 1.4),
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    IconButton(
                      tooltip: 'Aumentar zoom',
                      onPressed: () => _zoom(1.4),
                      icon: const Icon(Icons.add_rounded),
                    ),
                    IconButton(
                      tooltip: 'Reenquadrar teia',
                      onPressed: () {
                        if (_viewport case final Size size) _fit(size);
                      },
                      icon: const Icon(Icons.center_focus_strong_rounded),
                    ),
                    IconButton(
                      tooltip: _motionPaused
                          ? 'Ativar movimento sutil'
                          : 'Pausar movimento',
                      onPressed: () {
                        setState(() => _motionPaused = !_motionPaused);
                        _syncMotion();
                      },
                      icon: Icon(
                        _motionPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              if (points.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: palette.surfaceMuted.withValues(alpha: .6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height:
                              MediaQuery.textScalerOf(context).scale(15) * 3,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              selectedSubject?.name ??
                                  'Selecione um ponto para explorar',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.fontFamily,
                                color: palette.ink,
                                fontSize: 15,
                                height: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              key: const ValueKey('study-map-choose'),
                              onPressed: _choosePoint,
                              icon: const Icon(
                                Icons.touch_app_outlined,
                                size: 18,
                              ),
                              label: const Text('Escolher ponto'),
                            ),
                            if (widget.onOpen != null)
                              FilledButton.icon(
                                key: const ValueKey('study-map-open-profile'),
                                onPressed: selectedSubject == null
                                    ? null
                                    : () => widget.onOpen!(selectedSubject),
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                                label: const Text('Abrir perfil'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(
                height: MediaQuery.sizeOf(context).width < 600 ? 390 : 500,
                child: _canvas(),
              ),
              if (neighbours.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nesta vizinhança 2D',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Selecione uma conexão para continuar explorando.',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: context.palette.inkSoft),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final (subject, _) in neighbours)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth,
                                ),
                                child: ActionChip(
                                  key: ValueKey(
                                    'study-neighbour:${subject.key}',
                                  ),
                                  tooltip: 'Selecionar ${subject.name} na teia',
                                  avatar: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          spectrumOf(subject)?.color ??
                                          palette.accent,
                                    ),
                                  ),
                                  label: Text(
                                    subject.name,
                                    softWrap: true,
                                    style: TextStyle(
                                      color: palette.ink,
                                      fontSize: 13,
                                    ),
                                  ),
                                  backgroundColor: palette.surfaceMuted
                                      .withValues(alpha: .5),
                                  side: BorderSide(color: palette.line),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 8,
                                  ),
                                  onPressed: () => widget.onSelected(subject),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Text(
                  'Arraste para explorar · amplie para separar os pontos · toque para conectar ideias',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: context.palette.inkSoft),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            for (final spectrum in visibleSpectra)
              _legend(context, spectrum.name, spectrum.color),
            if (hasOther) _legend(context, 'Outros verbetes', palette.accent),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Projeção quadrada: ${widget.projection.xLabel} e ${widget.projection.yLabel}. '
          'As linhas mostram vizinhança nesta projeção, não influência histórica.'
          '${omitted == 0 ? '' : ' $omitted perfis sem base suficiente aparecem na área Sem posição, fora do quadrado.'}',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: context.palette.inkSoft),
        ),
      ],
    );
  }
}

class _NebulaClusterData {
  const _NebulaClusterData({
    required this.centroid,
    required this.radius,
    required this.specColor,
    required this.textColor,
    required this.name,
  });

  final Offset centroid;
  final double radius;
  final Color specColor;
  final Color textColor;
  final String name;
}

class _ConstellationPainter extends CustomPainter {
  _ConstellationPainter({
    required this.points,
    required this.selectedKey,
    this.hoveredKey,
    required this.palette,
    required this.animation,
    required this.camera,
    required this.projection,
    this.viewportSize,
    List<(Offset, Offset)>? staticEdges,
    List<_NebulaClusterData>? nebulaClusters,
  })  : staticEdges = staticEdges ??
            computeStaticEdges(points.where((p) => p.$2.dx <= 800).toList()),
        nebulaClusters = nebulaClusters ??
            computeNebulaClusters(
              points.where((p) => p.$2.dx <= 800).toList(),
              palette.isDark,
            ),
        super(repaint: Listenable.merge([animation, camera]));

  final List<(StudySubject, Offset)> points;
  final List<(Offset, Offset)> staticEdges;
  final List<_NebulaClusterData> nebulaClusters;
  final String? selectedKey;
  final String? hoveredKey;
  final EspectroPalette palette;
  final Animation<double> animation;
  final TransformationController camera;
  final StudyMapProjection projection;
  final Size? viewportSize;

  double get _screenScale => camera.value.getMaxScaleOnAxis().clamp(.01, 4.0);

  String? _lastActiveNeighbourKey;
  List<(StudySubject, Offset)> _cachedActiveNeighbours = const [];

  List<(StudySubject, Offset)> _getActiveNeighbours(
    List<(StudySubject, Offset)> placedPoints,
    String? activeKey,
  ) {
    if (activeKey == null) return const [];
    if (activeKey == _lastActiveNeighbourKey) return _cachedActiveNeighbours;
    _lastActiveNeighbourKey = activeKey;
    _cachedActiveNeighbours = _nearbyPoints(placedPoints, activeKey);
    return _cachedActiveNeighbours;
  }

  static const _tier1Anchors = {
    'current:anarcocapitalismo',
    'current:liberalismo-classico',
    'current:social-democracia',
    'current:marxismo-leninismo',
    'current:fascismo',
    'current:conservadorismo-tradicional',
    'current:anarquismo-classico',
    'current:democracia-crista',
    'current:ecologismo-politico',
    'current:socialismo-democratico',
    'current:monarquismo-constitucional',
    'current:neoliberalismo',
    'current:nacional-bolchevismo',
    'current:distributismo',
    'current:minarquismo',
    'current:comunismo-de-conselhos',
    'current:nacional-conservadorismo',
    'current:criptoanarquismo',
    'current:transhumanismo-democratico',
    'current:mutualismo',
    'current:ordoliberalismo',
    'current:socialismo-libertario',
  };

  static List<_NebulaClusterData> computeNebulaClusters(
    List<(StudySubject, Offset)> placedPoints,
    bool isDark,
  ) {
    final clusters = <_NebulaClusterData>[];
    for (final spec in studySpectra) {
      final cluster = placedPoints
          .where((p) => spectrumOf(p.$1)?.id == spec.id)
          .map((p) => p.$2)
          .toList();
      if (cluster.isEmpty) continue;
      final avgX =
          cluster.map((p) => p.dx).reduce((a, b) => a + b) / cluster.length;
      final avgY =
          cluster.map((p) => p.dy).reduce((a, b) => a + b) / cluster.length;
      final centroid = Offset(avgX, avgY);
      final radius = math.max(
        110.0,
        math.min(210.0, 45.0 + cluster.length * 3.8),
      );
      clusters.add(
        _NebulaClusterData(
          centroid: centroid,
          radius: radius,
          specColor: spec.color,
          textColor: spec.ink(isDark),
          name: spec.name,
        ),
      );
    }
    return clusters;
  }

  static List<(Offset, Offset)> computeStaticEdges(
    List<(StudySubject, Offset)> placedPoints,
  ) {
    final edges = <(Offset, Offset)>[];
    final corePoints = placedPoints
        .where(
          (p) =>
              p.$1.kind == 'current' ||
              _tier1Anchors.contains(p.$1.key),
        )
        .toList();
    final sourcePoints = corePoints.length >= 10 ? corePoints : placedPoints;

    final pointsBySpectrum = <String, List<(StudySubject, Offset)>>{};
    for (final p in sourcePoints) {
      final spec = spectrumOf(p.$1)?.id ?? 'other';
      (pointsBySpectrum[spec] ??= []).add(p);
    }

    // Intra-spectrum connections: connect proximate nodes of same spectrum
    for (final cluster in pointsBySpectrum.values) {
      for (var i = 0; i < cluster.length; i++) {
        final p1 = cluster[i];
        var connections = 0;
        for (var j = i + 1; j < cluster.length; j++) {
          final p2 = cluster[j];
          final dist = (p1.$2 - p2.$2).distance;
          if (dist < 125) {
            edges.add((p1.$2, p2.$2));
            connections++;
            if (connections >= 2) break;
          }
        }
      }
    }

    // Adjacent-spectrum bridges (connect very close nodes across different spectra)
    for (var i = 0; i < sourcePoints.length; i += 2) {
      final p1 = sourcePoints[i];
      final s1 = spectrumOf(p1.$1)?.id;
      for (var j = i + 1; j < sourcePoints.length; j += 2) {
        final p2 = sourcePoints[j];
        final s2 = spectrumOf(p2.$1)?.id;
        if (s1 != s2) {
          final dist = (p1.$2 - p2.$2).distance;
          if (dist < 65) {
            edges.add((p1.$2, p2.$2));
            break;
          }
        }
      }
    }
    return edges;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Canvas background: transparent so the constellation blends seamlessly
    final placedPoints = points.where((p) => p.$2.dx <= 800).toList();

    // 2. Atmospheric Nebula Clouds per ideological spectrum (precomputed)
    for (final nebula in nebulaClusters) {
      final nebulaPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            nebula.specColor.withValues(alpha: palette.isDark ? 0.20 : 0.12),
            nebula.specColor.withValues(alpha: palette.isDark ? 0.06 : 0.03),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(
          Rect.fromCircle(center: nebula.centroid, radius: nebula.radius),
        );
      canvas.drawCircle(nebula.centroid, nebula.radius, nebulaPaint);

      // Subtle uppercase cluster name
      _text(
        canvas,
        nebula.name.toUpperCase(),
        nebula.centroid,
        nebula.textColor.withValues(alpha: 0.45),
        11.5,
      );
    }

    // 3. Subtle guidelines (Crosshairs for Cartesian projections; Triangle outline for Tríades)
    if (projection.isTriad) {
      const v0 = Offset(140, 710);
      const v1 = Offset(740, 710);
      const v2 = Offset(440, 150);
      final triPath = Path()
        ..moveTo(v0.dx, v0.dy)
        ..lineTo(v1.dx, v1.dy)
        ..lineTo(v2.dx, v2.dy)
        ..close();
      canvas.drawPath(
        triPath,
        Paint()
          ..color = (palette.isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFCBD5E1))
              .withValues(alpha: 0.38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 / _screenScale,
      );
      final triGrid = Paint()
        ..color = (palette.isDark
                ? const Color(0xFF334155)
                : const Color(0xFFCBD5E1))
            .withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 / _screenScale;
      for (var i = 1; i < 4; i++) {
        final t = i / 4.0;
        canvas.drawLine(
          Offset.lerp(v0, v1, t)!,
          Offset.lerp(v0, v2, t)!,
          triGrid,
        );
        canvas.drawLine(
          Offset.lerp(v1, v0, t)!,
          Offset.lerp(v1, v2, t)!,
          triGrid,
        );
        canvas.drawLine(
          Offset.lerp(v2, v0, t)!,
          Offset.lerp(v2, v1, t)!,
          triGrid,
        );
      }
    } else {
      final crossPaint = Paint()
        ..color = (palette.isDark
                ? const Color(0xFF334155)
                : const Color(0xFFCBD5E1))
            .withValues(alpha: 0.28)
        ..strokeWidth = 1.0 / _screenScale;
      canvas.drawLine(
        const Offset(40, 440),
        const Offset(840, 440),
        crossPaint,
      );
      canvas.drawLine(
        const Offset(440, 40),
        const Offset(440, 840),
        crossPaint,
      );
    }

    // Unplaced / Sem posição tray
    if (points.any((p) => p.$2.dx > 800)) {
      final trayRect = const Rect.fromLTWH(806, 100, 72, 680);
      canvas.drawRRect(
        RRect.fromRectAndRadius(trayRect, const Radius.circular(8)),
        Paint()
          ..color = (palette.isDark ? const Color(0xFF1E293B) : Colors.white)
              .withValues(alpha: 0.75)
          ..style = PaintingStyle.fill,
      );
      _text(
        canvas,
        'Sem posição',
        const Offset(842, 117),
        palette.inkSoft,
        9,
        background: palette.surface,
      );
    }

    final activeKey = selectedKey ?? hoveredKey;
    final activeSubject =
        placedPoints.where((p) => p.$1.key == activeKey).firstOrNull;
    final activeNeighbours = _getActiveNeighbours(placedPoints, activeKey);

    // 4. Precomputed constellation network edges (zero O(N^2) calculations per frame)
    final bgEdgePaint = Paint()
      ..color = (palette.isDark
              ? const Color(0xFF334155)
              : const Color(0xFFCBD5E1))
          .withValues(alpha: activeKey == null ? 0.32 : 0.12)
      ..strokeWidth = 0.85 / _screenScale;

    for (final edge in staticEdges) {
      canvas.drawLine(edge.$1, edge.$2, bgEdgePaint);
    }

    // 5. Active dynamic connections for selected/hovered node
    if (activeSubject != null) {
      final activeColor =
          spectrumOf(activeSubject.$1)?.color ?? palette.accent;
      final pulsePhase = animation.value;

      final glowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.26)
        ..strokeWidth =
            (5.0 + 1.8 * math.sin(pulsePhase * math.pi * 2)) / _screenScale
        ..strokeCap = StrokeCap.round;

      final sharpPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.92)
        ..strokeWidth = 2.0 / _screenScale
        ..strokeCap = StrokeCap.round;

      final pulseDotPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.92);

      for (final neighbour in activeNeighbours) {
        canvas.drawLine(activeSubject.$2, neighbour.$2, glowPaint);
        canvas.drawLine(activeSubject.$2, neighbour.$2, sharpPaint);

        // Responsive traveling energy pulse dot along active connection
        final t = (pulsePhase * 2.8) % 1.0;
        final pulsePos = Offset.lerp(activeSubject.$2, neighbour.$2, t)!;
        canvas.drawCircle(
          pulsePos,
          2.8 / _screenScale,
          pulseDotPaint,
        );
      }

      // Breathing halo on active star
      final haloRadius =
          (20.0 + 3.5 * math.sin(pulsePhase * math.pi * 2)) / _screenScale;
      canvas.drawCircle(
        activeSubject.$2,
        haloRadius,
        Paint()..color = activeColor.withValues(alpha: 0.18),
      );
    }

    // Viewport visible bounds for culling offscreen elements
    final vp = viewportSize ?? size;
    final visibleBounds = Rect.fromPoints(
      camera.toScene(Offset.zero),
      camera.toScene(Offset(vp.width, vp.height)),
    ).inflate(40.0);

    // 6. Node stars / points (using reusable paints to eliminate GC thrashing)
    final nodeFillPaint = Paint()..style = PaintingStyle.fill;
    final nodeStrokePaint = Paint()..style = PaintingStyle.stroke;
    final activeNeighbourKeys = activeNeighbours.map((p) => p.$1.key).toSet();

    for (final (subject, point) in points) {
      final isSelected = subject.key == selectedKey;
      final isHovered = subject.key == hoveredKey;
      final isActive = isSelected || isHovered;
      final isNeighbour = activeNeighbourKeys.contains(subject.key);

      // Viewport culling for distant offscreen stars
      if (!isActive && !isNeighbour && !visibleBounds.contains(point)) {
        continue;
      }

      final isAnchor = _tier1Anchors.contains(subject.key);
      final color = spectrumOf(subject)?.color ?? palette.accent;

      if (activeKey != null) {
        if (isActive) {
          // Double concentric ring
          nodeStrokePaint
            ..color = color
            ..strokeWidth = 2.2 / _screenScale;
          canvas.drawCircle(point, 13 / _screenScale, nodeStrokePaint);
          nodeFillPaint.color = color;
          canvas.drawCircle(point, 6.5 / _screenScale, nodeFillPaint);
        } else if (isNeighbour) {
          // Highlighted neighbour
          nodeFillPaint.color = color.withValues(alpha: 0.24);
          canvas.drawCircle(point, 9.0 / _screenScale, nodeFillPaint);
          nodeFillPaint.color = color;
          canvas.drawCircle(point, 5.2 / _screenScale, nodeFillPaint);
        } else {
          // Dimmed background node
          nodeFillPaint.color = color.withValues(alpha: 0.22);
          canvas.drawCircle(point, 3.0 / _screenScale, nodeFillPaint);
        }
      } else {
        // Idle constellation state
        if (isAnchor) {
          nodeFillPaint.color = color.withValues(alpha: 0.20);
          canvas.drawCircle(point, 8.0 / _screenScale, nodeFillPaint);
          nodeFillPaint.color = color.withValues(alpha: 0.95);
          canvas.drawCircle(point, 5.0 / _screenScale, nodeFillPaint);
        } else {
          nodeFillPaint.color = color.withValues(alpha: 0.15);
          canvas.drawCircle(point, 6.5 / _screenScale, nodeFillPaint);
          nodeFillPaint.color = color.withValues(alpha: 0.88);
          canvas.drawCircle(point, 3.8 / _screenScale, nodeFillPaint);
        }
      }
    }

    // 7. Anti-collision label allocation with visual hierarchy
    final allocatedBoxes = <Rect>[];

    void tryDrawLabel({
      required (StudySubject, Offset) entry,
      required Color textColor,
      required Color bgColor,
      required double fontSize,
      required bool isPriority,
    }) {
      final (subject, point) = entry;
      // Skip if offscreen or if quota reached (unless priority)
      if (!isPriority &&
          (!visibleBounds.contains(point) || allocatedBoxes.length >= 32)) {
        return;
      }

      final painter = TextPainter(
        text: TextSpan(
          text: subject.name,
          style: TextStyle(
            color: textColor,
            fontFamily: 'IBMPlexSans',
            fontSize: fontSize / _screenScale,
            fontWeight: isPriority ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: math.min(260 / _screenScale, 864));

      final w = painter.width;
      final h = painter.height;

      // 4 candidate placement offsets relative to node center
      final candidates = [
        Offset(-w / 2, 12 / _screenScale), // below
        Offset(-w / 2, -(h + 12 / _screenScale)), // above
        Offset(12 / _screenScale, -h / 2), // right
        Offset(-(w + 12 / _screenScale), -h / 2), // left
      ];

      Rect? chosenBox;
      Offset? chosenOffset;

      for (final cand in candidates) {
        final candTopLeft = point + cand;
        final candOffset = Offset(
          candTopLeft.dx.clamp(8.0, 872.0 - w),
          candTopLeft.dy.clamp(8.0, 872.0 - h),
        );
        final box = candOffset & Size(w, h);
        final collides = allocatedBoxes.any(
          (existing) => existing.inflate(3.0 / _screenScale).overlaps(box),
        );
        if (!collides) {
          chosenBox = box;
          chosenOffset = candOffset;
          break;
        }
      }

      if (chosenBox == null && isPriority) {
        // Force placement for priority (selected/hovered)
        final candOffset = Offset(
          (point.dx - w / 2).clamp(8.0, 872.0 - w),
          (point.dy + 14 / _screenScale).clamp(8.0, 872.0 - h),
        );
        chosenBox = candOffset & Size(w, h);
        chosenOffset = candOffset;
      }

      if (chosenBox != null && chosenOffset != null) {
        allocatedBoxes.add(chosenBox);

        // Frosted background pill
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            (chosenOffset - Offset(4 / _screenScale, 2 / _screenScale)) &
                Size(w + 8 / _screenScale, h + 4 / _screenScale),
            Radius.circular(4 / _screenScale),
          ),
          Paint()..color = bgColor,
        );

        if (isPriority) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              (chosenOffset - Offset(4 / _screenScale, 2 / _screenScale)) &
                  Size(w + 8 / _screenScale, h + 4 / _screenScale),
              Radius.circular(4 / _screenScale),
            ),
            Paint()
              ..color = textColor.withValues(alpha: 0.35)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0 / _screenScale,
          );
        }

        painter.paint(canvas, chosenOffset);
      }
    }

    // Draw in priority order:
    // Priority 1: Selected and Hovered nodes
    if (selectedKey != null) {
      final selectedEntry = placedPoints
          .where((p) => p.$1.key == selectedKey)
          .firstOrNull;
      if (selectedEntry != null) {
        tryDrawLabel(
          entry: selectedEntry,
          textColor: palette.ink,
          bgColor: palette.surface,
          fontSize: 13.5,
          isPriority: true,
        );
      }
    }
    if (hoveredKey != null && hoveredKey != selectedKey) {
      final hoveredEntry = placedPoints
          .where((p) => p.$1.key == hoveredKey)
          .firstOrNull;
      if (hoveredEntry != null) {
        tryDrawLabel(
          entry: hoveredEntry,
          textColor: palette.ink,
          bgColor: palette.surface.withValues(alpha: 0.95),
          fontSize: 12.5,
          isPriority: true,
        );
      }
    }

    // Priority 2: Direct neighbours of active node
    for (final neighbour in activeNeighbours) {
      if (neighbour.$1.key == selectedKey || neighbour.$1.key == hoveredKey) {
        continue;
      }
      tryDrawLabel(
        entry: neighbour,
        textColor: palette.ink,
        bgColor: palette.surface.withValues(alpha: 0.90),
        fontSize: 11.5,
        isPriority: false,
      );
    }

    // Priority 3: Historical Tier-1 Anchors
    for (final p in placedPoints) {
      if (_tier1Anchors.contains(p.$1.key)) {
        if (p.$1.key == selectedKey ||
            p.$1.key == hoveredKey ||
            activeNeighbours.any((n) => n.$1.key == p.$1.key)) {
          continue;
        }
        tryDrawLabel(
          entry: p,
          textColor: palette.ink,
          bgColor: palette.surface.withValues(alpha: 0.85),
          fontSize: 11.0,
          isPriority: false,
        );
      }
    }

    // Priority 4: Secondary currents (when zoom is >= 1.2 or list is small)
    if (placedPoints.length < 35 || _screenScale >= 1.2) {
      for (final p in placedPoints) {
        if (_tier1Anchors.contains(p.$1.key) ||
            p.$1.key == selectedKey ||
            p.$1.key == hoveredKey ||
            activeNeighbours.any((n) => n.$1.key == p.$1.key)) {
          continue;
        }
        tryDrawLabel(
          entry: p,
          textColor: palette.inkSoft,
          bgColor: palette.surface.withValues(alpha: 0.80),
          fontSize: 10.0,
          isPriority: false,
        );
      }
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset center,
    Color color,
    double size, {
    Color? background,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontFamily: 'IBMPlexSans',
          fontSize: size / _screenScale,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: math.min(260 / _screenScale, 864));
    final offset = Offset(
      (center.dx - painter.width / 2).clamp(8, 872 - painter.width),
      center.dy - painter.height / 2,
    );
    if (background != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          (offset - const Offset(4, 2)) &
              Size(painter.width + 8, painter.height + 4),
          const Radius.circular(4),
        ),
        Paint()..color = background,
      );
    }
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.selectedKey != selectedKey ||
      oldDelegate.hoveredKey != hoveredKey ||
      oldDelegate.palette != palette ||
      oldDelegate.projection != projection;
}
