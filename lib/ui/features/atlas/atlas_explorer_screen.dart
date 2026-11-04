import 'package:flutter/material.dart';

import '../../../domain/models/atlas_models.dart';
import '../../../domain/models/study_models.dart';
import '../../../theme.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/common.dart';
import '../../../widgets/espectro_scaffold.dart';
import 'study_map_screen.dart';
import '../../view_models/app_view_model.dart';
import '../compare/study_comparison_screen.dart';
import 'study_profile_screen.dart';
import 'study_taxonomy.dart';
import 'study_identity.dart';
import '../../../domain/models/study_media.dart';

/// Um único catálogo e estado de busca para a lista, a teia e os percursos de estudo.
class AtlasExplorerScreen extends StatefulWidget {
  const AtlasExplorerScreen({
    required this.appViewModel,
    this.initialTabIndex = 0,
    this.initialKind,
    this.initialQuery = '',
    this.initialSpectrum,
    this.initialMap = false,
    this.initialType,
    super.key,
  });
  final AppViewModel appViewModel;
  final int initialTabIndex;
  final AtlasKind? initialKind;
  final String initialQuery;
  final String? initialSpectrum;
  final bool initialMap;
  final String? initialType;
  @override
  State<AtlasExplorerScreen> createState() => _AtlasExplorerScreenState();
}

class _AtlasExplorerScreenState extends State<AtlasExplorerScreen> {
  late final TextEditingController _search;
  String? _kind, _spectrum;
  bool _map = false, _favorites = false;
  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.initialQuery);
    _spectrum = normalizeSpectrumFilter(widget.initialSpectrum);
    _map = widget.initialMap;
    _kind = widget.initialType ?? widget.initialKind?.singularLabel;
    if (_kind == null &&
        widget.initialTabIndex > 0 &&
        widget.initialTabIndex <= 5) {
      _kind = const [
        AtlasKind.personality,
        AtlasKind.country,
        AtlasKind.party,
        AtlasKind.history,
        AtlasKind.book,
      ][widget.initialTabIndex - 1].singularLabel;
    }
    if (!studySpectra.any((s) => s.name == _spectrum)) _spectrum = null;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(StudySubject subject) {
    widget.appViewModel.visitStudySubject(subject.key);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: studyProfileRoute(subject.key)),
        builder: (_) => StudyProfileScreen(
          appViewModel: widget.appViewModel,
          subjectKey: subject.key,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.appViewModel,
    builder: (context, _) {
      final vm = widget.appViewModel;
      final catalog = StudyCatalog(vm.data, records: vm.history);
      final subjects = catalog.subjects.where((s) => s.record == null).toList();
      final kinds = subjects.map((s) => s.kindLabel).toSet().toList();
      // Legacy entry points select the same dataset rather than maintaining separate tabs.
      if (_kind != null && !kinds.contains(_kind)) _kind = null;
      final matches =
          catalog
              .search(_search.text)
              .where(
                (s) =>
                    s.record == null &&
                    (_kind == null || s.kindLabel == _kind) &&
                    (_spectrum == null || spectrumOf(s)?.name == _spectrum) &&
                    (!_favorites || vm.studyFavorites.contains(s.key)),
              )
              .toList()
            ..sort(compareStudySubjects);
      final p = context.palette;
      if (_map) {
        final selectedKind = _kind == null
            ? (_search.text.isEmpty ? 'current' : null)
            : subjects.where((s) => s.kindLabel == _kind).firstOrNull?.kind;
        return StudyMapScreen(
          appViewModel: vm,
          initialQuery: _search.text,
          initialKind: selectedKind,
          initialSpectrum: _spectrum,
          onClose: () => setState(() => _map = false),
        );
      }
      final active =
          _search.text.isNotEmpty ||
          _kind != null ||
          _spectrum != null ||
          _favorites;
      return EspectroScaffold(
        appViewModel: vm,
        selectedIndex: 2,
        isSectionRoot: true,
        appBar: AppBar(
          title: const Text('Atlas político'),
          actions: [
            IconButton(
              tooltip: 'Comparação livre',
              icon: Badge(
                label: Text('${vm.studyComparison.length}'),
                isLabelVisible: vm.studyComparison.isNotEmpty,
                child: const Icon(Icons.compare_arrows_rounded),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StudyComparisonScreen(appViewModel: vm),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Copiar link desta exploração',
              icon: const Icon(Icons.link),
              onPressed: () => copyStudyLink(
                context,
                Uri(
                  path: '/atlas',
                  queryParameters: {
                    'v': '1',
                    if (_search.text.isNotEmpty) 'q': _search.text,
                    'spectrum': ?_spectrum,
                    if (_map) 'view': 'map',
                  },
                ).toString(),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            key: const PageStorageKey('study-atlas'),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1060),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditorialHeading(
                            eyebrow: 'UM CATÁLOGO PARA INVESTIGAR',
                            title: 'Siga uma ideia.\nDescubra as conexões.',
                            description:
                                '${vm.data.catalog.currents.length} correntes · ${vm.data.atlas.personalities.length} personalidades · ${vm.data.atlas.books.length} obras. Explore sem precisar fazer um teste.',
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _search,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Buscar em todo o Atlas',
                              hintText: 'Ideia, pessoa, país, partido ou obra',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _search.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Limpar busca',
                                      onPressed: () => setState(_search.clear),
                                      icon: const Icon(Icons.close),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('Tudo'),
                                selected: _kind == null,
                                onSelected: (_) => setState(() => _kind = null),
                              ),
                              for (final kind in kinds)
                                ChoiceChip(
                                  label: Text(
                                    '$kind (${subjects.where((s) => s.kindLabel == kind).length})',
                                  ),
                                  selected: _kind == kind,
                                  onSelected: (_) => setState(
                                    () => _kind = _kind == kind ? null : kind,
                                  ),
                                ),
                              FilterChip(
                                label: const Text('Salvos'),
                                avatar: const Icon(
                                  Icons.bookmark_outline,
                                  size: 16,
                                ),
                                selected: _favorites,
                                onSelected: (v) =>
                                    setState(() => _favorites = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (!active) ...[
                            Text(
                              'Tradições e espectros',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Agrupamentos editoriais. Correntes têm divergências internas e podem atravessar mais de uma tradição.',
                              style: TextStyle(color: p.muted),
                            ),
                            const SizedBox(height: 14),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final columns = constraints.maxWidth >= 700
                                    ? 4
                                    : 2;
                                final width =
                                    (constraints.maxWidth -
                                        (columns - 1) * 10) /
                                    columns;
                                return Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    for (final spectrum in studySpectra)
                                      SizedBox(
                                        width: width,
                                        child: Material(
                                          color: p.surface,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            onTap: () => setState(
                                              () => _spectrum = spectrum.name,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: p.line,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 24,
                                                    height: 4,
                                                    color: spectrum.color,
                                                  ),
                                                  const SizedBox(height: 14),
                                                  Text(
                                                    spectrum.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    '${subjects.where((s) => s.current != null && spectrumOf(s)?.id == spectrum.id).length} correntes →',
                                                    style: TextStyle(
                                                      color: p.muted,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 28),
                          ],
                          if (_spectrum != null)
                            SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _spectrum!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    studySpectra
                                        .firstWhere((s) => s.name == _spectrum)
                                        .description,
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        setState(() => _spectrum = null),
                                    child: const Text('Ver todos os caminhos'),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${matches.length} verbetes',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              SegmentedButton<bool>(
                                showSelectedIcon: false,
                                segments: const [
                                  ButtonSegment(
                                    value: false,
                                    icon: Icon(Icons.view_list_outlined),
                                    label: Text('Lista'),
                                  ),
                                  ButtonSegment(
                                    value: true,
                                    icon: Icon(Icons.hub_outlined),
                                    label: Text('Teia'),
                                  ),
                                ],
                                selected: {_map},
                                onSelectionChanged: (s) =>
                                    setState(() => _map = s.first),
                              ),
                            ],
                          ),
                          if (active)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => setState(() {
                                  _search.clear();
                                  _kind = null;
                                  _spectrum = null;
                                  _favorites = false;
                                }),
                                icon: const Icon(
                                  Icons.filter_alt_off_outlined,
                                  size: 16,
                                ),
                                label: const Text('Limpar filtros'),
                              ),
                            ),
                          const SizedBox(height: 16),
                          if (vm.studyStorageError != null)
                            Text(
                              vm.studyStorageError!,
                              style: TextStyle(color: p.warning),
                            ),
                          if (matches.isEmpty)
                            SectionCard(
                              child: Column(
                                children: [
                                  const Icon(Icons.search_off, size: 32),
                                  const SizedBox(height: 12),
                                  Text(
                                    _favorites
                                        ? 'Nenhum salvo com estes filtros.'
                                        : 'Nenhum verbete encontrado.',
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Experimente outro termo ou limpe os filtros.',
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final s = matches[index];
                    final spectrum = spectrumOf(s);
                    final group =
                        index == 0 ||
                        spectrumOf(matches[index - 1])?.id != spectrum?.id;
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1060),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (group)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 18,
                                  bottom: 10,
                                ),
                                child: Row(
                                  children: [
                                    SpectrumBar(
                                      color: spectrum?.color ?? p.line,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        spectrum?.name ?? 'Outros verbetes',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    Text(
                                      '${matches.where((v) => spectrumOf(v)?.id == spectrum?.id).length}',
                                      style: TextStyle(color: p.inkSoft),
                                    ),
                                  ],
                                ),
                              ),
                            StudySubjectTile(
                              subject: s,
                              portrait: vm.data.portraits[s.key],
                              onTap: () => _open(s),
                              trailing: IconButton(
                                tooltip: vm.studyFavorites.contains(s.key)
                                    ? 'Remover dos salvos'
                                    : 'Salvar verbete',
                                onPressed: () => vm.toggleStudyFavorite(s.key),
                                icon: Icon(
                                  vm.studyFavorites.contains(s.key)
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class StudySubjectTile extends StatelessWidget {
  const StudySubjectTile({
    required this.subject,
    required this.onTap,
    this.trailing,
    this.portrait,
    super.key,
  });
  final StudySubject subject;
  final VoidCallback onTap;
  final Widget? trailing;
  final StudyPortrait? portrait;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: p.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: p.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                StudyIdentityAvatar(
                  subject: subject,
                  portrait: portrait,
                  size: subject.kind == 'personality' ? 54 : 38,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subject.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p.inkSoft, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(Icons.arrow_forward_rounded, color: p.muted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
