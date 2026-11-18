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
    this.initialSelectedSubject,
    super.key,
  });
  final AppViewModel appViewModel;
  final int initialTabIndex;
  final AtlasKind? initialKind;
  final String initialQuery;
  final String? initialSpectrum;
  final bool initialMap;
  final String? initialType;
  final String? initialSelectedSubject;
  @override
  State<AtlasExplorerScreen> createState() => _AtlasExplorerScreenState();
}

class _AtlasExplorerScreenState extends State<AtlasExplorerScreen> {
  static const String _parliamentaryKindLabel = 'Bancada / Congresso';

  late final TextEditingController _search;
  String? _kind, _spectrum, _tier, _vocation;
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
      final kindCounts = <String, int>{};
      for (final s in subjects) {
        kindCounts[s.kindLabel] = (kindCounts[s.kindLabel] ?? 0) + 1;
      }
      final kinds = kindCounts.keys.toList();
      final canonicalPersCount = vm.data.atlas.canonicalPersonalities.length;
      final parliamentariansCount = vm.data.atlas.parliamentarians.length;

      // Legacy entry points select the same dataset rather than maintaining separate tabs.
      if (_kind != null &&
          _kind != _parliamentaryKindLabel &&
          !kinds.contains(_kind)) {
        _kind = null;
      }
      if (_kind != AtlasKind.personality.singularLabel) {
        _tier = null;
        _vocation = null;
      }

      if (_map) {
        final selectedKind = _kind == null
            ? (_search.text.isEmpty ? 'current' : null)
            : subjects.where((s) => s.kindLabel == _kind).firstOrNull?.kind;
        return StudyMapScreen(
          appViewModel: vm,
          initialQuery: _search.text,
          initialKind: selectedKind,
          initialSpectrum: _spectrum,
          initialSubject: widget.initialSelectedSubject,
          onClose: () => setState(() => _map = false),
        );
      }

      bool matchesKindAndVocation(StudySubject s) {
        if (_kind == _parliamentaryKindLabel) {
          return s.vocation == PersonalityVocation.parliamentarian;
        }
        if (_kind == AtlasKind.personality.singularLabel) {
          if (s.kindLabel != AtlasKind.personality.singularLabel) return false;
          if (_tier == 'tier2_institutional_record') {
            return true;
          }
          if (_vocation != null) {
            return s.vocation?.id == _vocation;
          }
          // Por padrão em "Personalidade", exibe apenas o cânone intelectual e histórico
          // (Filósofos, Economistas, Cientistas Políticos/Sociólogos/Juristas e Estadistas),
          // sem misturar os 1.405 parlamentares de voto nominal nem influenciadores de bolha.
          return s.isCanonicalSubject;
        }
        if (_kind != null) {
          return s.kindLabel == _kind;
        }
        // Em "Tudo", sem busca textual ativa, oculta parlamentares avulsos e comunicadores de bolha.
        if (_search.text.trim().isEmpty) {
          return s.isCanonicalSubject;
        }
        return true;
      }

      final matches =
          catalog
              .search(_search.text)
              .where(
                (s) =>
                    s.record == null &&
                    matchesKindAndVocation(s) &&
                    (_tier == null ||
                        (s.entry?.editorialBasis?.evidenceTier ??
                                s.current?.editorialBasis?.evidenceTier) ==
                            _tier) &&
                    (_spectrum == null || spectrumOf(s)?.name == _spectrum) &&
                    (!_favorites || vm.studyFavorites.contains(s.key)),
              )
              .toList()
            ..sort(compareStudySubjects);
      final spectrumCounts = <String?, int>{};
      final categorySectionCounts = <int, int>{};
      for (final item in matches) {
        final sid = spectrumOf(item)?.id;
        spectrumCounts[sid] = (spectrumCounts[sid] ?? 0) + 1;
        final cid = studyCategoryPriority(item);
        categorySectionCounts[cid] = (categorySectionCounts[cid] ?? 0) + 1;
      }
      final p = context.palette;
      final active =
          _search.text.isNotEmpty ||
          _kind != null ||
          _tier != null ||
          _vocation != null ||
          _spectrum != null ||
          _favorites;
      return EspectroScaffold(
        appViewModel: vm,
        selectedIndex: 2,
        isSectionRoot: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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
                            eyebrow: 'CATÁLOGO & PERSONALIDADES',
                            title: 'Siga uma ideia.\nDescubra as conexões.',
                            description:
                                '$canonicalPersCount pensadores, economistas e estadistas · ${vm.data.catalog.currents.length} correntes · ${vm.data.atlas.books.length} obras clássicas · $parliamentariansCount parlamentares nos 12 eixos e 6 tríades.',
                          ),
                          if (_search.text.isEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildStatBadge(
                                  context,
                                  '$canonicalPersCount',
                                  'pensadores e estadistas',
                                  p,
                                ),
                                _buildStatBadge(
                                  context,
                                  '${vm.data.catalog.currents.length}',
                                  'correntes',
                                  p,
                                ),
                                _buildStatBadge(
                                  context,
                                  '$parliamentariansCount',
                                  'bancada parlamentar',
                                  p,
                                ),
                                _buildStatBadge(
                                  context,
                                  '18/18',
                                  'dimensões por ficha',
                                  p,
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
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
                                onSelected: (_) => setState(() {
                                  _kind = null;
                                  _vocation = null;
                                  _tier = null;
                                }),
                              ),
                              for (final kind in kinds)
                                ChoiceChip(
                                  label: Text(
                                    kind == AtlasKind.personality.singularLabel
                                        ? '$kind ($canonicalPersCount)'
                                        : '$kind (${kindCounts[kind] ?? 0})',
                                  ),
                                  selected: _kind == kind,
                                  onSelected: (_) => setState(() {
                                    _kind = _kind == kind ? null : kind;
                                    _vocation = null;
                                    _tier = null;
                                  }),
                                ),
                              ChoiceChip(
                                avatar: const Icon(
                                  Icons.how_to_vote_outlined,
                                  size: 16,
                                ),
                                label: Text(
                                  '$_parliamentaryKindLabel ($parliamentariansCount)',
                                ),
                                selected: _kind == _parliamentaryKindLabel,
                                onSelected: (_) => setState(() {
                                  _kind = _kind == _parliamentaryKindLabel
                                      ? null
                                      : _parliamentaryKindLabel;
                                  _vocation = null;
                                  _tier = null;
                                }),
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
                          if (_kind == AtlasKind.personality.singularLabel) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final (id, label) in [
                                  (
                                    null,
                                    'Canônicos: Pensadores & Estadistas ($canonicalPersCount)',
                                  ),
                                  (
                                    PersonalityVocation.philosopher.id,
                                    'Filósofos & Teóricos (${vm.data.atlas.personalities.where((p) => p.vocation == PersonalityVocation.philosopher).length})',
                                  ),
                                  (
                                    PersonalityVocation.economist.id,
                                    'Economistas (${vm.data.atlas.personalities.where((p) => p.vocation == PersonalityVocation.economist).length})',
                                  ),
                                  (
                                    PersonalityVocation.scholar.id,
                                    'Cientistas Políticos, Sociólogos & Juristas (${vm.data.atlas.personalities.where((p) => p.vocation == PersonalityVocation.scholar).length})',
                                  ),
                                  (
                                    PersonalityVocation.statesman.id,
                                    'Estadistas & Líderes (${vm.data.atlas.personalities.where((p) => p.vocation == PersonalityVocation.statesman).length})',
                                  ),
                                  (
                                    PersonalityVocation.communicator.id,
                                    'Debate Público & Divulgadores (${vm.data.atlas.communicators.length})',
                                  ),
                                ])
                                  ChoiceChip(
                                    label: Text(label),
                                    selected: _vocation == id && _tier == null,
                                    onSelected: (_) => setState(() {
                                      _vocation = id;
                                      _tier = null;
                                    }),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final (id, label) in const [
                                  (null, 'Todos os níveis'),
                                  (
                                    'tier1_editorial_reconstruction',
                                    'Nível 1 · Reconstrução primária',
                                  ),
                                  (
                                    'tier2_institutional_record',
                                    'Nível 2 · Votações nominais',
                                  ),
                                  (
                                    'tier3_preliminary_curation',
                                    'Nível 3 · Curadoria preliminar',
                                  ),
                                ])
                                  ChoiceChip(
                                    label: Text(label),
                                    selected: _tier == id,
                                    onSelected: (_) => setState(
                                      () => _tier = _tier == id ? null : id,
                                    ),
                                  ),
                              ],
                            ),
                          ],
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
                                if (constraints.maxWidth < 680) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        for (final spectrum in studySpectra)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            child: ChoiceChip(
                                              avatar: SpectrumBar(
                                                color: spectrum.color,
                                                height: 14,
                                                width: 4,
                                              ),
                                              label: Text(spectrum.name),
                                              selected:
                                                  _spectrum == spectrum.name,
                                              onSelected: (_) => setState(
                                                () => _spectrum =
                                                    _spectrum == spectrum.name
                                                    ? null
                                                    : spectrum.name,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }
                                const columns = 4;
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
                                        child: _SpectrumCard(
                                          spectrum: spectrum,
                                          count: subjects
                                              .where(
                                                (s) =>
                                                    s.current != null &&
                                                    spectrumOf(s)?.id ==
                                                        spectrum.id,
                                              )
                                              .length,
                                          selected: _spectrum == spectrum.name,
                                          onTap: () => setState(
                                            () => _spectrum =
                                                _spectrum == spectrum.name
                                                ? null
                                                : spectrum.name,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                          ],
                          if (_spectrum != null)
                            SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SpectrumBar(
                                        color:
                                            studySpectra
                                                .where(
                                                  (s) => s.name == _spectrum,
                                                )
                                                .firstOrNull
                                                ?.color ??
                                            p.accent,
                                        height: 24,
                                        width: 4,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _spectrum!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ),
                                    ],
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
                                  _tier = null;
                                  _vocation = null;
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
                    final bool groupByCategory = _kind == null && _spectrum == null;
                    final bool group = index == 0 ||
                        (groupByCategory
                            ? studyCategoryPriority(matches[index - 1]) !=
                                studyCategoryPriority(s)
                            : spectrumOf(matches[index - 1])?.id !=
                                spectrum?.id);
                    final String headerTitle = groupByCategory
                        ? studyCategorySectionTitle(s)
                        : (spectrum?.name ?? 'Outros verbetes');
                    final int headerCount = groupByCategory
                        ? (categorySectionCounts[studyCategoryPriority(s)] ?? 0)
                        : (spectrumCounts[spectrum?.id] ?? 0);
                    final Color headerColor = groupByCategory
                        ? p.accent
                        : (spectrum?.color ?? p.line);
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
                                      color: headerColor,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        headerTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    Text(
                                      '$headerCount',
                                      style: TextStyle(color: p.inkSoft),
                                    ),
                                  ],
                                ),
                              ),
                            StudySubjectTile(
                              subject: s,
                              portrait: vm.data.portraits[s.key],
                              onTap: () => _open(s),
                              trailing:
                                  (s.kind == 'current' ||
                                      s.key.startsWith('current:'))
                                  ? null
                                  : IconButton(
                                      tooltip: vm.studyFavorites.contains(s.key)
                                          ? 'Remover dos salvos'
                                          : 'Salvar verbete',
                                      onPressed: () =>
                                          vm.toggleStudyFavorite(s.key),
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

  Widget _buildStatBadge(
    BuildContext context,
    String value,
    String label,
    EspectroPalette p,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: p.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: p.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontFamily: 'IBMPlexMono',
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: p.inkSoft, fontSize: 12)),
        ],
      ),
    );
  }
}

class TwelveAxisDnaStrip extends StatelessWidget {
  const TwelveAxisDnaStrip({required this.axes, super.key});
  final Map<String, double> axes;

  static const List<(String, String, String, String, Color, Color)> _axisMeta =
      [
        (
          'estrutura',
          'Estrutura',
          'Federal',
          'Unitário',
          Color(0xFF6366F1),
          Color(0xFF8B5CF6),
        ),
        (
          'representacao',
          'Representação',
          'Democracia',
          'Autocracia',
          Color(0xFF3B82F6),
          Color(0xFFDC2626),
        ),
        (
          'poder',
          'Poder',
          'Segurança',
          'Liberdade',
          Color(0xFFD97706),
          Color(0xFF10B981),
        ),
        (
          'imigracao',
          'Imigração',
          'Assimilação',
          'Multicultura',
          Color(0xFFE11D48),
          Color(0xFF06B6D4),
        ),
        (
          'diplomacia',
          'Diplomacia',
          'Militarista',
          'Pacifista',
          Color(0xFFB91C1C),
          Color(0xFF059669),
        ),
        (
          'intervencao',
          'Intervenção',
          'Não interv.',
          'Nacionalista',
          Color(0xFF0284C7),
          Color(0xFFD97706),
        ),
        (
          'economia',
          'Economia',
          'Público',
          'Privado',
          Color(0xFFDC2626),
          Color(0xFF2563EB),
        ),
        (
          'controle',
          'Controle',
          'Planejamento',
          'Livre mercado',
          Color(0xFFBE123C),
          Color(0xFF0D9488),
        ),
        (
          'comercio',
          'Comércio',
          'Protecionismo',
          'Globalismo',
          Color(0xFFEA580C),
          Color(0xFF4F46E5),
        ),
        (
          'religiao',
          'Religião',
          'Irreligioso',
          'Religioso',
          Color(0xFF64748B),
          Color(0xFF9333EA),
        ),
        (
          'moral',
          'Moral',
          'Progressista',
          'Tradicionalista',
          Color(0xFFEC4899),
          Color(0xFF78350F),
        ),
        (
          'tecnologia',
          'Tecnologia',
          'Tecnologia',
          'Biologia',
          Color(0xFF0284C7),
          Color(0xFF16A34A),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (id, label, leftPole, rightPole, leftColor, rightColor)
              in _axisMeta) ...[
            _buildPill(
              context,
              id,
              label,
              leftPole,
              rightPole,
              leftColor,
              rightColor,
              p,
            ),
            if (id != 'tecnologia') const SizedBox(width: 3),
          ],
        ],
      ),
    );
  }

  Widget _buildPill(
    BuildContext context,
    String id,
    String label,
    String leftPole,
    String rightPole,
    Color leftColor,
    Color rightColor,
    EspectroPalette p,
  ) {
    final val = axes[id];
    if (val == null) {
      return Container(
        width: 7,
        height: 12,
        decoration: BoxDecoration(
          color: p.line.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
    final isRight = val > 0;
    final pole = isRight ? rightPole : leftPole;
    final color = isRight ? rightColor : leftColor;
    final intensity = val.abs().clamp(0.0, 1.0);
    final pct = (intensity * 100).round();

    return Tooltip(
      waitDuration: const Duration(milliseconds: 100),
      message: '$label: $pole $pct%',
      child: Container(
        width: 7,
        height: 12,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.35 + 0.65 * intensity),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class StudySubjectTile extends StatefulWidget {
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
  State<StudySubjectTile> createState() => _StudySubjectTileState();
}

class _StudySubjectTileState extends State<StudySubjectTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final subject = widget.subject;
    final spectrum = spectrumOf(subject);
    final isPersonality = subject.kind == 'personality';
    final isCurrent =
        subject.kind == 'current' || subject.key.startsWith('current:');
    final accentColor = spectrum?.color ?? p.accent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -3.0 : 0.0, 0),
          decoration: BoxDecoration(
            color: _isHovered
                ? (p.isDark
                      ? Color.alphaBlend(
                          accentColor.withValues(alpha: 0.08),
                          p.surface,
                        )
                      : Colors.white)
                : p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? accentColor.withValues(alpha: 0.65) : p.line,
              width: _isHovered ? 1.4 : 1.0,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: p.isDark ? 0.22 : 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : EspectroElevation.cardShadows(p),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.5),
            child: Stack(
              children: [
                if (!isCurrent)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    width: 3.5,
                    child: ColoredBox(
                      color: accentColor.withValues(alpha: _isHovered ? 0.95 : 0.7),
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(16),
                    hoverColor: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isCurrent ? 16 : 19,
                        16,
                        16,
                        16,
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StudyIdentityAvatar(
                          subject: subject,
                          portrait: widget.portrait,
                          size: isPersonality ? 64 : 52,
                          rectangular: isPersonality || subject.kind == 'book',
                          heroTag: 'avatar_${subject.key}',
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      subject.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ?widget.trailing,
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subject.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: p.inkSoft,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (spectrum != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: spectrum.color.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: spectrum.color.withValues(
                                            alpha: 0.35,
                                          ),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        spectrum.name.toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexMono',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: spectrum.ink(p.isDark),
                                        ),
                                      ),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: p.surfaceMuted,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: p.line,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      '${subject.coveredDimensions}/18 dim.',
                                      style: TextStyle(
                                        fontFamily: 'IBMPlexMono',
                                        fontSize: 9.5,
                                        color: p.inkSoft,
                                      ),
                                    ),
                                  ),
                                  if (subject.vocation case final voc?)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: p.accent.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: p.accent.withValues(alpha: 0.30),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        voc.shortLabel,
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexMono',
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: p.accent,
                                        ),
                                      ),
                                    ),
                                  if (subject.entry?.era case final era?
                                      when era.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: p.line.withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        era,
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexMono',
                                          fontSize: 10,
                                          color: p.inkSoft,
                                        ),
                                      ),
                                    ),
                                  if (subject
                                          .entry
                                          ?.editorialBasis
                                          ?.evidenceTier
                                      case final tier?)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: p.surfaceMuted,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: p.line,
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        tier == 'tier1_editorial_reconstruction'
                                            ? 'N1 · Reconstruído'
                                            : (tier == 'tier2_institutional_record'
                                                  ? 'N2 · Votos'
                                                  : 'N3 · Preliminar'),
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexMono',
                                          fontSize: 9.5,
                                          color: p.inkSoft,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (subject.summary.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        subject.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.42,
                          color: p.inkSoft,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        if (subject.axes.isNotEmpty)
                          TwelveAxisDnaStrip(axes: subject.axes)
                        else
                          Text(
                            subject.kindLabel,
                            style: TextStyle(fontSize: 11, color: p.muted),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ver perfil',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                            if (!isCurrent) ...[
                              const SizedBox(width: 4),
                              AnimatedSlide(
                                offset: Offset(_isHovered ? 0.25 : 0.0, 0),
                                duration: const Duration(milliseconds: 180),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpectrumCard extends StatefulWidget {
  const _SpectrumCard({
    required this.spectrum,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final StudySpectrum spectrum;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SpectrumCard> createState() => _SpectrumCardState();
}

class _SpectrumCardState extends State<_SpectrumCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bool active = widget.selected;
    final Color color = widget.spectrum.color;

    final Color inkAccent = widget.spectrum.ink(p.isDark);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: TactilePress(
        scale: 0.98,
        child: AnimatedContainer(
          duration: EspectroMotion.fast,
          curve: EspectroMotion.easeOut,
          clipBehavior: Clip.antiAlias,
          decoration: EspectroElevation.cardDecoration(
            p,
            color: active
                ? color.withValues(alpha: p.isDark ? 0.18 : 0.10)
                : (_hovered
                      ? Color.alphaBlend(
                          color.withValues(alpha: p.isDark ? 0.09 : 0.04),
                          p.surface,
                        )
                      : p.surface),
            borderColor: active
                ? color
                : (_hovered ? color.withValues(alpha: 0.65) : p.line),
            tint: (_hovered || active) ? color : p.ink,
            radius: 15,
            borderWidth: active ? 1.8 : (_hovered ? 1.3 : 1.0),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: widget.onTap,
              hoverColor: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(height: 3.5, color: color),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(
                                  alpha: p.isDark ? 0.18 : 0.10,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${widget.count}',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: inkAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.spectrum.name,
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: active ? inkAccent : p.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.spectrum.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.inkSoft,
                            fontSize: 11.5,
                            height: 1.32,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${widget.count} correntes →',
                          style: TextStyle(
                            color: active || _hovered ? inkAccent : p.muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}
