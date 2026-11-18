import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/models/study_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../view_models/app_view_model.dart';
import '../../charts/study_ternary_chart.dart';
import '../../charts/study_comparative_radar_chart.dart';
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
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final hPad = math.max(22.0, (constraints.maxWidth - 1000.0) / 2);
              return ListView(
                padding: EdgeInsets.fromLTRB(hPad, 22, hPad, 22),
                children: [
                  const EditorialHeading(
                    eyebrow: 'LADO A LADO',
                    title: 'Compare ideias.\nEncontre as diferenças.',
                    description: 'Escolha de dois a três perfis. Correntes, pessoas, países, obras e suas avaliações podem ocupar a mesma escala.',
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 18),
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
                      const SizedBox(height: 10),
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
                    const SizedBox(height: 24),
                    Text(
                      'Proximidade por par',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < selected.length; i++)
                      for (var j = i + 1; j < selected.length; j++)
                        _pair(context, catalog, selected[i], selected[j]),
                    const SizedBox(height: 24),
                    SectionCard(
                      child: LayoutBuilder(
                        builder: (context, radarBox) {
                          final bool sideBySide = radarBox.maxWidth >= 680;
                          final Widget chart = Center(
                            child: StudyComparativeRadarChart(
                              axes: vm.data.twelveAxes.axes,
                              subjects: selected,
                              colors: subjectColors,
                            ),
                          );
                          final Widget legend = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Eyebrow('SOBREPOSIÇÃO EM 12 EIXOS', color: p.accent),
                              const SizedBox(height: 6),
                              Text(
                                'Visão em teia: 12 eixos sobrepostos',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sobreposição simultânea dos 12 eixos na teia radial, revelando áreas de convergência e polos divergentes.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                children: [
                                  for (var i = 0; i < selected.length; i++)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: subjectColors[i],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          selected[i].name,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: p.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
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
                    const SizedBox(height: 24),
                    Text(
                      'Mesmos eixos, mesma régua',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 18),
                    for (final axis in vm.data.twelveAxes.axes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SectionCard(
                          child: StudyAxisRow(
                            label: axis.label,
                            left: axis.leftPole,
                            right: axis.rightPole,
                            leftColor: axis.leftColor,
                            rightColor: axis.rightColor,
                            isOverlaid: _overlayAxes,
                            seriesColors: subjectColors,
                            seriesPhotos: [for (final s in selected) s.photoUrl],
                            values: [
                              for (final s in selected)
                                (s.name, s.displayAxes[axis.id]),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    for (final triad in vm.data.sixTriangles.categories)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SectionCard(
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
                                      selected[sIdx].displayTriangles[triad.id],
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
                      ),
                    const SizedBox(height: 18),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('COMO LER A COMPARAÇÃO'),
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
              );
            },
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
    final int? simPct = match?.similarity.round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: EspectroElevation.cardShadows(p),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Container(
                color: p.surface,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${a.name} × ${b.name}',
                            style: text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (simPct != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: p.accentSoft,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: p.accent.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                '$simPct%',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: p.accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (match == null)
                        const Text(
                          'Não há dimensões em comum suficientes para calcular proximidade.',
                        )
                      else ...[
                        ProgressRail(
                          value: (match.similarity / 100.0).clamp(0.0, 1.0),
                          color: p.accent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${match.sharedAxes} eixos · ${match.sharedTriads} tríades · ${(match.coverage * 100).round()}% de sobreposição disponível',
                          style: text.bodySmall?.copyWith(
                            fontFamily: 'IBMPlexMono',
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, colBox) {
                            final bool split = colBox.maxWidth >= 600;
                            final Widget convPanel = Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: p.success.withValues(
                                  alpha: p.isDark ? 0.12 : 0.06,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: p.success.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 16,
                                        color: p.success,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Convergências',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: p.success,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (match.similarities.isEmpty)
                                    Text(
                                      'Sem convergências fortes observadas.',
                                      style: text.bodySmall,
                                    )
                                  else
                                    for (final item in match.similarities)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          item,
                                          style: text.bodySmall?.copyWith(
                                            color: p.ink,
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            );
                            final Widget diffPanel = Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: p.warning.withValues(
                                  alpha: p.isDark ? 0.12 : 0.07,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: p.warning.withValues(alpha: 0.32),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.compare_arrows_rounded,
                                        size: 16,
                                        color: p.warning,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Contrastes',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: p.warning,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (match.differences.isEmpty)
                                    Text(
                                      'Nenhuma divergência acima do limiar exploratório de 25% da distância máxima.',
                                      style: text.bodySmall?.copyWith(
                                        color: p.ink,
                                      ),
                                    )
                                  else
                                    for (final item in match.differences)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          item,
                                          style: text.bodySmall?.copyWith(
                                            color: p.ink,
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            );
                            if (split) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: convPanel),
                                  const SizedBox(width: 12),
                                  Expanded(child: diffPanel),
                                ],
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                convPanel,
                                const SizedBox(height: 10),
                                diffPanel,
                              ],
                            );
                          },
                        ),
                      ],
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 4,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ColoredBox(
                        color: colorA,
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: ColoredBox(
                        color: colorB,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: p.line),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
