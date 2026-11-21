import 'package:flutter/material.dart';

import '../../../domain/engine/comparison_engine.dart';
import '../../../domain/engine/atlas_and_nolan_engine.dart';
import '../../../domain/models/atlas_models.dart';
import '../../../domain/models/political_models.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../charts/diverging_axis_bar.dart';
import '../../charts/interactive_triad_chart.dart';
import '../../charts/multidimensional_radar_chart.dart';
import '../../charts/nolan_diagram_chart.dart';
import '../../view_models/app_view_model.dart';
import '../../shared/metric_presentation.dart';

/// Tela de comparação entre duas avaliações quaisquer do histórico —
/// inclusive entre modalidades diferentes (ex.: 12 Eixos vs. Espectro Integrado,
/// 6 Tríades vs. 12 Eixos via compatibilidade ideológica, ou Rápida vs. Profunda).
class CompareEvaluationsScreen extends StatefulWidget {
  const CompareEvaluationsScreen({
    required this.appViewModel,
    this.initialBaseline,
    this.initialTarget,
    super.key,
  });

  final AppViewModel appViewModel;
  final EvaluationRecord? initialBaseline;
  final EvaluationRecord? initialTarget;

  @override
  State<CompareEvaluationsScreen> createState() =>
      _CompareEvaluationsScreenState();
}

class _CompareEvaluationsScreenState extends State<CompareEvaluationsScreen> {
  late EvaluationRecord _baseline;
  late EvaluationRecord _target;

  List<EvaluationRecord> get _records => widget.appViewModel.history;

  @override
  void initState() {
    super.initState();
    final bool hasExternal =
        widget.initialTarget != null || widget.initialBaseline != null;
    assert(
      hasExternal || _records.length >= 2,
      'Comparação exige ao menos 2 avaliações (ou uma avaliação recebida por link).',
    );
    _target = widget.initialTarget ?? _records.first;
    _baseline =
        widget.initialBaseline ??
        _records.firstWhere(
          (r) => r.id != _target.id,
          orElse: () => _records.length > 1 ? _records[1] : _target,
        );
  }

  String _shortDate(DateTime dt) {
    final String d = dt.day.toString().padLeft(2, '0');
    final String m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  void _swap() {
    setState(() {
      final EvaluationRecord tmp = _baseline;
      _baseline = _target;
      _target = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;

    final EvaluationComparisonReport report = EspectroComparisonEngine.compare(
      baseline: _baseline,
      target: _target,
      catalog: widget.appViewModel.data.catalog,
      questionTextByUid: widget.appViewModel.data.questionTextByUid,
    );

    return EspectroScaffold(
      appViewModel: widget.appViewModel,
      selectedIndex: 4,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: CircleIconButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Voltar',
            ),
          ),
        ),
        title: const Text('Comparar Avaliações'),
        actions: <Widget>[
          IconButton(
            onPressed: _swap,
            tooltip: 'Inverter base e comparada',
            icon: const Icon(Icons.swap_vert_rounded),
          ),
        ],
      ),
      body: ResponsiveContentFrame(
        maxWidth: EspectroLayout.workspaceMaxWidth,
        child: ListView(
          padding: EspectroLayout.pagePadding,
          children: <Widget>[
            const EditorialHeading(
              eyebrow: 'Histórico / Comparação',
              title: 'Um perfil,\ndiferentes momentos.',
              description: 'Explore as mudanças entre duas avaliações e os limites da comparação.',
            ),
          const SizedBox(height: 28),
          SectionCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _RecordPickerRow(
                  badge: 'A · BASE',
                  badgeColor: p.muted,
                  selected: _baseline,
                  options: _records,
                  formatDate: _shortDate,
                  onChanged: (EvaluationRecord rec) =>
                      setState(() => _baseline = rec),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),
                _RecordPickerRow(
                  badge: 'B · ATUAL',
                  badgeColor: p.accent,
                  selected: _target,
                  options: _records,
                  formatDate: _shortDate,
                  onChanged: (EvaluationRecord rec) =>
                      setState(() => _target = rec),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionCard(
            color: p.heroBackground,
            borderColor: p.heroBackground,
            child: Row(
              children: <Widget>[
                _StatColumn(
                  value:
                      '${report.significantAxesCount}/${report.sharedAxes.length}',
                  label: 'eixos c/ mudança sig.',
                  palette: p,
                ),
                _StatColumn(
                  value:
                      '${report.significantTriadsCount}/${report.sharedTriads.length}',
                  label: 'tríades c/ mudança sig.',
                  palette: p,
                ),
                _StatColumn(
                  value: report.sharedAnsweredQuestions == 0
                      ? '—'
                      : '${((report.unchangedAnswersCount / report.sharedAnsweredQuestions) * 100).round()}%',
                  label: 'respostas idênticas',
                  palette: p,
                ),
              ],
            ),
          ),
          Builder(
            builder: (BuildContext context) {
              final NolanCoordinates? nolanTarget =
                  EspectroNolanEngine.fromEvaluation(
                    axes: _target.axes,
                    triads: _target.triads,
                  );
              final NolanCoordinates? nolanBaseline =
                  EspectroNolanEngine.fromEvaluation(
                    axes: _baseline.axes,
                    triads: _baseline.triads,
                  );
              if (nolanTarget == null || nolanBaseline == null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Expanded(
                            child: Eyebrow(
                              'Diagrama de Nolan Comparativo (A → B)',
                            ),
                          ),
                          Tag(
                            label:
                                '${nolanBaseline.quadrantLabel} → ${nolanTarget.quadrantLabel}',
                            background: p.accentSoft,
                            foreground: p.accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'A seta tracejada ilustra o vetor de mudança das suas coordenadas '
                        'no diagrama bidimensional (Liberdade Pessoal vs. Econômica).',
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: NolanDiagramChart(
                          coordinates: nolanTarget,
                          baselineCoordinates: nolanBaseline,
                          userLabel: 'Avaliação B (Atual)',
                          baselineLabel: 'Avaliação A (Base)',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (report.sharedAxes.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Eyebrow('Sobreposição nos eixos bipolares'),
                  const SizedBox(height: 6),
                  Text(
                    'O círculo vazado indica a Avaliação A (base); o círculo sólido '
                    'indica a Avaliação B (atual). Mudanças só são marcadas como '
                    'significativas quando superam a incerteza combinada (±1,96·√(SE_A²+SE_B²)).',
                    style: text.bodySmall,
                  ),
                  if (_baseline.axes.length == _target.axes.length &&
                      _target.axes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Center(
                      child: MultidimensionalRadarChart(
                        axes: _target.axes,
                        baselineAxes: _baseline.axes,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  for (
                    var i = 0;
                    i < report.sharedAxes.length;
                    i++
                  ) ...<Widget>[
                    Builder(
                      builder: (BuildContext context) {
                        final AxisComparisonDelta delta = report.sharedAxes[i];
                        final BipolarDimensionScore targAxis = _target.axisById(
                          delta.axisId,
                        )!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            DivergingAxisBar(
                              dimension: targAxis,
                              baselineScore: delta.baselineScore,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: <Widget>[
                                Tag(
                                  label: delta.isSignificant
                                      ? 'Significativa'
                                      : 'Dentro da margem',
                                  background: delta.isSignificant
                                      ? p.accentSoft
                                      : p.surfaceMuted,
                                  foreground: delta.isSignificant
                                      ? p.accent
                                      : p.muted,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    delta.shiftSummary,
                                    style: text.bodySmall?.copyWith(
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    if (i != report.sharedAxes.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                  ],
                ],
              ),
            ),
          ],
          if (report.sharedTriads.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Eyebrow('Deslocamento nas tríades'),
                  const SizedBox(height: 6),
                  Text(
                    'A linha liga o ponto da Avaliação A (vazado) ao ponto da Avaliação B.',
                    style: text.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  for (
                    var i = 0;
                    i < report.sharedTriads.length;
                    i++
                  ) ...<Widget>[
                    Builder(
                      builder: (BuildContext context) {
                        final TriadComparisonDelta delta =
                            report.sharedTriads[i];
                        final TriadDimensionScore targTri = _target
                            .triadByCategoryId(delta.categoryId)!;
                        final Color accent = p.triadColor(delta.categoryId);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    delta.label,
                                    style: text.titleMedium,
                                  ),
                                ),
                                Tag(
                                  label: delta.isSignificant
                                      ? 'Deslocamento ${(delta.compositionDistance * 100).round()} pp'
                                      : 'Estável',
                                  background: delta.isSignificant
                                      ? accent.withValues(alpha: 0.16)
                                      : p.surfaceMuted,
                                  foreground: delta.isSignificant
                                      ? accent
                                      : p.muted,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: InteractiveTriadChart(
                                triad: targTri,
                                accentColor: accent,
                                baselineComposition: delta.baselineComposition,
                                size: 240,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    if (i != report.sharedTriads.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(),
                      ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Eyebrow('Comparação de compatibilidade ideológica'),
                const SizedBox(height: 6),
                Text(
                  report.hasDirectDimensionOverlap
                      ? 'Variação na convergência com as correntes mais próximas de B.'
                      : 'Mesmo entre testes de modalidades distintas (${_baseline.suite.title} vs. '
                            '${_target.suite.title}), o catálogo comum permite comparar a leitura ideológica.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 14),
                for (final CurrentComparisonShift s
                    in report.currentShifts.take(8))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            s.current.name,
                            style: text.bodyMedium?.copyWith(color: p.ink),
                          ),
                        ),
                        Text(
                          '${MetricPresentation.formatPercent(s.baselineCompatibility)} → '
                          '${MetricPresentation.formatPercent(s.targetCompatibility)}',
                          style: text.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: p.inkSoft,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 58,
                          child: Text(
                            '${s.delta >= 0 ? "+" : ""}${MetricPresentation.formatScore(s.delta)}',
                            textAlign: TextAlign.right,
                            style: text.labelLarge?.copyWith(
                              fontSize: 12.5,
                              color: s.delta.abs() < 1.0
                                  ? p.muted
                                  : (s.delta > 0 ? p.success : p.warning),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (report.answerShifts.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Eyebrow(
                    'Mudanças em afirmações idênticas (${report.answerShifts.length} de ${report.sharedAnsweredQuestions})',
                  ),
                  const SizedBox(height: 12),
                  for (final QuestionAnswerShift shift
                      in report.answerShifts.take(12))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            shift.statement,
                            style: text.bodyMedium?.copyWith(color: p.ink),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'A: ${shift.previousAnswer.label}  →  B: ${shift.currentAnswer.label}',
                            style: text.bodySmall?.copyWith(
                              color: p.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          ],
        ),
      ),
    );
  }
}

class _RecordPickerRow extends StatelessWidget {
  const _RecordPickerRow({
    required this.badge,
    required this.badgeColor,
    required this.selected,
    required this.options,
    required this.formatDate,
    required this.onChanged,
  });

  final String badge;
  final Color badgeColor;
  final EvaluationRecord selected;
  final List<EvaluationRecord> options;
  final String Function(DateTime) formatDate;
  final ValueChanged<EvaluationRecord> onChanged;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Tag(
          label: badge,
          background: badgeColor.withValues(alpha: 0.16),
          foreground: badgeColor,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected.id,
              isExpanded: true,
              dropdownColor: p.surface,
              items: <DropdownMenuItem<String>>[
                for (final EvaluationRecord r in options)
                  DropdownMenuItem<String>(
                    value: r.id,
                    child: Text(
                      '${r.displayTitle} · ${formatDate(r.createdAt)}',
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium?.copyWith(
                        color: p.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
              onChanged: (String? id) {
                if (id == null) return;
                final EvaluationRecord found = options.firstWhere(
                  (r) => r.id == id,
                );
                onChanged(found);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    required this.palette,
  });

  final String value;
  final String label;
  final EspectroPalette palette;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: text.headlineSmall?.copyWith(color: palette.heroForeground),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: text.bodySmall?.copyWith(
              color: palette.heroMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
