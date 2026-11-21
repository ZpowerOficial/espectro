import 'package:flutter/material.dart';

import '../../../domain/models/study_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../view_models/app_view_model.dart';
import '../../charts/axis_colors.dart';
import '../../charts/study_ternary_chart.dart';
import '../../charts/study_comparative_radar_chart.dart';
import '../../shared/metric_presentation.dart';
import '../atlas/study_taxonomy.dart';
import '../atlas/study_profile_screen.dart';
import '../atlas/study_identity.dart';

/// Comparação livre de posições do catálogo e, por escolha, registros locais.
class StudyComparisonScreen extends StatefulWidget {
  const StudyComparisonScreen({
    required this.appViewModel,
    this.initialKeys,
    super.key,
  });
  final AppViewModel appViewModel;
  final List<String>? initialKeys;
  @override
  State<StudyComparisonScreen> createState() => _StudyComparisonScreenState();
}

class _StudyComparisonScreenState extends State<StudyComparisonScreen> {
  final _query = TextEditingController();
  List<String>? _linkedKeys;
  bool _overlayAxes = true;
  bool _overlayTriads = true;

  List<Color> _resolveSubjectColors(List<StudySubject> list, EspectroPalette p) {
    final paletteFallbacks = [
      p.accent,
      p.poleLeft,
      p.isDark ? const Color(0xFFE5A64B) : const Color(0xFFB46B1E),
      const Color(0xFF4284D1),
    ];
    final colors = <Color>[];
    final used = <Color>{};
    for (var i = 0; i < list.length; i++) {
      final specColor = spectrumOf(list[i])?.color;
      if (specColor != null && !used.contains(specColor)) {
        colors.add(specColor);
        used.add(specColor);
      } else {
        final fallback = paletteFallbacks.firstWhere(
          (c) => !used.contains(c),
          orElse: () => paletteFallbacks[i % paletteFallbacks.length],
        );
        colors.add(fallback);
        used.add(fallback);
      }
    }
    return colors;
  }
  @override
  void initState() {
    super.initState();
    _linkedKeys = widget.initialKeys?.take(3).toList();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<String> get _keys => _linkedKeys ?? widget.appViewModel.studyComparison;
  void _toggle(String key) {
    if (_linkedKeys != null) {
      setState(() {
        if (_linkedKeys!.contains(key)) {
          _linkedKeys!.remove(key);
        } else if (_linkedKeys!.length < 3) {
          _linkedKeys!.add(key);
        }
      });
    } else {
      widget.appViewModel.toggleStudyComparison(key);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.appViewModel,
    builder: (context, _) {
      final vm = widget.appViewModel, p = context.palette;
      final catalog = StudyCatalog(vm.data, records: vm.history);
      final selected = [for (final key in _keys) ?catalog.find(key)];
      final missing = _keys.where((key) => catalog.find(key) == null).toList();
      final results = catalog
          .search(_query.text)
          .where((s) => !selected.any((v) => s.key == v.key))
          .take(18)
          .toList();
      final subjectColors = _resolveSubjectColors(selected, p);
      return EspectroScaffold(
        appViewModel: vm,
        selectedIndex: 4,
        isSectionRoot: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: EspectroLayout.pageHorizontalPadding,
          title: const Text('Comparação livre'),
          actions: [
            if (selected.length >= 2 && selected.every((s) => s.record == null))
              IconButton(
                tooltip: 'Copiar link da comparação',
                icon: const Icon(Icons.link),
                onPressed: () => copyStudyLink(
                  context,
                  Uri(
                    path: '/compare',
                    queryParameters: {
                      'v': '1',
                      'items': selected.map((s) => s.key).join(','),
                    },
                  ).toString(),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: ResponsiveContentFrame(
            maxWidth: EspectroLayout.workspaceMaxWidth,
            child: ListView(
              padding: EspectroLayout.pagePadding,
              children: [
                  const EditorialHeading(
                    eyebrow: 'Comparação lado a lado',
                    title: 'Compare ideias.\nEncontre as diferenças.',
                    description: 'Escolha de dois a três perfis. Correntes, pessoas, países, obras e suas avaliações podem ocupar a mesma escala.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in selected)
                        InputChip(
                          avatar: StudyIdentityAvatar(
                            subject: s,
                            size: 20,
                            rectangular: s.kind == 'personality' || s.kind == 'book',
                          ),
                          label: Text(s.name),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => StudyProfileScreen(
                                appViewModel: vm,
                                subjectKey: s.key,
                              ),
                            ),
                          ),
                          onDeleted: () => _toggle(s.key),
                        ),
                      for (final key in missing)
                        InputChip(
                          label: Text('Indisponível: $key'),
                          onDeleted: () => _toggle(key),
                        ),
                    ],
                  ),
                  if (missing.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Alguns perfis deste link não estão no catálogo instalado. Registros pessoais exigem o dispositivo original.',
                      ),
                    ),
                  const SizedBox(height: EspectroLayout.controlGap),
                  if (_keys.length < 3) ...[
                    TextField(
                      controller: _query,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Adicionar um perfil',
                        hintText: 'Busque qualquer nome ou ideia',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    if (selected.length < 2 ||
                        _query.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: selected.isEmpty ? 270 : 180,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: p.line),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Material(
                              color: p.surface,
                              child: ListView.builder(
                                itemCount: results.length,
                                itemBuilder: (context, i) => ListTile(
                                  dense: true,
                                  leading: StudyIdentityAvatar(
                                    subject: results[i],
                                    size: 32,
                                    rectangular:
                                        results[i].kind == 'personality' ||
                                        results[i].kind == 'book',
                                  ),
                                  title: Text(results[i].name),
                                  subtitle: Text(results[i].kindLabel),
                                  trailing: const Icon(
                                    Icons.add_circle_outline,
                                  ),
                                  onTap: () {
                                    _toggle(results[i].key);
                                    _query.clear();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (results.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'Nenhum perfil encontrado. Experimente outro termo.',
                          ),
                        ),
                    ] else if (results.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      if (MediaQuery.sizeOf(context).width < 680) ...[
                        Text(
                          'Adicionar 3º perfil:',
                          style: TextStyle(
                            fontFamily: 'IBMPlexMono',
                            fontSize: 10.5,
                            color: p.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          key: const Key('comparacao-mobile-suggestions-rail'),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0; i < results.take(4).length; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                ActionChip(
                                  avatar: const Icon(
                                    Icons.add_rounded,
                                    size: 15,
                                  ),
                                  label: Text(
                                    results[i].name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  onPressed: () {
                                    _toggle(results[i].key);
                                    _query.clear();
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ] else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Adicionar 3º perfil:',
                              style: TextStyle(
                                fontFamily: 'IBMPlexMono',
                                fontSize: 10.5,
                                color: p.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            for (final candidate in results.take(4))
                              ActionChip(
                                avatar: const Icon(Icons.add_rounded, size: 15),
                                label: Text(
                                  candidate.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  _toggle(candidate.key);
                                  _query.clear();
                                },
                              ),
                          ],
                        ),
                    ],
                  ] else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          if (_linkedKeys != null) {
                            setState(() => _linkedKeys = []);
                          } else {
                            vm.clearStudyComparison();
                          }
                        },
                        child: const Text('Limpar seleção'),
                      ),
                    ),
                  if (selected.length < 2)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Text(
                        'Adicione ao menos dois perfis para revelar convergências e contrastes. Nenhum teste é necessário.',
                      ),
                    ),
                  if (selected.length >= 2) ...[
                    const SizedBox(height: EspectroLayout.sectionGap),
                    Text(
                      'Proximidade por par',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: EspectroLayout.headerToContentGap),
                    for (final (int pIdx, (StudySubject, StudySubject) pair)
                        in <(StudySubject, StudySubject)>[
                      for (var i = 0; i < selected.length; i++)
                        for (var j = i + 1; j < selected.length; j++)
                          (selected[i], selected[j]),
                    ].indexed) ...[
                      if (pIdx > 0)
                        const SizedBox(height: EspectroLayout.cardGap),
                      _pair(context, catalog, pair.$1, pair.$2),
                    ],
                    const SizedBox(height: EspectroLayout.sectionGap),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.line),
                      ),
                      child: LayoutBuilder(
                        builder: (context, radarBox) {
                          final bool sideBySide = radarBox.maxWidth >= 700;
                          final Widget chart = Center(
                            child: StudyComparativeRadarChart(
                              axes: vm.data.twelveAxes.axes,
                              subjects: selected,
                              colors: subjectColors,
                              size: sideBySide ? 350 : 280,
                            ),
                          );
                          final Widget legend = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Visão em teia: 12 eixos sobrepostos',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sobreposição simultânea dos 12 eixos na teia radial, revelando áreas de convergência e polos divergentes. As legendas clicáveis abaixo da teia identificam cada perfil.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          );
                          if (sideBySide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(flex: 5, child: legend),
                                const SizedBox(width: 20),
                                Expanded(flex: 6, child: chart),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              legend,
                              const SizedBox(height: 12),
                              chart,
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: EspectroLayout.sectionGap),
                    Text(
                      'Mesmos eixos, mesma régua',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            'A ausência de evidência não vira uma posição neutra. Posições de catálogo são editoriais; avaliações pessoais vêm das respostas.',
                          ),
                        ),
                        const SizedBox(width: 16),
                        SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: true,
                              label: Text('Sobrepor',
                                  style: TextStyle(fontSize: 12)),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text('Separados',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                          selected: {_overlayAxes},
                          onSelectionChanged: (set) =>
                              setState(() => _overlayAxes = set.first),
                        ),
                      ],
                    ),
                    const SizedBox(height: EspectroLayout.headerToContentGap),
                    for (var aIdx = 0;
                        aIdx < vm.data.twelveAxes.axes.length;
                        aIdx++)
                      () {
                        final axis = vm.data.twelveAxes.axes[aIdx];
                        final bool isLast =
                            aIdx == vm.data.twelveAxes.axes.length - 1;
                        return Container(
                          margin: EdgeInsets.only(
                            bottom: isLast ? 0 : EspectroLayout.cardGap,
                          ),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: p.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: p.line),
                            boxShadow: EspectroElevation.cardShadows(p),
                          ),
                          child: StudyAxisRow(
                            axisId: axis.id,
                            label: axis.label,
                            left: axis.leftPole,
                            right: axis.rightPole,
                            leftColor: axis.leftColor,
                            rightColor: axis.rightColor,
                            isOverlaid: _overlayAxes,
                            seriesColors: subjectColors,
                            seriesPhotos: [
                              for (final s in selected) s.photoUrl,
                            ],
                            values: [
                              for (final s in selected)
                                (s.name, s.displayAxes[axis.id]),
                            ],
                          ),
                        );
                      }(),

                    const SizedBox(height: EspectroLayout.sectionGap),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tríades: composições relativas',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Cada triângulo mapeia a distribuição proporcional entre 3 polos conceituais na mesma escala.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: true,
                              label: Text('Sobrepor',
                                  style: TextStyle(fontSize: 12)),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text('Simples',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                          selected: {_overlayTriads},
                          onSelectionChanged: (set) =>
                              setState(() => _overlayTriads = set.first),
                        ),
                      ],
                    ),
                    const SizedBox(height: EspectroLayout.headerToContentGap),
                    for (var tIdx = 0;
                        tIdx < vm.data.sixTriangles.categories.length;
                        tIdx++)
                      () {
                        final triad = vm.data.sixTriangles.categories[tIdx];
                        final bool isLast =
                            tIdx == vm.data.sixTriangles.categories.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: isLast ? 0 : EspectroLayout.cardGap,
                          ),
                          child: SectionCard(
                            radius: 14,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  triad.label,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  triad.subcategories.join(' / '),
                                  style: TextStyle(color: p.muted, fontSize: 12),
                                ),
                                const SizedBox(height: 14),
                                StudyTernaryChart(
                                  vertices: triad.subcategories,
                                  isOverlaid: _overlayTriads,
                                  series: [
                                    for (var sIdx = 0;
                                        sIdx < selected.length;
                                        sIdx++)
                                      StudyTernarySeries(
                                        selected[sIdx].name,
                                        selected[sIdx]
                                            .displayTriangles[triad.id],
                                        sIdx < subjectColors.length
                                            ? subjectColors[sIdx]
                                            : p.accent,
                                        photoUrl: selected[sIdx].photoUrl,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        );
                      }(),
                    const SizedBox(height: EspectroLayout.sectionGap),
                    SectionCard(
                      radius: 14,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('Como ler a comparação'),
                          const SizedBox(height: 12),
                          Text(StudyCatalog.methodDescription),
                          const SizedBox(height: 12),
                          const Text(
                            'Este índice de estudo não substitui as afinidades, a cobertura e os intervalos do relatório pessoal.',
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (vm.studyStorageError != null)
                    Text(
                      vm.studyStorageError!,
                      style: TextStyle(color: p.warning),
                    ),
                ],
            ),
          ),
        ),
      );
    },
  );
  Widget _pair(
    BuildContext context,
    StudyCatalog catalog,
    StudySubject a,
    StudySubject b,
  ) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final match = catalog.compare(a, b);
    final Color colorA = spectrumOf(a)?.color ?? p.accent;
    final Color colorB = spectrumOf(b)?.color ?? p.poleRight;
    final String? simPctLabel = match == null
        ? null
        : MetricPresentation.formatPercent(match.similarity);

    Widget buildDimensionRows({
      required List<StudyComparisonDimension> details,
      required List<String> fallbackTexts,
      required String descriptor,
      required Color tagColor,
    }) {
      if (details.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in details)
              () {
                final Color dimColor = item.isTriad
                    ? p.triadColor(item.triadCategoryId ?? 0)
                    : (item.axisId != null
                          ? AxisColors.pairFor(item.axisId!, p).$1
                          : tagColor);
                final Color dimInk = AxisColors.readableInk(
                  dimColor,
                  isDark: p.isDark,
                );
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: p.line)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: dimColor.withValues(
                                alpha: p.isDark ? 0.16 : 0.10,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.isTriad
                                      ? AxisColors.triadIconFor(
                                          item.triadCategoryId ?? 0,
                                        )
                                      : AxisColors.iconFor(item.axisId ?? ''),
                                  size: 11,
                                  color: dimInk,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.componentLabel.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexMono',
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                    color: dimInk,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item.qualifiedLabel,
                            style: text.bodySmall?.copyWith(
                              color: p.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$descriptor (${item.distancePercent}% da distância máxima).',
                        style: text.bodySmall?.copyWith(
                          color: p.inkSoft,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }(),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in fallbackTexts)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: p.line)),
              ),
              child: Text(
                item,
                style: text.bodySmall?.copyWith(color: p.ink),
              ),
            ),
        ],
      );
    }

    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: ColoredBox(color: colorA)),
                const SizedBox(width: 2),
                Expanded(child: ColoredBox(color: colorB)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, headerBox) {
                      final bool stackScore =
                          MediaQuery.textScalerOf(context).scale(1) > 1.35 ||
                          headerBox.maxWidth < 300;
                      final Widget titleWidget = Text(
                        '${a.name} × ${b.name}',
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      );
                      final Widget? scoreWidget = simPctLabel == null
                          ? null
                          : Column(
                              crossAxisAlignment: stackScore
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Text(
                                  simPctLabel,
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexMono',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                    color: p.accent,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'prox. exploratória',
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexMono',
                                          fontSize: 10,
                                          color: p.muted,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const MetricInfoBadge(
                                      tooltip: MetricPresentation
                                          .exploratorySimilarityTooltip,
                                      semanticLabel:
                                          'Explicação sobre proximidade exploratória',
                                      size: 13,
                                    ),
                                  ],
                                ),
                              ],
                            );
                      if (stackScore) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleWidget,
                            if (scoreWidget != null) ...[
                              const SizedBox(height: 8),
                              scoreWidget,
                            ],
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: titleWidget),
                          if (scoreWidget != null) ...[
                            const SizedBox(width: 14),
                            scoreWidget,
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  if (match == null)
                    const Text(
                      'Não há dimensões em comum suficientes para calcular proximidade.',
                    )
                  else ...[
                    Text(
                      '${match.sharedAxes} eixos e ${match.sharedTriads} tríades (${MetricPresentation.formatPercent(match.coverage * 100)} de sobreposição disponível) · proximidade geométrica 100 × (1 − RMSD).',
                      style: text.bodySmall?.copyWith(color: p.inkSoft),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, colBox) {
                        final bool split = colBox.maxWidth >= 600;
                        final Widget convList = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Convergências',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: p.poleLeft,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (match.similarities.isEmpty &&
                                match.similarityDetails.isEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: p.line)),
                                ),
                                child: Text(
                                  'Sem convergências fortes observadas.',
                                  style: text.bodySmall,
                                ),
                              )
                            else
                              buildDimensionRows(
                                details: match.similarityDetails,
                                fallbackTexts: match.similarities,
                                descriptor: 'Posições próximas',
                                tagColor: p.poleLeft,
                              ),
                          ],
                        );
                        final Widget diffList = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contrastes',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: p.poleRight,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (match.differences.isEmpty &&
                                match.differenceDetails.isEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: p.line)),
                                ),
                                child: Text(
                                  'Nenhuma divergência acima do limiar exploratório de 25% da distância máxima.',
                                  style: text.bodySmall?.copyWith(color: p.ink),
                                ),
                              )
                            else
                              buildDimensionRows(
                                details: match.differenceDetails,
                                fallbackTexts: match.differences,
                                descriptor: 'Posições distintas',
                                tagColor: p.poleRight,
                              ),
                          ],
                        );
                        if (split) {
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: convList),
                                Container(
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  color: p.line,
                                ),
                                Expanded(child: diffList),
                              ],
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            convList,
                            const SizedBox(height: 16),
                            diffList,
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
    );
  }
}
