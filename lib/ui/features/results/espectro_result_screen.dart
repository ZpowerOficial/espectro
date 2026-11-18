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
import '../../../data/portable_export_helper.dart';
import '../../view_models/app_view_model.dart';
import '../atlas/atlas_explorer_screen.dart';
import '../atlas/study_identity.dart';
import '../atlas/study_taxonomy.dart';
import '../atlas/study_profile_screen.dart';
import '../../../domain/models/study_models.dart';
import '../compare/compare_evaluations_screen.dart';
import '../compare/entity_comparison_screen.dart';
import '../compare/raio_x_card.dart';
import '../../../domain/engine/raio_x_engine.dart';
import '../methodology/methodology_screen.dart';
import '../quiz/espectro_quiz_screen.dart';
import '../share/shareable_card_sheet.dart';
import '../../view_models/quiz_view_model.dart';

String _formatPercent(num? val, {int decimals = 2}) {
  if (val == null) return '0.00%';
  return '${val.toStringAsFixed(decimals)}%';
}

String _formatScore(num? val, {int decimals = 2}) {
  if (val == null) return '0.00';
  return val.toStringAsFixed(decimals);
}

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
    this.quizViewModel,
    this.isPreliminary = false,
    super.key,
  });

  final AppViewModel appViewModel;
  final EvaluationRecord record;
  final int? initialTabIndex;
  final bool readOnly;
  final QuizViewModel? quizViewModel;
  final bool isPreliminary;

  @override
  State<EspectroResultScreen> createState() => _EspectroResultScreenState();
}

class _EspectroResultScreenState extends State<EspectroResultScreen> {
  bool _showCurrentsOnTriads = true;
  bool _showAllCurrents = false;
  bool _isExportingPdf = false;
  AtlasKind _selectedAtlasKind = AtlasKind.personality;
  late EvaluationRecord _record;

  bool get _isPreliminary => widget.isPreliminary || _record.isPreliminary;

  bool get _canCompleteWithTriads =>
      !widget.readOnly &&
      !_isPreliminary &&
      _record.axes.isNotEmpty &&
      _record.triads.isEmpty;

  /// Padrões que não diferenciam alternativas não devem ser apresentados como
  /// uma identidade ideológica firme, mesmo quando a geometria produz um
  /// "melhor match" numérico.
  bool get _hasCautiousReading =>
      _record.quality.hasLowDiscriminationWarning ||
      _record.quality.hasUniformExtremeWarning ||
      _record.quality.hasAllNeutralWarning;

  List<BipolarDimensionScore> get _activeAxes {
    final List<BipolarDimensionScore> valid = _record.axes
        .where((a) => !a.isIndeterminate)
        .toList();
    if (valid.isNotEmpty) return valid;
    final List<BipolarDimensionScore> answered = _record.axes
        .where((a) => a.answeredCount > 0)
        .toList();
    if (answered.isNotEmpty) {
      return answered
          .map(
            (a) => BipolarDimensionScore(
              axisId: a.axisId,
              label: a.label,
              leftPole: a.leftPole,
              rightPole: a.rightPole,
              score: a.score,
              standardError: a.standardError,
              coverage: 1.0,
              answeredCount: a.answeredCount,
              presentedCount: a.presentedCount,
              tensionScore: a.tensionScore,
            ),
          )
          .toList();
    }
    return _record.axes
        .map(
          (a) => BipolarDimensionScore(
            axisId: a.axisId,
            label: a.label,
            leftPole: a.leftPole,
            rightPole: a.rightPole,
            score: a.score,
            standardError: a.standardError,
            coverage: 1.0,
            answeredCount: 1,
            presentedCount: a.presentedCount,
            tensionScore: a.tensionScore,
          ),
        )
        .toList();
  }

  int _countryFilterIndex = 0; // 0: Todos, 1: Atuais, 2: Históricos
  int _partyFilterIndex = 0; // 0: Todos, 1: Atuais, 2: Históricos
  int _heroAffinitiesTab = 0; // 0: 12 Eixos, 1: 6 Tríades

  AtlasMatchResult? _findBestPersonalityForAxis(
    PoliticalAtlas atlas,
    BipolarDimensionScore axis,
  ) {
    if (atlas.personalities.isEmpty) return null;
    final singleAxis = BipolarDimensionScore(
      axisId: axis.axisId,
      score: axis.score,
      label: axis.label,
      leftPole: axis.leftPole,
      rightPole: axis.rightPole,
      standardError: axis.standardError,
      coverage: 1.0,
      answeredCount: 1,
      presentedCount: axis.presentedCount,
      tensionScore: axis.tensionScore,
    );
    final canonical = atlas.canonicalPersonalities
        .where((p) => p.axes.containsKey(axis.axisId))
        .toList();
    final core = canonical.take(125).toList();
    final coreMatch = EspectroAtlasEngine.rankEntries(
      entries: core,
      axes: [singleAxis],
      triads: const <TriadDimensionScore>[],
    ).firstOrNull;

    if (coreMatch != null && coreMatch.compatibilityPercent >= 80) {
      return coreMatch;
    }

    return EspectroAtlasEngine.rankEntries(
      entries: canonical,
      axes: [singleAxis],
      triads: const <TriadDimensionScore>[],
    ).firstOrNull;
  }

  AtlasMatchResult? _findBestPersonalityForTriad(
    PoliticalAtlas atlas,
    TriadDimensionScore triad,
  ) {
    if (atlas.personalities.isEmpty) return null;
    final singleTriad = TriadDimensionScore(
      categoryId: triad.categoryId,
      label: triad.label,
      classification: triad.classification,
      composition: triad.composition,
      engagement: triad.engagement,
      vertices: triad.vertices,
      vertexScores: triad.vertexScores,
      vertexSupport: triad.vertexSupport,
      coverage: 1.0,
      standardError: triad.standardError,
      answeredCount: 1,
      presentedCount: triad.presentedCount,
    );
    final validPers = atlas.canonicalPersonalities
        .where((p) => p.triangles.containsKey(triad.categoryId))
        .toList();
    if (validPers.isEmpty) return null;

    final core = validPers.take(125).toList();
    final coreMatch = EspectroAtlasEngine.rankEntries(
      entries: core,
      axes: const <BipolarDimensionScore>[],
      triads: [singleTriad],
    ).firstOrNull;

    if (coreMatch != null && coreMatch.compatibilityPercent >= 80) {
      return coreMatch;
    }

    return EspectroAtlasEngine.rankEntries(
      entries: validPers,
      axes: const <BipolarDimensionScore>[],
      triads: [singleTriad],
    ).firstOrNull;
  }

  int _activeTocIndex = 0;
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _keyEixos = GlobalKey();
  final GlobalKey _keyDistincao = GlobalKey();
  final GlobalKey _keyPaises = GlobalKey();
  final GlobalKey _keyPersonalidades = GlobalKey();
  final GlobalKey _keyLivros = GlobalKey();
  final GlobalKey _keyPartidos = GlobalKey();
  final GlobalKey _keyBussola = GlobalKey();
  final GlobalKey _keyIdeologias = GlobalKey();

  List<GlobalKey> get _tocKeys => <GlobalKey>[
    _keyEixos,
    _keyDistincao,
    _keyPaises,
    _keyPersonalidades,
    _keyLivros,
    _keyPartidos,
    _keyBussola,
    _keyIdeologias,
  ];

  void _scrollToSection(GlobalKey key, int index) {
    setState(() => _activeTocIndex = index);
    final BuildContext? targetContext = key.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _resumeQuiz() async {
    if (widget.quizViewModel != null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    final ActiveQuizDraft? draft = widget.appViewModel.activeDraft;
    if (draft != null) {
      final QuizViewModel quizVm = QuizViewModel.fromDraft(
        data: widget.appViewModel.data,
        repository: widget.appViewModel.repository,
        draft: draft,
        history: widget.appViewModel.history,
      );
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => EspectroQuizScreen(
            appViewModel: widget.appViewModel,
            quizViewModel: quizVm,
          ),
        ),
      );
      if (mounted) setState(() {});
    }
  }

  Future<void> _completeWithTriads() async {
    final QuizViewModel quizVm = QuizViewModel.startTriadSupplement(
      data: widget.appViewModel.data,
      repository: widget.appViewModel.repository,
      baseRecord: _record,
    );
    final EvaluationRecord? updated = await Navigator.of(context)
        .push<EvaluationRecord>(
          MaterialPageRoute<EvaluationRecord>(
            builder: (BuildContext context) => EspectroQuizScreen(
              appViewModel: widget.appViewModel,
              quizViewModel: quizVm,
              returnCompletedRecord: true,
            ),
          ),
        );
    if (mounted && updated != null) {
      setState(() {
        _record = updated;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _record = widget.record;
  }

  Future<void> _exportPdf() async {
    if (_isExportingPdf) return;
    setState(() => _isExportingPdf = true);
    try {
      final String exported = await EspectroPdfService.exportAndSharePdf(
        record: _record,
        data: widget.appViewModel.data,
      );
      if (mounted &&
          currentPortableTarget() != PortableTarget.mobileOrNativeShare) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dossiê PDF salvo em:\n$exported')),
        );
      }
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
      axes: _activeAxes,
      triads: _record.triads,
    );
    final PoliticalAtlas atlas = widget.appViewModel.data.atlas;
    final List<AtlasMatchResult> topCountries = EspectroAtlasEngine.rankEntries(
      entries: atlas.countries,
      axes: _activeAxes,
      triads: _record.triads,
    );
    final List<AtlasMatchResult> topPers = EspectroAtlasEngine.rankEntries(
      entries: atlas.canonicalPersonalities,
      axes: _activeAxes,
      triads: _record.triads,
    );
    final List<AtlasMatchResult> topParties = EspectroAtlasEngine.rankEntries(
      entries: atlas.partiesAndMovements,
      axes: _activeAxes,
      triads: _record.triads,
    );
    final BookRecommendationReport books = EspectroAtlasEngine.recommendBooks(
      books: atlas.books,
      axes: _activeAxes,
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
        '- Liberdade Pessoal: ${_formatPercent(nolan.personalFreedom)} (±${_formatPercent(nolan.personalSe)})',
      );
      buf.writeln(
        '- Liberdade Econômica: ${_formatPercent(nolan.economicFreedom)} (±${_formatPercent(nolan.economicSe)})',
      );
    }

    if (compat.topMatches.isNotEmpty) {
      buf.writeln('\nCorrentes ideológicas mais próximas:');
      for (final CurrentCompatibility c in compat.topMatches.take(4)) {
        buf.writeln(
          '- ${c.current.name}: ${_formatPercent(c.compatibilityPercent)}',
        );
      }
    }

    if (topCountries.isNotEmpty) {
      buf.writeln('\nModelos de País afins:');
      for (final AtlasMatchResult c in topCountries.take(3)) {
        buf.writeln(
          '- ${c.entry.name} (${c.entry.era}): ${_formatPercent(c.compatibilityPercent)}',
        );
      }
    }

    if (topPers.isNotEmpty) {
      buf.writeln('\nPersonalidades históricas afins:');
      for (final AtlasMatchResult p in topPers.take(3)) {
        buf.writeln(
          '- ${p.entry.name} (${p.entry.era}): ${_formatPercent(p.compatibilityPercent)}',
        );
      }
    }

    if (topParties.isNotEmpty) {
      buf.writeln('\nPartidos e Movimentos com afinidade:');
      for (final AtlasMatchResult m in topParties.take(2)) {
        buf.writeln(
          '- ${m.entry.name} (${m.entry.origin}): ${_formatPercent(m.compatibilityPercent)}',
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
          '(${t.vertices[0]} ${_formatPercent(t.composition[0] * 100)} / '
          '${t.vertices[1]} ${_formatPercent(t.composition[1] * 100)} / '
          '${t.vertices[2]} ${_formatPercent(t.composition[2] * 100)})',
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
              Tag(label: 'Cobertura ${_formatPercent(axis.coverage * 100)}'),
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
            '${_formatPercent(axis.rightPercentLow)} a ${_formatPercent(axis.rightPercentHigh)} '
            '(${axis.answeredCount} de ${axis.presentedCount} itens respondidos).',
            style: text.bodyMedium,
          ),
          if (axis.isIndeterminate) ...<Widget>[
            const SizedBox(height: 10),
            SectionCard(
              elevated: false,
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
              elevated: false,
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
                  elevated: false,
                  color: p.surfaceMuted,
                  borderColor: p.line.withValues(alpha: 0.7),
                  padding: const EdgeInsets.all(12),
                  radius: 13,
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
                    '${_formatPercent(match.compatibilityPercent)} compatível',
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
                elevated: false,
                color: p.surfaceMuted,
                borderColor: p.line.withValues(alpha: 0.7),
                radius: 13,
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
                  elevated: false,
                  color: p.surfaceMuted,
                  borderColor: p.line.withValues(alpha: 0.7),
                  radius: 13,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StudyIdentityAvatar(
                subject: StudySubject.fromEntry(entry),
                size: 56,
                rectangular:
                    entry.kind == AtlasKind.personality ||
                    entry.kind == AtlasKind.book,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.subtitle,
                      style: text.titleMedium?.copyWith(color: p.muted),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: <Widget>[
                        Tag(label: entry.category),
                        if (entry.origin.isNotEmpty) Tag(label: entry.origin),
                        if (entry.era.isNotEmpty) Tag(label: entry.era),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Tag(
                label: pin?.quadrantLabel ?? 'Sem projeção bidimensional',
                background: p.accentSoft,
                foreground: p.accent,
              ),
              if (match != null)
                Tag(
                  label:
                      '${_formatPercent(match.compatibilityPercent)} afinidade com você',
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
      axes: _activeAxes,
      triads: _record.triads,
    );

    final List<Tab> tabs = <Tab>[
      const Tab(text: 'Visão Completa'),
      if (_record.axes.isNotEmpty) const Tab(text: 'Eixos (12)'),
      if (_record.triads.isNotEmpty) const Tab(text: 'Tríades (6)'),
      const Tab(text: 'Atlas'),
      const Tab(text: 'Biblioteca'),
    ];

    final PoliticalAtlas atlas = widget.appViewModel.data.atlas;
    final List<Widget> tabViews = <Widget>[
      _buildOverviewTab(context, compat, p, text),
      if (_record.axes.isNotEmpty) _buildAxesTab(context, atlas, p, text),
      if (_record.triads.isNotEmpty)
        _buildTriadsTab(context, atlas, compat, p, text),
      _buildAtlasTab(context, p, text),
      _buildLibraryTab(context, p, text),
    ];

    return DefaultTabController(
      key: ValueKey<int>(tabs.length),
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
                icon: (widget.quizViewModel != null || _isPreliminary)
                    ? Icons.arrow_back_rounded
                    : Icons.close_rounded,
                onPressed: () {
                  if (_isPreliminary) {
                    _resumeQuiz();
                  } else if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                tooltip: (widget.quizViewModel != null || _isPreliminary)
                    ? 'Voltar ao teste'
                    : 'Voltar ao início',
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
            if (_isPreliminary)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: MediaQuery.sizeOf(context).width >= 560
                    ? FilledButton.tonalIcon(
                        onPressed: _resumeQuiz,
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: const Text('Continuar teste'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        ),
                      )
                    : IconButton(
                        tooltip: 'Continuar teste e refinar',
                        onPressed: _resumeQuiz,
                        icon: const Icon(Icons.play_arrow_rounded),
                      ),
              ),
            IconButton(
              tooltip: 'Compartilhar card',
              onPressed: _openShareCard,
              icon: const Icon(Icons.share_rounded, size: 20),
            ),
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
          bottom: FadeEdgeTabBar(
            tabBar: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: p.accent,
              unselectedLabelColor: p.muted,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: p.accent, width: 2.5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
                insets: const EdgeInsets.symmetric(horizontal: 4),
              ),
              dividerColor: p.line,
              tabs: tabs,
            ),
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
    TextTheme text,
  ) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = screenWidth >= 1100;

    final CompatibilityReport effectiveCompat = compat.primaryMatch != null
        ? compat
        : EspectroCompatibilityEngine.evaluate(
            catalog: widget.appViewModel.data.catalog,
            axes: _activeAxes,
            triads: _record.triads,
          );
    final CurrentCompatibility? primaryMatch =
        effectiveCompat.primaryMatch ?? effectiveCompat.topMatches.firstOrNull;

    // 1. Distinction metrics
    final List<BipolarDimensionScore> sortedByExtremity =
        List<BipolarDimensionScore>.from(_activeAxes)
          ..sort((a, b) => b.score.abs().compareTo(a.score.abs()));
    final BipolarDimensionScore? mostUncommon = sortedByExtremity.firstOrNull;

    final List<BipolarDimensionScore> sortedByCommonality =
        List<BipolarDimensionScore>.from(_activeAxes)
          ..sort((a, b) => a.score.abs().compareTo(b.score.abs()));
    final BipolarDimensionScore? mostCommon = sortedByCommonality.firstOrNull;

    int uncommonPercentLower = 75;
    if (mostUncommon != null) {
      final List<IdeologicalCurrent> allCurrents =
          widget.appViewModel.data.catalog.currents;
      if (allCurrents.isNotEmpty) {
        int count = 0;
        for (final IdeologicalCurrent c in allCurrents) {
          final double val = c.axes[mostUncommon.axisId]?.mu ?? 0.0;
          if (mostUncommon.score >= 0 && val < mostUncommon.score) {
            count++;
          } else if (mostUncommon.score < 0 && val > mostUncommon.score) {
            count++;
          }
        }
        uncommonPercentLower = ((count / allCurrents.length) * 100)
            .round()
            .clamp(10, 99);
      }
    }

    // 2. Atlas Collections & Filterings
    final PoliticalAtlas atlas = widget.appViewModel.data.atlas;

    // Countries
    final List<AtlasEntry> filteredCountries;
    if (_countryFilterIndex == 1) {
      filteredCountries = atlas.countries
          .where(
            (c) =>
                c.era.toLowerCase().contains('presente') ||
                c.era.toLowerCase().contains('atual'),
          )
          .toList();
    } else if (_countryFilterIndex == 2) {
      filteredCountries = atlas.countries
          .where(
            (c) =>
                !c.era.toLowerCase().contains('presente') &&
                !c.era.toLowerCase().contains('atual'),
          )
          .toList();
    } else {
      filteredCountries = atlas.countries;
    }

    final List<AtlasMatchResult> countryMatches =
        EspectroAtlasEngine.rankEntries(
          entries: filteredCountries.isNotEmpty
              ? filteredCountries
              : atlas.countries,
          axes: _activeAxes,
          triads: _record.triads,
        );
    final AtlasMatchResult? topCountry = countryMatches.firstOrNull;

    // Sub-dimension rankings for countries
    final List<BipolarDimensionScore> polAxes = _activeAxes
        .where(
          (a) => const <String>[
            'poder',
            'representacao',
            'estrutura',
            'diplomacia',
          ].contains(a.axisId),
        )
        .toList();
    final List<BipolarDimensionScore> socAxes = _activeAxes
        .where(
          (a) => const <String>[
            'moral',
            'religiao',
            'sociedade',
            'imigracao',
          ].contains(a.axisId),
        )
        .toList();
    final List<BipolarDimensionScore> ecoAxes = _activeAxes
        .where(
          (a) => const <String>[
            'economia',
            'controle',
            'comercio',
            'trabalho',
            'propriedade',
          ].contains(a.axisId),
        )
        .toList();

    final AtlasMatchResult? polCountry = polAxes.isNotEmpty
        ? EspectroAtlasEngine.rankEntries(
            entries: atlas.countries,
            axes: polAxes,
            triads: const <TriadDimensionScore>[],
          ).firstOrNull
        : null;
    final AtlasMatchResult? socCountry = socAxes.isNotEmpty
        ? EspectroAtlasEngine.rankEntries(
            entries: atlas.countries,
            axes: socAxes,
            triads: const <TriadDimensionScore>[],
          ).firstOrNull
        : null;
    final AtlasMatchResult? ecoCountry = ecoAxes.isNotEmpty
        ? EspectroAtlasEngine.rankEntries(
            entries: atlas.countries,
            axes: ecoAxes,
            triads: const <TriadDimensionScore>[],
          ).firstOrNull
        : null;

    // Personalities (apenas cânone intelectual e histórico: filósofos, economistas, cientistas políticos e estadistas)
    final List<AtlasEntry> canonicalPers = atlas.canonicalPersonalities;
    final List<AtlasMatchResult> persMatches = EspectroAtlasEngine.rankEntries(
      entries: canonicalPers,
      axes: _activeAxes,
      triads: _record.triads,
    );
    final AtlasMatchResult? topPers = persMatches.firstOrNull;
    final AtlasMatchResult? polPers = polAxes.isNotEmpty
        ? EspectroAtlasEngine.rankEntries(
            entries: canonicalPers,
            axes: polAxes,
            triads: const <TriadDimensionScore>[],
          ).firstOrNull
        : null;
    final AtlasMatchResult? socPers = socAxes.isNotEmpty
        ? EspectroAtlasEngine.rankEntries(
            entries: canonicalPers,
            axes: socAxes,
            triads: const <TriadDimensionScore>[],
          ).firstOrNull
        : null;
    final AtlasMatchResult? ecoPers = ecoAxes.isNotEmpty
        ? EspectroAtlasEngine.rankEntries(
            entries: canonicalPers
                .where(
                  (p) =>
                      p.vocation == PersonalityVocation.economist ||
                      p.vocation == PersonalityVocation.philosopher,
                )
                .toList(),
            axes: ecoAxes,
            triads: const <TriadDimensionScore>[],
          ).firstOrNull
        : null;

    // Books
    final BookRecommendationReport bookReport =
        EspectroAtlasEngine.recommendBooks(
          books: atlas.books,
          axes: _activeAxes,
          triads: _record.triads,
        );
    final AtlasMatchResult? topBook = bookReport.affinityBooks.firstOrNull;
    final AtlasMatchResult? secondBook = bookReport.affinityBooks.length > 1
        ? bookReport.affinityBooks[1]
        : null;
    final AtlasMatchResult? counterpointBook =
        bookReport.counterpointBooks.firstOrNull;

    // Parties & Movements
    final List<AtlasEntry> filteredParties;
    if (_partyFilterIndex == 1) {
      filteredParties = atlas.partiesAndMovements
          .where(
            (m) =>
                m.era.toLowerCase().contains('fundado') ||
                m.era.toLowerCase().contains('presente') ||
                m.era.toLowerCase().contains('ativo'),
          )
          .toList();
    } else if (_partyFilterIndex == 2) {
      filteredParties = atlas.partiesAndMovements
          .where(
            (m) =>
                m.era.toLowerCase().contains('–') ||
                m.era.toLowerCase().contains('extinto') ||
                m.era.toLowerCase().contains('dissolvido'),
          )
          .toList();
    } else {
      filteredParties = atlas.partiesAndMovements;
    }
    final List<AtlasMatchResult> partyMatches = EspectroAtlasEngine.rankEntries(
      entries: filteredParties.isNotEmpty
          ? filteredParties
          : atlas.partiesAndMovements,
      axes: _activeAxes,
      triads: _record.triads,
    );
    final AtlasMatchResult? topParty = partyMatches.firstOrNull;

    // Nolan & Syntheses
    final NolanCoordinates? nolan = EspectroNolanEngine.fromEvaluation(
      axes: _activeAxes,
      triads: _record.triads,
    );
    final List<ThematicSynthesis> syntheses =
        EspectroAtlasEngine.computeSyntheses(
          axes: _activeAxes,
          triads: _record.triads,
        );
    final List<DoctrinalTension> tensions =
        EspectroAtlasEngine.detectDoctrinalTensions(
          axes: _activeAxes,
          triads: _record.triads,
        );

    // Afinidades individuais de personalidades por eixo e por tríade
    final Map<String, AtlasMatchResult> bestPersByAxis =
        <String, AtlasMatchResult>{};
    for (final axis in _activeAxes) {
      final match = _findBestPersonalityForAxis(atlas, axis);
      if (match != null) {
        bestPersByAxis[axis.axisId] = match;
      }
    }

    final Map<int, AtlasMatchResult> bestPersByTriad =
        <int, AtlasMatchResult>{};
    for (final triad in _record.triads) {
      final match = _findBestPersonalityForTriad(atlas, triad);
      if (match != null) {
        bestPersByTriad[triad.categoryId] = match;
      }
    }

    // Color for primary current
    final Color spectrumColor = primaryMatch != null
        ? (spectrumOf(StudySubject.fromCurrent(primaryMatch.current))?.color ??
              p.accent)
        : p.accent;

    final Widget mainNarrative = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_isPreliminary) ...<Widget>[
          _PreliminaryBanner(
            answeredCount:
                widget.quizViewModel?.answeredCount ??
                (widget.appViewModel.activeDraft?.answers
                        .where((a) => a != null)
                        .length ??
                    _record.quality.totalAnswered),
            totalCount:
                widget.quizViewModel?.totalCount ??
                (widget.appViewModel.activeDraft?.questionUids.length ??
                    _record.quality.totalPresented),
            onContinue: _resumeQuiz,
          ),
          const SizedBox(height: 18),
        ],

        if (_record.quality.warnings.isNotEmpty) ...<Widget>[
          _ResponseQualityBanner(warnings: _record.quality.warnings),
          const SizedBox(height: 18),
        ],

        // Hero Ideology Match Card
        if (primaryMatch != null) ...<Widget>[
          _buildHeroIdeologyCard(
            context,
            primaryMatch,
            compat,
            countryMatches,
            persMatches,
            bestPersByAxis,
            bestPersByTriad,
            spectrumColor,
            p,
            text,
          ),
          if (_canCompleteWithTriads) ...<Widget>[
            const SizedBox(height: 18),
            _CompleteTriadsBanner(
              isExpress: _record.depth == TestDepth.express,
              onComplete: _completeWithTriads,
            ),
          ],
          const SizedBox(height: 18),
          RaioXDiagnosticCard(
            diagnostic: RaioXEngine.fromCurrentCompatibility(
              compatibility: primaryMatch,
              twelveAxes: widget.appViewModel.data.twelveAxes,
              sixTriangles: widget.appViewModel.data.sixTriangles,
            ),
          ),
        ],

        if (!isDesktop) ...<Widget>[
          const SizedBox(height: 16),
          _MobileQuickNav(
            activeTocIndex: _activeTocIndex,
            onSelect: (int idx) {
              final GlobalKey targetKey = _tocKeys[idx];
              _scrollToSection(targetKey, idx);
            },
          ),
        ],

        const SizedBox(height: 32),

        // 01 Seus 12 Eixos
        Container(
          key: _keyEixos,
          child: _buildSection12Axes(context, bestPersByAxis, p, text),
        ),

        const SizedBox(height: 36),

        // 02 Distinção
        Container(
          key: _keyDistincao,
          child: _buildSectionDistinction(
            context,
            mostUncommon,
            mostCommon,
            uncommonPercentLower,
            p,
            text,
          ),
        ),

        const SizedBox(height: 36),

        // 03 Países mais próximos
        Container(
          key: _keyPaises,
          child: _buildSectionCountries(
            context,
            topCountry,
            countryMatches,
            polCountry,
            socCountry,
            ecoCountry,
            p,
            text,
          ),
        ),

        const SizedBox(height: 36),

        // 04 Personalidades mais próximas
        Container(
          key: _keyPersonalidades,
          child: _buildSectionPersonalities(
            context,
            topPers,
            persMatches,
            polPers,
            socPers,
            ecoPers,
            p,
            text,
          ),
        ),

        const SizedBox(height: 36),

        // 05 Livros recomendados
        Container(
          key: _keyLivros,
          child: _buildSectionBooks(
            context,
            topBook,
            secondBook,
            counterpointBook,
            bookReport,
            p,
            text,
          ),
        ),

        const SizedBox(height: 36),

        // 06 Partidos e movimentos
        Container(
          key: _keyPartidos,
          child: _buildSectionParties(context, topParty, partyMatches, p, text),
        ),

        const SizedBox(height: 36),

        // 07 Bússola & Tríades
        Container(
          key: _keyBussola,
          child: _buildSectionCompassAndTriads(
            context,
            nolan,
            syntheses,
            tensions,
            compat,
            bestPersByTriad,
            p,
            text,
          ),
        ),

        const SizedBox(height: 36),

        // 08 Outras ideologias
        Container(
          key: _keyIdeologias,
          child: _buildSectionOtherIdeologies(context, compat, p, text),
        ),

        const SizedBox(height: 36),

        // 09 Ações finais
        _buildFinalActions(context, compat, p, text),
      ],
    );

    if (isDesktop) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1220),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(right: 28),
                    child: mainNarrative,
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: _StickyTocPanel(
                    activeIndex: _activeTocIndex,
                    onSelect: (int idx) {
                      final GlobalKey targetKey = _tocKeys[idx];
                      _scrollToSection(targetKey, idx);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1220),
          child: mainNarrative,
        ),
      ),
    );
  }

  Widget _buildHeroIdeologyCard(
    BuildContext context,
    CurrentCompatibility primaryMatch,
    CompatibilityReport compat,
    List<AtlasMatchResult> countryMatches,
    List<AtlasMatchResult> persMatches,
    Map<String, AtlasMatchResult> bestPersByAxis,
    Map<int, AtlasMatchResult> bestPersByTriad,
    Color spectrumColor,
    EspectroPalette p,
    TextTheme text,
  ) {
    final spectrum = spectrumOf(StudySubject.fromCurrent(primaryMatch.current));
    final bool lowInformation =
        compat.isLowDiscrimination || _hasCautiousReading;

    final bool showMiniRadar = _activeAxes.length >= 3;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: EspectroElevation.cardDecoration(
        p,
        color: p.surface,
        borderColor: p.line,
        tint: spectrumColor,
        radius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SpectrumGradientRule(height: 3.5, radius: 0),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Colored bar/pill for spectrum - STRICTLY NO ICONS
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: spectrumColor.withValues(
                          alpha: p.isDark ? 0.18 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: spectrumColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        lowInformation
                            ? 'LEITURA CAUTELOSA'
                            : 'SEU ESPECTRO: ${spectrum?.name.toUpperCase() ?? primaryMatch.current.family.toUpperCase()}',
                        style: TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: spectrumColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Text(
                      lowInformation
                          ? 'PROXIMIDADE GEOMÉTRICA · LEITURA CAUTELOSA'
                          : 'MAIOR AFINIDADE ESTIMADA',
                      style: TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 11,
                        color: lowInformation ? p.warning : p.muted,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                if (spectrum?.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    spectrum!.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: p.inkSoft,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool isExtraNarrow =
                        constraints.maxWidth < 460 ||
                        MediaQuery.textScalerOf(context).scale(16) > 20;
                    final bool narrow = constraints.maxWidth < 560;
                    final bool showRadarAside =
                        showMiniRadar && constraints.maxWidth >= 600;

                    final Widget titleCol = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          primaryMatch.current.name,
                          style: text.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: p.ink,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lowInformation
                              ? 'Proximidade geométrica no espaço medido, não afinidade ideológica definida'
                              : compat.isTechnicalTie
                              ? 'Empate técnico de convergência com outras correntes'
                              : 'Perfil editorial com máxima convergência aos seus valores',
                          style: text.bodySmall?.copyWith(
                            color: lowInformation ? p.warning : p.inkSoft,
                          ),
                        ),
                      ],
                    );

                    final Widget gauge = _AnimatedMatchGauge(
                      percent: primaryMatch.compatibilityPercent,
                      size: narrow ? 72 : 84,
                      accentColor: spectrumColor,
                      label: lowInformation ? 'PROX.' : 'MATCH',
                    );

                    final Widget visualCluster = showRadarAside
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: p.surfaceMuted.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: p.line.withValues(alpha: 0.75),
                                  ),
                                ),
                                child: MultidimensionalRadarChart(
                                  axes: _activeAxes,
                                  size: 132,
                                ),
                              ),
                              const SizedBox(width: 14),
                              gauge,
                            ],
                          )
                        : gauge;

                    if (isExtraNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          titleCol,
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 14,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              gauge,
                              if (showMiniRadar)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: p.surfaceMuted.withValues(
                                      alpha: 0.55,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: p.line.withValues(alpha: 0.75),
                                    ),
                                  ),
                                  child: MultidimensionalRadarChart(
                                    axes: _activeAxes,
                                    size: 118,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(child: titleCol),
                        const SizedBox(width: 16),
                        visualCluster,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Quote box: UMA FRASE QUE TE DESCREVE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: p.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(color: spectrumColor, width: 3.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        lowInformation
                            ? '— FRASE DO PERFIL MAIS PRÓXIMO'
                            : '— UMA FRASE QUE TE DESCREVE',
                        style: TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.9,
                          color: p.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '“${primaryMatch.current.summary}”',
                        style: text.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          color: p.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints box) {
                    final bool stackButtons = box.maxWidth < 520;
                    final Widget shareBtn = AppButton(
                      label: 'Compartilhar card',
                      icon: Icons.share_rounded,
                      kind: AppButtonKind.filled,
                      expand: stackButtons,
                      onPressed: _openShareCard,
                    );
                    final Widget compareBtn = AppButton(
                      label: 'Comparar comigo em detalhes',
                      icon: Icons.compare_arrows_rounded,
                      kind: AppButtonKind.outline,
                      expand: stackButtons,
                      onPressed: () => EntityComparisonScreen.showCurrent(
                        context,
                        record: _record,
                        current: primaryMatch.current,
                        appViewModel: widget.appViewModel,
                      ),
                    );
                    final Widget detailsBtn = AppButton(
                      label: 'Ver detalhes da ideologia',
                      icon: Icons.info_outline_rounded,
                      kind: AppButtonKind.outline,
                      expand: stackButtons,
                      onPressed: () => _showCurrentMatchSheet(primaryMatch),
                    );
                    if (stackButtons) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          shareBtn,
                          const SizedBox(height: 10),
                          compareBtn,
                          const SizedBox(height: 10),
                          detailsBtn,
                        ],
                      );
                    }
                    return Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: <Widget>[shareBtn, compareBtn, detailsBtn],
                    );
                  },
                ),

                // 1. CORRENTES MAIS PRÓXIMAS
                _buildNearestCurrentsHero(context, compat, p, text),

                // 2. AFINIDADES POR EIXO E TRÍADE: PERSONALIDADES MAIS PRÓXIMAS
                _buildAxesAffinitiesHero(
                  context,
                  _activeAxes,
                  _record.triads,
                  bestPersByAxis,
                  bestPersByTriad,
                  p,
                  text,
                ),

                // 3. PERSONALIDADES QUE COMBINAM COM VOCÊ
                _buildPersonalitiesHero(context, persMatches, p, text),

                // 4. MODELOS ESTATAIS & RECORTES HISTÓRICOS
                _buildCountriesHero(context, countryMatches, p, text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearestCurrentsHero(
    BuildContext context,
    CompatibilityReport compat,
    EspectroPalette p,
    TextTheme text,
  ) {
    final topMatches = compat.topMatches.take(3).toList();
    if (topMatches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Divider(height: 1, color: p.line.withValues(alpha: 0.6)),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              'CORRENTES MAIS PRÓXIMAS',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: p.muted,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${topMatches.length} em maior convergência',
              style: TextStyle(fontSize: 11, color: p.inkSoft),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 640;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var idx = 0; idx < topMatches.length; idx++)
                  () {
                    final match = topMatches[idx];
                    final curSpectrum = spectrumOf(
                      StudySubject.fromCurrent(match.current),
                    );
                    final curColor = curSpectrum?.color ?? p.accent;
                    final curInk = curSpectrum?.ink(p.isDark) ?? curColor;
                    final pct = _formatScore(match.compatibilityPercent);
                    final width = isNarrow
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 20) / 3;

                    return InkWell(
                      onTap: () => _showCurrentMatchSheet(match),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: width,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: p.surfaceMuted,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: curColor.withValues(alpha: 0.38),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(height: 3.5, color: curColor),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: p.surface,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(color: p.line),
                                        ),
                                        child: Text(
                                          '#${idx + 1}',
                                          style: TextStyle(
                                            fontFamily: 'IBMPlexMono',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: p.inkSoft,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          curSpectrum?.name.toUpperCase() ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'IBMPlexMono',
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: curInk,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: curColor.withValues(
                                            alpha: 0.16,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '$pct%',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: curInk,
                                            fontFamily: 'IBMPlexMono',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    match.current.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: match.compatibilityPercent / 100.0,
                                      minHeight: 5,
                                      backgroundColor: p.line.withValues(
                                        alpha: 0.45,
                                      ),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        curColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          match.current.family,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: p.inkSoft,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 14,
                                        color: curInk,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAxesAffinitiesHero(
    BuildContext context,
    List<BipolarDimensionScore> activeAxes,
    List<TriadDimensionScore> triads,
    Map<String, AtlasMatchResult> bestPersByAxis,
    Map<int, AtlasMatchResult> bestPersByTriad,
    EspectroPalette p,
    TextTheme text,
  ) {
    if (activeAxes.isEmpty && triads.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Divider(height: 1, color: p.line.withValues(alpha: 0.6)),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              'AFINIDADES POR EIXO E TRÍADE: PERSONALIDADES MAIS PRÓXIMAS',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: p.muted,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              _heroAffinitiesTab == 0
                  ? '${activeAxes.length} figuras históricas por eixo'
                  : '${triads.length} figuras históricas por tríade',
              style: TextStyle(fontSize: 11, color: p.inkSoft),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SegmentedButton<int>(
          segments: const <ButtonSegment<int>>[
            ButtonSegment<int>(value: 0, label: Text('12 Eixos (Bipolar)')),
            ButtonSegment<int>(value: 1, label: Text('6 Tríades (Ternário)')),
          ],
          selected: <int>{_heroAffinitiesTab},
          onSelectionChanged: (Set<int> newSelection) {
            setState(() {
              _heroAffinitiesTab = newSelection.first;
            });
          },
        ),
        const SizedBox(height: 14),
        if (_heroAffinitiesTab == 0)
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 640;
              final double itemWidth = isNarrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  for (final axis in activeAxes)
                    () {
                      final axisDef = widget.appViewModel.data.twelveAxes.axes
                          .where((a) => a.id == axis.axisId)
                          .firstOrNull;
                      final axisColor =
                          (axis.leansLeft
                              ? axisDef?.leftColor
                              : axisDef?.rightColor) ??
                          p.accent;
                      final bestMatch = bestPersByAxis[axis.axisId];
                      final entry = bestMatch?.entry;
                      final pct = _formatScore(bestMatch?.compatibilityPercent);
                      final spec = entry != null
                          ? spectrumOf(StudySubject.fromEntry(entry))
                          : null;
                      final col = spec?.color ?? axisColor;

                      return Container(
                        width: itemWidth,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: p.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: p.line.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    axis.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: p.ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  flex: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: axisColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${axis.dominantPole} ${_formatPercent(axis.dominantPercent)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: axisColor,
                                        fontFamily: 'IBMPlexMono',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (entry != null) ...[
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () =>
                                    EntityComparisonScreen.showAtlasEntry(
                                      context,
                                      record: _record,
                                      entry: entry,
                                      appViewModel: widget.appViewModel,
                                    ),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: p.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: col.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, c) {
                                      final isNarrow = c.maxWidth < 290;
                                      return Row(
                                        children: [
                                          _buildAvatarImage(
                                            photoUrl: entry.photoUrl,
                                            name: entry.name,
                                            color: col,
                                            size: isNarrow ? 28 : 34,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  entry.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 1),
                                                Text(
                                                  '${entry.origin} · ${entry.era}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: p.inkSoft,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: col.withValues(
                                                      alpha: 0.15,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '$pct% afim',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: col,
                                                      fontFamily: 'IBMPlexMono',
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .compare_arrows_rounded,
                                                      size: 12,
                                                      color: p.muted,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      'comparar',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 9.5,
                                                        color: p.muted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }(),
                ],
              );
            },
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 640;
              final double itemWidth = isNarrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  for (final triad in triads)
                    () {
                      final bestMatch = bestPersByTriad[triad.categoryId];
                      final entry = bestMatch?.entry;
                      final pct = _formatScore(bestMatch?.compatibilityPercent);
                      final spec = entry != null
                          ? spectrumOf(StudySubject.fromEntry(entry))
                          : null;
                      final col = spec?.color ?? p.triadColor(triad.categoryId);

                      return Container(
                        width: itemWidth,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: p.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: p.line.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    triad.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: p.ink,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p
                                        .triadColor(triad.categoryId)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    triad.classification,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: p.triadColor(triad.categoryId),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${triad.vertices[0]} ${_formatPercent(triad.composition[0] * 100)} · '
                              '${triad.vertices[1]} ${_formatPercent(triad.composition[1] * 100)} · '
                              '${triad.vertices[2]} ${_formatPercent(triad.composition[2] * 100)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: p.inkSoft,
                              ),
                            ),
                            if (entry != null) ...[
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () =>
                                    EntityComparisonScreen.showAtlasEntry(
                                      context,
                                      record: _record,
                                      entry: entry,
                                      appViewModel: widget.appViewModel,
                                    ),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: p.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: col.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, c) {
                                      final isNarrow = c.maxWidth < 290;
                                      return Row(
                                        children: [
                                          _buildAvatarImage(
                                            photoUrl: entry.photoUrl,
                                            name: entry.name,
                                            color: col,
                                            size: isNarrow ? 28 : 34,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  entry.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 1),
                                                Text(
                                                  '${entry.origin} · ${entry.era}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: p.inkSoft,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: col.withValues(
                                                      alpha: 0.15,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '$pct% afim',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: col,
                                                      fontFamily: 'IBMPlexMono',
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .compare_arrows_rounded,
                                                      size: 12,
                                                      color: p.muted,
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      'comparar',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 9.5,
                                                        color: p.muted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }(),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildPersonalitiesHero(
    BuildContext context,
    List<AtlasMatchResult> persMatches,
    EspectroPalette p,
    TextTheme text,
  ) {
    final topPers = persMatches.take(3).toList();
    if (topPers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Divider(height: 1, color: p.line.withValues(alpha: 0.6)),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              'PERSONALIDADES QUE COMBINAM COM VOCÊ',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: p.muted,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Figuras históricas',
              style: TextStyle(fontSize: 11, color: p.inkSoft),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 640;
            final double itemWidth = isNarrow
                ? constraints.maxWidth
                : (constraints.maxWidth - 20) / 3;

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final match in topPers)
                  () {
                    final entry = match.entry;
                    final subject = StudySubject.fromEntry(entry);
                    final spec = spectrumOf(subject);
                    final col = spec?.color ?? p.accent;
                    final pct = _formatScore(match.compatibilityPercent);
                    final photo = entry.photoUrl;

                    return Container(
                      width: itemWidth,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: p.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: p.line.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildAvatarImage(
                                photoUrl: photo,
                                name: entry.name,
                                color: col,
                                size: 44,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${entry.origin} • ${entry.era}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: p.inkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: col.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: col.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  '$pct%',
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexMono',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: col,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (entry.quote != null &&
                              entry.quote!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '“${entry.quote}”',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: p.inkSoft,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.compare_arrows_rounded,
                                size: 14,
                              ),
                              label: const Text(
                                'Comparar comigo',
                                style: TextStyle(fontSize: 11.5),
                              ),
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              onPressed: () =>
                                  EntityComparisonScreen.showAtlasEntry(
                                    context,
                                    record: _record,
                                    entry: entry,
                                    appViewModel: widget.appViewModel,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCountriesHero(
    BuildContext context,
    List<AtlasMatchResult> countryMatches,
    EspectroPalette p,
    TextTheme text,
  ) {
    final topCountries = countryMatches.take(3).toList();
    if (topCountries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Divider(height: 1, color: p.line.withValues(alpha: 0.6)),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              'MODELOS ESTATAIS & RECORTES HISTÓRICOS',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: p.muted,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Países e regimes',
              style: TextStyle(fontSize: 11, color: p.inkSoft),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 640;
            final double itemWidth = isNarrow
                ? constraints.maxWidth
                : (constraints.maxWidth - 20) / 3;

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final match in topCountries)
                  () {
                    final entry = match.entry;
                    final pct = _formatScore(match.compatibilityPercent);
                    final photo = entry.photoUrl;

                    return Container(
                      width: itemWidth,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: p.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: p.line.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: p.line),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: photo != null && photo.isNotEmpty
                                    ? (photo.startsWith('http://') ||
                                              photo.startsWith('https://')
                                          ? Image.network(
                                              photo,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  _fallbackFlag(entry.name, p),
                                            )
                                          : Image.asset(
                                              photo,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  _fallbackFlag(entry.name, p),
                                            ))
                                    : _fallbackFlag(entry.name, p),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // PROMINENT RECORTE HISTÓRICO BADGE
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: p.accent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: p.accent.withValues(
                                            alpha: 0.35,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        entry.era,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexMono',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: p.accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: p.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: p.accent.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  '$pct%',
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexMono',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: p.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: p.inkSoft),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.compare_arrows_rounded,
                                size: 14,
                              ),
                              label: const Text(
                                'Comparar comigo',
                                style: TextStyle(fontSize: 11.5),
                              ),
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              onPressed: () =>
                                  EntityComparisonScreen.showAtlasEntry(
                                    context,
                                    record: _record,
                                    entry: entry,
                                    appViewModel: widget.appViewModel,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }(),
              ],
            );
          },
        ),
      ],
    );
  }

  static Widget _buildAvatarImage({
    required String? photoUrl,
    required String name,
    required Color color,
    double size = 28,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null && photoUrl.isNotEmpty
          ? (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')
                ? Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallbackAvatar(name, color),
                  )
                : Image.asset(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallbackAvatar(name, color),
                  ))
          : _fallbackAvatar(name, color),
    );
  }

  static Widget _fallbackAvatar(String name, Color color) {
    final initials = name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s.characters.first)
        .join();
    return Container(
      color: color.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  static Widget _fallbackFlag(String name, EspectroPalette p) {
    return Container(
      color: p.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(Icons.flag_outlined, size: 16, color: p.muted),
    );
  }

  Widget _buildSection12Axes(
    BuildContext context,
    Map<String, AtlasMatchResult> bestPersByAxis,
    EspectroPalette p,
    TextTheme text,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _TwelveAxesSectionHeading(
          number: '01',
          eyebrow: '12 EIXOS',
          title: 'Seus 12 eixos',
          description: 'Posição detalhada em cada um dos doze eixos bipolares com a personalidade histórica mais alinhada a você em cada dimensão. Toque em qualquer eixo para ver afirmações e margem de erro, ou toque na personalidade para comparar.',
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool twoCols = constraints.maxWidth >= 720;
            final double itemWidth = twoCols
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 14,
              children: <Widget>[
                for (final BipolarDimensionScore axis in _record.axes)
                  () {
                    final bestPers = bestPersByAxis[axis.axisId];
                    return SizedBox(
                      width: itemWidth,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: p.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DivergingAxisBar(
                              dimension: axis,
                              onTap: () => _showAxisBreakdown(axis),
                            ),
                            if (bestPers != null) ...[
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () =>
                                    EntityComparisonScreen.showAtlasEntry(
                                      context,
                                      record: _record,
                                      entry: bestPers.entry,
                                      appViewModel: widget.appViewModel,
                                    ),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.surfaceMuted,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: p.line.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildAvatarImage(
                                        photoUrl: bestPers.entry.photoUrl,
                                        name: bestPers.entry.name,
                                        color:
                                            spectrumOf(
                                              StudySubject.fromEntry(
                                                bestPers.entry,
                                              ),
                                            )?.color ??
                                            p.accent,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'Mais afim: ',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: p.inkSoft,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: bestPers.entry.name,
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: p.ink,
                                                ),
                                              ),
                                            ],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: p.accentSoft,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          '${_formatScore(bestPers.compatibilityPercent)}%',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'IBMPlexMono',
                                            color: p.accent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionDistinction(
    BuildContext context,
    BipolarDimensionScore? mostUncommon,
    BipolarDimensionScore? mostCommon,
    int uncommonPercentLower,
    EspectroPalette p,
    TextTheme text,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _TwelveAxesSectionHeading(
          number: '02',
          eyebrow: 'ASSINATURA',
          title: 'O que te distingue',
          description: 'Suas marcas registradas e seu posicionamento em relação à mediana das correntes catalogadas.',
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool twoCols = constraints.maxWidth >= 680;
            final double cardWidth = twoCols
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 16,
              runSpacing: 14,
              children: <Widget>[
                if (mostUncommon != null)
                  SizedBox(
                    width: cardWidth,
                    child: _DistinctionCard(
                      eyebrow: 'SUA POSIÇÃO MAIS INCOMUM',
                      eyebrowColor: p.accent,
                      axisName: mostUncommon.label,
                      dominantPercent: mostUncommon.dominantPercent,
                      dominantPole: mostUncommon.dominantPole,
                      description:
                          '$uncommonPercentLower% das correntes catalogadas puxam menos que você para ${mostUncommon.dominantPole.toLowerCase()}.',
                      isCommon: false,
                      dimension: mostUncommon,
                      onTap: () => _showAxisBreakdown(mostUncommon),
                    ),
                  ),
                if (mostCommon != null)
                  SizedBox(
                    width: cardWidth,
                    child: _DistinctionCard(
                      eyebrow: 'SUA POSIÇÃO MAIS COMUM',
                      eyebrowColor: p.inkSoft,
                      axisName: mostCommon.label,
                      dominantPercent: 50,
                      dominantPole: 'Na mediana',
                      description:
                          'Aqui você está em terreno comum e equilibrado. Não puxa fortemente para ${mostCommon.leftPole} nem para ${mostCommon.rightPole}.',
                      isCommon: true,
                      dimension: mostCommon,
                      onTap: () => _showAxisBreakdown(mostCommon),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionCountries(
    BuildContext context,
    AtlasMatchResult? topCountry,
    List<AtlasMatchResult> countryMatches,
    AtlasMatchResult? polCountry,
    AtlasMatchResult? socCountry,
    AtlasMatchResult? ecoCountry,
    EspectroPalette p,
    TextTheme text,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _TwelveAxesSectionHeading(
          number: '03',
          eyebrow: 'GEOGRAFIA POLÍTICA',
          title: 'Países mais próximos de você',
          description: 'Modelos constitucionais e experiências históricas de nações com maior proximidade com suas posições.',
        ),
        const SizedBox(height: 14),
        _FilterPills(
          options: const <String>[
            'Todos os países',
            'Países atuais',
            'Experiências históricas',
          ],
          selectedIndex: _countryFilterIndex,
          onSelect: (int idx) => setState(() => _countryFilterIndex = idx),
        ),
        const SizedBox(height: 18),
        if (topCountry != null) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool isCompact =
                        constraints.maxWidth < 460 ||
                        MediaQuery.textScalerOf(context).scale(16) > 20;

                    final Widget info = Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        StudyIdentityAvatar(
                          subject: StudySubject.fromEntry(topCountry.entry),
                          size: 56,
                          rectangular: false,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                topCountry.entry.name,
                                style: text.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${topCountry.entry.subtitle} · ${topCountry.entry.era}',
                                style: text.bodySmall?.copyWith(
                                  color: p.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    final Widget gauge = _AnimatedMatchGauge(
                      percent: topCountry.compatibilityPercent,
                      size: 72,
                    );

                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          info,
                          const SizedBox(height: 12),
                          gauge,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(child: info),
                        const SizedBox(width: 12),
                        gauge,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  topCountry.entry.summary,
                  style: text.bodyMedium?.copyWith(height: 1.35),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Saber mais sobre ${topCountry.entry.name}',
                  kind: AppButtonKind.outline,
                  icon: Icons.travel_explore_rounded,
                  onPressed: () => _showAtlasEntryDetailSheet(
                    context,
                    topCountry.entry,
                    topCountry,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'TAMBÉM PRÓXIMOS, POR DIMENSÃO',
            style: TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: p.muted,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool threeCols = constraints.maxWidth >= 720;
              final double dimWidth = threeCols
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: <Widget>[
                  if (polCountry != null)
                    SizedBox(
                      width: dimWidth,
                      child: _MiniDimensionalCard(
                        arena: 'POLITICAMENTE',
                        name: polCountry.entry.name,
                        percent: polCountry.compatibilityPercent,
                        onTap: () => _showAtlasEntryDetailSheet(
                          context,
                          polCountry.entry,
                          polCountry,
                        ),
                      ),
                    ),
                  if (socCountry != null)
                    SizedBox(
                      width: dimWidth,
                      child: _MiniDimensionalCard(
                        arena: 'SOCIALMENTE',
                        name: socCountry.entry.name,
                        percent: socCountry.compatibilityPercent,
                        onTap: () => _showAtlasEntryDetailSheet(
                          context,
                          socCountry.entry,
                          socCountry,
                        ),
                      ),
                    ),
                  if (ecoCountry != null)
                    SizedBox(
                      width: dimWidth,
                      child: _MiniDimensionalCard(
                        arena: 'ECONOMICAMENTE',
                        name: ecoCountry.entry.name,
                        percent: ecoCountry.compatibilityPercent,
                        onTap: () => _showAtlasEntryDetailSheet(
                          context,
                          ecoCountry.entry,
                          ecoCountry,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          if (countryMatches.length > 1) ...<Widget>[
            const SizedBox(height: 18),
            Text(
              'OUTROS PAÍSES AFINS',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: p.muted,
              ),
            ),
            const SizedBox(height: 10),
            for (final AtlasMatchResult m in countryMatches.skip(1).take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AtlasMatchRow(
                  rank: countryMatches.indexOf(m) + 1,
                  match: m,
                  onTap: () => _showAtlasEntryDetailSheet(context, m.entry, m),
                ),
              ),
          ],
        ],
      ],
    );
  }

  Widget _buildSectionPersonalities(
    BuildContext context,
    AtlasMatchResult? topPers,
    List<AtlasMatchResult> persMatches,
    AtlasMatchResult? polPers,
    AtlasMatchResult? socPers,
    AtlasMatchResult? ecoPers,
    EspectroPalette p,
    TextTheme text,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _TwelveAxesSectionHeading(
          number: '04',
          eyebrow: 'PENSADORES & LÍDERES',
          title: 'Personalidades mais próximas de você',
          description: 'Figuras marcantes do pensamento político ocidental e oriental cujos eixos e tríades convergem com os seus.',
        ),
        const SizedBox(height: 18),
        if (topPers != null) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool isCompact =
                        constraints.maxWidth < 460 ||
                        MediaQuery.textScalerOf(context).scale(16) > 20;

                    final Widget info = Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        StudyIdentityAvatar(
                          subject: StudySubject.fromEntry(topPers.entry),
                          size: 60,
                          rectangular: false,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                topPers.entry.name,
                                style: text.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${topPers.entry.subtitle} · ${topPers.entry.era}',
                                style: text.bodySmall?.copyWith(
                                  color: p.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    final Widget gauge = _AnimatedMatchGauge(
                      percent: topPers.compatibilityPercent,
                      size: 72,
                    );

                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          info,
                          const SizedBox(height: 12),
                          gauge,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(child: info),
                        const SizedBox(width: 12),
                        gauge,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  topPers.entry.summary,
                  style: text.bodyMedium?.copyWith(height: 1.35),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Saber mais sobre ${topPers.entry.name}',
                  kind: AppButtonKind.outline,
                  icon: Icons.person_outline_rounded,
                  onPressed: () => _showAtlasEntryDetailSheet(
                    context,
                    topPers.entry,
                    topPers,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'TAMBÉM PRÓXIMAS, POR DIMENSÃO',
            style: TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: p.muted,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool threeCols = constraints.maxWidth >= 720;
              final double dimWidth = threeCols
                  ? (constraints.maxWidth - 24) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: <Widget>[
                  if (polPers != null)
                    SizedBox(
                      width: dimWidth,
                      child: _MiniDimensionalCard(
                        arena: 'POLITICAMENTE',
                        name: polPers.entry.name,
                        percent: polPers.compatibilityPercent,
                        onTap: () => _showAtlasEntryDetailSheet(
                          context,
                          polPers.entry,
                          polPers,
                        ),
                      ),
                    ),
                  if (socPers != null)
                    SizedBox(
                      width: dimWidth,
                      child: _MiniDimensionalCard(
                        arena: 'SOCIALMENTE',
                        name: socPers.entry.name,
                        percent: socPers.compatibilityPercent,
                        onTap: () => _showAtlasEntryDetailSheet(
                          context,
                          socPers.entry,
                          socPers,
                        ),
                      ),
                    ),
                  if (ecoPers != null)
                    SizedBox(
                      width: dimWidth,
                      child: _MiniDimensionalCard(
                        arena: 'ECONOMICAMENTE',
                        name: ecoPers.entry.name,
                        percent: ecoPers.compatibilityPercent,
                        onTap: () => _showAtlasEntryDetailSheet(
                          context,
                          ecoPers.entry,
                          ecoPers,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          if (persMatches.length > 1) ...<Widget>[
            const SizedBox(height: 18),
            Text(
              'OUTRAS PERSONALIDADES AFINS',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: p.muted,
              ),
            ),
            const SizedBox(height: 10),
            for (final AtlasMatchResult m in persMatches.skip(1).take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AtlasMatchRow(
                  rank: persMatches.indexOf(m) + 1,
                  match: m,
                  onTap: () => _showAtlasEntryDetailSheet(context, m.entry, m),
                ),
              ),
          ],
        ],
      ],
    );
  }

  Widget _buildSectionBooks(
    BuildContext context,
    AtlasMatchResult? topBook,
    AtlasMatchResult? secondBook,
    AtlasMatchResult? counterpointBook,
    BookRecommendationReport report,
    EspectroPalette p,
    TextTheme text,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _TwelveAxesSectionHeading(
          number: '05',
          eyebrow: 'BIBLIOTECA EDITORIAL',
          title: 'Para ler',
          description: 'Uma curadoria personalizada entre as 76 obras clássicas do Atlas Político baseada nos seus resultados.',
        ),
        const SizedBox(height: 18),
        if (topBook != null)
          _BookRecommendationCard(
            match: topBook,
            isCounterpoint: false,
            onTap: () =>
                _showAtlasEntryDetailSheet(context, topBook.entry, topBook),
          ),
        if (secondBook != null) ...<Widget>[
          const SizedBox(height: 12),
          _BookRecommendationCard(
            match: secondBook,
            isCounterpoint: false,
            onTap: () => _showAtlasEntryDetailSheet(
              context,
              secondBook.entry,
              secondBook,
            ),
          ),
        ],
        if (counterpointBook != null) ...<Widget>[
          const SizedBox(height: 12),
          _BookRecommendationCard(
            match: counterpointBook,
            isCounterpoint: true,
            onTap: () => _showAtlasEntryDetailSheet(
              context,
              counterpointBook.entry,
              counterpointBook,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionParties(
    BuildContext context,
    AtlasMatchResult? topParty,
    List<AtlasMatchResult> partyMatches,
    EspectroPalette p,
    TextTheme text,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _TwelveAxesSectionHeading(
          number: '06',
          eyebrow: 'FORÇAS POLÍTICAS',
          title: 'Partidos mais próximos de você',
          description: 'Partidos e movimentos históricos ou contemporâneos com programas políticos afins ao seu resultado.',
        ),
        const SizedBox(height: 14),
        _FilterPills(
          options: const <String>[
            'Todos os partidos',
            'Partidos atuais',
            'Partidos históricos',
          ],
          selectedIndex: _partyFilterIndex,
          onSelect: (int idx) => setState(() => _partyFilterIndex = idx),
        ),
        const SizedBox(height: 18),
        if (topParty != null) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool isCompact =
                        constraints.maxWidth < 460 ||
                        MediaQuery.textScalerOf(context).scale(16) > 20;

                    final Widget info = Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        StudyIdentityAvatar(
                          subject: StudySubject.fromEntry(topParty.entry),
                          size: 56,
                          rectangular: false,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                topParty.entry.name,
                                style: text.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${topParty.entry.origin} · ${topParty.entry.era}',
                                style: text.bodySmall?.copyWith(
                                  color: p.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    final Widget gauge = _AnimatedMatchGauge(
                      percent: topParty.compatibilityPercent,
                      size: 72,
                    );

                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          info,
                          const SizedBox(height: 12),
                          gauge,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(child: info),
                        const SizedBox(width: 12),
                        gauge,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  topParty.entry.summary,
                  style: text.bodyMedium?.copyWith(height: 1.35),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Saber mais sobre ${topParty.entry.name}',
                  kind: AppButtonKind.outline,
                  icon: Icons.groups_rounded,
                  onPressed: () => _showAtlasEntryDetailSheet(
                    context,
                    topParty.entry,
                    topParty,
                  ),
                ),
              ],
            ),
          ),
          if (partyMatches.length > 1) ...<Widget>[
            const SizedBox(height: 18),
            Text(
              'OUTROS PARTIDOS AFINS',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: p.muted,
              ),
            ),
            const SizedBox(height: 10),
            for (final AtlasMatchResult m in partyMatches.skip(1).take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AtlasMatchRow(
                  rank: partyMatches.indexOf(m) + 1,
                  match: m,
                  onTap: () => _showAtlasEntryDetailSheet(context, m.entry, m),
                ),
              ),
          ],
        ],
      ],
    );
  }

  Widget _buildSectionCompassAndTriads(
    BuildContext context,
    NolanCoordinates? nolan,
    List<ThematicSynthesis> syntheses,
    List<DoctrinalTension> tensions,
    CompatibilityReport compat,
    Map<int, AtlasMatchResult> bestPersByTriad,
    EspectroPalette p,
    TextTheme text,
  ) {
    final TriadDimensionScore? primaryTriad = _record.triads.firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _TwelveAxesSectionHeading(
          number: '07',
          eyebrow: 'MAPEAMENTO GEOMÉTRICO',
          title: 'Bússola política & Tríades composicionais',
          description: 'Projeção 2D de Nolan e as 6 tríades do simplex de Aitchison com decomposição de composição e apoio absoluto.',
        ),
        const SizedBox(height: 18),
        if (nolan != null) ...<Widget>[
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ReportSectionHeader(
                  title: const Eyebrow('Diagrama de Nolan (1969) & Bússola 2D'),
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
                        .map((c) => EspectroNolanEngine.fromCurrent(c.current))
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
                          'Liberdade Pessoal: ${_formatPercent(nolan.personalFreedom)} (±${_formatPercent(nolan.personalSe)})',
                    ),
                    Tag(
                      label:
                          'Liberdade Econômica: ${_formatPercent(nolan.economicFreedom)} (±${_formatPercent(nolan.economicSe)})',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(nolan.quadrantDescription, style: text.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        if (syntheses.isNotEmpty) ...<Widget>[
          FundamentalValuesSection(syntheses: syntheses),
          const SizedBox(height: 18),
        ],
        if (tensions.isNotEmpty) ...<Widget>[
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
          const SizedBox(height: 18),
        ],
        // Tríades 6 list
        SectionCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Eyebrow('6 Tríades Políticas em Simplex Aitchison'),
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
                'Representação triangular das 6 dimensões ternárias. A posição do ponto é a '
                'composição relativa entre os três vértices; o anel ao redor dele mostra o apoio '
                'absoluto médio (I), que distingue apoio amplo de rejeição ampla.',
                style: text.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (primaryTriad != null) ...<Widget>[
          SectionCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ReportSectionHeader(
                  title: Text(primaryTriad.label, style: text.titleLarge),
                  trailing: Tag(
                    label: primaryTriad.classification,
                    background: p
                        .triadColor(primaryTriad.categoryId)
                        .withValues(alpha: 0.16),
                    foreground: p.triadColor(primaryTriad.categoryId),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Composição: '
                  '${primaryTriad.vertices[0]} ${_formatPercent(primaryTriad.composition[0] * 100)} · '
                  '${primaryTriad.vertices[1]} ${_formatPercent(primaryTriad.composition[1] * 100)} · '
                  '${primaryTriad.vertices[2]} ${_formatPercent(primaryTriad.composition[2] * 100)}',
                  style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Apoio absoluto: ${_supportLabel(primaryTriad, 0)} · '
                  '${_supportLabel(primaryTriad, 1)} · ${_supportLabel(primaryTriad, 2)}',
                  style: text.bodySmall?.copyWith(color: p.inkSoft),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    Tag(
                      label:
                          'Cobertura ${_formatPercent(primaryTriad.coverage * 100)}',
                    ),
                    Tag(
                      label:
                          'Confiança ${primaryTriad.confidenceLabel.toLowerCase()}',
                    ),
                    Tag(
                      label:
                          'Apoio médio I = ${_formatPercent(primaryTriad.engagement * 100)}',
                    ),
                    if (primaryTriad.vertexBreakdownAvailable &&
                        !primaryTriad.hasAllVerticesObserved)
                      Tag(
                        label:
                            '${3 - primaryTriad.observedVertexCount} vértice(s) não avaliado(s)',
                        background: p.warning.withValues(alpha: 0.16),
                        foreground: p.warning,
                      ),
                  ],
                ),
                if (primaryTriad.isIndeterminate) ...<Widget>[
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
                const SizedBox(height: 14),
                Center(
                  child: InteractiveTriadChart(
                    triad: primaryTriad,
                    overlayPins: _showCurrentsOnTriads
                        ? compat.topMatches
                              .where(
                                (m) => m.current.triangles.containsKey(
                                  primaryTriad.categoryId,
                                ),
                              )
                              .map(
                                (m) => TriadOverlayPin(
                                  id: m.current.id,
                                  label: m.current.name,
                                  composition: m
                                      .current
                                      .triangles[primaryTriad.categoryId]!
                                      .mu,
                                ),
                              )
                              .toList()
                        : const <TriadOverlayPin>[],
                  ),
                ),
                if (bestPersByTriad[primaryTriad.categoryId] != null) ...[
                  const SizedBox(height: 14),
                  () {
                    final bestPers = bestPersByTriad[primaryTriad.categoryId]!;
                    final entry = bestPers.entry;
                    final spec = spectrumOf(StudySubject.fromEntry(entry));
                    final col =
                        spec?.color ?? p.triadColor(primaryTriad.categoryId);
                    return InkWell(
                      onTap: () => EntityComparisonScreen.showAtlasEntry(
                        context,
                        record: _record,
                        entry: entry,
                        appViewModel: widget.appViewModel,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: p.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: p.line.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildAvatarImage(
                              photoUrl: entry.photoUrl,
                              name: entry.name,
                              color: col,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Figura histórica mais afim nesta tríade:',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: p.inkSoft,
                                    ),
                                  ),
                                  Text(
                                    '${entry.name} (${entry.origin} · ${entry.era})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: p.accentSoft,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${_formatPercent(bestPers.compatibilityPercent)} afim',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'IBMPlexMono',
                                      color: p.accent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.compare_arrows_rounded,
                              size: 16,
                              color: p.accent,
                            ),
                          ],
                        ),
                      ),
                    );
                  }(),
                ],
                const SizedBox(height: 14),
                Center(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.change_history_rounded, size: 16),
                    label: Text(
                      'Explorar todas as ${_record.triads.length} Tríades em Detalhes',
                    ),
                    onPressed: () {
                      DefaultTabController.of(context).animateTo(2);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildSectionOtherIdeologies(
    BuildContext context,
    CompatibilityReport compat,
    EspectroPalette p,
    TextTheme text,
  ) {
    final List<CurrentCompatibility> currents = _showAllCurrents
        ? compat.ranked
        : compat.topMatches.skip(1).take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _TwelveAxesSectionHeading(
          number: '08',
          eyebrow: 'CORRENTES AFINS',
          title: 'Outras ideologias',
          description: 'Correntes do pensamento político que compartilham premissas centrais com o seu perfil.',
        ),
        const SizedBox(height: 18),
        if (_showAllCurrents) ...<Widget>[
          for (var i = 0; i < compat.ranked.length; i++) ...<Widget>[
            _CurrentCompatibilityRow(
              rank: i + 1,
              match: compat.ranked[i],
              onTap: () => _showCurrentMatchSheet(compat.ranked[i]),
            ),
            if (i != compat.ranked.length - 1) const SizedBox(height: 10),
          ],
        ] else ...<Widget>[
          for (final CurrentCompatibility c in currents)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // Colored bar/pill for spectrum - STRICTLY NO ICONS
                        SpectrumBar(
                          color:
                              spectrumOf(StudySubject.fromCurrent(c.current))
                                  ?.color ??
                              p.accent,
                          height: 22,
                          width: 4,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            c.current.family.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'IBMPlexMono',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color:
                                  spectrumOf(
                                    StudySubject.fromCurrent(c.current),
                                  )?.color ??
                                  p.accent,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatPercent(c.compatibilityPercent),
                          style: TextStyle(
                            fontFamily: 'IBMPlexMono',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: p.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.current.name,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.current.summary,
                      style: text.bodySmall?.copyWith(height: 1.35),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      children: <Widget>[
                        OutlinedButton.icon(
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                          ),
                          label: Text('Saber mais sobre ${c.current.name}'),
                          onPressed: () => _showCurrentMatchSheet(c),
                        ),
                        FilledButton.tonalIcon(
                          icon: const Icon(
                            Icons.compare_arrows_rounded,
                            size: 16,
                          ),
                          label: const Text('Comparar comigo'),
                          onPressed: () => EntityComparisonScreen.showCurrent(
                            context,
                            record: _record,
                            current: c.current,
                            appViewModel: widget.appViewModel,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
        if (compat.ranked.length > 6) ...<Widget>[
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              icon: Icon(
                _showAllCurrents
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
              label: Text(
                _showAllCurrents
                    ? 'Mostrar apenas as correntes principais'
                    : 'Ver todas as ${compat.ranked.length} correntes catalogadas',
              ),
              onPressed: () =>
                  setState(() => _showAllCurrents = !_showAllCurrents),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFinalActions(
    BuildContext context,
    CompatibilityReport compat,
    EspectroPalette p,
    TextTheme text,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: p.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Eyebrow('COMPARTILHAMENTO & DOSSIÊ', color: p.accent),
          const SizedBox(height: 8),
          Text(
            'Guarde, exporte ou aprofunde suas análises',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              AppButton(
                label: 'Card Compartilhável',
                icon: Icons.share_rounded,
                kind: AppButtonKind.outline,
                onPressed: _openShareCard,
              ),
              AppButton(
                label: _isExportingPdf ? 'Gerando...' : 'Dossiê PDF (6 pág.)',
                icon: Icons.picture_as_pdf_rounded,
                kind: AppButtonKind.filled,
                onPressed: _isExportingPdf ? () {} : _exportPdf,
              ),
              AppButton(
                label: 'Copiar Resumo',
                icon: Icons.copy_rounded,
                kind: AppButtonKind.outline,
                onPressed: () => _copySummary(compat),
              ),
              if (widget.appViewModel.history.length >= 2)
                AppButton(
                  label: 'Comparar com outra avaliação',
                  icon: Icons.compare_arrows_rounded,
                  kind: AppButtonKind.outline,
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
              AppButton(
                label: 'Metodologia e Fórmulas',
                icon: Icons.functions_rounded,
                kind: AppButtonKind.outline,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MethodologyScreen(
                      data: widget.appViewModel.data,
                      appViewModel: widget.appViewModel,
                    ),
                  ),
                ),
              ),
            ],
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
        entries = atlas.canonicalPersonalities;
        labelKind = 'Personalidades Canônicas';
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
      axes: _activeAxes,
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
                HorizontalAffordanceStrip(
                  fadeColor: p.surface,
                  showArrows: false,
                  builder: (context, controller) => SingleChildScrollView(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        _AtlasKindChip(
                          label:
                              'Personalidades (${atlas.canonicalPersonalities.length})',
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
                      label: _formatPercent(antipode.compatibilityPercent),
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
      axes: _activeAxes,
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
    PoliticalAtlas atlas,
    EspectroPalette p,
    TextTheme text,
  ) {
    final Map<String, AtlasMatchResult> bestPersByAxis =
        <String, AtlasMatchResult>{};
    for (final axis in _record.axes) {
      final match = _findBestPersonalityForAxis(atlas, axis);
      if (match != null) {
        bestPersByAxis[axis.axisId] = match;
      }
    }

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
                  'expressa a dispersão estimada pelo modelo (SE), sem validação psicométrica.',
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
                  'Toque em qualquer eixo para ver os itens respondidos, os limites de '
                  'cobertura e as perguntas que mais influenciaram a sua pontuação.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < _record.axes.length; i++) ...<Widget>[
                  () {
                    final axis = _record.axes[i];
                    final bestPers = bestPersByAxis[axis.axisId];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _showAxisBreakdown(axis),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: DivergingAxisBar(dimension: axis),
                          ),
                        ),
                        if (bestPers != null) ...[
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => EntityComparisonScreen.showAtlasEntry(
                              context,
                              record: _record,
                              entry: bestPers.entry,
                              appViewModel: widget.appViewModel,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: p.surfaceMuted,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: p.line.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildAvatarImage(
                                    photoUrl: bestPers.entry.photoUrl,
                                    name: bestPers.entry.name,
                                    color:
                                        spectrumOf(
                                          StudySubject.fromEntry(
                                            bestPers.entry,
                                          ),
                                        )?.color ??
                                        p.accent,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'Mais afim: ',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: p.inkSoft,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: bestPers.entry.name,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: p.ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: p.accentSoft,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${_formatScore(bestPers.compatibilityPercent)}%',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'IBMPlexMono',
                                        color: p.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }(),
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
    return '$vertex ${_formatPercent(triad.vertexSupport[index] * 100)}';
  }

  Widget _buildTriadsTab(
    BuildContext context,
    PoliticalAtlas atlas,
    CompatibilityReport compat,
    EspectroPalette p,
    TextTheme text,
  ) {
    final Map<int, AtlasMatchResult> bestPersByTriad =
        <int, AtlasMatchResult>{};
    for (final triad in _record.triads) {
      final match = _findBestPersonalityForTriad(atlas, triad);
      if (match != null) {
        bestPersByTriad[triad.categoryId] = match;
      }
    }

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
                    '${t.vertices[0]} ${_formatPercent(t.composition[0] * 100)} · '
                    '${t.vertices[1]} ${_formatPercent(t.composition[1] * 100)} · '
                    '${t.vertices[2]} ${_formatPercent(t.composition[2] * 100)}',
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
                      Tag(
                        label: 'Cobertura ${_formatPercent(t.coverage * 100)}',
                      ),
                      Tag(
                        label: 'Confiança ${t.confidenceLabel.toLowerCase()}',
                      ),
                      Tag(
                        label:
                            'Apoio médio I = ${_formatPercent(t.engagement * 100)}',
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
                  if (bestPersByTriad[t.categoryId] != null) ...[
                    const SizedBox(height: 12),
                    () {
                      final match = bestPersByTriad[t.categoryId]!;
                      final entry = match.entry;
                      final spec = spectrumOf(StudySubject.fromEntry(entry));
                      final col = spec?.color ?? p.triadColor(t.categoryId);
                      return InkWell(
                        onTap: () => EntityComparisonScreen.showAtlasEntry(
                          context,
                          record: _record,
                          entry: entry,
                          appViewModel: widget.appViewModel,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: p.surfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: p.line.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildAvatarImage(
                                photoUrl: entry.photoUrl,
                                name: entry.name,
                                color: col,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Figura histórica mais afim nesta tríade:',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: p.inkSoft,
                                      ),
                                    ),
                                    Text(
                                      '${entry.name} (${entry.origin} · ${entry.era})',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.accentSoft,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${_formatPercent(match.compatibilityPercent)} afim',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'IBMPlexMono',
                                        color: p.accent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.compare_arrows_rounded,
                                size: 16,
                                color: p.accent,
                              ),
                            ],
                          ),
                        ),
                      );
                    }(),
                  ],
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
                StudyIdentityAvatar(
                  subject: StudySubject.fromEntry(match.entry),
                  size: 38,
                  rectangular:
                      match.entry.kind == AtlasKind.personality ||
                      match.entry.kind == AtlasKind.book,
                ),
                const SizedBox(width: 12),
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
                      if (match.twelveAxesAffinity case final affinity?)
                        Text(
                          '12 eixos ${affinity.percent.round()}/100 · '
                          '${affinity.sharedAxes}/12 eixos',
                          style: text.bodySmall?.copyWith(
                            fontSize: 10.5,
                            color: p.muted,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatPercent(match.compatibilityPercent),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StudyIdentityAvatar(
              subject: StudySubject.fromEntry(match.entry),
              size: 48,
              rectangular: true,
            ),
            const SizedBox(width: 12),
            Expanded(
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
                          ? 'Divergência ${_formatPercent(100 - match.compatibilityPercent)}'
                          : 'Afinidade ${_formatPercent(match.compatibilityPercent)}',
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
                SpectrumBar(
                  color:
                      spectrumOf(StudySubject.fromCurrent(match.current))
                          ?.color ??
                      p.accent,
                  height: 30,
                  width: 4,
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
                  _formatPercent(match.compatibilityPercent),
                  style: text.titleMedium?.copyWith(color: p.accent),
                ),
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

class _PreliminaryBanner extends StatelessWidget {
  const _PreliminaryBanner({
    required this.answeredCount,
    required this.totalCount,
    required this.onContinue,
  });

  final int answeredCount;
  final int totalCount;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final int remaining = math.max(0, totalCount - answeredCount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          p.accent.withValues(alpha: p.isDark ? 0.14 : 0.08),
          p.surface,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: p.accent.withValues(alpha: p.isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: p.accent.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'RESULTADO PRELIMINAR',
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: p.isDark ? const Color(0xFF061318) : Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$answeredCount de $totalCount afirmações respondidas',
                  style: text.labelSmall?.copyWith(
                    fontFamily: 'IBMPlexMono',
                    fontWeight: FontWeight.w600,
                    color: p.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Suas coordenadas nos 12 eixos e 6 tríades foram estimadas a partir das respostas dadas até aqui. '
            'Você pode voltar ao teste a qualquer momento para continuar respondendo e refinar a precisão.',
            style: text.bodyMedium?.copyWith(height: 1.35, color: p.ink),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: remaining > 0
                  ? 'Continuar teste e refinar ($remaining)'
                  : 'Continuar respondendo',
              icon: Icons.play_arrow_rounded,
              kind: AppButtonKind.filled,
              onPressed: onContinue,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompleteTriadsBanner extends StatelessWidget {
  const _CompleteTriadsBanner({
    required this.isExpress,
    required this.onComplete,
  });

  final bool isExpress;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          p.accent.withValues(alpha: p.isDark ? 0.12 : 0.06),
          p.surface,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: p.accent.withValues(alpha: p.isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: p.accent.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: p.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isExpress
                      ? 'MODO EXPRESSO · 12 EIXOS CONCLUÍDOS'
                      : 'PERFIL DE EIXOS · TRÍADES DISPONÍVEIS',
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: p.isDark ? const Color(0xFF061318) : Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '~3 min adicionais',
                  textAlign: TextAlign.right,
                  style: text.labelSmall?.copyWith(
                    fontFamily: 'IBMPlexMono',
                    fontWeight: FontWeight.w600,
                    color: p.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Seu posicionamento nos 12 eixos bipolares já está calibrado. '
            'Se quiser aprofundar agora ou mais tarde, adicione as 6 tríades políticas '
            '(1 afirmação por vértice) para destravar os triângulos de valores e refinar as afinidades.',
            style: text.bodyMedium?.copyWith(height: 1.35, color: p.ink),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Completar o perfil com as Tríades (+18 perguntas)',
              icon: Icons.change_history_rounded,
              kind: AppButtonKind.filled,
              onPressed: onComplete,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseQualityBanner extends StatelessWidget {
  const _ResponseQualityBanner({required this.warnings});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: 'Qualidade das respostas. ${warnings.join(' ')}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            p.warning.withValues(alpha: p.isDark ? 0.16 : 0.08),
            p.surface,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: p.warning.withValues(alpha: p.isDark ? 0.55 : 0.42),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.warning_amber_rounded, size: 20, color: p.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'QUALIDADE DAS RESPOSTAS',
                    style: TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: p.warning,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Leia este resultado com cautela. O aviso abaixo faz parte da leitura, não é um detalhe opcional.',
              style: text.bodyMedium?.copyWith(
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: p.ink,
              ),
            ),
            const SizedBox(height: 8),
            for (final String warning in warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '• ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: p.warning,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        warning,
                        style: text.bodySmall?.copyWith(
                          height: 1.4,
                          color: p.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 12Axes-Style Supporting Widgets
// ============================================================================

class _AnimatedMatchGauge extends StatelessWidget {
  const _AnimatedMatchGauge({
    required this.percent,
    this.size = 80,
    this.accentColor,
    this.label = 'MATCH',
  });

  final double percent;
  final double size;
  final Color? accentColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final Color color = accentColor ?? p.accent;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: percent.clamp(0.0, 100.0)),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CustomPaint(
                size: Size(size, size),
                painter: _CircularGaugePainter(
                  progress: value / 100.0,
                  trackColor: p.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  progressColor: color,
                  strokeWidth: size * 0.08,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '${value.round()}%',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontWeight: FontWeight.w700,
                          fontSize: size * 0.23,
                          color: p.ink,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontWeight: FontWeight.w700,
                          fontSize: size * 0.11,
                          color: color,
                          letterSpacing: 0.8,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularGaugePainter extends CustomPainter {
  const _CircularGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final Paint progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final double sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.trackColor != trackColor;
}

class _TwelveAxesSectionHeading extends StatelessWidget {
  const _TwelveAxesSectionHeading({
    required this.number,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String number;
  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$number / $eyebrow',
          style: TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: p.accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: p.ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: text.bodySmall?.copyWith(color: p.inkSoft, height: 1.35),
        ),
      ],
    );
  }
}

class _StickyTocPanel extends StatelessWidget {
  const _StickyTocPanel({required this.activeIndex, required this.onSelect});

  final int activeIndex;
  final ValueChanged<int> onSelect;

  static const List<String> _items = <String>[
    '12 eixos',
    'Distinção',
    'Países',
    'Personalidades',
    'Livros',
    'Partidos',
    'Bússola & Tríades',
    'Outras ideologias',
  ];

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: p.isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'NESTA PÁGINA',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                color: p.muted,
              ),
            ),
          ),
          const SizedBox(height: 6),
          for (int i = 0; i < _items.length; i++)
            _TocItemButton(
              index: i,
              label: _items[i],
              isSelected: activeIndex == i,
              onTap: () => onSelect(i),
            ),
        ],
      ),
    );
  }
}

class _TocItemButton extends StatelessWidget {
  const _TocItemButton({
    required this.index,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final String numStr = (index + 1).toString().padLeft(2, '0');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? p.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <Widget>[
            Text(
              numStr,
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? p.accent : p.muted,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? p.accent : p.ink,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileQuickNav extends StatelessWidget {
  const _MobileQuickNav({required this.activeTocIndex, required this.onSelect});

  final int activeTocIndex;
  final ValueChanged<int> onSelect;

  static const List<String> _chips = <String>[
    '12 Eixos',
    'Distinção',
    'Países',
    'Personalidades',
    'Livros',
    'Partidos',
    'Bússola & Tríades',
    'Outras ideologias',
  ];

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;

    return HorizontalAffordanceStrip(
      fadeColor: p.canvas,
      showArrows: false,
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (int i = 0; i < _chips.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_chips[i]),
                  selected: activeTocIndex == i,
                  onSelected: (_) => onSelect(i),
                  selectedColor: p.accentSoft,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: activeTocIndex == i
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: activeTocIndex == i ? p.accent : p.inkSoft,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterPills extends StatelessWidget {
  const _FilterPills({
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;

    return HorizontalAffordanceStrip(
      fadeColor: p.canvas,
      showArrows: false,
      builder: (context, controller) => SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (int i = 0; i < options.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(options[i]),
                  selected: selectedIndex == i,
                  onSelected: (_) => onSelect(i),
                  selectedColor: p.accentSoft,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: selectedIndex == i
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selectedIndex == i ? p.accent : p.inkSoft,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DistinctionCard extends StatelessWidget {
  const _DistinctionCard({
    required this.eyebrow,
    required this.eyebrowColor,
    required this.axisName,
    required this.dominantPercent,
    required this.dominantPole,
    required this.description,
    required this.isCommon,
    required this.dimension,
    required this.onTap,
  });

  final String eyebrow;
  final Color eyebrowColor;
  final String axisName;
  final num dominantPercent;
  final String dominantPole;
  final String description;
  final bool isCommon;
  final BipolarDimensionScore dimension;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              eyebrow,
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: eyebrowColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    axisName,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isCommon
                      ? 'Mediana'
                      : '${dominantPercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isCommon ? p.inkSoft : p.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dominantPole,
              style: text.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: p.accent,
              ),
            ),
            const SizedBox(height: 10),
            Text(description, style: text.bodySmall?.copyWith(height: 1.35)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: LinearProgressIndicator(
                  value: (dimension.score + 1.0) / 2.0,
                  backgroundColor: p.line,
                  color: isCommon ? p.inkSoft : p.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniDimensionalCard extends StatelessWidget {
  const _MiniDimensionalCard({
    required this.arena,
    required this.name,
    required this.percent,
    required this.onTap,
  });

  final String arena;
  final String name;
  final double percent;
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
          border: Border.all(color: p.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              arena,
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: p.muted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: text.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatPercent(percent)} compatível',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: p.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
