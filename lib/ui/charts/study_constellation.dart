import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../domain/engine/atlas_and_nolan_engine.dart';
import '../../domain/models/study_models.dart';
import '../../data/models.dart' as data;
import '../../theme.dart';
import '../features/atlas/study_taxonomy.dart';
import 'teia_cartographic_layer.dart';

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
      // Projeção baricêntrica sobre triângulo equilátero calibrado
      const v0 = TeiaCartographicLayer.triadV0;
      const v1 = TeiaCartographicLayer.triadV1;
      const v2 = TeiaCartographicLayer.triadV2;
      final sum = comp[0] + comp[1] + comp[2];
      if (sum <= 1e-9) return TeiaCartographicLayer.triadCentroid;
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
    this.compact = false,
    this.projection = const StudyMapProjection(),
    super.key,
  });

  final List<StudySubject> subjects;
  final StudySubject? selected;
  final ValueChanged<StudySubject> onSelected;
  final ValueChanged<StudySubject>? onOpen;
  final bool expanded;
  final bool compact;
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

  double _fitScaleFor(Size viewport) {
    final double span = (widget.compact || viewport.shortestSide < 420)
        ? 880.0
        : 810.0;
    return math.min(viewport.width / span, viewport.height / span);
  }

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
  late List<SpectrumTerritory> _territories;
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
    _territories = TeiaCartographicLayer.computeTerritories(
      placed,
      isDark: dark,
    );
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
      _territories = TeiaCartographicLayer.computeTerritories(
        placed,
        isDark: dark,
      );
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
          final fitScale = _fitScaleFor(_viewport!);
          final double targetTx = _viewport!.width / 2 - point.dx * scale;
          final double targetTy = _viewport!.height / 2 - point.dy * scale;
          final double tx;
          final double ty;
          if (scale <= fitScale * 1.15) {
            // Quando toda a figura cabe na tela, desloca suavemente sem jogar o
            // diagrama inteiro para um canto.
            final double fitDx = (_viewport!.width - 880 * scale) / 2;
            final double fitDy = (_viewport!.height - 880 * scale) / 2;
            tx = fitDx + (targetTx - fitDx) * 0.22;
            ty = fitDy + (targetTy - fitDy) * 0.22;
          } else {
            tx = targetTx;
            ty = targetTy;
          }
          _flyTo(
            Matrix4.identity()
              ..translateByDouble(tx, ty, 0, 1)
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
    final scale = _fitScaleFor(viewport);
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
    final fit = _fitScaleFor(viewport);
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

  Widget _buildSceneAnchoredBadge({
    required String label,
    required Offset sceneAnchor,
    required Matrix4 matrix,
    required double alignX,
    required double alignY,
  }) {
    final p = context.palette;
    final Offset screenAnchor = MatrixUtils.transformPoint(matrix, sceneAnchor);
    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: _SceneAnchoredBadgeDelegate(
          anchor: screenAnchor,
          alignX: alignX,
          alignY: alignY,
          compact: widget.compact,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 6 : 9,
            vertical: widget.compact ? 2.5 : 4,
          ),
          decoration: BoxDecoration(
            color: p.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: p.line.withValues(alpha: 0.92),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: widget.compact ? 9.5 : 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
              color: p.inkSoft,
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
              territories: _territories,
              selectedKey: widget.selected?.key,
              hoveredKey: _hovered?.key,
              palette: context.palette,
              animation: _breathing,
              camera: _camera,
              projection: widget.projection,
              viewportSize: viewport,
              compact: widget.compact,
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
              child: ValueListenableBuilder<Matrix4>(
                valueListenable: _camera,
                builder: (BuildContext context, Matrix4 matrix, _) {
                  if (widget.projection.isTriad &&
                      widget.projection.triadVertices.length == 3) {
                    return Stack(
                      children: [
                        _buildSceneAnchoredBadge(
                          label:
                              '${widget.projection.triadVertices[2].toUpperCase()} ↑',
                          sceneAnchor:
                              TeiaCartographicLayer.triadV2 +
                              const Offset(0, -14),
                          matrix: matrix,
                          alignX: -0.5,
                          alignY: -1.0,
                        ),
                        _buildSceneAnchoredBadge(
                          label:
                              '← ${widget.projection.triadVertices[0].toUpperCase()}',
                          sceneAnchor:
                              TeiaCartographicLayer.triadV0 +
                              const Offset(0, 14),
                          matrix: matrix,
                          alignX: -0.5,
                          alignY: 0.0,
                        ),
                        _buildSceneAnchoredBadge(
                          label:
                              '${widget.projection.triadVertices[1].toUpperCase()} →',
                          sceneAnchor:
                              TeiaCartographicLayer.triadV1 +
                              const Offset(0, 14),
                          matrix: matrix,
                          alignX: -0.5,
                          alignY: 0.0,
                        ),
                      ],
                    );
                  }
                  return Stack(
                    children: [
                      _buildSceneAnchoredBadge(
                        label: widget.projection.isNolan
                            ? 'AUTORITARISMO ↑'
                            : '${widget.projection.yHigh.toUpperCase()} ↑',
                        sceneAnchor: const Offset(440, 84),
                        matrix: matrix,
                        alignX: -0.5,
                        alignY: -1.0,
                      ),
                      _buildSceneAnchoredBadge(
                        label: widget.projection.isNolan
                            ? 'ANARQUISMO ↓'
                            : '${widget.projection.yLow.toUpperCase()} ↓',
                        sceneAnchor: const Offset(440, 796),
                        matrix: matrix,
                        alignX: -0.5,
                        alignY: 0.0,
                      ),
                      _buildSceneAnchoredBadge(
                        label: widget.projection.isNolan
                            ? '← ESQUERDA'
                            : '← ${widget.projection.xLow.toUpperCase()}',
                        sceneAnchor: const Offset(86, 440),
                        matrix: matrix,
                        alignX: -1.0,
                        alignY: -0.5,
                      ),
                      _buildSceneAnchoredBadge(
                        label: widget.projection.isNolan
                            ? 'DIREITA →'
                            : '${widget.projection.xHigh.toUpperCase()} →',
                        sceneAnchor: const Offset(794, 440),
                        matrix: matrix,
                        alignX: 0.0,
                        alignY: -0.5,
                      ),
                    ],
                  );
                },
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
      if (widget.compact) {
        return Column(
          key: const ValueKey('study-map-full-canvas'),
          children: [
            Expanded(child: _canvas()),
            Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: palette.surface.withValues(alpha: 0.94),
                border: Border(
                  top: BorderSide(color: palette.line.withValues(alpha: 0.65)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Aumentar zoom',
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    padding: const EdgeInsets.all(4),
                    iconSize: 15,
                    onPressed: () => _zoom(1.4),
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    tooltip: 'Diminuir zoom',
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    padding: const EdgeInsets.all(4),
                    iconSize: 15,
                    onPressed: () => _zoom(1 / 1.4),
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton(
                    tooltip: 'Reenquadrar teia',
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    padding: const EdgeInsets.all(4),
                    iconSize: 15,
                    onPressed: () {
                      if (_viewport case final Size v) _fit(v);
                    },
                    icon: const Icon(Icons.center_focus_strong),
                  ),
                  IconButton(
                    tooltip: _motionPaused
                        ? 'Ativar movimento sutil'
                        : 'Pausar movimento',
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    padding: const EdgeInsets.all(4),
                    iconSize: 15,
                    onPressed: () {
                      setState(() => _motionPaused = !_motionPaused);
                      _syncMotion();
                    },
                    icon: Icon(_motionPaused ? Icons.play_arrow : Icons.pause),
                  ),
                ],
              ),
            ),
          ],
        );
      }
      return Stack(
        key: const ValueKey('study-map-full-canvas'),
        children: [
          Positioned.fill(child: _canvas()),
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              decoration: BoxDecoration(
                color: palette.surface.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.line),
              ),
              child: Material(
                type: MaterialType.transparency,
                borderRadius: BorderRadius.circular(8),
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
                      child: ExcludeSemantics(
                        child: Text(
                          'Projeção em coordenadas',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: palette.inkSoft,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
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
    this.compact = false,
    List<(Offset, Offset)>? staticEdges,
    List<SpectrumTerritory>? territories,
  })  : staticEdges = staticEdges ??
            computeStaticEdges(points.where((p) => p.$2.dx <= 800).toList()),
        territories = territories ??
            TeiaCartographicLayer.computeTerritories(
              points.where((p) => p.$2.dx <= 800).toList(),
              isDark: palette.isDark,
            ),
        super(repaint: Listenable.merge([animation, camera]));

  final List<(StudySubject, Offset)> points;
  final List<(Offset, Offset)> staticEdges;
  final List<SpectrumTerritory> territories;
  final String? selectedKey;
  final String? hoveredKey;
  final EspectroPalette palette;
  final Animation<double> animation;
  final TransformationController camera;
  final StudyMapProjection projection;
  final Size? viewportSize;
  final bool compact;

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
    'current:social_democracia',
    'current:socialismo_democratico',
    'current:trabalhismo_desenvolvimentista',
    'current:ecologismo_politico',
    'current:marxismo_leninismo',
    'current:trotskismo',
    'current:comunismo_de_conselhos',
    'current:maoismo',
    'current:anarquismo_social',
    'current:anarcossindicalismo',
    'current:mutualismo_proudhoniano',
    'current:liberalismo_social',
    'current:centrismo_pragmatico',
    'current:democracia_crista',
    'current:distributismo_comunitarismo',
    'current:liberalismo_classico',
    'current:conservadorismo_liberal',
    'current:conservadorismo_tradicionalista',
    'current:nacionalismo_civico',
    'current:anarcocapitalismo',
    'current:libertarianismo_minarquista',
    'current:agorismo',
    'current:peronismo_justicialismo',
    'current:fascismo_historico',
    'current:falangismo_nacional_sindicalismo',
    'current:fundamentalismo_teocratico',
    'current:etnonacionalismo',
  };

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

  static String _shortMapLabel(String raw) {
    String out = raw.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
    final int slash = out.indexOf('/');
    if (slash > 0) {
      out = out.substring(0, slash);
    }
    out = out.trim();
    return out.length >= 3 ? out : raw;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final placedPoints = points.where((p) => p.$2.dx <= 800).toList();
    final activeKeyNow = selectedKey ?? hoveredKey;
    final String? focusSpectrumId = activeKeyNow != null
        ? spectrumOf(
            placedPoints.where((p) => p.$1.key == activeKeyNow).firstOrNull?.$1 ??
                const StudySubject(key: '', name: '', kind: '', kindLabel: ''),
          )?.id
        : (territories.length == 1 ? territories.first.id : null);

    // 1. Retículo cartográfico calibrado (grade ortogonal ou simplex ternário)
    TeiaCartographicLayer.paintGraticule(
      canvas,
      palette,
      scale: _screenScale,
      showScaleTicks: !compact,
      isTriad: projection.isTriad,
      fillAnalyticalPlate: true,
    );

    // 2. Envoltórias territoriais nítidas por espectro (preserva contexto mesmo sob seleção)
    TeiaCartographicLayer.paintTerritories(
      canvas,
      territories,
      palette,
      opacityMultiplier: activeKeyNow == null
          ? (compact ? 0.72 : 1.0)
          : (compact ? 0.58 : 0.85),
      showLabels: !compact && _screenScale <= 2.1,
      zoomScale: _screenScale,
      labelOpacity: activeKeyNow == null ? 1.0 : 0.48,
      isTriad: projection.isTriad,
      focusSpectrumId: focusSpectrumId,
    );

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
          .withValues(
            alpha: activeKey == null
                ? (projection.isTriad ? 0.16 : 0.24)
                : 0.10,
          )
      ..strokeWidth = 0.75 / _screenScale;

    for (final edge in staticEdges) {
      canvas.drawLine(edge.$1, edge.$2, bgEdgePaint);
    }

    // 5. Active dynamic connections for selected/hovered node (linhas nítidas sem glow difuso)
    if (activeSubject != null) {
      final activeColor =
          spectrumOf(activeSubject.$1)?.color ?? palette.accent;
      final pulsePhase = animation.value;

      final edgePaint = Paint()
        ..color = activeColor.withValues(alpha: 0.88)
        ..strokeWidth = 1.9 / _screenScale
        ..strokeCap = StrokeCap.round;

      final pulseDotPaint = Paint()
        ..color = palette.ink.withValues(alpha: 0.90);

      for (final neighbour in activeNeighbours) {
        canvas.drawLine(activeSubject.$2, neighbour.$2, edgePaint);

        // Indicador discreto de ligação ao longo da aresta ativa
        final t = (pulsePhase * 2.2) % 1.0;
        final pulsePos = Offset.lerp(activeSubject.$2, neighbour.$2, t)!;
        canvas.drawCircle(
          pulsePos,
          2.2 / _screenScale,
          pulseDotPaint,
        );
      }

      // Anel concêntrico limpo no nó ativo (sem halo borrado)
      canvas.drawCircle(
        activeSubject.$2,
        12.0 / _screenScale,
        Paint()
          ..color = activeColor.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6 / _screenScale,
      );
    }

    // Viewport visible bounds for culling offscreen elements
    final vp = viewportSize ?? size;
    final visibleBounds = Rect.fromPoints(
      camera.toScene(Offset.zero),
      camera.toScene(Offset(vp.width, vp.height)),
    ).inflate(40.0);

    // 6. Node stars / points (using reusable paints with crisp stroke separation)
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
          // Marcação cartográfica dupla nítida
          nodeStrokePaint
            ..color = color
            ..strokeWidth = 2.2 / _screenScale;
          canvas.drawCircle(point, 12.5 / _screenScale, nodeStrokePaint);
          nodeFillPaint.color = color;
          canvas.drawCircle(point, 6.4 / _screenScale, nodeFillPaint);
          nodeStrokePaint
            ..color = palette.surface
            ..strokeWidth = 1.5 / _screenScale;
          canvas.drawCircle(point, 6.4 / _screenScale, nodeStrokePaint);
        } else if (isNeighbour) {
          // Vizinho imediato com anel de contraste (sem halo borrado)
          nodeFillPaint.color = color;
          canvas.drawCircle(point, 5.2 / _screenScale, nodeFillPaint);
          nodeStrokePaint
            ..color = palette.surface
            ..strokeWidth = 1.2 / _screenScale;
          canvas.drawCircle(point, 5.2 / _screenScale, nodeStrokePaint);
        } else {
          // Preserva riqueza cromática e contexto com contorno discreto
          nodeFillPaint.color = color.withValues(
            alpha: palette.isDark ? 0.38 : 0.34,
          );
          canvas.drawCircle(point, 3.3 / _screenScale, nodeFillPaint);
        }
      } else {
        // Estado de constelação aberta com contornos de separação nítidos
        final double radius = (isAnchor ? 4.9 : 3.5) / _screenScale;
        nodeFillPaint.color = color.withValues(
          alpha: isAnchor ? 0.96 : (palette.isDark ? 0.88 : 0.84),
        );
        canvas.drawCircle(point, radius, nodeFillPaint);
        nodeStrokePaint
          ..color = palette.surface.withValues(alpha: palette.isDark ? 0.90 : 0.95)
          ..strokeWidth = (isAnchor ? 1.1 : 0.85) / _screenScale;
        canvas.drawCircle(point, radius, nodeStrokePaint);
      }
    }

    // 7. Anti-collision label allocation with HUD exclusion & spatial balance
    final allocatedBoxes = <Rect>[];
    final hudZones = <Rect>[];
    final nodeObstacles = <Rect>[];

    Rect screenToSceneRect(Rect screenRect) => Rect.fromPoints(
          camera.toScene(screenRect.topLeft),
          camera.toScene(screenRect.bottomRight),
        );

    // Reserva áreas de HUD (espectros, seletor de projeção, controles de zoom) e vértices
    if (!compact && vp.width >= 600) {
      hudZones.add(screenToSceneRect(Rect.fromLTWH(8, vp.height - 242, 204, 236)));
      hudZones.add(screenToSceneRect(const Rect.fromLTWH(8, 8, 224, 52)));
      hudZones.add(screenToSceneRect(Rect.fromLTWH(vp.width - 66, 8, 58, 210)));
    } else {
      hudZones.add(screenToSceneRect(Rect.fromLTWH(8, vp.height - 56, 150, 52)));
    }
    if (projection.isTriad) {
      hudZones.add(Rect.fromCenter(center: TeiaCartographicLayer.triadV2 - const Offset(0, 26), width: 140, height: 36));
      hudZones.add(Rect.fromCenter(center: TeiaCartographicLayer.triadV0 + const Offset(0, 26), width: 150, height: 36));
      hudZones.add(Rect.fromCenter(center: TeiaCartographicLayer.triadV1 + const Offset(0, 26), width: 150, height: 36));
    } else {
      hudZones.add(Rect.fromCenter(center: const Offset(440, 84), width: 165, height: 36));
      hudZones.add(Rect.fromCenter(center: const Offset(440, 796), width: 150, height: 36));
      hudZones.add(Rect.fromCenter(center: const Offset(86, 440), width: 130, height: 38));
      hudZones.add(Rect.fromCenter(center: const Offset(794, 440), width: 120, height: 38));
      if (vp.width < 520) {
        hudZones.add(screenToSceneRect(Rect.fromLTWH(4, vp.height / 2 - 36, 118, 72)));
        hudZones.add(screenToSceneRect(Rect.fromLTWH(vp.width - 118, vp.height / 2 - 36, 114, 72)));
      }
    }

    for (final (subject, pt) in placedPoints) {
      if (subject.key == activeKey ||
          activeNeighbourKeys.contains(subject.key) ||
          _tier1Anchors.contains(subject.key)) {
        final double r = (subject.key == activeKey ? 13.0 : 7.0) / _screenScale;
        nodeObstacles.add(Rect.fromCircle(center: pt, radius: r));
      }
    }

    final Rect safeScreenSceneBounds = screenToSceneRect(
      Rect.fromLTRB(
        10,
        12,
        math.max(120.0, vp.width - (compact ? 10.0 : 66.0)),
        math.max(120.0, vp.height - 12.0),
      ),
    );

    final int labelBudget = compact
        ? (_screenScale >= 1.6 ? 12 : 6)
        : (_screenScale >= 1.85 ? 28 : (_screenScale >= 1.25 ? 16 : 9));
    final double passiveClearance =
        (_screenScale >= 1.85 ? 6.0 : (_screenScale >= 1.25 ? 11.0 : 18.0)) /
        _screenScale;
    final Color haloStrokeColor =
        (palette.isDark ? const Color(0xFF0E141E) : const Color(0xFFFAF9F5))
            .withValues(alpha: 0.94);

    void tryDrawLabel({
      required (StudySubject, Offset) entry,
      required Color textColor,
      required Color bgColor,
      required double fontSize,
      required bool isPriority,
      required bool haloOnly,
      bool avoidHud = true,
      bool forcePlacement = false,
    }) {
      final (subject, point) = entry;
      if (!isPriority &&
          (!visibleBounds.contains(point) ||
              allocatedBoxes.length >= labelBudget)) {
        return;
      }

      final String displayText =
          haloOnly ? _shortMapLabel(subject.name) : subject.name;
      final double maxTextWidth = haloOnly
          ? (136.0 / _screenScale)
          : ((isPriority ? 230.0 : 175.0) / _screenScale);

      final TextStyle textStyle = TextStyle(
        color: textColor,
        fontFamily: 'IBMPlexSans',
        fontSize: fontSize / _screenScale,
        fontWeight: isPriority ? FontWeight.w700 : FontWeight.w600,
      );

      final painter = TextPainter(
        text: TextSpan(text: displayText, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: math.min(maxTextWidth, 864));

      final w = painter.width;
      final h = painter.height;
      final double gap = (isPriority ? 14.0 : 10.0) / _screenScale;
      final double diag = 10.5 / _screenScale;
      final double padX = (haloOnly ? 4.0 : 8.0) / _screenScale;
      final double padY = (haloOnly ? 2.0 : 4.0) / _screenScale;

      final candidates = <Offset>[
        Offset(gap, -h / 2),
        Offset(-(w + gap), -h / 2),
        Offset(-w / 2, gap),
        Offset(-w / 2, -(h + gap)),
        Offset(diag, diag),
        Offset(-(w + diag), diag),
        Offset(diag, -(h + diag)),
        Offset(-(w + diag), -(h + diag)),
      ];

      Rect? chosenBox;
      Offset? chosenOffset;
      int chosenIndex = -1;
      final double boxClearance = isPriority
          ? (3.5 / _screenScale)
          : passiveClearance;

      for (int idx = 0; idx < candidates.length; idx++) {
        final candTopLeft = point + candidates[idx];
        final candOffset = Offset(
          candTopLeft.dx.clamp(12.0, 868.0 - w),
          candTopLeft.dy.clamp(12.0, 868.0 - h),
        );
        final pillBox = (candOffset - Offset(padX / 2, padY / 2)) &
            Size(w + padX, h + padY);
        final bool overlapsLabel = allocatedBoxes.any(
          (existing) => existing.inflate(boxClearance).overlaps(pillBox),
        );
        final bool overlapsHud =
            avoidHud && hudZones.any((hz) => hz.overlaps(pillBox));
        final bool overlapsOtherNode = nodeObstacles.any(
          (obs) =>
              (obs.center - point).distanceSquared > 1.0 &&
              obs.overlaps(pillBox),
        );
        final bool outOfSafeViewport =
            !isPriority &&
            (pillBox.left < safeScreenSceneBounds.left ||
                pillBox.right > safeScreenSceneBounds.right ||
                pillBox.top < safeScreenSceneBounds.top ||
                pillBox.bottom > safeScreenSceneBounds.bottom);
        if (!overlapsLabel &&
            !overlapsHud &&
            !overlapsOtherNode &&
            !outOfSafeViewport) {
          chosenBox = pillBox;
          chosenOffset = candOffset;
          chosenIndex = idx;
          break;
        }
      }

      if (chosenBox == null && forcePlacement) {
        final candOffset = Offset(
          (point.dx - w / 2).clamp(12.0, 868.0 - w),
          (point.dy + gap).clamp(12.0, 868.0 - h),
        );
        chosenBox = (candOffset - Offset(padX / 2, padY / 2)) &
            Size(w + padX, h + padY);
        chosenOffset = candOffset;
        chosenIndex = 0;
      }

      if (chosenBox != null && chosenOffset != null) {
        allocatedBoxes.add(chosenBox);

        final Offset pillCenter = chosenBox.center;
        final double dist = (pillCenter - point).distance;
        if ((isPriority && (chosenIndex >= 4 || dist > 20 / _screenScale)) ||
            (haloOnly && dist > 16 / _screenScale)) {
          final Offset dir = (pillCenter - point) / math.max(1.0, dist);
          final Offset start = point + dir * ((isPriority ? 6.8 : 5.2) / _screenScale);
          final Offset end = chosenBox.contains(point)
              ? start
              : point + dir * (dist - math.min(w, h) * 0.40);
          if ((end - start).distance > 2 / _screenScale) {
            canvas.drawLine(
              start,
              end,
              Paint()
                ..color = textColor.withValues(alpha: haloOnly ? 0.30 : 0.44)
                ..strokeWidth = (haloOnly ? 0.75 : 0.95) / _screenScale,
            );
          }
        }

        if (haloOnly) {
          final TextPainter haloPainter = TextPainter(
            text: TextSpan(
              text: displayText,
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: fontSize / _screenScale,
                fontWeight: FontWeight.w600,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3.2 / _screenScale
                  ..strokeJoin = StrokeJoin.round
                  ..color = haloStrokeColor,
              ),
            ),
            textDirection: TextDirection.ltr,
            maxLines: 1,
            ellipsis: '…',
          )..layout(maxWidth: math.min(maxTextWidth, 864));
          haloPainter.paint(canvas, chosenOffset);
          painter.paint(canvas, chosenOffset);
        } else {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              chosenBox,
              Radius.circular(5 / _screenScale),
            ),
            Paint()..color = bgColor,
          );
          if (isPriority) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                chosenBox,
                Radius.circular(5 / _screenScale),
              ),
              Paint()
                ..color = textColor.withValues(alpha: 0.38)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.0 / _screenScale,
            );
          }
          painter.paint(canvas, chosenOffset);
        }
      }
    }

    // Priority 1: Selected and Hovered nodes (full name, crisp pill)
    if (selectedKey != null) {
      final selectedEntry = placedPoints
          .where((p) => p.$1.key == selectedKey)
          .firstOrNull;
      if (selectedEntry != null) {
        tryDrawLabel(
          entry: selectedEntry,
          textColor: palette.ink,
          bgColor: palette.surface,
          fontSize: 13.0,
          isPriority: true,
          haloOnly: false,
          avoidHud: false,
          forcePlacement: true,
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
          bgColor: palette.surface.withValues(alpha: 0.96),
          fontSize: 12.0,
          isPriority: true,
          haloOnly: false,
          avoidHud: false,
          forcePlacement: selectedKey == null,
        );
      }
    }

    // Priority 2: Direct neighbours of active node (concise pill)
    for (final neighbour in activeNeighbours) {
      if (neighbour.$1.key == selectedKey || neighbour.$1.key == hoveredKey) {
        continue;
      }
      tryDrawLabel(
        entry: neighbour,
        textColor: palette.ink,
        bgColor: palette.surface.withValues(alpha: 0.92),
        fontSize: 11.0,
        isPriority: false,
        haloOnly: false,
      );
    }

    // Priority 3: Round-robin peripheral-first distribution of Tier-1 landmarks
    // across all 8 spectra (prevents center overcrowding; renders clean halo text).
    final Offset anchorOrigin = projection.isTriad
        ? TeiaCartographicLayer.triadCentroid
        : const Offset(440.0, 440.0);
    final Map<String, List<(StudySubject, Offset)>> anchorsBySpectrum = {};
    for (final p in placedPoints) {
      if (_tier1Anchors.contains(p.$1.key) &&
          p.$1.key != selectedKey &&
          p.$1.key != hoveredKey &&
          !activeNeighbourKeys.contains(p.$1.key)) {
        final String spec = spectrumOf(p.$1)?.id ?? 'other';
        (anchorsBySpectrum[spec] ??= []).add(p);
      }
    }
    for (final list in anchorsBySpectrum.values) {
      list.sort((a, b) {
        final int distCmp = (b.$2 - anchorOrigin).distanceSquared.compareTo(
              (a.$2 - anchorOrigin).distanceSquared,
            );
        return distCmp != 0 ? distCmp : a.$1.key.compareTo(b.$1.key);
      });
    }
    final List<String> anchorSpecs = anchorsBySpectrum.keys.toList()..sort();
    for (int round = 0; round < 6; round++) {
      bool anyAdded = false;
      for (final specKey in anchorSpecs) {
        if (allocatedBoxes.length >= labelBudget) break;
        final list = anchorsBySpectrum[specKey]!;
        if (round < list.length) {
          anyAdded = true;
          tryDrawLabel(
            entry: list[round],
            textColor: palette.ink,
            bgColor: palette.surface,
            fontSize: 10.5,
            isPriority: false,
            haloOnly: true,
          );
        }
      }
      if (!anyAdded || allocatedBoxes.length >= labelBudget) break;
    }

    // Priority 4: Additional per-spectrum currents only when zoomed or compact filtered set
    if (placedPoints.length < 35 || _screenScale >= 1.25) {
      final Map<String, List<(StudySubject, Offset)>> bySpectrum = {};
      for (final p in placedPoints) {
        if (_tier1Anchors.contains(p.$1.key) ||
            p.$1.key == selectedKey ||
            p.$1.key == hoveredKey ||
            activeNeighbourKeys.contains(p.$1.key)) {
          continue;
        }
        if (!visibleBounds.contains(p.$2)) continue;
        final String spec = spectrumOf(p.$1)?.id ?? 'other';
        (bySpectrum[spec] ??= []).add(p);
      }
      final Offset vbCenter = visibleBounds.center;
      for (final list in bySpectrum.values) {
        list.sort(
          (a, b) => (a.$2 - vbCenter).distanceSquared.compareTo(
                (b.$2 - vbCenter).distanceSquared,
              ),
        );
      }
      final int maxPerSpectrum = _screenScale >= 1.85 ? 5 : 2;
      final List<String> specKeys = bySpectrum.keys.toList()..sort();
      for (int round = 0; round < maxPerSpectrum; round++) {
        bool anyDrawn = false;
        for (final specKey in specKeys) {
          if (allocatedBoxes.length >= labelBudget) break;
          final list = bySpectrum[specKey]!;
          if (round < list.length) {
            anyDrawn = true;
            tryDrawLabel(
              entry: list[round],
              textColor: palette.inkSoft,
              bgColor: palette.surface,
              fontSize: 9.8,
              isPriority: false,
              haloOnly: true,
            );
          }
        }
        if (!anyDrawn || allocatedBoxes.length >= labelBudget) break;
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

class _SceneAnchoredBadgeDelegate extends SingleChildLayoutDelegate {
  const _SceneAnchoredBadgeDelegate({
    required this.anchor,
    required this.alignX,
    required this.alignY,
    required this.compact,
  });

  final Offset anchor;
  final double alignX;
  final double alignY;
  final bool compact;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        maxWidth: math.max(80.0, constraints.maxWidth - 20.0),
        maxHeight: math.max(24.0, constraints.maxHeight - 20.0),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x = anchor.dx + alignX * childSize.width;
    double y = anchor.dy + alignY * childSize.height;

    double minX = 10.0;
    double maxX = math.max(minX, size.width - childSize.width - 10.0);
    final double minY = 10.0;
    final double maxY = math.max(minY, size.height - childSize.height - 10.0);

    y = y.clamp(minY, maxY);

    if (!compact && size.width >= 600) {
      if (y + childSize.height > size.height - 246.0) {
        minX = math.max(minX, 208.0);
      }
      if (y < 214.0) {
        maxX = math.min(maxX, math.max(minX, size.width - childSize.width - 68.0));
      }
      if (y < 58.0) {
        minX = math.max(minX, 224.0);
      }
    }

    x = x.clamp(minX, math.max(minX, maxX));
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant _SceneAnchoredBadgeDelegate oldDelegate) =>
      oldDelegate.anchor != anchor ||
      oldDelegate.alignX != alignX ||
      oldDelegate.alignY != alignY ||
      oldDelegate.compact != compact;
}
