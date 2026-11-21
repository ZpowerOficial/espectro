import 'package:flutter/material.dart' hide Axis;

import '../../../data/models.dart';
import '../../../domain/engine/compatibility_engine.dart';
import '../../../domain/engine/comparison_engine.dart';
import '../../../domain/models/political_models.dart';
import '../../../domain/models/study_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../charts/evolution_line_chart.dart';
import '../../view_models/app_view_model.dart';
import '../../shared/metric_presentation.dart';
import '../atlas/study_taxonomy.dart';
import '../compare/compare_evaluations_screen.dart';
import '../quiz/espectro_suites_screen.dart';
import '../results/espectro_result_screen.dart';

/// Tela de histórico completo de avaliações e acompanhamento cronológico da
/// evolução por eixo bipolar ou vértice triangular.
class HistoryEvolutionScreen extends StatefulWidget {
  const HistoryEvolutionScreen({required this.appViewModel, super.key});

  final AppViewModel appViewModel;

  @override
  State<HistoryEvolutionScreen> createState() => _HistoryEvolutionScreenState();
}

class _HistoryEvolutionScreenState extends State<HistoryEvolutionScreen> {
  bool _trackTriad = false;
  late String _selectedAxisId;
  int _selectedTriadCat = 0;
  int _selectedVertexIdx = 0;

  @override
  void initState() {
    super.initState();
    _selectedAxisId = widget.appViewModel.data.twelveAxes.axes.first.id;
  }

  String _formatDate(DateTime dt) {
    final String d = dt.day.toString().padLeft(2, '0');
    final String m = dt.month.toString().padLeft(2, '0');
    final String hh = dt.hour.toString().padLeft(2, '0');
    final String mm = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} às $hh:$mm';
  }

  Future<void> _confirmDelete(EvaluationRecord record) async {
    final EspectroPalette p = context.palette;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: const Text('Excluir avaliação?'),
        content: Text('Remover "${record.displayTitle}" do histórico local?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.appViewModel.deleteRecord(record.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: widget.appViewModel,
      builder: (BuildContext context, _) {
        final List<EvaluationRecord> records = widget.appViewModel.history;

        return DefaultTabController(
          length: 2,
          child: EspectroScaffold(
            appViewModel: widget.appViewModel,
            selectedIndex: 3,
            isSectionRoot: true,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: EspectroLayout.pageHorizontalPadding,
              title: const Text('Histórico'),
              actions: <Widget>[
                if (records.length >= 2)
                  IconButton(
                    icon: const Icon(Icons.compare_arrows_rounded),
                    tooltip: 'Comparar duas avaliações',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CompareEvaluationsScreen(
                            appViewModel: widget.appViewModel,
                          ),
                        ),
                      );
                    },
                  ),
              ],
              bottom: TabBar(
                padding: const EdgeInsets.symmetric(
                  horizontal: EspectroLayout.pageHorizontalPadding,
                ),
                labelColor: p.accent,
                unselectedLabelColor: p.muted,
                indicatorColor: p.accent,
                dividerColor: p.line,
                tabs: <Widget>[
                  Tab(text: 'Avaliações (${records.length})'),
                  const Tab(text: 'Evolução no Tempo'),
                ],
              ),
            ),
            body: ResponsiveContentFrame(
              maxWidth: EspectroLayout.workspaceMaxWidth,
              child: TabBarView(
                children: <Widget>[
                  _buildRecordsList(context, records, p, text),
                  _buildEvolutionView(context, records, p, text),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordsList(
    BuildContext context,
    List<EvaluationRecord> records,
    EspectroPalette p,
    TextTheme text,
  ) {
    const Widget heading = EditorialHeading(
      eyebrow: 'Histórico / Comparação',
      title: 'Suas ideias podem\nmudar.',
      description:
          'Compare avaliações sem apagar a metodologia utilizada em cada período.',
    );

    if (records.isEmpty) {
      return ListView(
        padding: EspectroLayout.pagePadding,
        children: <Widget>[
          heading,
          const SizedBox(height: EspectroLayout.sectionGap),
          SectionCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.history_rounded, size: 42, color: p.muted),
                  const SizedBox(height: 14),
                  Text('Nenhuma avaliação salva', style: text.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Conclua qualquer teste no Espectro para registrar seu histórico '
                    'local e acompanhar sua evolução ao longo do tempo.',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: EspectroLayout.pagePadding,
      itemCount: records.length + (records.length == 1 ? 2 : 1),
      separatorBuilder: (_, int index) => SizedBox(
        height: index == 0
            ? EspectroLayout.blockGap
            : EspectroLayout.cardGap,
      ),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) return heading;
        if (records.length == 1 && index == 2) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: p.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.timeline_rounded, size: 17, color: p.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Comparação temporal disponível a partir de 2 avaliações',
                        style: text.titleSmall?.copyWith(
                          color: p.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Conclua outra avaliação ao longo do tempo para acompanhar '
                  'a evolução por dimensão e comparar matrizes lado a lado.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 14),
                TactilePress(
                  scale: 0.97,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => EspectroSuitesScreen(
                            appViewModel: widget.appViewModel,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_chart_rounded, size: 17),
                    label: const Text('Nova avaliação'),
                  ),
                ),
              ],
            ),
          );
        }
        final EvaluationRecord rec = records[index - 1];
        final CompatibilityReport compat = EspectroCompatibilityEngine.evaluate(
          catalog: widget.appViewModel.data.catalog,
          axes: rec.axes,
          triads: rec.triads,
        );

        void openRecord() {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => EspectroResultScreen(
                appViewModel: widget.appViewModel,
                record: rec,
              ),
            ),
          );
        }

        final topMatch = compat.primaryMatch;
        final StudySpectrum? topSpectrum = topMatch != null
            ? spectrumOf(StudySubject.fromCurrent(topMatch.current))
            : null;
        final Color stripeColor = topSpectrum?.color ?? p.accent;
        final double coveragePct = rec.quality.coverage.clamp(0.0, 1.0);

        return Stack(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: Semantics(
                container: true,
                button: true,
                label:
                    'Abrir avaliação ${rec.displayTitle}, ${compat.headline}, ${_formatDate(rec.createdAt)}',
                onTap: openRecord,
                child: ExcludeSemantics(
                  child: TactilePress(
                    scale: 0.988,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: openRecord,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: p.line),
                          boxShadow: EspectroElevation.cardShadows(p),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(height: 4, color: stripeColor),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                16,
                                18,
                                18,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 40),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: <Widget>[
                                        Tag(
                                          label: rec.suite.title,
                                          background: p.accentSoft,
                                          foreground: p.accent,
                                        ),
                                        Tag(label: rec.depth.label),
                                        if (topSpectrum != null &&
                                            topMatch != null)
                                          Tag(
                                            label:
                                                '${topSpectrum.name} · ${MetricPresentation.formatPercent(topMatch.compatibilityPercent)} conv.',
                                            background: stripeColor.withValues(
                                              alpha: p.isDark ? 0.18 : 0.10,
                                            ),
                                            foreground:
                                                topSpectrum.ink(p.isDark),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          rec.displayTitle,
                                          style: text.titleLarge,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _formatDate(rec.createdAt),
                                        style: text.bodySmall?.copyWith(
                                          fontFamily: 'IBMPlexMono',
                                          fontSize: 11,
                                          fontFeatures: const <FontFeature>[
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    compat.headline,
                                    style: text.bodyMedium?.copyWith(
                                      color: p.ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  LayoutBuilder(
                                    builder: (context, railBox) {
                                      final String label =
                                          '${rec.quality.totalAnswered} respostas · cobertura ${(coveragePct * 100).round()}%';
                                      if (railBox.maxWidth < 340) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            ProgressRail(
                                              value: coveragePct,
                                              color: stripeColor,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              label,
                                              style: text.bodySmall?.copyWith(
                                                fontFamily: 'IBMPlexMono',
                                                fontSize: 11,
                                                fontFeatures:
                                                    const <FontFeature>[
                                                      FontFeature.tabularFigures(),
                                                    ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: ProgressRail(
                                              value: coveragePct,
                                              color: stripeColor,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            label,
                                            style: text.bodySmall?.copyWith(
                                              fontFamily: 'IBMPlexMono',
                                              fontSize: 11,
                                              fontFeatures:
                                                  const <FontFeature>[
                                                    FontFeature.tabularFigures(),
                                                  ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
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
              ),
            ),
            Positioned(
              top: 14,
              right: 10,
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 19,
                  color: p.muted,
                ),
                visualDensity: VisualDensity.compact,
                tooltip: 'Excluir',
                onPressed: () => _confirmDelete(rec),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEvolutionView(
    BuildContext context,
    List<EvaluationRecord> records,
    EspectroPalette p,
    TextTheme text,
  ) {
    if (records.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.timeline_rounded, size: 46, color: p.muted),
              const SizedBox(height: 14),
              Text('Complete ao menos 2 avaliações', style: text.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Com duas ou mais avaliações registradas, o Espectro plota a curva '
                'de evolução e a margem de incerteza em cada eixo e tríade.',
                textAlign: TextAlign.center,
                style: text.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final List<Axis> axes = widget.appViewModel.data.twelveAxes.axes;
    final List<SixCategory> cats =
        widget.appViewModel.data.sixTriangles.categories;

    final List<EvolutionPoint> points;
    final String topLabel;
    final String bottomLabel;
    if (!_trackTriad) {
      final Axis ax = axes.firstWhere((a) => a.id == _selectedAxisId);
      points = EspectroComparisonEngine.axisSeries(
        records: records,
        axisId: ax.id,
      );
      topLabel = ax.rightPole;
      bottomLabel = ax.leftPole;
    } else {
      final SixCategory cat = cats[_selectedTriadCat];
      points = EspectroComparisonEngine.triadVertexSeries(
        records: records,
        categoryId: cat.id,
        vertexIndex: _selectedVertexIdx,
      );
      topLabel = cat.subcategories[_selectedVertexIdx];
      bottomLabel = 'Demais vértices';
    }

    return ListView(
      padding: EspectroLayout.pagePadding,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: ChoiceChip(
                label: const Text('Eixos Bipolares'),
                selected: !_trackTriad,
                onSelected: (_) => setState(() => _trackTriad = false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChoiceChip(
                label: const Text('Vértices Triangulares'),
                selected: _trackTriad,
                onSelected: (_) => setState(() => _trackTriad = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (!_trackTriad)
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              for (final Axis ax in axes)
                ChoiceChip(
                  label: Text(ax.label),
                  selected: _selectedAxisId == ax.id,
                  onSelected: (_) => setState(() => _selectedAxisId = ax.id),
                ),
            ],
          )
        else ...<Widget>[
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              for (final SixCategory cat in cats)
                ChoiceChip(
                  label: Text(cat.label),
                  selected: _selectedTriadCat == cat.id,
                  onSelected: (_) => setState(() {
                    _selectedTriadCat = cat.id;
                    _selectedVertexIdx = 0;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            children: <Widget>[
              for (var v = 0; v < 3; v++)
                ChoiceChip(
                  label: Text(cats[_selectedTriadCat].subcategories[v]),
                  selected: _selectedVertexIdx == v,
                  onSelected: (_) => setState(() => _selectedVertexIdx = v),
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        SectionCard(
          child: points.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    'Nenhuma avaliação no histórico mediu esta dimensão ainda.',
                    textAlign: TextAlign.center,
                    style: text.bodyMedium,
                  ),
                )
              : EvolutionLineChart(
                  points: points,
                  topLabel: topLabel,
                  bottomLabel: bottomLabel,
                ),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Comparar duas avaliações lado a lado',
          kind: AppButtonKind.outline,
          icon: Icons.compare_arrows_rounded,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    CompareEvaluationsScreen(appViewModel: widget.appViewModel),
              ),
            );
          },
        ),
      ],
    );
  }
}
