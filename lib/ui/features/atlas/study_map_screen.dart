import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models.dart' as data;
import '../../../domain/models/study_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../charts/axis_colors.dart';
import '../../charts/study_constellation.dart';
import '../../charts/study_ternary_chart.dart';
import '../../view_models/app_view_model.dart';
import 'atlas_explorer_screen.dart';
import 'study_profile_screen.dart';
import 'study_taxonomy.dart';

/// An uninterrupted viewport for exploration. Search and detail panels open on
/// demand; neither the map nor pointer gestures live inside a page scroll view.
enum _MobileInspectorDetent { peek, half, full }

class StudyMapScreen extends StatefulWidget {
  const StudyMapScreen({
    required this.appViewModel,
    this.initialQuery = '',
    this.initialKind = 'current',
    this.initialSpectrum,
    this.initialSubject,
    this.onClose,
    super.key,
  });
  final AppViewModel appViewModel;
  final String initialQuery;
  final String? initialKind, initialSpectrum, initialSubject;
  final VoidCallback? onClose;
  @override
  State<StudyMapScreen> createState() => _StudyMapScreenState();
}

class _StudyMapScreenState extends State<StudyMapScreen> {
  late final StudyCatalog _catalog = StudyCatalog(widget.appViewModel.data);
  late final TextEditingController _query = TextEditingController(
    text: widget.initialQuery,
  );
  late String? _kind = widget.initialKind;
  late String? _spectrum = normalizeSpectrumFilter(widget.initialSpectrum);
  StudySubject? _selected;
  StudyMapProjection _projection = const StudyMapProjection();
  late List<StudyMapProjection> _projections;
  bool? _legendExpanded;
  int _inspectorTab = 0;
  int _mobileActiveIndex = 0;
  _MobileInspectorDetent _mobileDetent = _MobileInspectorDetent.peek;
  late final PageController _mobilePageController = PageController();

  bool _isLegendExpanded(BuildContext context) =>
      _legendExpanded ??
      (_projections.length == 1 && MediaQuery.sizeOf(context).width >= 600);

  @override
  void initState() {
    super.initState();
    _projections = [_projection];
    if (widget.initialSubject != null) {
      final initKey = widget.initialSubject!;
      _selected = _catalog.subjects.where((s) =>
        s.key == initKey ||
        s.key == 'current:$initKey' ||
        s.current?.id == initKey,
      ).firstOrNull;
    }
  }

  List<StudySubject>? _cachedMatches;
  String? _lastQueryText;
  String? _lastKind;
  String? _lastSpectrum;

  List<StudySubject> get _matches {
    final queryText = _query.text;
    if (_cachedMatches != null &&
        _lastQueryText == queryText &&
        _lastKind == _kind &&
        _lastSpectrum == _spectrum) {
      return _cachedMatches!;
    }
    _lastQueryText = queryText;
    _lastKind = _kind;
    _lastSpectrum = _spectrum;
    return _cachedMatches = _catalog
        .search(queryText, kind: _kind)
        .where(
          (s) =>
              s.record == null &&
              (_spectrum == null || spectrumOf(s)?.name == _spectrum),
        )
        .toList()
      ..sort(compareStudySubjects);
  }

  final Map<String, int> _plottedCountCache = {};

  int _getPlottedCount(List<StudySubject> matches, StudyMapProjection projection) {
    final key = '${matches.length}:${projection.xAxisId}:${projection.yAxisId}:${projection.triadId}';
    return _plottedCountCache.putIfAbsent(key, () {
      return matches
          .where(
            (s) =>
                StudyConstellationGeometry.position(s, projection: projection) !=
                null,
          )
          .length;
    });
  }

  @override
  void dispose() {
    _query.dispose();
    _mobilePageController.dispose();
    super.dispose();
  }

  void _select(StudySubject s) => setState(() {
    _selected = s;
    _mobileDetent = _MobileInspectorDetent.peek;
  });

  void _cycleMobileDetent() => setState(() {
    _mobileDetent = switch (_mobileDetent) {
      _MobileInspectorDetent.peek => _MobileInspectorDetent.half,
      _MobileInspectorDetent.half => _MobileInspectorDetent.full,
      _MobileInspectorDetent.full => _MobileInspectorDetent.peek,
    };
  });

  void _stepMobileDetentUp() => setState(() {
    _mobileDetent = switch (_mobileDetent) {
      _MobileInspectorDetent.peek => _MobileInspectorDetent.half,
      _MobileInspectorDetent.half => _MobileInspectorDetent.full,
      _MobileInspectorDetent.full => _MobileInspectorDetent.full,
    };
  });

  void _stepMobileDetentDown() => setState(() {
    _mobileDetent = switch (_mobileDetent) {
      _MobileInspectorDetent.peek => _MobileInspectorDetent.peek,
      _MobileInspectorDetent.half => _MobileInspectorDetent.peek,
      _MobileInspectorDetent.full => _MobileInspectorDetent.half,
    };
  });
  void _open(StudySubject s) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: studyProfileRoute(s.key)),
        builder: (_) => StudyProfileScreen(
          appViewModel: widget.appViewModel,
          subjectKey: s.key,
        ),
      ),
    );
  }

  Future<void> _search() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) {
          void change(VoidCallback fn) {
            setState(fn);
            update(() {});
          }

          final matches = _matches;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 12,
              ),
              child: SizedBox(
                height: math.min(MediaQuery.sizeOf(context).height * .8, 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explorar a teia',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _query,
                      onChanged: (_) => change(() {}),
                      decoration: InputDecoration(
                        labelText: 'Buscar na teia',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          tooltip: 'Limpar busca',
                          onPressed: () => change(_query.clear),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _kind ?? 'all',
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Catálogo'),
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('Todos os tipos'),
                        ),
                        DropdownMenuItem(
                          value: 'current',
                          child: Text('Correntes'),
                        ),
                        DropdownMenuItem(
                          value: 'personality',
                          child: Text('Personalidades'),
                        ),
                        DropdownMenuItem(
                          value: 'party',
                          child: Text('Partidos e movimentos'),
                        ),
                        DropdownMenuItem(
                          value: 'history',
                          child: Text('História'),
                        ),
                        DropdownMenuItem(value: 'book', child: Text('Livros')),
                        DropdownMenuItem(
                          value: 'country',
                          child: Text('Países e modelos'),
                        ),
                      ],
                      onChanged: (v) =>
                          change(() => _kind = v == 'all' ? null : v),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _spectrum ?? 'all',
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Espectro'),
                      items: [
                        const DropdownMenuItem(
                          value: 'all',
                          child: Text('Todos os oito espectros'),
                        ),
                        for (final s in studySpectra)
                          DropdownMenuItem(
                            value: s.name,
                            child: Row(
                              children: [
                                SpectrumBar(color: s.color, height: 18),
                                const SizedBox(width: 10),
                                Text(s.name),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (v) =>
                          change(() => _spectrum = v == 'all' ? null : v),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${matches.length} verbetes · sem limite de pontos',
                          ),
                        ),
                        TextButton(
                          onPressed: () => change(() {
                            _query.clear();
                            _kind = 'current';
                            _spectrum = null;
                          }),
                          child: const Text('Todas as correntes'),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final s = matches[index];
                          final point = StudyConstellationGeometry.position(
                            s,
                            projection: _projection,
                          );
                          return ListTile(
                            key: ValueKey('map-catalog:${s.key}'),
                            leading: SpectrumBar(
                              color:
                                  spectrumOf(s)?.color ?? context.palette.line,
                            ),
                            title: Text(s.name),
                            subtitle: Text(
                              '${s.kindLabel} · ${spectrumOf(s)?.name ?? s.family}${point == null ? ' · sem dados nesta projeção' : ''}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              _select(s);
                            },
                          );
                        },
                      ),
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

  List<(String, StudyMapProjection)> _presetProjections() {
    final axes = widget.appViewModel.data.twelveAxes.axes;
    final map = {for (final a in axes) a.id: a};
    final triads = widget.appViewModel.data.sixTriangles.categories;
    return [
      ('Nolan clássico', const StudyMapProjection()),
      if (map['economia'] != null && map['poder'] != null)
        (
          'Estado × Mercado',
          StudyMapProjection.axes(map['economia']!, map['poder']!),
        ),
      if (map['moral'] != null && map['religiao'] != null)
        (
          'Cultura & Tradição',
          StudyMapProjection.axes(map['moral']!, map['religiao']!),
        ),
      if (map['diplomacia'] != null && map['imigracao'] != null)
        (
          'Nação × Globalismo',
          StudyMapProjection.axes(map['diplomacia']!, map['imigracao']!),
        ),
      if (map['representacao'] != null && map['estrutura'] != null)
        (
          'Representação × Ordem',
          StudyMapProjection.axes(map['representacao']!, map['estrutura']!),
        ),
      if (map['sociedade'] != null && map['progresso'] != null)
        (
          'Sociedade × Tecnologia',
          StudyMapProjection.axes(map['sociedade']!, map['progresso']!),
        ),
      for (final t in triads)
        (
          'Tríade: ${t.label}',
          StudyMapProjection.triad(
            triadId: t.id,
            triadLabel: t.label,
            triadVertices: t.subcategories,
          ),
        ),
    ];
  }

  void _addProjection() {
    if (_projections.length >= 4) return;
    final presets = _presetProjections();
    final next = presets.firstWhere(
      (p) => !_projections.any(
        (curr) =>
            (curr.isTriad && p.$2.isTriad && curr.triadId == p.$2.triadId) ||
            (!curr.isTriad &&
                !p.$2.isTriad &&
                curr.xAxisId == p.$2.xAxisId &&
                curr.yAxisId == p.$2.yAxisId),
      ),
      orElse: () => presets[_projections.length % presets.length],
    );
    setState(() {
      _projections.add(next.$2);
    });
  }

  void _removeProjection(int index) {
    if (_projections.length <= 1) return;
    setState(() {
      _projections.removeAt(index);
      if (_mobileActiveIndex >= _projections.length) {
        _mobileActiveIndex = math.max(0, _projections.length - 1);
      }
      _projection = _projections[_mobileActiveIndex];
    });
  }

  Future<void> _axes({int index = 0}) async {
    final axes = widget.appViewModel.data.twelveAxes.axes;
    final targetProj =
        index < _projections.length ? _projections[index] : _projection;
    var nolan = targetProj.isNolan;
    var x = targetProj.xAxisId ?? 'economia';
    var y = targetProj.yAxisId ?? 'poder';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Escolher eixos${_projections.length > 1 ? ' (Teia ${index + 1})' : ''}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'O plano mostra duas dimensões por vez. Explore qualquer combinação dos 12 eixos ou volte à projeção de Nolan.',
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Nolan quadrado'),
                        selected: nolan,
                        onSelected: (_) => update(() => nolan = true),
                      ),
                      ChoiceChip(
                        label: const Text('12 eixos'),
                        selected: !nolan,
                        onSelected: (_) => update(() => nolan = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (nolan)
                    const Text(
                      'Horizontal: liberdade econômica\nVertical: liberdade civil\nAs coordenadas compostas usam somente dados disponíveis.',
                    ),
                  if (!nolan) ...[
                    DropdownButtonFormField<String>(
                      key: ValueKey('map-x:$x'),
                      initialValue: x,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Eixo horizontal',
                      ),
                      items: [
                        for (final a in axes)
                          DropdownMenuItem(value: a.id, child: Text(a.label)),
                      ],
                      onChanged: (v) => update(() {
                        x = v!;
                        if (x == y) y = axes.firstWhere((a) => a.id != x).id;
                      }),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: ValueKey('map-y:$y'),
                      initialValue: y,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Eixo vertical',
                      ),
                      items: [
                        for (final a in axes.where((a) => a.id != x))
                          DropdownMenuItem(value: a.id, child: Text(a.label)),
                      ],
                      onChanged: (v) => update(() => y = v!),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Perfis sem dados nos dois eixos continuam disponíveis na busca; não são colocados artificialmente no centro.',
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final applied = nolan
                            ? const StudyMapProjection()
                            : StudyMapProjection.axes(
                                axes.firstWhere((a) => a.id == x),
                                axes.firstWhere((a) => a.id == y),
                              );
                        setState(() {
                          if (index < _projections.length) {
                            _projections[index] = applied;
                          }
                          if (index == 0) {
                            _projection = applied;
                          }
                        });
                        Navigator.pop(sheetContext);
                      },
                      child: const Text('Aplicar projeção'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _legend() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Oito espectros',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              for (final s in studySpectra)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SpectrumBar(color: s.color),
                  title: Text(s.name),
                  subtitle: Text(s.description),
                  onTap: () {
                    setState(() => _spectrum = s.name);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildInspectorCard({
    required BuildContext context,
    required StudySubject subject,
    required bool isDesktop,
  }) {
    final p = context.palette;
    final spec = spectrumOf(subject);
    final specColor = spec?.color ?? p.accent;
    final axes = widget.appViewModel.data.twelveAxes.axes;

    final bool isPeekMobile =
        !isDesktop && _mobileDetent == _MobileInspectorDetent.peek;

    return Container(
      key: isDesktop ? null : const ValueKey('teia-mobile-inspector'),
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.line),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 20 : 14,
            isDesktop ? 16 : 8,
            isDesktop ? 20 : 14,
            isDesktop ? 16 : 10,
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDesktop) ...[
              Semantics(
                button: true,
                label: 'Alternar altura do painel de detalhes',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _cycleMobileDetent,
                  onVerticalDragEnd: (details) {
                    final double vy = details.primaryVelocity ?? 0;
                    if (vy < -150) {
                      _stepMobileDetentUp();
                    } else if (vy > 150) {
                      _stepMobileDetentDown();
                    }
                  },
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4.5,
                      margin: EdgeInsets.only(bottom: isPeekMobile ? 6 : 10),
                      decoration: BoxDecoration(
                        color: p.inkSoft.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (isPeekMobile) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StudySubjectTile(
                        subject: subject,
                        portrait: widget.appViewModel.data.portraits[subject.key],
                        compact: true,
                        onTap: () => _open(subject),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Expandir detalhes',
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_up_rounded,
                                size: 22,
                              ),
                              onPressed: _cycleMobileDetent,
                            ),
                            IconButton(
                              tooltip: 'Fechar detalhes',
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () => setState(() => _selected = null),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => _open(subject),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                minimumSize: const Size(0, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(
                                Icons.open_in_new_rounded,
                                size: 15,
                              ),
                              label: const Text(
                                'Abrir ficha',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 6),
                            OutlinedButton.icon(
                              onPressed: _stepMobileDetentUp,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                minimumSize: const Size(0, 34),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(
                                Icons.unfold_more_rounded,
                                size: 15,
                              ),
                              label: const Text(
                                '12 eixos e 6 tríades',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
            StudySubjectTile(
              subject: subject,
              portrait: widget.appViewModel.data.portraits[subject.key],
              onTap: () => _open(subject),
              trailing: isDesktop
                  ? IconButton(
                      tooltip: 'Fechar detalhes',
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => setState(() => _selected = null),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: _mobileDetent == _MobileInspectorDetent.full
                              ? 'Recolher detalhes'
                              : 'Expandir detalhes',
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          icon: Icon(
                            _mobileDetent == _MobileInspectorDetent.full
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_up_rounded,
                            size: 22,
                          ),
                          onPressed: _cycleMobileDetent,
                        ),
                        IconButton(
                          tooltip: 'Fechar detalhes',
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => setState(() => _selected = null),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: p.line),
            const SizedBox(height: 12),
            // Metric Section Switcher: 12 EIXOS / 6 TRÍADES
            Container(
              height: 34,
              decoration: BoxDecoration(
                color: p.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.line.withValues(alpha: 0.6)),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'Aba OS 12 EIXOS',
                      selected: _inspectorTab == 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _inspectorTab = 0),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _inspectorTab == 0
                                ? p.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: _inspectorTab == 0
                                ? Border.all(color: p.line)
                                : null,
                          ),
                          child: Text(
                            'OS 12 EIXOS',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: _inspectorTab == 0
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: _inspectorTab == 0 ? p.ink : p.inkSoft,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'Aba AS 6 TRÍADES',
                      selected: _inspectorTab == 1,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _inspectorTab = 1),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _inspectorTab == 1
                                ? p.surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: _inspectorTab == 1
                                ? Border.all(color: p.line)
                                : null,
                          ),
                          child: Text(
                            'AS 6 TRÍADES',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: _inspectorTab == 1
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: _inspectorTab == 1 ? p.ink : p.inkSoft,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Metric Content list (12 Eixos or 6 Tríades)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    if (_inspectorTab == 0) ...[
                      for (final axis in axes) ...[
                        if (subject.displayAxes[axis.id] case final double val)
                          TeiaAxisSlider(axis: axis, value: val),
                      ],
                    ] else ...[
                      for (final triad in widget.appViewModel.data.sixTriangles.categories) ...[
                        if (subject.displayTriangles[triad.id] case final comp?)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: p.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: p.line.withValues(alpha: 0.7),
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    triad.label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: p.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  StudyTernaryChart(
                                    vertices: triad.subcategories,
                                    series: [
                                      StudyTernarySeries(
                                        subject.name,
                                        comp,
                                        specColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            ],
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildFloatingLegend(BuildContext context) {
    final p = context.palette;
    if (!_isLegendExpanded(context)) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: p.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
          boxShadow: EspectroElevation.cardShadows(p),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => setState(() => _legendExpanded = true),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SpectrumBar(color: p.accent, width: 3.5, height: 12),
                  const SizedBox(width: 7),
                  Text(
                    _spectrum ?? 'Espectros',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.expand_less, size: 16, color: p.inkSoft),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 185),
      child: Container(
        decoration: BoxDecoration(
          color: p.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.line),
          boxShadow: EspectroElevation.cardShadows(p),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'ESPECTROS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: p.inkSoft,
                    ),
                  ),
                  const Spacer(),
                  if (_spectrum != null)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() => _spectrum = null),
                        child: Text(
                          'Limpar',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: p.accent,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  Semantics(
                    button: true,
                    label: 'Recolher legenda dos espectros',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => setState(() => _legendExpanded = false),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.expand_more,
                          size: 16,
                          color: p.inkSoft,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              for (final s in studySpectra) ...[
                InkWell(
                  onTap: () => setState(
                    () => _spectrum = _spectrum == s.name ? null : s.name,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: _spectrum == s.name
                          ? s.color.withValues(alpha: 0.16)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        SpectrumBar(color: s.color, width: 3.5, height: 13),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            s.name,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: _spectrum == s.name
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _spectrum == s.name ? s.color : p.ink,
                            ),
                          ),
                        ),
                        if (_spectrum == s.name)
                          Icon(Icons.check, size: 13, color: s.color),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeiaPane({
    required BuildContext context,
    required int index,
    required StudyMapProjection projection,
    required List<StudySubject> matches,
    required StudySubject? selected,
  }) {
    final p = context.palette;
    final presets = _presetProjections();
    final projName = projection.isTriad
        ? (projection.triadLabel ?? 'Tríade')
        : projection.isNolan
            ? 'Nolan'
            : '${projection.xLabel} × ${projection.yLabel}';
    final plotted = _getPlottedCount(matches, projection);

    final bool multiPane = _projections.length > 1;
    final Widget projMenuButton = PopupMenuButton<StudyMapProjection>(
      tooltip: 'Trocar eixos desta teia',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onSelected: (newProj) {
        setState(() {
          _projections[index] = newProj;
          if (index == 0) _projection = newProj;
        });
      },
      itemBuilder: (context) => [
        for (final (title, preset) in presets)
          PopupMenuItem(
            value: preset,
            child: Row(
              children: [
                if ((preset.isNolan && projection.isNolan) ||
                    (!preset.isNolan &&
                        !projection.isNolan &&
                        preset.xAxisId == projection.xAxisId &&
                        preset.yAxisId == projection.yAxisId))
                  Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: p.accent,
                  )
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _axes(index: index);
            });
          },
          child: const Row(
            children: [
              Icon(Icons.tune_rounded, size: 16),
              SizedBox(width: 8),
              Text('Personalizar eixos…'),
            ],
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (multiPane) ...[
            Text(
              'Teia ${index + 1}: ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: p.accent,
              ),
            ),
          ],
          Flexible(
            child: Text(
              projName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.arrow_drop_down,
            size: 16,
            color: p.inkSoft,
          ),
        ],
      ),
    );

    final Widget headerControls = Row(
      mainAxisSize: multiPane ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (multiPane)
          Flexible(child: projMenuButton)
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 230),
            child: projMenuButton,
          ),
        const SizedBox(width: 6),
        Text(
          '($plotted)',
          style: TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: p.inkSoft,
          ),
        ),
        if (multiPane) const Spacer(),
        if (index == 0 && (_query.text.isNotEmpty || _spectrum != null)) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              [
                if (_spectrum != null) _spectrum,
                if (_query.text.isNotEmpty) '“${_query.text}”',
              ].join(' · '),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: p.accent,
              ),
            ),
          ),
        ],
        if (multiPane) ...[
          const SizedBox(width: 4),
          Semantics(
            button: true,
            label: 'Remover esta teia',
            child: Tooltip(
              message: 'Remover esta teia',
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => _removeProjection(index),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: p.inkSoft,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );

    if (multiPane) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: p.line.withValues(alpha: 0.75)),
        ),
        child: Column(
          children: [
            Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: p.surface.withValues(alpha: 0.92),
                border: Border(bottom: BorderSide(color: p.line.withValues(alpha: 0.75))),
              ),
              child: headerControls,
            ),
            Expanded(
              child: StudyConstellation(
                key: ValueKey(
                  'teia-constellation-$index-${projection.xAxisId}-${projection.yAxisId}',
                ),
                subjects: matches,
                selected: selected,
                onSelected: _select,
                onOpen: _open,
                expanded: true,
                compact: true,
                projection: projection,
              ),
            ),
          ],
        ),
      );
    }

    final bool compactHeaderBar =
        !multiPane && MediaQuery.sizeOf(context).width < 600;
    if (compactHeaderBar) {
      return Column(
        children: [
          Container(
            height: 36,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: p.surface.withValues(alpha: 0.94),
              border: Border(
                bottom: BorderSide(color: p.line.withValues(alpha: 0.85)),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: headerControls,
            ),
          ),
          Expanded(
            child: StudyConstellation(
              key: ValueKey(
                'teia-constellation-$index-${projection.xAxisId}-${projection.yAxisId}',
              ),
              subjects: matches,
              selected: selected,
              onSelected: _select,
              onOpen: _open,
              expanded: true,
              projection: projection,
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: StudyConstellation(
            key: ValueKey(
              'teia-constellation-$index-${projection.xAxisId}-${projection.yAxisId}',
            ),
            subjects: matches,
            selected: selected,
            onSelected: _select,
            onOpen: _open,
            expanded: true,
            projection: projection,
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            decoration: BoxDecoration(
              color: p.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.line),
            ),
            child: Material(
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: headerControls,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeiaGrid({
    required BuildContext context,
    required bool isDesktop,
    required List<StudySubject> matches,
    required StudySubject? selected,
  }) {
    if (_projections.length == 1) {
      return _buildTeiaPane(
        context: context,
        index: 0,
        projection: _projections[0],
        matches: matches,
        selected: selected,
      );
    }

    if (isDesktop) {
      if (_projections.length == 2) {
        return Row(
          children: [
            Expanded(
              child: _buildTeiaPane(
                context: context,
                index: 0,
                projection: _projections[0],
                matches: matches,
                selected: selected,
              ),
            ),
            Expanded(
              child: _buildTeiaPane(
                context: context,
                index: 1,
                projection: _projections[1],
                matches: matches,
                selected: selected,
              ),
            ),
          ],
        );
      }
      if (_projections.length == 3) {
        return Row(
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: _buildTeiaPane(
                  context: context,
                  index: i,
                  projection: _projections[i],
                  matches: matches,
                  selected: selected,
                ),
              ),
          ],
        );
      }
      // 4 panes: 2x2 grid on desktop
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildTeiaPane(
                    context: context,
                    index: 0,
                    projection: _projections[0],
                    matches: matches,
                    selected: selected,
                  ),
                ),
                Expanded(
                  child: _buildTeiaPane(
                    context: context,
                    index: 1,
                    projection: _projections[1],
                    matches: matches,
                    selected: selected,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildTeiaPane(
                    context: context,
                    index: 2,
                    projection: _projections[2],
                    matches: matches,
                    selected: selected,
                  ),
                ),
                Expanded(
                  child: _buildTeiaPane(
                    context: context,
                    index: 3,
                    projection: _projections[3],
                    matches: matches,
                    selected: selected,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Mobile layout (< 800px): Clean full-size teia with swipe and tab bar
    final p = context.palette;
    final activeIndex = _mobileActiveIndex.clamp(0, _projections.length - 1);

    return Column(
      children: [
        // Tab switcher strip for mobile
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: p.surface.withValues(alpha: 0.95),
            border: Border(
              bottom: BorderSide(color: p.line.withValues(alpha: 0.6)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: HorizontalAffordanceStrip(
                  fadeColor: p.surface,
                  showArrows: false,
                  builder: (context, controller) => SingleChildScrollView(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < _projections.length; i++) ...[
                          () {
                            final proj = _projections[i];
                            final isActive = i == activeIndex;
                            final label = proj.isNolan
                                ? 'Nolan'
                                : proj.isTriad
                                    ? 'Tríade ${proj.triadId}'
                                    : '${proj.xLabel.substring(0, math.min(4, proj.xLabel.length))} × ${proj.yLabel.substring(0, math.min(4, proj.yLabel.length))}';
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Material(
                                color: isActive
                                    ? p.accent.withValues(alpha: 0.16)
                                    : p.surfaceMuted,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  key: ValueKey('mobile-teia-tab-$i'),
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    setState(() => _mobileActiveIndex = i);
                                    if (_mobilePageController.hasClients) {
                                      if (MediaQuery.disableAnimationsOf(
                                        context,
                                      )) {
                                        _mobilePageController.jumpToPage(i);
                                      } else {
                                        _mobilePageController.animateToPage(
                                          i,
                                          duration: EspectroMotion.medium,
                                          curve: EspectroMotion.easeOut,
                                        );
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isActive
                                            ? p.accent
                                            : p.line.withValues(alpha: 0.5),
                                        width: isActive ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Teia ${i + 1}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isActive
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: isActive ? p.accent : p.ink,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? p.accent.withValues(alpha: 0.25)
                                                : p.canvas.withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            label,
                                            style: TextStyle(
                                              fontFamily: 'IBMPlexMono',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: isActive ? p.accent : p.inkSoft,
                                            ),
                                          ),
                                        ),
                                        if (isActive && _projections.length > 1) ...[
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () => _removeProjection(i),
                                            child: Tooltip(
                                              message: 'Remover esta teia',
                                              child: Icon(
                                                Icons.close_rounded,
                                                size: 15,
                                                color: p.accent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (_projections.length < 4)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconButton(
                    key: const ValueKey('add-teia-strip-btn'),
                    tooltip: 'Adicionar teia (${_projections.length}/4)',
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: p.accent,
                      size: 22,
                    ),
                    onPressed: _addProjection,
                  ),
                ),
            ],
          ),
        ),
        // Active full-size teia view
        Expanded(
          child: PageView.builder(
            controller: _mobilePageController,
            itemCount: _projections.length,
            onPageChanged: (i) => setState(() => _mobileActiveIndex = i),
            itemBuilder: (context, i) {
              return _buildTeiaPane(
                context: context,
                index: i,
                projection: _projections[i],
                matches: matches,
                selected: selected,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 800;
    final matches = _matches;
    final selected = _selected;
    final double mobileInspectorHeight = switch (_mobileDetent) {
      _MobileInspectorDetent.peek => math.min(size.height * 0.24, 156.0),
      _MobileInspectorDetent.half => math.min(size.height * 0.50, 400.0),
      _MobileInspectorDetent.full => math.min(size.height * 0.78, 600.0),
    };
    final bool showLegendOnScreen =
        (_projections.length == 1 || (_legendExpanded ?? false)) &&
        (isDesktop ||
            selected == null ||
            _mobileDetent == _MobileInspectorDetent.peek);
    final double legendBottom = (!isDesktop && selected != null)
        ? mobileInspectorHeight + 18
        : 12;
    final Duration detentDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);

    return EspectroScaffold(
      appViewModel: widget.appViewModel,
      selectedIndex: 2,
      isSectionRoot: true,
      navigationVisible: false,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar à lista',
          onPressed: widget.onClose ?? () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            const Text('Teia'),
            if (size.width >= 500) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: _query,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar ideologia…',
                        hintStyle: TextStyle(fontSize: 13, color: p.inkSoft),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        suffixIcon: _query.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () => setState(() => _query.clear()),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        filled: true,
                        fillColor: p.surfaceMuted.withValues(alpha: 0.6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_projections.length < 4) ...[
            if (size.width >= 600)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                child: OutlinedButton.icon(
                  key: const ValueKey('add-teia-btn'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(color: p.accent.withValues(alpha: 0.6)),
                  ),
                  onPressed: _addProjection,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(
                    '+ Teia (${_projections.length}/4)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              IconButton(
                key: const ValueKey('add-teia-btn'),
                tooltip: 'Adicionar teia (${_projections.length}/4)',
                onPressed: _addProjection,
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
          ],
          IconButton(
            tooltip: 'Buscar e filtrar',
            onPressed: _search,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            tooltip: 'Escolher eixos',
            onPressed: () => _axes(index: 0),
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            tooltip: 'Legenda dos oito espectros',
            onPressed: _legend,
            icon: const Icon(Icons.palette_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Constellation canvas / multi-teia grid
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              right: isDesktop && selected != null ? 406 : 0,
              child: _buildTeiaGrid(
                context: context,
                isDesktop: isDesktop,
                matches: matches,
                selected: selected,
              ),
            ),

            // Em 2..4 projeções simultâneas, recolhe a pílula flutuante para não
            // sobrepor o quadrante inferior esquerdo (mantém acesso pelo botão do topo).
            if (showLegendOnScreen)
              Positioned(
                left: 12,
                bottom: legendBottom,
                child: _buildFloatingLegend(context),
              ),

            // Side Inspector Drawer on Desktop (12axes layout)
            if (isDesktop && selected != null)
              Positioned(
                top: 12,
                right: 12,
                bottom: 12,
                width: 390,
                child: _buildInspectorCard(
                  context: context,
                  subject: selected,
                  isDesktop: true,
                ),
              ),

            // Bottom Inspector Drawer on Mobile (3 detents: peek/half/full)
            if (!isDesktop && selected != null)
              AnimatedPositioned(
                duration: detentDuration,
                curve: Curves.easeOutCubic,
                left: 10,
                right: 10,
                bottom: 10,
                height: mobileInspectorHeight,
                child: _buildInspectorCard(
                  context: context,
                  subject: selected,
                  isDesktop: false,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dual-track 12axes slider widget with percentage, active pole pill and knob
class TeiaAxisSlider extends StatelessWidget {
  const TeiaAxisSlider({
    required this.axis,
    required this.value,
    super.key,
  });

  final data.Axis axis;
  final double value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final normalized = ((value + 1) / 2).clamp(0.0, 1.0);
    final leansLeft = normalized <= 0.5;
    final dominantPole = leansLeft ? axis.leftPole : axis.rightPole;
    final dominantColor = leansLeft ? axis.leftColor : axis.rightColor;
    final Color dominantInk = AxisColors.readableInk(
      dominantColor,
      isDark: p.isDark,
    );
    final IconData axisIcon = AxisColors.iconFor(axis.id);
    final percentage = (leansLeft ? (1.0 - normalized) : normalized) * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(axisIcon, size: 14, color: dominantInk),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        axis.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: p.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.round()}% $dominantPole',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: dominantInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              const trackHeight = 7.0;
              const knobSize = 14.0;
              final knobX = (normalized * (trackWidth - knobSize))
                  .clamp(0.0, trackWidth - knobSize);

              return SizedBox(
                height: knobSize,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: trackHeight,
                      width: trackWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(trackHeight / 2),
                        color: p.surfaceMuted,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              color: axis.leftColor.withValues(
                                alpha: leansLeft ? 0.85 : 0.22,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: axis.rightColor.withValues(
                                alpha: !leansLeft ? 0.85 : 0.22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: knobX,
                      child: Container(
                        width: knobSize,
                        height: knobSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: dominantColor,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: _PolePill(
                  label: axis.leftPole,
                  color: axis.leftColor,
                  isActive: leansLeft,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: _PolePill(
                  label: axis.rightPole,
                  color: axis.rightColor,
                  isActive: !leansLeft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolePill extends StatelessWidget {
  const _PolePill({
    required this.label,
    required this.color,
    required this.isActive,
  });

  final String label;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textInk = AxisColors.readableInk(color, isDark: p.isDark);
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: p.isDark ? 0.16 : 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: textInk,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.5,
          color: p.inkSoft,
        ),
      ),
    );
  }
}
