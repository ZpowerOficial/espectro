import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/study_sources.dart';
import '../../../domain/models/study_editorial_basis.dart';
import '../../../domain/models/study_link_uri.dart';

import '../../../domain/models/study_models.dart';
import '../../../domain/models/study_relations.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../view_models/app_view_model.dart';
import '../../ads/espectro_ad_units.dart';
import '../../ads/espectro_banner_ad.dart';
import '../../shared/resilient_image.dart';
import '../../charts/axis_colors.dart';
import '../../charts/study_ternary_chart.dart';
import '../compare/study_comparison_screen.dart';
import '../results/espectro_result_screen.dart';
import 'atlas_explorer_screen.dart';
import 'study_taxonomy.dart';
import 'study_identity.dart';

String studyProfileRoute(String key) =>
    Uri(path: '/atlas', queryParameters: {'v': '1', 'subject': key}).toString();
String publicStudyLink(String route) => buildPublicStudyLink(route);

Future<void> copyStudyLink(BuildContext context, String route) async {
  final link = publicStudyLink(route);
  await Clipboard.setData(ClipboardData(text: link));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          link.startsWith('http') ? 'Link copiado.' : 'Caminho copiado. Para obter um link completo, use a versão web.',
        ),
      ),
    );
  }
}

class StudyProfileScreen extends StatefulWidget {
  const StudyProfileScreen({
    required this.appViewModel,
    required this.subjectKey,
    this.initialTab = 0,
    super.key,
  });
  final AppViewModel appViewModel;
  final String subjectKey;
  final int initialTab;
  @override
  State<StudyProfileScreen> createState() => _StudyProfileScreenState();
}

class _StudyProfileScreenState extends State<StudyProfileScreen> {
  Map<String, StudyDimensionEvidence> _shardEvidence = const {};
  String? _loadedForKey;

  @override
  void initState() {
    super.initState();
    _ensureShardLoaded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.appViewModel.visitStudySubject(widget.subjectKey);
    });
  }

  @override
  void didUpdateWidget(covariant StudyProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subjectKey != widget.subjectKey) {
      _shardEvidence = const {};
      _loadedForKey = null;
      _ensureShardLoaded();
    }
  }

  void _ensureShardLoaded() {
    final catalog = StudyCatalog(
      widget.appViewModel.data,
      records: widget.appViewModel.history,
    );
    final s = catalog.find(widget.subjectKey);
    final basis = s?.current?.editorialBasis ?? s?.entry?.editorialBasis;
    final shard = basis?.dossierShard;
    if (shard == null || basis == null || _loadedForKey == widget.subjectKey) {
      return;
    }
    final targetKey = widget.subjectKey;
    _loadedForKey = targetKey;
    widget.appViewModel.data
        .loadDossierEvidence(
          targetKey,
          shard: shard,
          allowedSourceUrls: basis.sourceUrls,
        )
        .then((loaded) {
          if (mounted && _loadedForKey == targetKey && loaded.isNotEmpty) {
            setState(() => _shardEvidence = loaded);
          }
        });
  }

  void _open(StudySubject s) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: studyProfileRoute(s.key)),
      builder: (_) => StudyProfileScreen(
        appViewModel: widget.appViewModel,
        subjectKey: s.key,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.appViewModel,
    builder: (context, _) {
      final vm = widget.appViewModel, p = context.palette;
      final catalog = StudyCatalog(vm.data, records: vm.history);
      final s = catalog.find(widget.subjectKey);
      if (s == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Verbete indisponível')),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Este perfil não está no catálogo instalado. Avaliações pessoais só podem ser reabertas no dispositivo onde foram salvas.',
              ),
            ),
          ),
        );
      }
      final nearest = catalog.related(s, limit: catalog.subjects.length);
      final seenRelations = <String>{};
      final documented = relationsForStudy(s.key)
          .where(
            (r) =>
                catalog.find(r.targetKey) != null &&
                seenRelations.add(r.targetKey),
          )
          .toList();
      final traditions = documented
          .where((r) => r.kind == StudyRelationKind.tradition)
          .take(2)
          .toList();
      final spectrum = spectrumOf(s);
      final portrait = vm.data.portraits[s.key];
      final identityAccent = spectrum?.color ?? p.accent;
      final identityInk = spectrum?.ink(p.isDark) ?? p.accent;
      final evidence = evidenceForStudy(s.key);
      final rawBasis = s.current?.editorialBasis ?? s.entry?.editorialBasis;
      final basis = (_loadedForKey == s.key && _shardEvidence.isNotEmpty)
          ? rawBasis?.withDimensionEvidence(_shardEvidence)
          : rawBasis;
      final normalizedSubjectName = s.normalizedName;
      final normalizedSubjectSubtitle = StudyCatalog.normalize(s.subtitle);
      final authoredBooks = s.kind == 'personality'
          ? catalog.subjects
                .where(
                  (b) =>
                      b.kind == 'book' &&
                      StudyCatalog.normalize(b.subtitle) ==
                          normalizedSubjectName,
                )
                .toList()
          : const <StudySubject>[];
      final author = s.kind == 'book'
          ? catalog.subjects
                .where(
                  (b) =>
                      b.kind == 'personality' &&
                      b.normalizedName == normalizedSubjectSubtitle,
                )
                .toList()
          : const <StudySubject>[];
      final compactTabs = MediaQuery.sizeOf(context).width < 430;
      return DefaultTabController(
        length: 4,
        initialIndex: widget.initialTab.clamp(0, 3),
        child: EspectroScaffold(
          appViewModel: vm,
          selectedIndex: 2,
          appBar: AppBar(
            title: Row(
              children: [
                SpectrumBar(color: identityAccent, height: 22),
                const SizedBox(width: 10),
                Expanded(child: Text(s.kindLabel)),
              ],
            ),
            actions: [
              IconButton(
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
              if (s.record == null)
                IconButton(
                  tooltip: 'Copiar link do verbete',
                  onPressed: () =>
                      copyStudyLink(context, studyProfileRoute(s.key)),
                  icon: const Icon(Icons.link),
                ),
              const SizedBox(width: 6),
            ],
            bottom: FadeEdgeTabBar(
              edgeWidth: compactTabs ? 12 : 26,
              tabBar: TabBar(
                padding: EdgeInsets.symmetric(
                  horizontal: compactTabs ? 10 : 4,
                ),
                labelColor: identityInk,
                indicatorColor: identityAccent,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelPadding: EdgeInsets.symmetric(
                  horizontal: compactTabs ? 10 : 16,
                ),
                labelStyle: compactTabs
                    ? const TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      )
                    : null,
                unselectedLabelStyle: compactTabs
                    ? const TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      )
                    : null,
                tabs: const [
                  Tab(text: 'Visão geral'),
                  Tab(text: 'Dimensões'),
                  Tab(text: 'Conexões'),
                  Tab(text: 'Fontes e limites'),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _page([
                StudyIdentityHero(
                  subject: s,
                  portrait: portrait,
                  footer: s.axes.isEmpty
                      ? null
                      : TwelveAxisDnaStrip(axes: s.axes),
                ),
                if (portrait != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Retrato: ${portrait.author} · ${portrait.licenseName}',
                      style: TextStyle(color: p.inkSoft, fontSize: 11),
                    ),
                  ),
                const SizedBox(height: 18),
                if (s.entry case final entry?) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(entry.era)),
                      Chip(label: Text(entry.origin)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  s.summary,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(height: 1.6),
                ),
                if (documented.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _heading(context, 'Conexões documentadas'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final relation in documented.take(4))
                        ActionChip(
                          avatar: const Icon(Icons.link, size: 16),
                          label: Text(
                            catalog.find(relation.targetKey)?.name ??
                                relation.label,
                          ),
                          onPressed: () {
                            final target = catalog.find(relation.targetKey);
                            if (target != null) _open(target);
                          },
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 22),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    TactilePress(
                      scale: 0.97,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: identityAccent,
                          foregroundColor:
                              ThemeData.estimateBrightnessForColor(
                                    identityAccent,
                                  ) ==
                                  Brightness.dark
                              ? Colors.white
                              : const Color(0xFF151A20),
                        ),
                        onPressed: () async {
                          if (!vm.studyComparison.contains(s.key)) {
                            if (vm.studyComparison.length >= 3) {
                              final replace = await showDialog<String>(
                                context: context,
                                builder: (dialogContext) => SimpleDialog(
                                  title: const Text('Substituir um perfil'),
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        'A comparação comporta até três perfis. Escolha qual substituir.',
                                      ),
                                    ),
                                    for (final key in vm.studyComparison)
                                      SimpleDialogOption(
                                        onPressed: () =>
                                            Navigator.of(dialogContext).pop(key),
                                        child: Text(
                                          catalog.find(key)?.name ?? key,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                              if (replace == null || !context.mounted) return;
                              await vm.toggleStudyComparison(replace);
                            }
                            await vm.toggleStudyComparison(s.key);
                          }
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    StudyComparisonScreen(appViewModel: vm),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.compare_arrows),
                        label: const Text('Comparar perfil'),
                      ),
                    ),
                    if (s.record case final record?)
                      TactilePress(
                        scale: 0.97,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => EspectroResultScreen(
                                appViewModel: vm,
                                record: record,
                              ),
                            ),
                          ),
                          child: const Text('Abrir relatório completo'),
                        ),
                      ),
                    if (spectrum != null)
                      TactilePress(
                        scale: 0.97,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => AtlasExplorerScreen(
                                appViewModel: vm,
                                initialSpectrum: spectrum.name,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.explore_outlined, size: 16),
                          label: Text(spectrum.name),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.grid_view_rounded,
                            size: 14,
                            color: p.muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s.coverageLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: p.muted,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (s.kind == 'personality' &&
                          basis != null &&
                          basis.evidenceTier !=
                              'tier1_editorial_reconstruction')
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 14,
                              color: p.muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              basis.evidenceTierBadge,
                              style: TextStyle(fontSize: 12, color: p.muted),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (basis?.classificationNote case final classification?)
                  ExpansionTile(
                    title: const Text(
                      'Como este espectro foi escolhido',
                      style: TextStyle(fontSize: 13),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(classification),
                      ),
                    ],
                  ),
                if (s.current != null && s.ideas.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  SectionCard(
                    color: Color.alphaBlend(
                      identityAccent.withValues(alpha: .10),
                      p.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('Como um adepto resumiria'),
                        const SizedBox(height: 12),
                        Text(
                          '“Queremos uma sociedade orientada por ${s.ideas.first.replaceFirst(RegExp(r'[.!]$'), '').toLowerCase()}.”',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Paráfrase editorial baseada no primeiro princípio do catálogo. Não é citação histórica nem representa todas as variantes.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                if (traditions.isNotEmpty) ...[
                  _heading(context, 'Tradições de referência'),
                  for (final relation in traditions)
                    _relationCard(context, relation, catalog, vm),
                  const SizedBox(height: 20),
                ],
                _heading(
                  context,
                  s.kind == 'current'
                      ? 'Princípios e propostas'
                      : 'Pontos para investigar',
                ),
                for (final idea in s.ideas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: SpectrumBar(
                            color: identityAccent,
                            width: 3.5,
                            height: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(idea)),
                      ],
                    ),
                  ),
                if (s.entry?.quote case final quote?) ...[
                  const SizedBox(height: 12),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('Síntese do catálogo'),
                        const SizedBox(height: 10),
                        Text(quote),
                        const SizedBox(height: 10),
                        const Text(
                          'Texto editorial sem referência de página. Não deve ser reproduzido como citação literal da personalidade.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
                EspectroInlineAdSlot(
                  placementId: 'profile_content_inline',
                  adUnitId: EspectroAdUnits.detailBannerId,
                  verticalMargin: 24,
                ),
                const SizedBox(height: 26),
                _heading(context, 'Uma pergunta para continuar'),
                Text(
                  s.current != null
                      ? 'Que tensões aparecem ao aplicar estes princípios a sociedades diferentes? Explore as notas de cada dimensão e contraste correntes vizinhas.'
                      : 'O recorte temporal e a seleção de obras alteram esta leitura? Compare dimensões e verifique os limites da catalogação.',
                ),
                const SizedBox(height: 26),
                _heading(
                  context,
                  traditions.isNotEmpty
                      ? 'Continue pela tradição documentada'
                      : 'Próxima conexão no modelo',
                ),
                if (traditions.isNotEmpty)
                  StudySubjectTile(
                    subject: catalog.find(traditions.first.targetKey)!,
                    portrait: vm.data.portraits[traditions.first.targetKey],
                    onTap: () =>
                        _open(catalog.find(traditions.first.targetKey)!),
                  ),
                if (traditions.isEmpty && nearest.isNotEmpty)
                  StudySubjectTile(
                    subject: nearest.first.subject,
                    portrait: vm.data.portraits[nearest.first.subject.key],
                    onTap: () => _open(nearest.first.subject),
                  ),
                Text(
                  traditions.isNotEmpty
                      ? 'Relação intelectual documentada. Consulte a fonte em Conexões.'
                      : 'Sugestão por proximidade dimensional; não significa filiação ou influência.',
                ),
              ]),
              _page([
                const EditorialHeading(
                  eyebrow: 'POSIÇÕES DO PERFIL',
                  title: 'Doze eixos.\nMais de uma leitura.',
                  description: '−1 e +1 são os polos da escala. O centro não significa ausência de dados.',
                ),
                const SizedBox(height: 14),
                if (s.record == null)
                  Text(
                    basis?.evidenceTier == 'tier2_institutional_record'
                        ? '${basis!.dimensionEvidence.values.where((e) => e.isInstitutionalVote).length}/18 dimensões observadas em votações nominais / atos oficiais. Dimensões sem votação nominal permanecem ausentes.'
                        : (basis?.evidenceTier ==
                                  'tier3_preliminary_curation' &&
                              (basis?.dimensionEvidence.values
                                          .where((e) => e.hasDocumentedBasis)
                                          .length ??
                                      0) ==
                                  0)
                        ? '${basis!.evidenceTierBadge}: coordenadas estimadas em acervo de referência institucional; revisão por trecho pendente.'
                        : '${basis?.dimensionEvidence.values.where((e) => e.hasPrimarySupport).length ?? 0}/18 dimensões com leitura primária direta; ${basis?.dimensionEvidence.values.where((e) => e.isReconstructed).length ?? 0}/18 com reconstrução editorial documentada; ${basis?.dimensionEvidence.values.where((e) => e.isSynthesis).length ?? 0}/18 com síntese editorial ancorada em fonte registrada. Consulte as respostas e ressalvas em cada dimensão.',
                    style: TextStyle(color: p.inkSoft, fontSize: 12),
                  ),
                const SizedBox(height: 24),
                for (final axis in vm.data.twelveAxes.axes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StudyAxisRow(
                            axisId: axis.id,
                            label: axis.label,
                            left: axis.leftPole,
                            right: axis.rightPole,
                            leftColor: axis.leftColor,
                            rightColor: axis.rightColor,
                            values: [(s.name, s.displayAxes[axis.id])],
                            seriesPhotos: [s.photoUrl],
                            note:
                                s.current?.axes[axis.id]?.note ??
                                s.entry?.coordinateNotes[axis.id],
                          ),
                          _DimensionEvidenceView(
                            basis: basis,
                            dimension: 'axis:${axis.id}',
                            native: s.record != null,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 22),
                _heading(context, 'Seis tríades de valores'),
                Text(
                  s.record == null
                      ? 'Composições editoriais provisórias. A existência de um ponto não equivale a uma medição do autor; consulte a base documental abaixo de cada triângulo.'
                      : 'Composições obtidas das respostas locais, conforme a cobertura disponível.',
                ),
                const Text(
                  'Composição relativa de três valores. Somar 100% não implica apoio absoluto; no relatório pessoal a intensidade e a incerteza são apresentadas separadamente.',
                ),
                const SizedBox(height: 16),
                for (final triad in vm.data.sixTriangles.categories)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                AxisColors.triadIconFor(triad.id),
                                size: 17,
                                color: AxisColors.readableInk(
                                  p.triadColor(triad.id),
                                  isDark: p.isDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  triad.label,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: p
                                      .triadColor(triad.id)
                                      .withValues(alpha: p.isDark ? 0.16 : 0.10),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: p
                                        .triadColor(triad.id)
                                        .withValues(alpha: 0.38),
                                  ),
                                ),
                                child: Text(
                                  '△ Tríade',
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSans',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AxisColors.readableInk(
                                      p.triadColor(triad.id),
                                      isDark: p.isDark,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          StudyTernaryChart(
                            vertices: triad.subcategories,
                            series: [
                              StudyTernarySeries(
                                s.name,
                                s.displayTriangles[triad.id],
                                spectrumOf(s)?.color ?? p.accent,
                              ),
                            ],
                          ),
                          _DimensionEvidenceView(
                            basis: basis,
                            dimension: 'triad:${triad.id}',
                            native: s.record != null,
                          ),
                          if (s.current?.triangles[triad.id]?.note
                              case final note?)
                            Text(
                              note,
                              style: TextStyle(color: p.inkSoft, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ),
              ]),
              _page([
                const EditorialHeading(
                  eyebrow: 'CONEXÕES EXPLICÁVEIS',
                  title: 'Uma ideia leva\na outra.',
                  description: 'Autoria catalogada e semelhança numérica são relações diferentes.',
                ),
                const SizedBox(height: 24),
                _heading(context, 'Relações documentadas'),
                if (documented.isEmpty)
                  const Text(
                    'Ainda não há uma relação intelectual documentada para este verbete. A ausência dessa curadoria não significa ausência de vínculos históricos.',
                  ),
                for (final relation in documented.take(12))
                  _relationCard(context, relation, catalog, vm),
                if (documented.length > 12)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      'Mostrando 12 de ${documented.length} relações documentadas. '
                      'Use a busca do Atlas para encontrar outros vínculos por nome.',
                      style: TextStyle(color: p.inkSoft, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 22),
                _heading(context, 'Proximidade exploratória do modelo'),
                const Text(
                  'Os índices abaixo descrevem apenas as posições editoriais nas dimensões compartilhadas. Não identificam a escola de uma personalidade nem comprovam filiação, influência ou identidade histórica.',
                ),
                const SizedBox(height: 20),
                if (authoredBooks.isNotEmpty || author.isNotEmpty) ...[
                  _heading(context, 'Autoria registrada no catálogo'),
                  for (final item in [...author, ...authoredBooks])
                    StudySubjectTile(
                      subject: item,
                      portrait: vm.data.portraits[item.key],
                      onTap: () => _open(item),
                    ),
                  const SizedBox(height: 22),
                ],
                for (final kind in [
                  'current',
                  'personality',
                  'country',
                  'party',
                  'history',
                  'book',
                ]) ...[
                  if (nearest.any((m) => m.subject.kind == kind))
                    _heading(context, switch (kind) {
                      'current' => 'Correntes próximas',
                      'personality' => 'Personalidades próximas',
                      'country' => 'Recortes de países próximos',
                      'party' => 'Partidos e movimentos próximos',
                      'history' => 'Recortes históricos próximos',
                      _ => 'Biblioteca por proximidade',
                    }),
                  for (final match
                      in nearest
                          .where((m) => m.subject.kind == kind)
                          .take(3)) ...[
                    StudySubjectTile(
                      subject: match.subject,
                      portrait: vm.data.portraits[match.subject.key],
                      onTap: () => _open(match.subject),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 19, bottom: 14),
                      child: Text(
                        'Índice ${match.similarity.round()}/100 · '
                        '${match.sharedAxes} eixos e ${match.sharedTriads} tríades em comum'
                        '${match.twelveAxesAffinity == null ? '' : ' · 12 eixos ${match.twelveAxesAffinity!.percent.round()}/100 (${match.twelveAxesAffinity!.sharedAxes}/12)'}',
                        style: TextStyle(color: p.inkSoft, fontSize: 12),
                      ),
                    ),
                  ],
                ],
                _heading(context, 'Contrastes para estudar'),
                for (final match
                    in nearest.reversed
                        .where((m) => m.subject.kind == 'current')
                        .take(3))
                  StudySubjectTile(
                    subject: match.subject,
                    portrait: vm.data.portraits[match.subject.key],
                    onTap: () => _open(match.subject),
                  ),
                const SizedBox(height: 18),
                Text(
                  StudyCatalog.methodDescription,
                  style: TextStyle(color: p.inkSoft, fontSize: 12),
                ),
              ]),
              _page([
                const EditorialHeading(
                  eyebrow: 'PROVENIÊNCIA E INCERTEZA',
                  title: 'O que sabemos.\nO que falta verificar.',
                ),
                const SizedBox(height: 24),
                if (basis != null) ...[
                  _heading(context, 'Recorte e revisão editorial'),
                  Text(
                    basis.scope,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Registro editorial: ${basis.reviewedAt} · ${basis.evidenceTierBadge} · ${basis.empiricallyValidated ? 'Validação informada pelo catálogo' : 'Interpretação provisória, sem validação empírica'}',
                    style: TextStyle(color: p.inkSoft, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(basis.coordinateMethod),
                  if (basis.classificationNote case final note?) ...[
                    const SizedBox(height: 14),
                    _heading(context, 'Critério do espectro'),
                    Text(note),
                  ],
                  if (s.current != null && !basis.nativeMatchingEligible)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'Ficha de exploração editorial. Ainda não participa da classificação do resultado nativo; suas posições parciais não sustentam um diagnóstico completo.',
                      ),
                    ),
                  const SizedBox(height: 18),
                  _heading(context, 'Referências deste recorte'),
                  if (basis.sourceUrls.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Bibliografia específica pendente. Esta ficha ainda não tem documento vinculado; isso não é uma conclusão de que faltam fontes históricas.',
                      ),
                    ),
                  for (final url in basis.sourceUrls)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(basis.sourceTitles[url] ?? Uri.parse(url).host),
                          Text(
                            basis.dimensionEvidence.values.any(
                                  (e) =>
                                      e.hasDocumentedBasis &&
                                      e.sourceUrls.contains(url),
                                )
                                ? 'Documento primário · veja os trechos em Dimensões'
                                : 'Referência contextual ou leitura ainda a conferir',
                            style: TextStyle(color: p.inkSoft, fontSize: 11),
                          ),
                          if (basis.sourceMetadata[url] case final metadata?)
                            Text(
                              metadata,
                              style: TextStyle(color: p.inkSoft, fontSize: 11),
                            ),
                          SelectableText(
                            url,
                            style: TextStyle(color: p.accent, fontSize: 12),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              try {
                                final opened = await launchUrl(Uri.parse(url));
                                if (!opened && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Não foi possível abrir. Copie o endereço acima.',
                                      ),
                                    ),
                                  );
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Não foi possível abrir. Copie o endereço acima.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Consultar referência'),
                          ),
                        ],
                      ),
                    ),
                  for (final limitation in basis.limitations)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('• $limitation'),
                    ),
                  const SizedBox(height: 24),
                ],
                _heading(context, 'Origem desta ficha'),
                SelectableText(
                  'Catálogo offline do Espectro · versão ${vm.data.catalog.catalogVersion}\nChave: ${s.key}\nArquivo: ${s.current != null ? 'ideological_currents.json' : switch (s.kind) {
                          'personality' => 'personalities.json',
                          'country' => 'countries.json',
                          'party' => 'parties_movements.json',
                          'history' => 'historical_eras.json',
                          'book' => 'books_catalog.json',
                          _ => 'registro pessoal local',
                        }}',
                ),
                const SizedBox(height: 20),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow('Estado da evidência'),
                      const SizedBox(height: 12),
                      Text(
                        s.record != null
                            ? 'Resultado calculado a partir das respostas locais. Veja cobertura, intensidade e intervalos no relatório.'
                            : basis != null
                            ? 'Recorte, fontes contextuais, notas de interpretação e data de revisão estão disponíveis. Os valores numéricos são provisórios e não foram validados empiricamente; as leituras não justificam precisamente cada coordenada.'
                            : 'Síntese e coordenadas editoriais. Esta ficha ainda não registra fontes primárias por afirmação, justificativa bibliográfica por coordenada ou data de revisão.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'A posição de uma pessoa, partido ou país é um recorte interpretativo, não uma essência imutável nem uma medição empírica da população.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _heading(context, 'Limites que afetam a leitura'),
                const Text(
                  '• Proximidade calculada não comprova influência histórica.\n• Composições de tríades não medem intensidade absoluta.\n• A projeção em duas dimensões perde informação.\n• Famílias e espectros são ferramentas editoriais de navegação.\n• Fotografias e reproduções são identificadas pelo acervo e pela licença original.',
                ),
                const SizedBox(height: 24),
                _heading(context, 'Leituras primárias documentadas'),
                if (evidence.sources.isEmpty)
                  const Text(
                    'Ainda não há uma leitura primária vinculada documentalmente a esta ficha. As sugestões em Conexões são calculadas e têm outra função.',
                  ),
                for (final source in evidence.sources)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow(source.relation),
                          const SizedBox(height: 10),
                          Text(
                            source.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(source.period),
                          const SizedBox(height: 8),
                          Text(source.note),
                          const SizedBox(height: 10),
                          SelectableText(
                            source.url,
                            style: TextStyle(color: p.accent, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Referência conferida em ${source.verifiedOn}',
                            style: TextStyle(color: p.inkSoft, fontSize: 11),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              try {
                                final opened = await launchUrl(
                                  Uri.parse(source.url),
                                );
                                if (!opened && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Não foi possível abrir. Copie o endereço acima.',
                                      ),
                                    ),
                                  );
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Não foi possível abrir. Copie o endereço acima.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Abrir fonte original'),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(evidence.coordinateNote),
                const SizedBox(height: 24),
                _heading(context, 'Imagem e créditos'),
                if (portrait == null)
                  const Text(
                    'Este perfil ainda não possui um retrato verificado no acervo. A barra colorida identifica seu espectro editorial.',
                  ),
                if (portrait != null)
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Retrato de ${s.name}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Autoria: ${portrait.author}'),
                        Text('Licença: ${portrait.licenseName}'),
                        const SizedBox(height: 8),
                        Text(
                          portrait.changes,
                          style: TextStyle(color: p.inkSoft, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          portrait.sourceUrl,
                          style: TextStyle(color: identityInk, fontSize: 12),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  _launchSource(context, portrait.sourceUrl),
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('Acervo e autoria'),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  _launchSource(context, portrait.licenseUrl),
                              icon: const Icon(
                                Icons.description_outlined,
                                size: 16,
                              ),
                              label: const Text('Termos da licença'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                _heading(context, 'Como aprofundar'),
                const Text(
                  'Use a biblioteca para localizar obras e seus autores. Confronte a síntese com o texto original, uma edição identificada e o contexto histórico. As leituras sugeridas por proximidade não substituem referências documentais.',
                ),
                const SizedBox(height: 20),
                _heading(context, 'Método da comparação exploratória'),
                Text(StudyCatalog.methodDescription),
                const SizedBox(height: 20),
                _heading(context, 'Critérios para uma revisão documental'),
                const Text(
                  'Registrar edição, capítulo ou página, período analisado, justificativa da posição e divergências interpretativas. Cada relação histórica precisa de uma fonte própria; cada imagem, autoria e licença.',
                ),
              ]),
            ],
          ),
        ),
      );
    },
  );
  Widget _relationCard(
    BuildContext context,
    StudyRelation relation,
    StudyCatalog catalog,
    AppViewModel vm,
  ) {
    final target = catalog.find(relation.targetKey)!;
    final ink =
        spectrumOf(target)?.ink(context.palette.isDark) ??
        context.palette.accent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              relation.kind.label,
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 11.5,
                color: ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            StudySubjectTile(
              subject: target,
              portrait: vm.data.portraits[target.key],
              onTap: () => _open(target),
            ),
            Text(
              relation.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(relation.note),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _launchSource(context, relation.sourceUrl),
              icon: const Icon(Icons.open_in_new, size: 15),
              label: const Text('Consultar fonte desta relação'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchSource(BuildContext context, String url) async {
    try {
      if (await launchUrl(Uri.parse(url))) return;
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir. Copie o endereço da fonte.'),
        ),
      );
    }
  }

  Widget _page(List<Widget> children) => ResponsiveContentFrame(
    maxWidth: EspectroLayout.workspaceMaxWidth,
    child: ListView(
      padding: EspectroLayout.pagePadding,
      children: children,
    ),
  );
  Widget _heading(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}

/// Escala compartilhada no perfil e na comparação; ausências são explícitas.
class StudyAxisRow extends StatelessWidget {
  const StudyAxisRow({
    required this.label,
    required this.left,
    required this.right,
    required this.leftColor,
    required this.rightColor,
    required this.values,
    this.axisId,
    this.note,
    this.isOverlaid = false,
    this.seriesColors,
    this.seriesPhotos,
    super.key,
  });

  final String label, left, right;
  final Color leftColor, rightColor;
  final List<(String, double?)> values;
  final String? axisId;
  final String? note;
  final bool isOverlaid;
  final List<Color>? seriesColors;
  final List<String?>? seriesPhotos;

  static String? _inferAxisId(String label) {
    final lower = label.toLowerCase();
    if (lower.startsWith('estrutur')) return 'estrutura';
    if (lower.startsWith('representa')) return 'representacao';
    if (lower.startsWith('poder')) return 'poder';
    if (lower.startsWith('imigra')) return 'imigracao';
    if (lower.startsWith('diplom')) return 'diplomacia';
    if (lower.startsWith('interven')) return 'intervencao';
    if (lower.startsWith('econom')) return 'economia';
    if (lower.startsWith('control')) return 'controle';
    if (lower.startsWith('com')) return 'comercio';
    if (lower.startsWith('religi')) return 'religiao';
    if (lower.startsWith('moral')) return 'moral';
    if (lower.startsWith('tecnol')) return 'tecnologia';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final primaryValue = values.firstOrNull?.$2;
    final hasSingleValue = values.length == 1;
    final String? resolvedId = axisId ?? _inferAxisId(label);
    final AxisColorStrategy strategy = AxisColorStrategyScope.of(context);
    final bool primaryMode =
        strategy == AxisColorStrategy.primaryAnchor && resolvedId != null;
    final Color anchorColor =
        resolvedId != null ? AxisColors.primaryFor(resolvedId, p) : leftColor;
    final IconData? axisIcon =
        resolvedId != null ? AxisColors.icons[resolvedId] : null;

    // For single value: dominant pole & percentage
    final primaryNormalized = primaryValue != null
        ? ((primaryValue.clamp(-1.0, 1.0) + 1.0) / 2.0).clamp(0.0, 1.0)
        : null;
    final primaryLeansLeft = (primaryNormalized ?? 0.5) <= 0.5;
    final primaryDominantPole = primaryLeansLeft ? left : right;
    final Color effectiveLeftColor = primaryMode
        ? (hasSingleValue && primaryLeansLeft ? anchorColor : anchorColor)
        : leftColor;
    final Color effectiveRightColor = primaryMode ? p.line : rightColor;
    final primaryDominantColor = primaryMode
        ? anchorColor
        : (primaryLeansLeft ? leftColor : rightColor);
    final primaryDominantInk = AxisColors.readableInk(
      primaryDominantColor,
      isDark: p.isDark,
    );
    final headerInk = AxisColors.readableInk(
      hasSingleValue ? primaryDominantColor : effectiveLeftColor,
      isDark: p.isDark,
    );
    final primaryPercentage = primaryNormalized != null
        ? (primaryLeansLeft ? (1.0 - primaryNormalized) : primaryNormalized) *
              100
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Icon/Dot + Label + Dominant percentage (if single) + Info button
        Row(
          children: [
            if (axisIcon != null) ...[
              Icon(axisIcon, size: 15, color: headerInk),
              const SizedBox(width: 7),
            ] else ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: primaryDominantColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasSingleValue && primaryPercentage != null) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${primaryPercentage.round()}% $primaryDominantPole',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryDominantInk,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
            IconButton(
              tooltip: 'Entender $label',
              icon: const Icon(Icons.info_outline, size: 17),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () => showInfoSheet(
                context,
                title: label,
                child: Text(
                  '$left (−1) ↔ $right (+1). O ponto indica uma posição na escala. Dimensões ausentes não são substituídas pelo centro.\n\n${note ?? 'Posição editorial do catálogo. Consulte Fontes e limites para avaliar a evidência disponível.'}',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Value rows & Dual-track bars (Overlaid or Individual)
        if (isOverlaid && values.length > 1)
          _buildOverlaidTrack(
            context,
            p,
            trackLeftColor: effectiveLeftColor,
            trackRightColor: effectiveRightColor,
          )
        else
          for (final entry in values)
            _buildEntityTrack(
              context,
              entry,
              p,
              hasSingleValue,
              trackLeftColor: primaryMode
                  ? (primaryLeansLeft ? anchorColor : p.line)
                  : leftColor,
              trackRightColor: primaryMode
                  ? (!primaryLeansLeft ? anchorColor : p.line)
                  : rightColor,
            ),

        const SizedBox(height: 6),
        // Bottom Row: Two pole pills
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: PolePill(
                label: left,
                color: primaryMode && !primaryLeansLeft ? p.muted : effectiveLeftColor,
                isActive: primaryLeansLeft,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: PolePill(
                label: right,
                color: primaryMode && primaryLeansLeft ? p.muted : (primaryMode ? anchorColor : rightColor),
                isActive: !primaryLeansLeft,
              ),
            ),
          ],
        ),

        if (note != null) ...[
          const SizedBox(height: 6),
          Text(note!, style: TextStyle(color: p.inkSoft, fontSize: 11.5)),
        ],
      ],
    );
  }

  Widget _buildOverlaidTrack(
    BuildContext context,
    EspectroPalette p, {
    required Color trackLeftColor,
    required Color trackRightColor,
  }) {
    final validEntries = [
      for (var i = 0; i < values.length; i++)
        if (values[i].$2 != null) (i, values[i].$1, values[i].$2!),
    ];

    final defaultColors = [p.accent, p.poleRight, p.poleLeft];
    Color colorFor(int idx) =>
        (seriesColors != null && idx < seriesColors!.length)
        ? seriesColors![idx]
        : defaultColors[idx % defaultColors.length];
    String? photoFor(int idx) =>
        (seriesPhotos != null && idx < seriesPhotos!.length)
        ? seriesPhotos![idx]
        : null;

    Widget buildBadgeAvatar(
      int idx,
      Color col, {
      double size = 18,
      String? name,
    }) {
      final photo = photoFor(idx);
      if (photo != null && photo.isNotEmpty) {
        return ClipOval(
          child: buildResilientMediaImage(
            photo,
            width: size,
            height: size,
            fit: BoxFit.cover,
            fallback: _buildFallbackInitial(idx, col, size, name: name),
          ),
        );
      }
      return _buildFallbackInitial(idx, col, size, name: name);
    }

    int? deltaPp;
    if (validEntries.length >= 2) {
      final diff = (validEntries[0].$3 - validEntries[1].$3).abs();
      deltaPp = (diff / 2.0 * 100).round();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend badges row
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final item in validEntries)
              () {
                final idx = item.$1;
                final name = item.$2;
                final val = item.$3;
                final norm = ((val.clamp(-1.0, 1.0) + 1.0) / 2.0).clamp(
                  0.0,
                  1.0,
                );
                final leansL = norm <= 0.5;
                final domPole = leansL ? left : right;
                final pct = (leansL ? (1.0 - norm) : norm) * 100;
                final col = colorFor(idx);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: col.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: col.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: col,
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.center,
                        child: buildBadgeAvatar(idx, col, size: 18, name: name),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: p.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${pct.round()}% $domPole',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color.lerp(
                              col,
                              p.ink,
                              p.isDark ? 0.36 : 0.16,
                            )!,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }(),
            if (deltaPp != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: p.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: p.line.withValues(alpha: 0.6)),
                ),
                child: Text(
                  'Δ $deltaPp pp',
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: p.inkSoft,
                  ),
                ),
              ),
            for (var i = 0; i < values.length; i++)
              if (values[i].$2 == null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: p.surfaceMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${values[i].$1}: sem dados',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: p.muted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
          ],
        ),

        const SizedBox(height: 8),

        // Shared Overlaid Bar
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            const trackHeight = 8.0;
            const knobSize = 22.0;

            final positions = <(int, double, Color)>[];
            for (final item in validEntries) {
              final idx = item.$1;
              final val = item.$3;
              final norm = ((val.clamp(-1.0, 1.0) + 1.0) / 2.0).clamp(0.0, 1.0);
              final knobX = (norm * (trackWidth - knobSize)).clamp(
                0.0,
                trackWidth - knobSize,
              );
              positions.add((idx, knobX, colorFor(idx)));
            }

            return SizedBox(
              height: 28,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // Base Track
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
                            color: trackLeftColor.withValues(
                              alpha: p.isDark ? 0.38 : 0.32,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: trackRightColor.withValues(
                              alpha: p.isDark ? 0.38 : 0.32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Divider
                  Positioned(
                    left: trackWidth / 2 - 0.6,
                    top: (28 - trackHeight) / 2 - 2,
                    child: Container(
                      width: 1.2,
                      height: trackHeight + 4,
                      color: p.inkSoft.withValues(alpha: 0.4),
                    ),
                  ),

                  // Connecting bridge between knobs if 2 valid positions exist
                  if (positions.length >= 2) ...[
                    () {
                      final minX =
                          math.min(positions[0].$2, positions[1].$2) +
                          knobSize / 2;
                      final maxX =
                          math.max(positions[0].$2, positions[1].$2) +
                          knobSize / 2;
                      final spanW = math.max(0.0, maxX - minX);
                      return Positioned(
                        left: minX,
                        top: (28 - 4.0) / 2,
                        child: Container(
                          width: spanW,
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: p.accent.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }(),
                  ],

                  // Knobs for each entity
                  for (final pos in positions)
                    Positioned(
                      left: pos.$2,
                      top: (28 - knobSize) / 2,
                      child: Container(
                        width: knobSize,
                        height: knobSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pos.$3,
                          border: Border.all(color: Colors.white, width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: pos.$3.withValues(alpha: 0.45),
                              blurRadius: 4,
                              offset: const Offset(0, 1.5),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        alignment: Alignment.center,
                        child: buildBadgeAvatar(
                          pos.$1,
                          pos.$3,
                          size: knobSize,
                          name: pos.$1 < values.length
                              ? values[pos.$1].$1
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  static Widget _buildFallbackInitial(
    int idx,
    Color col,
    double size, {
    String? name,
  }) {
    if (idx == 0 || name == 'Você') {
      return Icon(Icons.person_rounded, size: size * 0.65, color: Colors.white);
    }
    final initials = (name != null && name.isNotEmpty)
        ? name
              .split(' ')
              .where((s) => s.isNotEmpty)
              .take(2)
              .map((s) => s.characters.first)
              .join()
        : '';
    return Text(
      initials,
      style: TextStyle(
        fontSize: initials.length > 1 ? size * 0.44 : size * 0.52,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        height: 1.0,
      ),
    );
  }

  Widget _buildEntityTrack(
    BuildContext context,
    (String, double?) entry,
    EspectroPalette p,
    bool hasSingleValue, {
    required Color trackLeftColor,
    required Color trackRightColor,
  }) {
    final val = entry.$2;
    final normalized = val != null
        ? ((val.clamp(-1.0, 1.0) + 1.0) / 2.0).clamp(0.0, 1.0)
        : null;
    final leansLeft = (normalized ?? 0.5) <= 0.5;
    final dominantPole = leansLeft ? left : right;
    final dominantColor = leansLeft ? trackLeftColor : trackRightColor;
    final dominantInk = AxisColors.readableInk(
      dominantColor,
      isDark: p.isDark,
    );
    final pct = normalized != null
        ? (leansLeft ? (1.0 - normalized) : normalized) * 100
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hasSingleValue) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    entry.$1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  pct != null ? '${pct.round()}% $dominantPole' : 'Sem posição',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: pct != null ? dominantInk : p.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (normalized != null) ...[
          Semantics(
            label:
                '${entry.$1}: ${val!.toStringAsFixed(2)} entre $left e $right',
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final trackWidth = constraints.maxWidth;
                  const trackHeight = 7.0;
                  const knobSize = 14.0;
                  final knobX = (normalized * (trackWidth - knobSize)).clamp(
                    0.0,
                    trackWidth - knobSize,
                  );

                  return SizedBox(
                    height: knobSize,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: trackHeight,
                          width: trackWidth,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              trackHeight / 2,
                            ),
                            color: p.surfaceMuted,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  color: trackLeftColor.withValues(
                                    alpha: leansLeft ? 0.85 : 0.22,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: trackRightColor.withValues(
                                    alpha: !leansLeft ? 0.85 : 0.22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: trackWidth / 2 - 0.5,
                          top: (knobSize - trackHeight) / 2 - 1,
                          child: Container(
                            width: 1,
                            height: trackHeight + 2,
                            color: Colors.white.withValues(alpha: 0.7),
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
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 3.5,
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
            ),
          ),
        ] else if (hasSingleValue) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Sem posição documentada',
              style: TextStyle(
                color: p.inkSoft,
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The same evidence standard applies to every political tradition.
class _DimensionEvidenceView extends StatelessWidget {
  const _DimensionEvidenceView({
    required this.basis,
    required this.dimension,
    this.native = false,
  });
  final StudyEditorialBasis? basis;
  final String dimension;
  final bool native;
  @override
  Widget build(BuildContext context) {
    if (native) {
      return const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text(
          'Origem: respostas locais da avaliação. Valores ausentes seguem as regras de cobertura do instrumento.',
          style: TextStyle(fontSize: 11),
        ),
      );
    }
    final evidence = basis?.dimensionEvidence[dimension];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            title: Text(
              evidence?.isReconstructed == true
                  ? 'Respostas reconstruídas e fontes'
                  : evidence?.isInstitutionalVote == true
                  ? 'Votações nominais e registro oficial'
                  : evidence?.hasPrimarySupport == true
                  ? 'Fonte primária e interpretação'
                  : evidence?.isSynthesis == true
                  ? 'Síntese editorial e fonte registrada'
                  : 'Base documental desta dimensão',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              evidence?.hasDocumentedBasis == true
                  ? evidence!.locator
                  : evidence?.status == 'insufficient'
                  ? 'O recorte consultado não permite fixar uma posição'
                  : 'Revisão por dimensão pendente',
              style: const TextStyle(fontSize: 11),
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                container: true,
                explicitChildNodes: true,
                label: [
                  evidence?.rationale ?? 'Esta dimensão ainda não foi revisada por documento e trecho. Isso não significa que inexista evidência histórica.',
                  if (evidence != null)
                    for (final url in evidence.sourceUrls)
                      '${basis!.sourceTitles[url] ?? Uri.parse(url).host}. ${basis!.sourceMetadata[url] ?? ''}. $url',
                ].join(' '),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evidence?.rationale ?? 'Esta dimensão ainda não foi revisada por documento e trecho. Isso não significa que inexista evidência histórica. Valores exibidos são estimativas editoriais preexistentes e ainda precisam dessa conferência.',
                    ),
                    if (evidence?.isSynthesis == true) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Síntese editorial da doutrina a partir da fonte registrada. O localizador indica o eixo temático, não uma citação literal página a página; o autor não respondeu ao questionário do Espectro.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (evidence?.isReconstructed == true) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Simulação editorial: o autor não respondeu ao teste. As respostas abaixo traduzem a leitura das fontes para o banco do Espectro; as intensidades e a seleção dos itens podem ser questionadas.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      for (final answer in evidence!.reconstructedAnswers)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(answer.statement),
                              Text(
                                'Resposta atribuída: ${answer.answerLabel}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                answer.rationale,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                    if (evidence != null)
                      for (final url in evidence.sourceUrls) ...[
                        const SizedBox(height: 8),
                        Text(basis!.sourceTitles[url] ?? Uri.parse(url).host),
                        if (basis!.sourceMetadata[url] case final metadata?)
                          Text(
                            metadata,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.palette.inkSoft,
                            ),
                          ),
                        SelectableText(
                          url,
                          style: const TextStyle(fontSize: 11),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await launchUrl(Uri.parse(url));
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Não foi possível abrir. Copie o endereço da referência.',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Abrir documento'),
                        ),
                      ],
                    const SizedBox(height: 8),
                    const Text(
                      'O documento fundamenta a leitura qualitativa. As coordenadas e proporções são estimativas do Espectro, não percentuais publicados pelo autor.',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
