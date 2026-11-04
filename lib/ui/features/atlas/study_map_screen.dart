import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/models/study_models.dart';
import '../../../theme.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../charts/study_constellation.dart';
import '../../view_models/app_view_model.dart';
import 'study_profile_screen.dart';
import 'study_taxonomy.dart';

/// An uninterrupted viewport for exploration. Search and detail panels open on
/// demand; neither the map nor pointer gestures live inside a page scroll view.
class StudyMapScreen extends StatefulWidget {
  const StudyMapScreen({
    required this.appViewModel,
    this.initialQuery = '',
    this.initialKind = 'current',
    this.initialSpectrum,
    this.onClose,
    super.key,
  });
  final AppViewModel appViewModel;
  final String initialQuery;
  final String? initialKind, initialSpectrum;
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

  List<StudySubject> get _matches =>
      _catalog
          .search(_query.text, kind: _kind)
          .where(
            (s) =>
                s.record == null &&
                (_spectrum == null || spectrumOf(s)?.name == _spectrum),
          )
          .toList()
        ..sort(compareStudySubjects);

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _select(StudySubject s) => setState(() => _selected = s);
  void _open(StudySubject s) {
    widget.appViewModel.visitStudySubject(s.key);
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

  Future<void> _axes() async {
    final axes = widget.appViewModel.data.twelveAxes.axes;
    var nolan = _projection.isNolan;
    var x = _projection.xAxisId ?? 'economia';
    var y = _projection.yAxisId ?? 'poder';
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
                    'Escolher eixos',
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
                        setState(
                          () => _projection = nolan
                              ? const StudyMapProjection()
                              : StudyMapProjection.axes(
                                  axes.firstWhere((a) => a.id == x),
                                  axes.firstWhere((a) => a.id == y),
                                ),
                        );
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

  Future<void> _details(StudySubject s) async {
    final p = context.palette;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .85,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(s.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(s.summary),
              const SizedBox(height: 20),
              Text(
                'Os 12 eixos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              for (final a in widget.appViewModel.data.twelveAxes.axes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      if (s.axes[a.id] case final double value) ...[
                        LinearProgressIndicator(
                          value: (value + 1) / 2,
                          minHeight: 5,
                          color: a.rightColor,
                          backgroundColor: a.leftColor,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                a.leftPole,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: p.inkSoft,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                a.rightPole,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: p.inkSoft,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else
                        Text(
                          'Sem dados documentados neste eixo',
                          style: TextStyle(color: p.inkSoft),
                        ),
                    ],
                  ),
                ),
              const Divider(),
              const Text(
                'As conexões da teia mostram vizinhança nesta projeção, não influência histórica. Consulte as fontes e os limites no perfil.',
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final matches = _matches;
    final plotted = matches
        .where(
          (s) =>
              StudyConstellationGeometry.position(s, projection: _projection) !=
              null,
        )
        .length;
    final selected = _selected;
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
        title: const Text('Teia'),
        actions: [
          IconButton(
            tooltip: 'Buscar e filtrar',
            onPressed: _search,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Escolher eixos',
            onPressed: _axes,
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
            Positioned.fill(
              child: StudyConstellation(
                subjects: matches,
                selected: selected,
                onSelected: _select,
                onOpen: _open,
                expanded: true,
                projection: _projection,
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 76,
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: p.surface.withValues(alpha: .95),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: _search,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$plotted de ${matches.length} ${_kind == 'current' ? 'correntes' : 'verbetes'} no mapa',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _projection.isNolan
                                ? 'Nolan · todos os 12 eixos em Escolher eixos'
                                : '${_projection.xLabel} × ${_projection.yLabel}',
                            style: TextStyle(color: p.inkSoft, fontSize: 11),
                          ),
                          if (_spectrum != null || _query.text.isNotEmpty)
                            Text(
                              [
                                ?_spectrum,
                                if (_query.text.isNotEmpty) '“${_query.text}”',
                              ].join(' · '),
                              style: TextStyle(color: p.inkSoft, fontSize: 11),
                            ),
                          if (plotted < matches.length)
                            Text(
                              '${matches.length - plotted} sem projeção · consultar na busca',
                              style: TextStyle(color: p.inkSoft, fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Material(
                    color: p.surface.withValues(alpha: .97),
                    elevation: 2,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: selected == null
                          ? Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Arraste para navegar. Use dois dedos ou a roda para ampliar.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: p.inkSoft,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _search,
                                  child: const Text('Explorar'),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                SpectrumBar(
                                  color: spectrumOf(selected)?.color ?? p.line,
                                  height: 42,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selected.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        spectrumOf(selected)?.name ??
                                            selected.kindLabel,
                                        style: TextStyle(
                                          color: p.inkSoft,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _details(selected),
                                  child: const Text('12 eixos'),
                                ),
                                IconButton(
                                  tooltip: 'Abrir perfil',
                                  onPressed: () => _open(selected),
                                  icon: const Icon(Icons.arrow_forward),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
