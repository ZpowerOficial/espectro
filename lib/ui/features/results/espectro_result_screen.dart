import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/engine/atlas_and_nolan_engine.dart';
import '../../../domain/engine/compatibility_engine.dart';
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
import '../../../data/pdf_export_service.dart';
import '../../view_models/app_view_model.dart';
import '../atlas/atlas_explorer_screen.dart';
import '../atlas/study_profile_screen.dart';
import '../../charts/axis_colors.dart';
import '../compare/compare_evaluations_screen.dart';
import '../compare/entity_comparison_screen.dart';
import '../methodology/methodology_screen.dart';
import '../share/shareable_card_sheet.dart';

/// Tela unificada de resultados do Espectro:
/// - Diagrama de Nolan (1969) e Bússola 2D com halo de incerteza e pinos de referência;
/// - Sínteses de valores fundamentais em 6 dimensões temáticas;
/// - Detecção auditável de tensões doutrinárias sem rótulos redutores;
/// - Compatibilidade com o catálogo de perfis ideológicos editoriais;
/// - Atlas Político: afinidade com personalidades, partidos e momentos históricos e antípoda;
/// - Biblioteca: recomendações personalizadas de afinidade e contraponto entre 76 obras clássicas;
/// - Visualização multi-eixos (12) e tríades composicionais (6).
class EspectroResultScreen extends StatefulWidget {
  const EspectroResultScreen({
    required this.appViewModel,
    required this.record,
    this.initialTabIndex,
    this.readOnly = false,
    super.key,
  });

  final AppViewModel appViewModel;
  final EvaluationRecord record;
  final int? initialTabIndex;
  final bool readOnly;

  @override
  State<EspectroResultScreen> createState() => _EspectroResultScreenState();
}

class _EspectroResultScreenState extends State<EspectroResultScreen> {
  bool _showCurrentsOnTriads = true;
  bool _showAllCurrents = false;
  bool _isExportingPdf = false;
  AtlasKind _selectedAtlasKind = AtlasKind.personality;
  late EvaluationRecord _record;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  Future<void> _exportPdf() async {
    if (_isExportingPdf) return;
    setState(() => _isExportingPdf = true);
    try {
      await EspectroPdfService.exportAndSharePdf(
        record: _record,
        data: widget.appViewModel.data,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar PDF: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingPdf = false);
      }
    }
  }

  void _openShareCard() {
    ShareableCardSheet.show(
      context,
      record: _record,
      appViewModel: widget.appViewModel,
    );
  }

  String _formatDate(DateTime dt) {
    final String d = dt.day.toString().padLeft(2, '0');
    final String m = dt.month.toString().padLeft(2, '0');
    final String hh = dt.hour.toString().padLeft(2, '0');
    final String mm = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} $hh:$mm';
  }

  Future<void> _copySummary(CompatibilityReport compat) async {
    final NolanCoordinates? nolan = EspectroNolanEngine.fromEvaluation(
      axes: _record.axes,
      triads: _record.triads,
    );
    final PoliticalAtlas atlas = widget.appViewModel.data.atlas;
    final List<AtlasMatchResult> topCountries = EspectroAtlasEngine.rankEntries(
      entries: atlas.countries,
      axes: _record.axes,
      triads: _record.triads,
    );
    final List<AtlasMatchResult> topPers = EspectroAtlasEngine.rankEntries(
      entries: atlas.personalities,
      axes: _record.axes,
      triads: _record.triads,
    );
    final List<AtlasMatchResult> topParties = EspectroAtlasEngine.rankEntries(
      entries: atlas.partiesAndMovements,
      axes: _record.axes,
      triads: _record.triads,
    );
    final BookRecommendationReport books = EspectroAtlasEngine.recommendBooks(
      books: atlas.books,
      axes: _record.axes,
      triads: _record.triads,
    );

    final StringBuffer buf = StringBuffer()
      ..writeln('Espectro · ${_record.displayTitle}')
      ..writeln('Data: ${_formatDate(_record.createdAt)}')
      ..writeln(compat.headline);

    if (nolan != null) {
      buf.writeln('\nDiagrama de Nolan (1969):');
      buf.writeln('- Quadrante: ${nolan.quadrantLabel}');
      buf.writeln(
        '- Liberdade Pessoal: ${nolan.personalFreedom.round()}% (±${nolan.personalSe.round()}%)',
      );
      buf.writeln(
        '- Liberdade Econômica: ${nolan.economicFreedom.round()}% (±${nolan.economicSe.round()}%)',
      );
    }

    if (compat.topMatches.isNotEmpty) {
      buf.writeln('\nCorrentes ideológicas mais próximas:');
      for (final CurrentCompatibility c in compat.topMatches.take(4)) {
        buf.writeln(
          '- ${c.current.name}: ${c.compatibilityPercent.toStringAsFixed(1)}%',
        );
      }
    }

    if (topCountries.isNotEmpty) {
      buf.writeln('\nModelos de País afins:');
      for (final AtlasMatchResult c in topCountries.take(3)) {
        buf.writeln(
          '- ${c.entry.name} (${c.entry.era}): ${c.compatibilityPercent.toStringAsFixed(1)}%',
        );
      }
    }

    if (topPers.isNotEmpty) {
      buf.writeln('\nPersonalidades históricas afins:');
      for (final AtlasMatchResult p in topPers.take(3)) {
        buf.writeln(
          '- ${p.entry.name} (${p.entry.era}): ${p.compatibilityPercent.toStringAsFixed(1)}%',
        );
      }
    }

    if (topParties.isNotEmpty) {
      buf.writeln('\nPartidos e Movimentos com afinidade:');
      for (final AtlasMatchResult m in topParties.take(2)) {
        buf.writeln(
          '- ${m.entry.name} (${m.entry.origin}): ${m.compatibilityPercent.toStringAsFixed(1)}%',
        );
      }
    }

    if (books.affinityBooks.isNotEmpty || books.counterpointBooks.isNotEmpty) {
      buf.writeln('\nRecomendações de Leitura:');
      if (books.affinityBooks.isNotEmpty) {
        final AtlasEntry b = books.affinityBooks.first.entry;
        buf.writeln('- Afinidade: "${b.name}" (${b.subtitle})');
      }
      if (books.counterpointBooks.isNotEmpty) {
        final AtlasEntry b = books.counterpointBooks.first.entry;
        buf.writeln('- Contraponto: "${b.name}" (${b.subtitle})');
      }
    }

    if (_record.axes.isNotEmpty) {
      buf.writeln('\nEixos Bipolares:');
      for (final BipolarDimensionScore a in _record.axes) {
        buf.writeln('- ${a.label}: ${a.summary}');
      }
    }
    if (_record.triads.isNotEmpty) {
      buf.writeln('\nTríades Políticas:');
      for (final TriadDimensionScore t in _record.triads) {
        buf.writeln(
          '- ${t.label}: ${t.classification} '
          '(${t.vertices[0]} ${(t.composition[0] * 100).round()}% / '
          '${t.vertices[1]} ${(t.composition[1] * 100).round()}% / '
          '${t.vertices[2]} ${(t.composition[2] * 100).round()}%)',
        );
      }
    }

    await Clipboard.setData(ClipboardData(text: buf.toString().trimRight()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resumo detalhado copiado para a área de transferência.'),
      ),
    );
  }

  Future<void> _renameDialog() async {
    if (widget.readOnly) return;
    final EspectroPalette p = context.palette;
    final TextEditingController ctrl = TextEditingController(
      text: _record.title ?? '',
    );
    final String? saved = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: p.surface,
        title: const Text('Nomear avaliação'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ex.: Antes do debate, Leitura completa...',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (saved == null || !mounted) return;
    await widget.appViewModel.renameRecord(_record.id, saved);
    if (!mounted) return;
    setState(() {
      _record = _record.copyWith(title: saved.trim());
    });
  }

  void _showAxisBreakdown(BipolarDimensionScore axis) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    showInfoSheet(
      context,
      title: '${axis.label}: ${axis.summary}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Tag(label: 'S = ${axis.score.toStringAsFixed(2)}'),
              Tag(label: 'SE = ±${axis.standardError.toStringAsFixed(2)}'),
              Tag(label: 'Cobertura ${(axis.coverage * 100).round()}%'),
              Tag(label: 'Confiança ${axis.confidenceLabel.toLowerCase()}'),
              if (axis.poleBreakdownAvailable)
                Tag(
                  label:
                      'Polos ${axis.answeredLeftCount}/${axis.presentedLeftCount} · '
                      '${axis.answeredRightCount}/${axis.presentedRightCount}',
                ),
              if (axis.hasInternalTension)
                Tag(
                  label:
                      'Tensão interna (${axis.tensionScore.toStringAsFixed(2)})',
                  background: p.warning.withValues(alpha: 0.16),
                  foreground: p.warning,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Faixa indicativa para ${axis.rightPole}: '
            '${axis.rightPercentLow.round()}% a ${axis.rightPercentHigh.round()}% '
            '(${axis.answeredCount} de ${axis.presentedCount} itens respondidos).',
            style: text.bodyMedium,
          ),
          if (axis.isIndeterminate) ...<Widget>[
            const SizedBox(height: 10),
            SectionCard(
              color: p.warning.withValues(alpha: 0.10),
              borderColor: p.warning.withValues(alpha: 0.35),
              padding: const EdgeInsets.all(12),
              child: Text(
                axis.answeredCount == 0
                    ? 'Nenhum item deste eixo foi respondido, então não há posição '
                          'a relatar. O valor central exibido é apenas ausência de '
                          'evidência, não uma resposta neutra.'
                    : 'Este eixo é indeterminado: falta observação de um dos polos '
                          '(ou de itens suficientes). O valor exibido é uma '
                          'estimativa provisória e não deve ser lido como posição '
                          'consolidada.',
                style: text.bodySmall?.copyWith(color: p.ink),
              ),
            ),
          ],
          if (axis.poleBreakdownAvailable && axis.hasBothPoles) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              'Média assinada dos itens de cada polo: '
              '${axis.leftPole} ${axis.leftPoleMean.toStringAsFixed(2)} · '
              '${axis.rightPole} ${axis.rightPoleMean.toStringAsFixed(2)}. '
              'Quanto maior a diferença entre elas, maior a tensão interna.',
              style: text.bodySmall,
            ),
          ],
          if (axis.hasInternalTension) ...<Widget>[
            const SizedBox(height: 10),
            SectionCard(
              color: p.warning.withValues(alpha: 0.10),
              borderColor: p.warning.withValues(alpha: 0.35),
              padding: const EdgeInsets.all(12),
              child: Text(
                'Suas respostas apoiaram afirmações dos dois polos deste eixo. '
                'Isso indica uma posição condicional ou híbrida, não mera indiferença.',
                style: text.bodySmall?.copyWith(color: p.ink),
              ),
            ),
          ],
          if (axis.topContributions.isNotEmpty) ...<Widget>[
            const SizedBox(height: 18),
            const Eyebrow('Afirmações que mais pesaram'),
            const SizedBox(height: 10),
            for (final ItemContribution item in axis.topContributions)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SectionCard(
                  padding: const EdgeInsets.all(12),
                  radius: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.statement,
                        style: text.bodyMedium?.copyWith(color: p.ink),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item.answer.label} · puxou para ${item.targetLabel}',
                        style: text.bodySmall?.copyWith(
                          color: item.signedContribution <= 0
                              ? p.poleLeft
                              : p.poleRight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _openStudy(String key) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: studyProfileRoute(key)),
      builder: (_) => StudyProfileScreen(
        appViewModel: widget.appViewModel,
        subjectKey: key,
      ),
    ),
  );

  void _showCurrentMatchSheet(CurrentCompatibility match) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final NolanReferencePin? pin = EspectroNolanEngine.fromCurrent(
      match.current,
    );

    showInfoSheet(
      context,
      title: match.current.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Tag(
                label:
                    '${match.compatibilityPercent.toStringAsFixed(1)}% compatível',
                background: p.accentSoft,
                foreground: p.accent,
              ),
              Tag(label: match.current.family),
              Tag(label: pin?.quadrantLabel ?? 'Sem projeção bidimensional'),
            ],
          ),
          const SizedBox(height: 12),
          Text(match.current.summary, style: text.bodyLarge),
          const SizedBox(height: 18),
          const Eyebrow('Ideias e Princípios Fundamentais'),
          const SizedBox(height: 8),
          for (final String idea in match.current.keyIdeas)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('• ', style: TextStyle(color: p.accent, fontSize: 16)),
                  Expanded(child: Text(idea, style: text.bodyMedium)),
                ],
              ),
            ),
          const SizedBox(height: 18),
          const Eyebrow('Onde suas respostas mais convergem'),
          const SizedBox(height: 10),
          for (final DimensionAlignmentDetail d in match.convergences)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SectionCard(
                radius: 14,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          d.dimensionLabel,
                          style: text.titleMedium?.copyWith(fontSize: 13.5),
                        ),
                        Text(
                          'z = ${d.normalizedZ.toStringAsFixed(2)}',
                          style: text.bodySmall?.copyWith(
                            color: p.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Você: ${d.userSummary} · Corrente: ${d.currentSummary}',
                      style: text.bodySmall?.copyWith(color: p.inkSoft),
                    ),
                    const SizedBox(height: 3),
                    Text(d.note, style: text.bodySmall),
                  ],
                ),
              ),
            ),
          if (match.divergences.isNotEmpty) ...<Widget>[
            const SizedBox(height: 18),
            const Eyebrow('Onde há maior divergência'),
            const SizedBox(height: 10),
            for (final DimensionAlignmentDetail d in match.divergences)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SectionCard(
                  radius: 14,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            d.dimensionLabel,
                            style: text.titleMedium?.copyWith(fontSize: 13.5),
                          ),
                          Text(
                            'z = ${d.normalizedZ.toStringAsFixed(2)}',
                            style: text.bodySmall?.copyWith(
                              color: p.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Você: ${d.userSummary} · Corrente: ${d.currentSummary}',
                        style: text.bodySmall?.copyWith(color: p.inkSoft),
                      ),
                      const SizedBox(height: 3),
                      Text(d.note, style: text.bodySmall),
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: 18),
          AppButton(
            label: 'Estudar corrente no Atlas',
            kind: AppButtonKind.outline,
            icon: Icons.menu_book_outlined,
            onPressed: () {
              Navigator.of(context).pop();
              _openStudy('current:${match.current.id}');
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Comparar Comigo em Detalhes',
            icon: Icons.compare_arrows_rounded,
            kind: AppButtonKind.filled,
            onPressed: () {
              Navigator.of(context).pop();
              EntityComparisonScreen.showCurrent(
                context,
                record: _record,
                current: match.current,
                appViewModel: widget.appViewModel,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAtlasEntryDetailSheet(
    BuildContext context,
    AtlasEntry entry,
    AtlasMatchResult? match,
  ) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final NolanReferencePin? pin = EspectroNolanEngine.fromAtlasEntry(entry);

    showInfoSheet(
      context,
      title: entry.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            entry.subtitle,
            style: text.titleMedium?.copyWith(color: p.muted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Tag(label: entry.category),
              if (entry.origin.isNotEmpty) Tag(label: entry.origin),
              if (entry.era.isNotEmpty) Tag(label: entry.era),
              Tag(
                label: pin?.quadrantLabel ?? 'Sem projeção bidimensional',
                background: p.accentSoft,
                foreground: p.accent,
              ),
              if (match != null)
                Tag(
                  label:
                      '${match.compatibilityPercent.toStringAsFixed(1)}% afinidade com você',
                  background: p.success.withValues(alpha: 0.16),
                  foreground: p.success,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(entry.summary, style: text.bodyLarge),
          if (entry.quote != null && entry.quote!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            SectionCard(
              padding: const EdgeInsets.all(12),
              color: p.surfaceMuted,
              radius: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.format_quote_rounded, size: 20, color: p.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.quote!,
                      style: text.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: p.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (entry.highlights.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            const Eyebrow('Pontos Marcantes e Legado'),
            const SizedBox(height: 8),
            for (final String hl in entry.highlights)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('• ', style: TextStyle(color: p.accent, fontSize: 16)),
                    Expanded(child: Text(hl, style: text.bodyMedium)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 16),
          const Eyebrow('Diagrama de Nolan'),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              height: 220,
              child: NolanDiagramChart(
                coordinates: EspectroNolanEngine.fromEvaluation(
                  axes: _record.axes,
                  triads: _record.triads,
                ),
                referencePins: <NolanReferencePin>[?pin],
                showModeSwitch: false,
                maxSize: 210,
              ),
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Explorar ficha e conexões',
            kind: AppButtonKind.outline,
            icon: Icons.menu_book_outlined,
            onPressed: () {
              Navigator.of(context).pop();
              _openStudy('${entry.kind.name}:${entry.id}');
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Comparar Comigo em Detalhes',
            icon: Icons.compare_arrows_rounded,
            kind: AppButtonKind.filled,
            onPressed: () {
              Navigator.of(context).pop();
              EntityComparisonScreen.showAtlasEntry(
                context,
                record: _record,
                entry: entry,
                appViewModel: widget.appViewModel,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final CompatibilityReport compat = EspectroCompatibilityEngine.evaluate(
      catalog: widget.appViewModel.data.catalog,
      axes: _record.axes,
      triads: _record.triads,
    );

    final List<Tab> tabs = <Tab>[
      const Tab(text: 'Síntese & Nolan'),
      if (_record.axes.isNotEmpty) const Tab(text: 'Eixos (12)'),
      if (_record.triads.isNotEmpty) const Tab(text: 'Tríades (6)'),
      const Tab(text: 'Atlas Político'),
      const Tab(text: 'Biblioteca'),
    ];

    final List<Widget> tabViews = <Widget>[
      _buildOverviewTab(context, compat, p, text),
      if (_record.axes.isNotEmpty) _buildAxesTab(context, p, text),
      if (_record.triads.isNotEmpty) _buildTriadsTab(context, compat, p, text),
      _buildAtlasTab(context, p, text),
      _buildLibraryTab(context, p, text),
    ];

    return DefaultTabController(
      length: tabs.length,
      initialIndex: widget.initialTabIndex ?? 0,
      child: EspectroScaffold(
        appViewModel: widget.appViewModel,
        selectedIndex: 1,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(
              child: CircleIconButton(
                icon: Icons.close_rounded,
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                tooltip: 'Voltar ao início',
              ),
            ),
          ),
          title: GestureDetector(
            onTap: widget.readOnly ? null : _renameDialog,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    _record.displayTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                if (!widget.readOnly)
                  Icon(Icons.edit_outlined, size: 16, color: p.muted),
              ],
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Ações do resultado',
              onSelected: (action) {
                switch (action) {
                  case 'share':
                    _openShareCard();
                  case 'pdf':
                    if (!_isExportingPdf) _exportPdf();
                  case 'copy':
                    _copySummary(compat);
                  case 'method':
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MethodologyScreen(
                          data: widget.appViewModel.data,
                          appViewModel: widget.appViewModel,
                        ),
                      ),
                    );
                  case 'atlas':
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AtlasExplorerScreen(
                          appViewModel: widget.appViewModel,
                        ),
                      ),
                    );
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'share', child: Text('Compartilhar card')),
                PopupMenuItem(value: 'pdf', child: Text('Exportar PDF')),
                PopupMenuItem(value: 'copy', child: Text('Copiar resumo')),
                PopupMenuItem(
                  value: 'method',
                  child: Text('Metodologia e cálculos'),
                ),
                PopupMenuItem(value: 'atlas', child: Text('Explorar Atlas')),
              ],
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: p.accent,
            unselectedLabelColor: p.muted,
            indicatorColor: p.accent,
            dividerColor: p.line,
            tabs: tabs,
          ),
        ),
        body: TabBarView(children: tabViews),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    CompatibilityReport compat,
    EspectroPalette p,
    TextTheme text, {
    bool detailed = false,
  }) {
    if (!detailed && MediaQuery.sizeOf(context).width >= 1100) {
      return _buildDesktopOverview(context, compat, p, text);
    }
    final tendencyAxes = _record.axes.where((a) => !a.isIndeterminate).toList()
      ..sort((a, b) => b.score.abs().compareTo(a.score.abs()));
    final List<CurrentCompatibility> displayedCurrents = _showAllCurrents
        ? compat.ranked
        : compat.topMatches;

    final NolanCoordinates? nolan = EspectroNolanEngine.fromEvaluation(
      axes: _record.axes,
      triads: _record.triads,
    );
    final List<ThematicSynthesis> syntheses =
        EspectroAtlasEngine.computeSyntheses(
          axes: _record.axes,
          triads: _record.triads,
        );
    final List<DoctrinalTension> tensions =
        EspectroAtlasEngine.detectDoctrinalTensions(
          axes: _record.axes,
          triads: _record.triads,
        );

    return ResponsiveContentFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: <Widget>[
          EditorialHero(
            eyebrow: 'Seu retrato inicial',
            title: 'Um perfil com\nmuitas camadas.',
            description:
                'Suas posições formam tendências. Um rótulo não explica tudo.',
            footer: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1D414B),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                '${_record.quality.totalAnswered} respostas  •  ${(_record.quality.coverage * 100).round()}% cobertura',
                style: const TextStyle(
                  fontFamily: 'IBMPlexMono',
                  color: Color(0xFF6AE0CB),
                  fontSize: 11,
                ),
              ),
            ),
          ),
          if (compat.topMatches.isNotEmpty) ...[
            const SizedBox(height: 18),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow('IDEIAS PARA EXPLORAR', color: p.accent),
                  const SizedBox(height: 12),
                  for (final match in compat.topMatches.take(2))
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(match.current.name),
                        subtitle: Text(
                          '${match.compatibilityPercent.round()}% de afinidade estimada',
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => _showCurrentMatchSheet(match),
                      ),
                    ),
                  const Text(
                    'Afinidade com perfis editoriais, não um diagnóstico de identidade.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          SectionCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'TENDÊNCIAS IDENTIFICADAS',
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: p.accent,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                for (
                  var i = 0;
                  i < math.min(3, tendencyAxes.length);
                  i++
                ) ...<Widget>[
                  Builder(
                    builder: (context) {
                      final ax = tendencyAxes[i];
                      final val = ((ax.score + 1.0) / 2.0 * 100).round();
                      final pair =
                          AxisColors.pairs[ax.axisId] ??
                          (p.poleLeft, p.poleRight);
                      final c = ax.score < 0 ? pair.$1 : pair.$2;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    ax.label,
                                    style: const TextStyle(
                                      fontFamily: 'IBMPlexSans',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$val/100',
                                  style: const TextStyle(
                                    fontFamily: 'IBMPlexMono',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Stack(
                                children: <Widget>[
                                  Container(height: 8, color: p.line),
                                  FractionallySizedBox(
                                    widthFactor: (val / 100.0).clamp(0.0, 1.0),
                                    child: Container(height: 8, color: c),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                InkWell(
                  onTap: () {
                    // Alterna ou foca na aba de eixos/tríades
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: p.accentSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'POR QUE ESSE RESULTADO?',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                  color: p.accent,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ver respostas, aproximações e divergências',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSans',
                                  fontSize: 12,
                                  color: p.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: p.accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: 'Card Compartilhável',
                  icon: Icons.share_rounded,
                  kind: AppButtonKind.outline,
                  onPressed: _openShareCard,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: _isExportingPdf ? 'Gerando...' : 'Dossiê PDF (6 pág.)',
                  icon: Icons.picture_as_pdf_rounded,
                  kind: AppButtonKind.filled,
                  onPressed: _isExportingPdf ? () {} : _exportPdf,
                ),
              ),
            ],
          ),
          if (nolan != null) ...<Widget>[
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ReportSectionHeader(
                    title: const Eyebrow(
                      'Diagrama de Nolan (1969) & Bússola 2D',
                    ),
                    trailing: Tag(
                      label: nolan.quadrantLabel,
                      background: p.accentSoft,
                      foreground: p.accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Plano bidimensional decompondo a liberdade individual em dois eixos ortogonais: '
                    'Liberdade Pessoal (costumes e expressão civil) e Liberdade Econômica (mercado e contratos).',
                    style: text.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: NolanDiagramChart(
                      coordinates: nolan,
                      referencePins: compat.topMatches
                          .take(3)
                          .map(
                            (c) => EspectroNolanEngine.fromCurrent(c.current),
                          )
                          .whereType<NolanReferencePin>()
                          .toList(),
                      userLabel: 'Seu Perfil',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      Tag(
                        label:
                            'Liberdade Pessoal: ${nolan.personalFreedom.round()}% (±${nolan.personalSe.round()}%)',
                      ),
                      Tag(
                        label:
                            'Liberdade Econômica: ${nolan.economicFreedom.round()}% (±${nolan.economicSe.round()}%)',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(nolan.quadrantDescription, style: text.bodySmall),
                ],
              ),
            ),
          ],
          if (syntheses.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            FundamentalValuesSection(syntheses: syntheses),
          ],
          if (tensions.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            SectionCard(
              color: p.warning.withValues(alpha: p.isDark ? 0.14 : 0.08),
              borderColor: p.warning.withValues(alpha: 0.35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Eyebrow(
                    'Nuances e Tensões Doutrinárias (${tensions.length})',
                    color: p.warning,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Posições que cruzam fronteiras doutrinárias usuais. O Espectro respeita '
                    'suas convicções sem forçá-las a um modelo unidimensional simplista.',
                    style: text.bodySmall?.copyWith(color: p.ink),
                  ),
                  const SizedBox(height: 10),
                  for (final DoctrinalTension t in tensions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: p.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(t.title, style: text.titleSmall),
                            const SizedBox(height: 3),
                            Text(
                              t.description,
                              style: text.bodySmall?.copyWith(color: p.inkSoft),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (_record.quality.warnings.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            SectionCard(
              color: p.warning.withValues(alpha: p.isDark ? 0.14 : 0.08),
              borderColor: p.warning.withValues(alpha: 0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Eyebrow('Transparência e consistência', color: p.warning),
                  const SizedBox(height: 10),
                  for (final String w in _record.quality.warnings)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        w,
                        style: text.bodySmall?.copyWith(color: p.ink),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ReportSectionHeader(
                  title: const Eyebrow('Compatibilidade com Correntes'),
                  trailing: Tag(
                    label: '${compat.ranked.length} perfis editoriais',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Toque em qualquer corrente para abrir o relatório de convergências e divergências.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < displayedCurrents.length; i++) ...<Widget>[
                  _CurrentCompatibilityRow(
                    rank: i + 1,
                    match: displayedCurrents[i],
                    onTap: () => _showCurrentMatchSheet(displayedCurrents[i]),
                  ),
                  if (i != displayedCurrents.length - 1)
                    const SizedBox(height: 12),
                ],
                if (compat.ranked.length > 6) ...<Widget>[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _showAllCurrents = !_showAllCurrents),
                      child: Text(
                        _showAllCurrents
                            ? 'Mostrar apenas as 6 mais próximas'
                            : 'Ver todas as ${compat.ranked.length} correntes',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (widget.appViewModel.history.length >= 2) ...<Widget>[
            AppButton(
              label: 'Comparar com outra avaliação',
              icon: Icons.compare_arrows_rounded,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CompareEvaluationsScreen(
                      appViewModel: widget.appViewModel,
                      initialTarget: _record,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
          AppButton(
            label: 'Explorar Atlas Político Completo',
            kind: AppButtonKind.outline,
            icon: Icons.travel_explore_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      AtlasExplorerScreen(appViewModel: widget.appViewModel),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Entender a metodologia e fórmulas',
            kind: AppButtonKind.outline,
            icon: Icons.functions_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MethodologyScreen(
                    data: widget.appViewModel.data,
                    appViewModel: widget.appViewModel,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopOverview(
    BuildContext context,
    CompatibilityReport compat,
    EspectroPalette p,
    TextTheme text,
  ) {
    final match = compat.topMatches.firstOrNull;
    final triad = _record.triads.firstOrNull;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditorialHeading(
            eyebrow: 'Relatório / Visão geral',
            title: 'Seu mapa de ideias',
            description:
                '${_record.quality.totalAnswered} respostas · ${(_record.quality.coverage * 100).round()}% de cobertura',
          ),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const EditorialHero(
                      eyebrow: 'Perfil multidimensional',
                      title: 'Muito além de esquerda e direita.',
                      description: 'Explore suas convergências, diferenças e áreas ainda não determinadas por respostas suficientes.',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_record.axes.isNotEmpty)
                          Expanded(
                            child: SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Eyebrow('12 eixos / Sinais', color: p.accent),
                                  const SizedBox(height: 18),
                                  Text(
                                    'Posições por dimensão',
                                    style: text.titleLarge,
                                  ),
                                  const SizedBox(height: 24),
                                  for (final axis in _record.axes.take(4))
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 20,
                                      ),
                                      child: InkWell(
                                        onTap: () => _showAxisBreakdown(axis),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    axis.label,
                                                    style: text.titleMedium
                                                        ?.copyWith(
                                                          fontSize: 13,
                                                        ),
                                                  ),
                                                ),
                                                Text(
                                                  axis.isIndeterminate
                                                      ? '—'
                                                      : '${axis.rightPercent.round()}',
                                                  style: text.bodySmall
                                                      ?.copyWith(
                                                        fontFamily:
                                                            'IBMPlexMono',
                                                      ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            ProgressRail(
                                              value: axis.isIndeterminate
                                                  ? 0
                                                  : axis.rightPercent / 100,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        if (_record.axes.isNotEmpty && triad != null)
                          const SizedBox(width: 16),
                        if (triad != null)
                          Expanded(
                            child: SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Eyebrow(
                                    '6 tríades / Composição',
                                    color: p.accent,
                                  ),
                                  const SizedBox(height: 18),
                                  Text(triad.label, style: text.titleLarge),
                                  const SizedBox(height: 18),
                                  LayoutBuilder(
                                    builder: (context, c) => Center(
                                      child: InteractiveTriadChart(
                                        triad: triad,
                                        size: math.min(c.maxWidth, 270),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Apoio absoluto: ${(triad.engagement * 100).round()}%',
                                    style: text.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: SectionCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow('Por que essa afinidade?', color: p.accent),
                      const SizedBox(height: 24),
                      Text(
                        match?.current.name ?? 'Mais respostas, mais contexto.',
                        style: text.headlineLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        match == null
                            ? compat.explanation
                            : '${match.compatibilityPercent.round()}% · índice heurístico, não probabilidade',
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: 28),
                      if (match != null) ...[
                        SectionCard(
                          color: p.accentSoft,
                          borderColor: p.accentSoft,
                          radius: 13,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Eyebrow('Convergências', color: p.accent),
                              const SizedBox(height: 18),
                              Text(
                                match.convergences
                                    .map((d) => d.dimensionLabel)
                                    .join(' · '),
                                style: text.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SectionCard(
                          color: p.isDark
                              ? p.surfaceMuted
                              : const Color(0xFFFFF0D7),
                          borderColor: Colors.transparent,
                          radius: 13,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Eyebrow('Divergências', color: p.warning),
                              const SizedBox(height: 18),
                              Text(
                                match.divergences.isEmpty
                                    ? 'Sem divergências observadas nas dimensões avaliadas.'
                                    : match.divergences
                                          .map((d) => d.dimensionLabel)
                                          .join(' · '),
                                style: text.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      Eyebrow('Transparência', color: p.accent),
                      const SizedBox(height: 18),
                      Text(
                        'Examine respostas, pesos, cobertura, fontes e versões do método de cálculo.',
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      if (match != null)
                        AppButton(
                          label: 'Abrir explicação detalhada',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () => _showCurrentMatchSheet(match),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Explore Eixos, Tríades, Atlas e Biblioteca nas abas do relatório.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.open_in_full_rounded),
            label: const Text('Análise completa: Nolan, valores e confiança'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Análise completa')),
                  body: _buildOverviewTab(
                    context,
                    compat,
                    p,
                    text,
                    detailed: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtlasTab(
    BuildContext context,
    EspectroPalette p,
    TextTheme text,
  ) {
    final PoliticalAtlas atlas = widget.appViewModel.data.atlas;
    List<AtlasEntry> entries;
    String labelKind;
    switch (_selectedAtlasKind) {
      case AtlasKind.personality:
        entries = atlas.personalities;
        labelKind = 'Personalidades';
        break;
      case AtlasKind.country:
        entries = atlas.countries;
        labelKind = 'Modelos de País';
        break;
      case AtlasKind.party:
        entries = atlas.partiesAndMovements;
        labelKind = 'Partidos e Movimentos';
        break;
      case AtlasKind.history:
        entries = atlas.historicalEras;
        labelKind = 'Momentos Históricos';
        break;
      case AtlasKind.book:
        entries = atlas.books;
        labelKind = 'Obras Clássicas';
        break;
    }

    final List<AtlasMatchResult> ranked = EspectroAtlasEngine.rankEntries(
      entries: entries,
      axes: _record.axes,
      triads: _record.triads,
    );

    final AtlasMatchResult? antipode = ranked.isNotEmpty ? ranked.last : null;

    return ResponsiveContentFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: <Widget>[
          SectionCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Eyebrow('Comparação com o Atlas Político'),
                const SizedBox(height: 6),
                Text(
                  'Veja quais figuras históricas, movimentos ou momentos do passado '
                  'mais se aproximam do seu padrão de respostas.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      _AtlasKindChip(
                        label: 'Personalidades (${atlas.personalities.length})',
                        selected: _selectedAtlasKind == AtlasKind.personality,
                        onTap: () => setState(
                          () => _selectedAtlasKind = AtlasKind.personality,
                        ),
                        palette: p,
                      ),
                      const SizedBox(width: 8),
                      _AtlasKindChip(
                        label: 'Países (${atlas.countries.length})',
                        selected: _selectedAtlasKind == AtlasKind.country,
                        onTap: () => setState(
                          () => _selectedAtlasKind = AtlasKind.country,
                        ),
                        palette: p,
                      ),
                      const SizedBox(width: 8),
                      _AtlasKindChip(
                        label: 'Partidos (${atlas.partiesAndMovements.length})',
                        selected: _selectedAtlasKind == AtlasKind.party,
                        onTap: () => setState(
                          () => _selectedAtlasKind = AtlasKind.party,
                        ),
                        palette: p,
                      ),
                      const SizedBox(width: 8),
                      _AtlasKindChip(
                        label: 'História (${atlas.historicalEras.length})',
                        selected: _selectedAtlasKind == AtlasKind.history,
                        onTap: () => setState(
                          () => _selectedAtlasKind = AtlasKind.history,
                        ),
                        palette: p,
                      ),
                      const SizedBox(width: 8),
                      _AtlasKindChip(
                        label: 'Livros (${atlas.books.length})',
                        selected: _selectedAtlasKind == AtlasKind.book,
                        onTap: () =>
                            setState(() => _selectedAtlasKind = AtlasKind.book),
                        palette: p,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ReportSectionHeader(
                  title: Eyebrow('Mais Afins em $labelKind'),
                  trailing: Tag(label: '${ranked.length} perfis'),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < ranked.take(8).length; i++) ...<Widget>[
                  _AtlasMatchRow(
                    rank: i + 1,
                    match: ranked[i],
                    onTap: () => _showAtlasEntryDetailSheet(
                      context,
                      ranked[i].entry,
                      ranked[i],
                    ),
                  ),
                  if (i != ranked.take(8).length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          if (antipode != null && ranked.length > 3) ...<Widget>[
            const SizedBox(height: 16),
            SectionCard(
              color: p.surfaceMuted,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ReportSectionHeader(
                    title: const Eyebrow(
                      'Seu Antípoda no Atlas (Menor Afinidade)',
                    ),
                    trailing: Tag(
                      label:
                          '${antipode.compatibilityPercent.toStringAsFixed(1)}%',
                      background: p.line,
                      foreground: p.muted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    antipode.entry.name,
                    style: text.titleLarge?.copyWith(fontSize: 18),
                  ),
                  Text(
                    '${antipode.entry.subtitle} · ${antipode.entry.era}',
                    style: text.bodySmall?.copyWith(color: p.inkSoft),
                  ),
                  const SizedBox(height: 8),
                  Text(antipode.entry.summary, style: text.bodyMedium),
                  if (antipode.divergences.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      'Ponto de maior distância doutrinária: ${antipode.divergences.first}',
                      style: text.bodySmall?.copyWith(
                        color: p.inkSoft,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    label: const Text('Inspecionar verbete completo'),
                    onPressed: () => _showAtlasEntryDetailSheet(
                      context,
                      antipode.entry,
                      antipode,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          AppButton(
            label: 'Explorar Catálogo Completo no Atlas',
            icon: Icons.travel_explore_rounded,
            kind: AppButtonKind.outline,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AtlasExplorerScreen(
                    appViewModel: widget.appViewModel,
                    initialKind: _selectedAtlasKind,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryTab(
    BuildContext context,
    EspectroPalette p,
    TextTheme text,
  ) {
    final PoliticalAtlas atlas = widget.appViewModel.data.atlas;
    final BookRecommendationReport report = EspectroAtlasEngine.recommendBooks(
      books: atlas.books,
      axes: _record.axes,
      triads: _record.triads,
    );

    return ResponsiveContentFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: <Widget>[
          SectionCard(
            color: p.heroBackground,
            borderColor: p.heroBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Eyebrow(
                  'Biblioteca Política · Recomendações',
                  color: p.heroMuted,
                ),
                const SizedBox(height: 10),
                Text(
                  'Obras Clássicas Selecionadas para Você',
                  style: text.headlineSmall?.copyWith(color: p.heroForeground),
                ),
                const SizedBox(height: 6),
                Text(
                  'A literatura política enriquece quando você lê autores que aprofundam '
                  'suas convicções e, com a mesma lucidez, lê os pensadores que '
                  'formularam as críticas mais vigorosas a elas.',
                  style: text.bodySmall?.copyWith(color: p.heroMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ReportSectionHeader(
                  title: const Eyebrow('Leituras de Afinidade'),
                  trailing: Tag(
                    label: '${report.affinityBooks.length} obras afins',
                    background: p.accentSoft,
                    foreground: p.accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Textos seminais que fundamentam e estruturam a tradição política mais próxima às suas respostas.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 14),
                for (final AtlasMatchResult b
                    in report.affinityBooks) ...<Widget>[
                  _BookRecommendationCard(
                    match: b,
                    isCounterpoint: false,
                    onTap: () =>
                        _showAtlasEntryDetailSheet(context, b.entry, b),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ReportSectionHeader(
                  title: const Eyebrow('Leituras de Contraponto Intelectual'),
                  trailing: Tag(
                    label: '${report.counterpointBooks.length} contrapontos',
                    background: p.warning.withValues(alpha: 0.16),
                    foreground: p.warning,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Obras clássicas que sustentam premissas opostas às suas com rigor filosófico e consistência lógica.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 14),
                for (final AtlasMatchResult b
                    in report.counterpointBooks) ...<Widget>[
                  _BookRecommendationCard(
                    match: b,
                    isCounterpoint: true,
                    onTap: () =>
                        _showAtlasEntryDetailSheet(context, b.entry, b),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Ver todas as ${atlas.books.length} Obras no Atlas',
            icon: Icons.menu_book_rounded,
            kind: AppButtonKind.outline,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AtlasExplorerScreen(
                    appViewModel: widget.appViewModel,
                    initialKind: AtlasKind.book,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAxesTab(
    BuildContext context,
    EspectroPalette p,
    TextTheme text,
  ) {
    return ResponsiveContentFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: <Widget>[
          const EditorialHeading(
            eyebrow: 'Resultado / Eixos',
            title: 'Suas dimensões\npolíticas',
            description:
                'Visualize o que foi medido — e o que permanece indeterminado.',
          ),
          const SizedBox(height: 28),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Eyebrow('Radar Multidimensional dos 12 Eixos'),
                const SizedBox(height: 6),
                Text(
                  'Os 12 eixos contínuos normalizados em [-1,0, +1,0]. A linha '
                  'tracejada interna representa o centro neutro; a área hachurada '
                  'expressa a margem de incerteza estatística (SE) das suas respostas.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 16),
                Center(child: MultidimensionalRadarChart(axes: _record.axes)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Eyebrow('Detalhamento Eixo a Eixo'),
                const SizedBox(height: 6),
                Text(
                  'Toque em qualquer eixo para ver os itens respondidos, o intervalo de '
                  'confiança empírico e as perguntas que mais influenciaram a sua pontuação.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < _record.axes.length; i++) ...<Widget>[
                  InkWell(
                    onTap: () => _showAxisBreakdown(_record.axes[i]),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: DivergingAxisBar(dimension: _record.axes[i]),
                    ),
                  ),
                  if (i != _record.axes.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Rótulo de apoio absoluto por vértice, sem apresentar preenchimento neutro
  /// como se fosse uma observação do usuário.
  String _supportLabel(TriadDimensionScore triad, int index) {
    final String vertex = triad.vertices[index];
    if (triad.vertexBreakdownAvailable && !triad.vertexObserved[index]) {
      return '$vertex não avaliado';
    }
    return '$vertex ${(triad.vertexSupport[index] * 100).round()}%';
  }

  Widget _buildTriadsTab(
    BuildContext context,
    CompatibilityReport compat,
    EspectroPalette p,
    TextTheme text,
  ) {
    return ResponsiveContentFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: <Widget>[
          const EditorialHeading(
            eyebrow: 'Visualização / Simplex',
            title: 'Três perspectivas,\nmuitas nuances.',
            description: 'A posição no triângulo e a intensidade de apoio medem coisas diferentes.',
          ),
          const SizedBox(height: 28),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Eyebrow(
                        '6 Tríades Políticas em Simplex Aitchison',
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showCurrentsOnTriads
                            ? Icons.push_pin_rounded
                            : Icons.push_pin_outlined,
                        size: 20,
                        color: _showCurrentsOnTriads ? p.accent : p.muted,
                      ),
                      tooltip: _showCurrentsOnTriads
                          ? 'Ocultar correntes nos diagramas'
                          : 'Exibir pinos das correntes',
                      onPressed: () {
                        setState(() {
                          _showCurrentsOnTriads = !_showCurrentsOnTriads;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Representação triangular das 6 dimensões ternárias. A posição do '
                  'ponto é a composição relativa entre os três vértices; o anel ao '
                  'redor dele mostra o apoio absoluto médio (I), que distingue '
                  'apoio amplo de rejeição ampla mesmo quando a composição é a mesma.',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final TriadDimensionScore t in _record.triads) ...<Widget>[
            SectionCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ReportSectionHeader(
                    title: Text(t.label, style: text.titleLarge),
                    trailing: Tag(
                      label: t.classification,
                      background: p
                          .triadColor(t.categoryId)
                          .withValues(alpha: 0.16),
                      foreground: p.triadColor(t.categoryId),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Composição: '
                    '${t.vertices[0]} ${(t.composition[0] * 100).round()}% · '
                    '${t.vertices[1]} ${(t.composition[1] * 100).round()}% · '
                    '${t.vertices[2]} ${(t.composition[2] * 100).round()}%',
                    style: text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Apoio absoluto: ${_supportLabel(t, 0)} · '
                    '${_supportLabel(t, 1)} · ${_supportLabel(t, 2)}',
                    style: text.bodySmall?.copyWith(color: p.inkSoft),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      Tag(label: 'Cobertura ${(t.coverage * 100).round()}%'),
                      Tag(
                        label: 'Confiança ${t.confidenceLabel.toLowerCase()}',
                      ),
                      Tag(
                        label:
                            'Apoio médio I = ${(t.engagement * 100).round()}%',
                      ),
                      if (t.vertexBreakdownAvailable &&
                          !t.hasAllVerticesObserved)
                        Tag(
                          label:
                              '${3 - t.observedVertexCount} vértice(s) não avaliado(s)',
                          background: p.warning.withValues(alpha: 0.16),
                          foreground: p.warning,
                        ),
                    ],
                  ),
                  if (t.isIndeterminate) ...<Widget>[
                    const SizedBox(height: 10),
                    SectionCard(
                      color: p.warning.withValues(alpha: 0.10),
                      borderColor: p.warning.withValues(alpha: 0.35),
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Dimensão indeterminada: a composição abaixo é provisória e '
                        'não representa uma posição consolidada. Vértices não avaliados '
                        'aparecem com participação zero e não recebem apoio inventado.',
                        style: text.bodySmall?.copyWith(color: p.ink),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Center(
                    child: InteractiveTriadChart(
                      triad: t,
                      overlayPins: _showCurrentsOnTriads
                          ? compat.topMatches
                                .where(
                                  (m) => m.current.triangles.containsKey(
                                    t.categoryId,
                                  ),
                                )
                                .map(
                                  (m) => TriadOverlayPin(
                                    id: m.current.id,
                                    label: m.current.name,
                                    composition:
                                        m.current.triangles[t.categoryId]!.mu,
                                  ),
                                )
                                .toList()
                          : const <TriadOverlayPin>[],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _AtlasKindChip extends StatelessWidget {
  const _AtlasKindChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.palette,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final EspectroPalette palette;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: palette.accentSoft,
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? palette.accent : palette.inkSoft,
      ),
    );
  }
}

class _AtlasMatchRow extends StatelessWidget {
  const _AtlasMatchRow({
    required this.rank,
    required this.match,
    required this.onTap,
  });

  final int rank;
  final AtlasMatchResult match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rank == 1 ? p.accent : p.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: rank == 1
                          ? (p.isDark ? const Color(0xFF061318) : Colors.white)
                          : p.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(match.entry.name, style: text.titleMedium),
                      Text(
                        '${match.entry.subtitle} · ${match.entry.era}',
                        style: text.bodySmall?.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${match.compatibilityPercent.toStringAsFixed(1)}%',
                  style: text.titleMedium?.copyWith(color: p.accent),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 18, color: p.muted),
              ],
            ),
            const SizedBox(height: 7),
            ProgressRail(
              value: match.compatibilityPercent / 100.0,
              color: rank == 1 ? p.accent : p.accent.withValues(alpha: 0.65),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookRecommendationCard extends StatelessWidget {
  const _BookRecommendationCard({
    required this.match,
    required this.isCounterpoint,
    required this.onTap,
  });

  final AtlasMatchResult match;
  final bool isCounterpoint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: p.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCounterpoint ? p.warning.withValues(alpha: 0.35) : p.line,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ReportSectionHeader(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    isCounterpoint
                        ? Icons.lightbulb_outline_rounded
                        : Icons.auto_stories_rounded,
                    size: 18,
                    color: isCounterpoint ? p.warning : p.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      match.entry.name,
                      style: text.titleMedium?.copyWith(fontSize: 15),
                    ),
                  ),
                ],
              ),
              trailing: Tag(
                label: isCounterpoint
                    ? 'Divergência ${(100 - match.compatibilityPercent).round()}%'
                    : 'Afinidade ${match.compatibilityPercent.round()}%',
                background: isCounterpoint
                    ? p.warning.withValues(alpha: 0.14)
                    : p.accentSoft,
                foreground: isCounterpoint ? p.warning : p.accent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${match.entry.subtitle} (${match.entry.era})',
              style: text.bodySmall?.copyWith(
                color: p.inkSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(match.entry.summary, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _CurrentCompatibilityRow extends StatelessWidget {
  const _CurrentCompatibilityRow({
    required this.rank,
    required this.match,
    required this.onTap,
  });

  final int rank;
  final CurrentCompatibility match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rank == 1 ? p.accent : p.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: rank == 1
                          ? (p.isDark ? const Color(0xFF061318) : Colors.white)
                          : p.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(match.current.name, style: text.titleMedium),
                      Text(
                        match.current.family,
                        style: text.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${match.compatibilityPercent.toStringAsFixed(1)}%',
                  style: text.titleMedium?.copyWith(color: p.accent),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 18, color: p.muted),
              ],
            ),
            const SizedBox(height: 7),
            ProgressRail(
              value: match.compatibilityPercent / 100.0,
              color: rank == 1 ? p.accent : p.accent.withValues(alpha: 0.65),
            ),
          ],
        ),
      ),
    );
  }
}

/// Arena, interpretação e explicação permanecem em níveis distintos mesmo com
/// títulos extensos ou fontes ampliadas. Nenhum rótulo é truncado como um chip.
class FundamentalValuesSection extends StatelessWidget {
  const FundamentalValuesSection({required this.syntheses, super.key});

  final List<ThematicSynthesis> syntheses;

  @override
  Widget build(BuildContext context) {
    if (syntheses.isEmpty) return const SizedBox.shrink();
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Eyebrow('Sínteses de Valores Fundamentais'),
          const SizedBox(height: 6),
          Text(
            'Agrupamento substantivo dos eixos em 6 pilares de orientação política e moral.',
            style: text.bodySmall,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool twoColumns =
                  constraints.maxWidth >= 640 &&
                  MediaQuery.textScalerOf(context).scale(16) <= 22;
              final double width = twoColumns
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  for (final ThematicSynthesis synthesis in syntheses)
                    SizedBox(
                      width: width,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: p.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: p.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              synthesis.arena,
                              style: text.labelMedium?.copyWith(color: p.muted),
                            ),
                            const SizedBox(height: 8),
                            Semantics(
                              header: true,
                              child: Text(
                                synthesis.title,
                                style: text.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(synthesis.summary, style: text.bodySmall),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Mantém títulos e metadados legíveis sem obrigar chips longos a compartilhar
/// uma linha estreita. Cada filho recebe sempre uma largura máxima finita.
class _ReportSectionHeader extends StatelessWidget {
  const _ReportSectionHeader({required this.title, required this.trailing});
  final Widget title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final Widget heading = Semantics(header: true, child: title);
      if (constraints.maxWidth < 520 ||
          MediaQuery.textScalerOf(context).scale(16) > 22) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[heading, const SizedBox(height: 8), trailing],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(flex: 3, child: heading),
          const SizedBox(width: 16),
          Flexible(flex: 2, child: trailing),
        ],
      );
    },
  );
}
