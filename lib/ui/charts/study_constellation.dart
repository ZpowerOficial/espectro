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

  /// Missing economic or civil evidence is omitted rather than placed at 50%.
  static Offset? position(
    StudySubject subject, {
    StudyMapProjection projection = const StudyMapProjection(),
  }) {
    if (!projection.isNolan) {
      final x = subject.axes[projection.xAxisId];
      final y = subject.axes[projection.yAxisId];
      if (x == null || y == null || !x.isFinite || !y.isFinite) return null;
      return center + Offset(x * 340, -y * 340);
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
    if (!hasEconomy || !hasCivil) return null;
    final coordinates = EspectroNolanEngine.fromRawMaps(
      axes: subject.axes,
      triangles: subject.triangles,
    );
    if (coordinates == null) return null;
    final economic = coordinates.economicFreedom / 100;
    final civil = coordinates.personalFreedom / 100;
    return center + Offset((economic * 2 - 1) * 340, -(civil * 2 - 1) * 340);
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
/// two of the twelve observed axes without imputing missing evidence.
class StudyMapProjection {
  const StudyMapProjection({
    this.xAxisId,
    this.yAxisId,
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
  final String? xAxisId, yAxisId;
  final String xLabel, yLabel, xLow, xHigh, yLow, yHigh;
  bool get isNolan => xAxisId == null && yAxisId == null;
}

List<(StudySubject, Offset)> _nearbyPoints(
  List<(StudySubject, Offset)> points,
  String? selectedKey,
) {
  final selected = points.where((p) => p.$1.key == selectedKey).firstOrNull;
  if (selected == null) return [];
  final neighbours = points.where((p) => p.$1.key != selectedKey).toList()
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

  List<(StudySubject, Offset)> get _points => [
    for (final subject in widget.subjects)
      if (StudyConstellationGeometry.position(
            subject,
            projection: widget.projection,
          )
          case final Offset point)
        (subject, point),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    final enabled =
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
    if (oldWidget.projection.xAxisId != widget.projection.xAxisId ||
        oldWidget.projection.yAxisId != widget.projection.yAxisId) {
      _interruptFlight();
      if (_viewport case final Size viewport) _fit(viewport);
    }
    if (oldWidget.selected?.key != widget.selected?.key &&
        widget.selected != null) {
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
          label: 'Teia de ideias. Use Escolher ponto para selecionar qualquer perfil, inclusive pontos sobrepostos.',
          child: CustomPaint(
            size: StudyConstellationGeometry.canvasSize,
            painter: _ConstellationPainter(
              points: _points,
              selectedKey: widget.selected?.key,
              palette: context.palette,
              animation: _breathing,
              camera: _camera,
              projection: widget.projection,
            ),
          ),
        ),
      );
      return Listener(
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
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final points = _points;
    final omitted = widget.subjects.length - points.length;
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
            child: Material(
              color: palette.surface,
              elevation: 2,
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
          '${omitted == 0 ? '' : ' $omitted perfis sem base suficiente aparecem apenas na lista.'}',
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
    required this.palette,
    required this.animation,
    required this.camera,
    required this.projection,
  }) : super(repaint: Listenable.merge([animation, camera]));

  final List<(StudySubject, Offset)> points;
  final String? selectedKey;
  final EspectroPalette palette;
  final Animation<double> animation;
  final TransformationController camera;
  final StudyMapProjection projection;
  double get _screenScale => camera.value.getMaxScaleOnAxis().clamp(.01, 4.0);
  @override
  void paint(Canvas canvas, Size size) {
    const c = StudyConstellationGeometry.center;
    final grid = Paint()
      ..color = palette.line
      ..strokeWidth = 1 / _screenScale
      ..style = PaintingStyle.stroke;
    const plot = Rect.fromLTWH(100, 100, 680, 680);
    canvas.drawRect(plot, grid);
    for (var i = 1; i < 10; i++) {
      final d = 100 + i * 68.0;
      canvas.drawLine(Offset(d, 100), Offset(d, 780), grid);
      canvas.drawLine(Offset(100, d), Offset(780, d), grid);
    }
    final axis = Paint()
      ..color = palette.inkSoft.withValues(alpha: .45)
      ..strokeWidth = 1.5 / _screenScale;
    canvas.drawLine(const Offset(100, 440), const Offset(780, 440), axis);
    canvas.drawLine(const Offset(440, 100), const Offset(440, 780), axis);
    _text(
      canvas,
      '${projection.yLabel} ↑',
      c - const Offset(0, 372),
      palette.inkSoft,
      12,
    );
    _text(
      canvas,
      '${projection.xLabel} →',
      c + const Offset(0, 372),
      palette.inkSoft,
      12,
    );
    _text(canvas, projection.xLow, const Offset(180, 810), palette.inkSoft, 10);
    _text(
      canvas,
      projection.xHigh,
      const Offset(700, 810),
      palette.inkSoft,
      10,
    );
    _text(
      canvas,
      projection.yHigh,
      const Offset(440, 100),
      palette.inkSoft,
      10,
      background: palette.surface,
    );
    _text(
      canvas,
      projection.yLow,
      const Offset(440, 780),
      palette.inkSoft,
      10,
      background: palette.surface,
    );
    final selected = points.where((p) => p.$1.key == selectedKey).firstOrNull;
    final neighbours = _nearbyPoints(points, selectedKey);
    if (selected != null) {
      for (final neighbour in neighbours) {
        canvas.drawLine(
          selected.$2,
          neighbour.$2,
          Paint()
            ..color = palette.accent.withValues(alpha: .35)
            ..strokeWidth = 1.4 / _screenScale,
        );
      }
      // A breathing halo is decorative only: no jitter in coordinates or hit areas.
      canvas.drawCircle(
        selected.$2,
        (15 + 2 * math.sin(animation.value * math.pi * 2)) / _screenScale,
        Paint()..color = palette.accent.withValues(alpha: .13),
      );
    }
    for (final (subject, point) in points) {
      final active = subject.key == selectedKey;
      final related = neighbours.any((p) => p.$1.key == subject.key);
      final color = spectrumOf(subject)?.color ?? palette.accent;
      canvas.drawCircle(
        point,
        (active ? 7 : 3.5) / _screenScale,
        Paint()
          ..color = color.withValues(
            alpha: selected == null || active || related ? .95 : .32,
          ),
      );
      if (active) {
        canvas.drawCircle(
          point,
          10 / _screenScale,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5 / _screenScale,
        );
      }
      if (active ||
          (related && _screenScale > .8) ||
          (points.length < 30 && _screenScale > .9)) {
        _text(
          canvas,
          subject.name,
          point - Offset(0, 22 / _screenScale),
          palette.ink,
          13,
          background: palette.surface,
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
      oldDelegate.palette != palette ||
      oldDelegate.projection != projection;
}
