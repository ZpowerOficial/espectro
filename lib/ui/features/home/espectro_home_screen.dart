import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models.dart' as data;
import '../../../domain/engine/compatibility_engine.dart';
import '../../../domain/models/political_models.dart';
import '../../../domain/models/study_models.dart';
import '../../../domain/models/study_media.dart';
import '../atlas/study_profile_screen.dart';
import '../atlas/study_taxonomy.dart';
import '../compare/study_comparison_screen.dart';
import '../results/espectro_result_screen.dart';
import '../share/home_share_card_specimen.dart';
import '../share/shareable_card_sheet.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/espectro_brand_mark.dart';
import '../../shared/metric_presentation.dart';
import '../../shared/resilient_image.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../../ads/espectro_banner_ad.dart';
import '../../charts/axis_colors.dart';
import '../../charts/teia_preview_panel.dart';
import '../quiz/espectro_suites_screen.dart';
import '../../view_models/app_view_model.dart';
import '../../view_models/quiz_view_model.dart';
import '../atlas/atlas_explorer_screen.dart';
import '../history/history_evolution_screen.dart';
import '../methodology/methodology_screen.dart';
import '../quiz/espectro_intro_screen.dart';
import '../quiz/espectro_quiz_screen.dart';

/// Tela inicial principal do Espectro: acesso às três modalidades de avaliação,
/// retomada de rascunho local, histórico/evolução, comparação entre testes,
/// metodologia aberta e preferências de tema claro/escuro.
class EspectroHomeScreen extends StatelessWidget {
  const EspectroHomeScreen({required this.appViewModel, super.key});

  final AppViewModel appViewModel;

  void _openSuite(BuildContext context, TestSuite suite) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            EspectroIntroScreen(appViewModel: appViewModel, suite: suite),
      ),
    );
  }

  void _resumeDraft(BuildContext context, ActiveQuizDraft draft) {
    final QuizViewModel quizVm = QuizViewModel.fromDraft(
      data: appViewModel.data,
      repository: appViewModel.repository,
      draft: draft,
      history: appViewModel.history,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EspectroQuizScreen(
          appViewModel: appViewModel,
          quizViewModel: quizVm,
        ),
      ),
    );
  }

  void _openDraftPreview(BuildContext context, ActiveQuizDraft draft) {
    final QuizViewModel quizVm = QuizViewModel.fromDraft(
      data: appViewModel.data,
      repository: appViewModel.repository,
      draft: draft,
      history: appViewModel.history,
    );
    final EvaluationRecord record = quizVm.buildPreliminaryRecord();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EspectroResultScreen(
          appViewModel: appViewModel,
          record: record,
          isPreliminary: true,
        ),
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            HistoryEvolutionScreen(appViewModel: appViewModel),
      ),
    );
  }

  void _openMethodology(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => MethodologyScreen(
          data: appViewModel.data,
          appViewModel: appViewModel,
        ),
      ),
    );
  }

  void _openAtlas(BuildContext context, {bool initialMap = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AtlasExplorerScreen(
          appViewModel: appViewModel,
          initialMap: initialMap,
        ),
      ),
    );
  }

  void _openComparison(BuildContext context, {List<String>? initialKeys}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => StudyComparisonScreen(
          appViewModel: appViewModel,
          initialKeys: initialKeys,
        ),
      ),
    );
  }

  void _openSubject(BuildContext context, String key) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: studyProfileRoute(key)),
        builder: (BuildContext context) =>
            StudyProfileScreen(appViewModel: appViewModel, subjectKey: key),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showInfoSheet(
      context,
      title: 'Preferências e Privacidade',
      child: ListenableBuilder(
        listenable: appViewModel,
        builder: (BuildContext context, _) {
          final EspectroPalette p = context.palette;
          final TextTheme text = Theme.of(context).textTheme;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Eyebrow('Aparência'),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const <ButtonSegment<ThemeMode>>[
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded, size: 17),
                      label: Text('Sistema'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded, size: 17),
                      label: Text('Claro'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded, size: 17),
                      label: Text('Escuro'),
                    ),
                  ],
                  selected: <ThemeMode>{appViewModel.themeMode},
                  onSelectionChanged: (Set<ThemeMode> selection) {
                    appViewModel.setThemeMode(selection.first);
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Eyebrow('Fluxo do Questionário'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: p.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.line),
                ),
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: appViewModel.autoAdvance,
                  onChanged: (bool value) => appViewModel.setAutoAdvance(value),
                  title: Text(
                    'Avanço automático ao responder',
                    style: text.titleMedium,
                  ),
                  subtitle: Text(
                    'Passa suavemente para o próximo item após marcar uma opção.',
                    style: text.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Eyebrow('Armazenamento Offline'),
              const SizedBox(height: 8),
              Text(
                'Todas as respostas, rascunhos e séries históricas permanecem '
                'no armazenamento local deste dispositivo ou navegador. Limpar os dados do navegador remove estes registros.',
                style: text.bodySmall,
              ),
              if (appViewModel.history.isNotEmpty ||
                  appViewModel.activeDraft != null) ...<Widget>[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final bool? confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext dialogContext) => AlertDialog(
                          backgroundColor: p.surface,
                          title: const Text('Apagar dados locais?'),
                          content: const Text(
                            'Isso removerá permanentemente todo o histórico de '
                            'avaliações e qualquer rascunho em andamento neste aparelho.',
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text('Apagar histórico'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await appViewModel.clearAllHistory();
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: p.warning,
                    ),
                    label: Text(
                      'Apagar histórico e rascunhos locais',
                      style: TextStyle(color: p.warning),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _openSuites(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => EspectroSuitesScreen(appViewModel: appViewModel),
    ),
  );

  void _startExpressQuiz(BuildContext context, {LikertAnswer? firstAnswer}) {
    final QuizViewModel quizVm = QuizViewModel.startNew(
      data: appViewModel.data,
      repository: appViewModel.repository,
      suite: TestSuite.espectroIntegrated,
      depth: TestDepth.express,
    );
    if (firstAnswer != null && quizVm.totalCount > 0) {
      quizVm.selectAnswer(firstAnswer);
      if (!quizVm.isLast) {
        quizVm.next();
      }
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => EspectroQuizScreen(
          appViewModel: appViewModel,
          quizViewModel: quizVm,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: appViewModel,
    builder: (context, _) {
      final p = context.palette;
      final bool wide = MediaQuery.sizeOf(context).width >= 1100;
      final draft = appViewModel.activeDraft;
      final catalog = StudyCatalog(
        appViewModel.data,
        records: appViewModel.history,
      );
      final recent = [
        for (final key in appViewModel.studyRecent) ?catalog.find(key),
      ];
      final saved = [
        for (final key in appViewModel.studyFavorites) ?catalog.find(key),
      ];
      return EspectroScaffold(
        appViewModel: appViewModel,
        isSectionRoot: true,
        body: SafeArea(
          child: ResponsiveContentFrame(
            maxWidth: wide ? EspectroLayout.workspaceMaxWidth : 760,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool twoColBento = constraints.maxWidth >= 820;

                final Widget toolsBentoCard = _ObservatoryToolsCard(
                  onOpenTeia: () => _openAtlas(context, initialMap: true),
                  onOpenCompare: () => _openComparison(context),
                  onOpenHistory: () => _openHistory(context),
                  onQuickCompare: (List<String> keys) =>
                      _openComparison(context, initialKeys: keys),
                );

                final Widget exploreBentoCard = SectionCard(
                  radius: 16,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explorar por conta própria',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: p.ink,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Escolha uma bateria específica ou consulte as fichas do Atlas.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: p.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _FigmaShortcutRow(
                        icon: Icons.tune_rounded,
                        iconBg: p.accentSoft,
                        iconColor: p.accent,
                        title: '12 EIXOS',
                        subtitle: 'Federalismo, economia, cultura e poder',
                        topRadius: 12,
                        onTap: () => _openSuite(context, TestSuite.bipolarAxes),
                      ),
                      Divider(
                        height: 1,
                        color: p.line.withValues(alpha: 0.5),
                      ),
                      _FigmaShortcutRow(
                        icon: Icons.change_history_rounded,
                        iconBg: p.accentSoft,
                        iconColor: p.accent,
                        title: '6 TRÍADES',
                        subtitle: 'Arenas baricêntricas com 3 vértices',
                        onTap: () => _openSuite(context, TestSuite.triads),
                      ),
                      Divider(
                        height: 1,
                        color: p.line.withValues(alpha: 0.5),
                      ),
                      _FigmaShortcutRow(
                        icon: Icons.menu_book_rounded,
                        iconBg: p.accentSoft,
                        iconColor: p.accent,
                        title: 'ATLAS DE CORRENTES',
                        subtitle:
                            '${appViewModel.data.catalog.currents.length} correntes, pensadores e obras',
                        bottomRadius: 12,
                        onTap: () => _openAtlas(context),
                      ),
                    ],
                  ),
                );

                final EvaluationRecord? latestRecord =
                    appViewModel.history.isNotEmpty
                    ? appViewModel.history.first
                    : null;

                return ListView(
                  // ignore: deprecated_member_use
                  cacheExtent: 1200,
                  padding: EdgeInsets.fromLTRB(
                    EspectroLayout.pageHorizontalPadding,
                    wide ? EspectroLayout.pageTopPadding : 16,
                    EspectroLayout.pageHorizontalPadding,
                    EspectroLayout.pageBottomPadding,
                  ),
                  children: [
                    if (!wide) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          children: [
                            const EspectroBrandMark(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ESPECTRO',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                      color: p.ink,
                                    ),
                                  ),
                                  Text(
                                    'Observatório político',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: p.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.science_outlined,
                                size: 20,
                              ),
                              tooltip: 'Metodologia e fórmulas',
                              onPressed: () => _openMethodology(context),
                            ),
                            IconButton(
                              icon: const Icon(Icons.tune_rounded, size: 20),
                              tooltip: 'Tema e preferências',
                              onPressed: () => _showSettingsSheet(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (draft != null) ...[
                      _DraftResumeCard(
                        draft: draft,
                        onResume: () => _resumeDraft(context, draft),
                        onDiscard: () => appViewModel.discardActiveDraft(),
                        onPreview: draft.answeredOrSkippedCount >= 4
                            ? () => _openDraftPreview(context, draft)
                            : null,
                      ),
                      const SizedBox(height: 28),
                    ],
                    // Beat 1: Cartografia Viva — Palco Aberto + Teia das 289 Correntes
                    _ObservatoryCoverHero(
                      twoColumn: twoColBento,
                      catalog: catalog,
                      onStartQuiz: () => _openSuites(context),
                      onOpenAtlas: () => _openAtlas(context),
                      onOpenTeia: () => _openAtlas(context, initialMap: true),
                      onOpenSubject: (String key) => _openSubject(context, key),
                    ),
                    if (latestRecord != null) ...[
                      const SizedBox(height: 40),
                      _LatestEvaluationBentoCard(
                        appViewModel: appViewModel,
                        record: latestRecord,
                        axesMeta: appViewModel.data.twelveAxes.axes,
                        onOpenResult: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => EspectroResultScreen(
                              appViewModel: appViewModel,
                              record: latestRecord,
                            ),
                          ),
                        ),
                        onOpenHistory: () => _openHistory(context),
                      ),
                    ],
                    // Beat 2: Carrossel Gigante de Cartão Compartilhável (4 Exemplares)
                    SizedBox(
                      height: latestRecord != null
                          ? 48
                          : (twoColBento ? 72 : 52),
                    ),
                    _HeroLiveSpectrumShowcase(
                      catalog: catalog,
                      portraits: appViewModel.data.portraits,
                      axesMeta: appViewModel.data.twelveAxes.axes,
                      compact: !twoColBento,
                      latestRecord: latestRecord,
                      onStartQuiz: () => _openSuites(context),
                      onOpenSubject: (String key) => _openSubject(context, key),
                      onOpenShareSheet: latestRecord == null
                          ? null
                          : () => ShareableCardSheet.show(
                              context,
                              record: latestRecord,
                              appViewModel: appViewModel,
                            ),
                    ),
                    // Beat 3: Dilema Relâmpago (amostra imediata)
                    const SizedBox(height: 44),
                    SectionCard(
                      padding: const EdgeInsets.all(24),
                      child: _HeroInstantDilemmaGame(
                        onStartWithAnswer: (LikertAnswer ans) =>
                            _startExpressQuiz(context, firstAnswer: ans),
                      ),
                    ),
                    // Beat 4: Jogo de Intuição Política ("Quem Pensa Assim?")
                    const SizedBox(height: 44),
                    _IdeologicalRiddleGameCard(
                      catalog: catalog,
                      onOpenSubject: (String key) => _openSubject(context, key),
                      onStartExpress: () => _startExpressQuiz(context),
                    ),
                    // Beat 5: Bento Grid com hierarquia clara
                    const SizedBox(height: 44),
                    if (twoColBento)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 5, child: exploreBentoCard),
                            const SizedBox(width: 24),
                            Expanded(flex: 6, child: toolsBentoCard),
                          ],
                        ),
                      )
                    else ...[
                      exploreBentoCard,
                      const SizedBox(height: 24),
                      toolsBentoCard,
                    ],
                    const EspectroInlineAdSlot(
                      placementId: 'home_mid_feed',
                      verticalMargin: 28,
                    ),
                    // Beat 6: Passaporte do Cartógrafo (Progresso Dotado)
                    const SizedBox(height: 44),
                    _ObservatoryPassportCard(
                      appViewModel: appViewModel,
                      onStartExpress: () => _startExpressQuiz(context),
                      onStartTriads: () =>
                          _openSuite(context, TestSuite.triads),
                      onOpenAtlas: () => _openAtlas(context),
                      onOpenCompare: () => _openComparison(context),
                    ),
                    const SizedBox(height: 44),
                    _HomeFeaturedSpotlight(
                      appViewModel: appViewModel,
                      catalog: catalog,
                      axesMeta: appViewModel.data.twelveAxes.axes,
                    ),
                    const SizedBox(height: 48),
                    _HomeTwelveAxesShowcase(
                      axesMeta: appViewModel.data.twelveAxes.axes,
                      onTapAxis: () =>
                          _openSuite(context, TestSuite.bipolarAxes),
                    ),
                    if (recent.isNotEmpty || saved.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Eyebrow('Sua biblioteca', color: p.accent),
                      const SizedBox(height: 12),
                      for (final subject in {
                        ...recent.take(3),
                        ...saved.take(3),
                      })
                        StudySubjectTile(
                          subject: subject,
                          portrait: appViewModel.data.portraits[subject.key],
                          onTap: () => _openSubject(context, subject.key),
                        ),
                    ],
                    if (appViewModel.studyStorageError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          appViewModel.studyStorageError!,
                          style: TextStyle(color: p.warning),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

class _AxisMetaInfo {
  const _AxisMetaInfo({
    required this.id,
    required this.label,
    required this.leftPole,
    required this.rightPole,
    required this.leftColor,
    required this.rightColor,
  });

  final String id;
  final String label;
  final String leftPole;
  final String rightPole;
  final Color leftColor;
  final Color rightColor;
}

const List<_AxisMetaInfo> _fallbackAxisInfos = [
  _AxisMetaInfo(
    id: 'estrutura',
    label: 'Estrutura',
    leftPole: 'Federal',
    rightPole: 'Unitário',
    leftColor: Color(0xFF2F6DC0),
    rightColor: Color(0xFFCF5A22),
  ),
  _AxisMetaInfo(
    id: 'representacao',
    label: 'Representação',
    leftPole: 'Democracia',
    rightPole: 'Autocracia',
    leftColor: Color(0xFF12907F),
    rightColor: Color(0xFFB02556),
  ),
  _AxisMetaInfo(
    id: 'poder',
    label: 'Poder',
    leftPole: 'Segurança',
    rightPole: 'Liberdade',
    leftColor: Color(0xFF3C5A80),
    rightColor: Color(0xFFAD7A06),
  ),
  _AxisMetaInfo(
    id: 'imigracao',
    label: 'Imigração',
    leftPole: 'Assimilação',
    rightPole: 'Multicultura',
    leftColor: Color(0xFFCC3456),
    rightColor: Color(0xFF6A45C0),
  ),
  _AxisMetaInfo(
    id: 'diplomacia',
    label: 'Diplomacia',
    leftPole: 'Militarista',
    rightPole: 'Pacifista',
    leftColor: Color(0xFF6A8425),
    rightColor: Color(0xFF2D86C8),
  ),
  _AxisMetaInfo(
    id: 'intervencao',
    label: 'Intervenção',
    leftPole: 'Não-intervenção',
    rightPole: 'Nacionalista',
    leftColor: Color(0xFF3F8E5C),
    rightColor: Color(0xFFB94A16),
  ),
  _AxisMetaInfo(
    id: 'economia',
    label: 'Economia',
    leftPole: 'Público',
    rightPole: 'Privado',
    leftColor: Color(0xFFD43A28),
    rightColor: Color(0xFF8E6516),
  ),
  _AxisMetaInfo(
    id: 'controle',
    label: 'Controle',
    leftPole: 'Planejamento',
    rightPole: 'Livre mercado',
    leftColor: Color(0xFF8A3AA0),
    rightColor: Color(0xFF1A8A56),
  ),
  _AxisMetaInfo(
    id: 'comercio',
    label: 'Comércio',
    leftPole: 'Protecionismo',
    rightPole: 'Globalismo',
    leftColor: Color(0xFF9C5E2A),
    rightColor: Color(0xFF0E86B0),
  ),
  _AxisMetaInfo(
    id: 'religiao',
    label: 'Religião',
    leftPole: 'Irreligioso',
    rightPole: 'Religioso',
    leftColor: Color(0xFFC65E0E),
    rightColor: Color(0xFF3B50B5),
  ),
  _AxisMetaInfo(
    id: 'moral',
    label: 'Moral',
    leftPole: 'Progressista',
    rightPole: 'Tradicionalista',
    leftColor: Color(0xFFD23E84),
    rightColor: Color(0xFF74502C),
  ),
  _AxisMetaInfo(
    id: 'tecnologia',
    label: 'Tecnologia',
    leftPole: 'Tecnologia',
    rightPole: 'Biologia',
    leftColor: Color(0xFF5376B0),
    rightColor: Color(0xFF4E9020),
  ),
];

List<_AxisMetaInfo> _resolveAxisInfos(List<data.Axis> axesMeta) {
  if (axesMeta.isEmpty) return _fallbackAxisInfos;
  return [
    for (final data.Axis ax in axesMeta)
      _AxisMetaInfo(
        id: ax.id,
        label: ax.label,
        leftPole: ax.leftPole,
        rightPole: ax.rightPole,
        leftColor: ax.leftColor,
        rightColor: ax.rightColor,
      ),
  ];
}

class _DominantAxisReading {
  const _DominantAxisReading({
    required this.axisId,
    required this.axisLabel,
    required this.dominantPole,
    required this.dominantColor,
    required this.percent,
    required this.magnitude,
  });

  final String axisId;
  final String axisLabel;
  final String dominantPole;
  final Color dominantColor;
  final int percent;
  final double magnitude;
}

List<_DominantAxisReading> _extractDominantTraits(
  Map<String, double> axes,
  List<_AxisMetaInfo> infos, {
  int limit = 2,
}) {
  final Map<String, _AxisMetaInfo> byId = {
    for (final _AxisMetaInfo info in infos) info.id: info,
  };
  final List<_DominantAxisReading> readings = [];
  for (final MapEntry<String, double> entry in axes.entries) {
    final _AxisMetaInfo? info = byId[entry.key];
    if (info == null) continue;
    final double score = entry.value.clamp(-1.0, 1.0);
    final bool isRight = score >= 0;
    final double mag = score.abs();
    readings.add(
      _DominantAxisReading(
        axisId: info.id,
        axisLabel: info.label,
        dominantPole: isRight ? info.rightPole : info.leftPole,
        dominantColor: isRight ? info.rightColor : info.leftColor,
        percent: ((0.5 + mag / 2.0) * 100).round().clamp(50, 100),
        magnitude: mag,
      ),
    );
  }
  readings.sort((a, b) => b.magnitude.compareTo(a.magnitude));
  return readings.take(limit).toList();
}

String? _resolvePortraitAsset(StudySubject subject, StudyPortrait? portrait) {
  if (portrait?.assetPath != null) return portrait!.assetPath;
  final String? url = subject.photoUrl;
  if (url != null && url.startsWith('assets/')) return url;
  return null;
}

class _SafeButtonContent extends StatelessWidget {
  const _SafeButtonContent({
    required this.icon,
    required this.label,
    this.iconSize = 18,
  });

  final IconData icon;
  final String label;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize),
        const SizedBox(width: 8),
        Flexible(child: Text(label)),
      ],
    );
  }
}

class _ObservatoryCoverHero extends StatefulWidget {
  const _ObservatoryCoverHero({
    required this.twoColumn,
    required this.catalog,
    required this.onStartQuiz,
    required this.onOpenAtlas,
    required this.onOpenTeia,
    required this.onOpenSubject,
  });

  final bool twoColumn;
  final StudyCatalog catalog;
  final VoidCallback onStartQuiz;
  final VoidCallback onOpenAtlas;
  final VoidCallback onOpenTeia;
  final ValueChanged<String> onOpenSubject;

  @override
  State<_ObservatoryCoverHero> createState() => _ObservatoryCoverHeroState();
}

class _ObservatoryCoverHeroState extends State<_ObservatoryCoverHero> {
  StudySubject? _focusedCurrent;

  late final List<StudySubject> _currents = widget.catalog.subjects
      .where((StudySubject s) => s.kind == 'current')
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _focusedCurrent = widget.catalog.find('current:liberalismo_classico') ??
        (_currents.isNotEmpty ? _currents.first : null);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final double scale = MediaQuery.textScalerOf(context).scale(16) / 16.0;
    final bool split = widget.twoColumn && scale <= 1.35;
    final int currentsCount = widget.catalog.data.catalog.currents.length;
    final Color primaryBtnBg =
        p.isDark ? const Color(0xFFE5A448) : p.accent;
    final Color primaryBtnFg =
        p.isDark ? const Color(0xFF140D03) : const Color(0xFFFAF9F6);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final bool wideSplit = split && box.maxWidth >= 960;
        final double titleFontSize = wideSplit ? 55 : (split ? 42 : 28);
        final double titleTracking = wideSplit ? -1.55 : (split ? -1.2 : -0.85);
        final double teiaHeight = wideSplit ? 396 : (split ? 384 : 284);
        final double minPitchHeight = wideSplit ? 412 : 396;
        final double ctaHeight = split ? 48 : 44;

        final Widget topEditorial = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: split ? 480 : double.infinity,
              ),
              child: Text(
                'Onde você realmente se situa além dos rótulos?',
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: titleTracking,
                  height: 1.04,
                  color: p.ink,
                ),
              ),
            ),
            SizedBox(height: split ? 20 : 10),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: split ? 456 : double.infinity,
              ),
              child: Text(
                'Política não cabe numa linha. Inspecione $currentsCount correntes na Teia e mapeie onde suas ideias convergem em 12 eixos e 6 tríades.',
                style: TextStyle(
                  fontSize: wideSplit ? 16.5 : 14.5,
                  height: 1.54,
                  color: p.inkSoft,
                ),
              ),
            ),
          ],
        );

        final Widget bottomActions = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: split ? 20 : 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: widget.onStartQuiz,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryBtnBg,
                    foregroundColor: primaryBtnFg,
                    elevation: 0,
                    minimumSize: Size(0, ctaHeight),
                    maximumSize: Size(double.infinity, ctaHeight),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.15,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                  label: const Text('Fazer Avaliação Expressa (3 min)'),
                ),
                OutlinedButton(
                  onPressed: widget.onOpenAtlas,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, ctaHeight),
                    maximumSize: Size(double.infinity, ctaHeight),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: p.ink,
                    side: BorderSide(color: p.line),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Explorar o Atlas'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '24 afirmações · 100% offline · Cartão 9:16 e 1:1',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 12,
                color: p.muted,
              ),
            ),
          ],
        );

        final Widget pitchColumn = split
            ? ConstrainedBox(
                constraints: BoxConstraints(minHeight: minPitchHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [topEditorial, bottomActions],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [topEditorial, bottomActions],
              );

        final Widget teiaStage = TeiaInteractivePreviewPanel(
          subjects: _currents,
          selected: _focusedCurrent,
          borderColor: p.line,
          height: teiaHeight,
          showFooter: true,
          headerHint: 'Toque num nó para inspecionar',
          onSelect: (StudySubject s) => setState(() => _focusedCurrent = s),
          onOpenSubject: widget.onOpenSubject,
          onOpenTeia: widget.onOpenTeia,
        );

        if (split) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 11, child: pitchColumn),
                const SizedBox(width: 28),
                Expanded(flex: 13, child: teiaStage),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            pitchColumn,
            const SizedBox(height: 20),
            teiaStage,
          ],
        );
      },
    );
  }
}

class _InstantDilemmaSpec {
  const _InstantDilemmaSpec({
    required this.axisId,
    required this.axisTag,
    required this.statement,
    required this.agreeInsight,
    required this.neutralInsight,
    required this.disagreeInsight,
  });

  final String axisId;
  final String axisTag;
  final String statement;
  final String agreeInsight;
  final String neutralInsight;
  final String disagreeInsight;
}

class _HeroInstantDilemmaGame extends StatefulWidget {
  const _HeroInstantDilemmaGame({required this.onStartWithAnswer});

  final ValueChanged<LikertAnswer> onStartWithAnswer;

  @override
  State<_HeroInstantDilemmaGame> createState() =>
      _HeroInstantDilemmaGameState();
}

class _HeroInstantDilemmaGameState extends State<_HeroInstantDilemmaGame>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const List<_InstantDilemmaSpec> _dilemmas = <_InstantDilemmaSpec>[
    _InstantDilemmaSpec(
      axisId: 'poder',
      axisTag: 'PODER · LIBERDADE VS. SEGURANÇA',
      statement:
          'Em crises graves, o Estado deve monitorar comunicações privadas para conter ameaças?',
      agreeInsight:
          'Alinha-se ao Realismo Estatal de Thomas Hobbes; distancia-se fortemente de Hannah Arendt.',
      neutralInsight:
          'Equilíbrio constitucional próximo a John Locke e Montesquieu.',
      disagreeInsight:
          'Converge com Hannah Arendt e o Libertarianismo Civil, colidindo com Hobbes.',
    ),
    _InstantDilemmaSpec(
      axisId: 'economia',
      axisTag: 'ECONOMIA · PÚBLICO VS. PRIVADO',
      statement:
          'Energia, água e ferrovias devem ser estatais mesmo que o setor privado opere com menor custo?',
      agreeInsight:
          'Converge com Celso Furtado e o Trabalhismo; diverge em polo econômico de Milton Friedman.',
      neutralInsight:
          'Postura regulatória mista próxima a John Maynard Keynes e ao Ordoliberalismo.',
      disagreeInsight:
          'Alinha-se a Friedrich Hayek e ao Liberalismo Clássico; polo oposto ao de Karl Marx.',
    ),
    _InstantDilemmaSpec(
      axisId: 'comercio',
      axisTag: 'COMÉRCIO · PROTECIONISMO VS. GLOBALISMO',
      statement:
          'Vale sobretaxar importados para proteger a indústria nacional, mesmo encarecendo bens?',
      agreeInsight:
          'Converge com Alexander Hamilton e o Desenvolvimentismo Nacional.',
      neutralInsight:
          'Pragmatismo estratégico próximo à Social-Democracia contemporânea.',
      disagreeInsight:
          'Converge com Adam Smith e o Livre-Cambismo Cosmopolita.',
    ),
    _InstantDilemmaSpec(
      axisId: 'moral',
      axisTag: 'CULTURA · TRADIÇÃO VS. PROGRESSO',
      statement:
          'Instituições testadas por gerações devem pesar mais que experimentos sociais acelerados?',
      agreeInsight:
          'Converge com Edmund Burke (Conservadorismo), colidindo com Rosa Luxemburgo.',
      neutralInsight:
          'Prudência institucional próxima a Alexis de Tocqueville.',
      disagreeInsight:
          'Converge com John Stuart Mill e o Progressismo Reformista.',
    ),
  ];

  int _index = 0;
  LikertAnswer? _picked;

  void _rotateDilemma() {
    setState(() {
      _index = (_index + 1) % _dilemmas.length;
      _picked = null;
    });
  }

  String _insightFor(_InstantDilemmaSpec d, LikertAnswer a) => switch (a) {
    LikertAnswer.agree || LikertAnswer.stronglyAgree => d.agreeInsight,
    LikertAnswer.neutral => d.neutralInsight,
    LikertAnswer.disagree || LikertAnswer.stronglyDisagree => d.disagreeInsight,
  };

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = context.palette;
    final _InstantDilemmaSpec spec = _dilemmas[_index];
    final Color rawAxisColor = AxisColors.pairFor(spec.axisId, p).$1;
    final Color axisInk = AxisColors.readableInk(rawAxisColor, isDark: p.isDark);
    final double scale = MediaQuery.textScalerOf(context).scale(16) / 16.0;
    final Color amberInk =
        p.isDark ? const Color(0xFFE5A64B) : const Color(0xFF9D5B12);

    final List<(LikertAnswer answer, String label, Color accent)> choices = [
      (LikertAnswer.agree, 'Concordo', p.poleLeft),
      (LikertAnswer.neutral, 'Depende', amberInk),
      (LikertAnswer.disagree, 'Discordo', p.accent),
    ];

    Widget buildChoiceChip(
      LikertAnswer answer,
      String label,
      Color accent, {
      bool expand = false,
    }) {
      final bool isSelected = _picked == answer;
      final Widget button = TactilePress(
        scale: 0.96,
        child: Material(
          color: isSelected
              ? accent.withValues(alpha: p.isDark ? 0.22 : 0.12)
              : p.surface,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => setState(() => _picked = answer),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? accent : p.line,
                  width: isSelected ? 1.4 : 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? accent : p.ink,
                ),
              ),
            ),
          ),
        ),
      );
      return expand ? Expanded(child: button) : button;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 14,
                  color: amberInk,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'DILEMA RELÂMPAGO · 1/24',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: amberInk,
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: _rotateDilemma,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 13,
                      color: p.inkSoft,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Outro dilema',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: p.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              AxisColors.iconFor(spec.axisId),
              size: 13,
              color: axisInk,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                spec.axisTag,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: axisInk,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          spec.statement,
          style: TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.38,
            color: p.ink,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 300 || scale > 1.35) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in choices) buildChoiceChip(c.$1, c.$2, c.$3),
                ],
              );
            }
            return Row(
              children: [
                for (var i = 0; i < choices.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  buildChoiceChip(
                    choices[i].$1,
                    choices[i].$2,
                    choices[i].$3,
                    expand: true,
                  ),
                ],
              ],
            );
          },
        ),
        AnimatedSize(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : EspectroMotion.medium,
          curve: EspectroMotion.easeOut,
          child: _picked == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: rawAxisColor.withValues(
                        alpha: p.isDark ? 0.12 : 0.06,
                      ),
                      border: Border(
                        left: BorderSide(color: axisInk, width: 2.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _insightFor(spec, _picked!),
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: p.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '4% concluído (1/24) · Seu Arquétipo começou a emergir',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: amberInk,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 4,
                            color: p.line,
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 0.08,
                              child: Container(color: amberInk),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: () => widget.onStartWithAnswer(_picked!),
                          style: FilledButton.styleFrom(
                            backgroundColor: p.isDark
                                ? const Color(0xFFE5A448)
                                : p.accent,
                            foregroundColor: p.isDark
                                ? const Color(0xFF140D03)
                                : const Color(0xFFFAF9F6),
                            minimumSize: const Size(0, 42),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 16),
                          label: const Text('Continuar da pergunta 2/24 →'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _IdeologicalRiddleSpec {
  const _IdeologicalRiddleSpec({
    required this.subjectKey,
    required this.answerName,
    required this.options,
    required this.clue,
    required this.paradoxExplanation,
  });

  final String subjectKey;
  final String answerName;
  final List<String> options;
  final String clue;
  final String paradoxExplanation;
}

/// Jogo psicológico interativo "Quem Pensa Assim?" direto na Home, usando perfis
/// reais e a fita DNA de 12 eixos do Atlas para gerar descoberta ativa.
class _IdeologicalRiddleGameCard extends StatefulWidget {
  const _IdeologicalRiddleGameCard({
    required this.catalog,
    required this.onOpenSubject,
    required this.onStartExpress,
  });

  final StudyCatalog catalog;
  final ValueChanged<String> onOpenSubject;
  final VoidCallback onStartExpress;

  @override
  State<_IdeologicalRiddleGameCard> createState() =>
      _IdeologicalRiddleGameCardState();
}

class _IdeologicalRiddleGameCardState
    extends State<_IdeologicalRiddleGameCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const List<_IdeologicalRiddleSpec> _riddles =
      <_IdeologicalRiddleSpec>[
        _IdeologicalRiddleSpec(
          subjectKey: 'personality:hannah_arendt',
          answerName: 'Hannah Arendt',
          options: <String>[
            'Hannah Arendt',
            'Thomas Hobbes',
            'Carl Schmitt',
          ],
          clue:
              'Defende a democracia participativa, a liberdade pública e o laicismo, mas desconfia de tecnocracias e rejeita tanto o autoritarismo quanto o mercado irrestrito.',
          paradoxExplanation:
              'Arendt combina defesa vigorosa da liberdade civil republicana com crítica firme aos totalitarismos do século XX e ao reducionismo economicista.',
        ),
        _IdeologicalRiddleSpec(
          subjectKey: 'personality:friedrich_hayek',
          answerName: 'Friedrich Hayek',
          options: <String>[
            'Karl Polanyi',
            'Friedrich Hayek',
            'Celso Furtado',
          ],
          clue:
              'Vê o mercado como coordenação descentralizada de conhecimento disperso, ao mesmo tempo em que defende Estado de Direito constitucional e instituições herdadas.',
          paradoxExplanation:
              'Diferente de anarcocapitalistas, Hayek aceita regras jurídicas gerais e uma rede mínima contra a miséria, preservando a ordem espontânea de preços.',
        ),
        _IdeologicalRiddleSpec(
          subjectKey: 'personality:celso_furtado',
          answerName: 'Celso Furtado',
          options: <String>[
            'Milton Friedman',
            'Celso Furtado',
            'Murray Rothbard',
          ],
          clue:
              'Articula democracia política com planejamento econômico estratégico, industrialização e fortalecimento do mercado interno para superar o subdesenvolvimento.',
          paradoxExplanation:
              'Economista brasileiro da CEPAL, Furtado enxerga o Estado planejador democrático como motor para romper a dependência estrutural periférica.',
        ),
        _IdeologicalRiddleSpec(
          subjectKey: 'personality:murray_rothbard',
          answerName: 'Murray Rothbard',
          options: <String>[
            'Murray Rothbard',
            'John Locke',
            'John Rawls',
          ],
          clue:
              'Leva autopropriedade e mercado ao limite máximo: propõe substituir polícia, tribunais e defesa estatal por associações voluntárias e contratos privados.',
          paradoxExplanation:
              'Rothbard rompeu com o liberalismo clássico de Locke ao rejeitar qualquer monopólio estatal legítimo da força, fundindo Escola Austríaca e anarcoindividualismo.',
        ),
        _IdeologicalRiddleSpec(
          subjectKey: 'personality:rosa_luxemburgo',
          answerName: 'Rosa Luxemburgo',
          options: <String>[
            'Edmund Burke',
            'Rosa Luxemburgo',
            'Max Weber',
          ],
          clue:
              'Propõe socialização radical da economia e internacionalismo operário, ao mesmo tempo em que critica severamente a burocracia autoritária de partido único.',
          paradoxExplanation:
              'Luxemburgo une transformação socialista profunda com defesa explícita da liberdade de imprensa, assembleia e pluralismo nos conselhos.',
        ),
      ];

  int _riddleIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _answeredCount = 0;
  String? _selectedOption;

  void _pick(String option) {
    if (_selectedOption != null) return;
    final _IdeologicalRiddleSpec spec = _riddles[_riddleIndex];
    final bool correct = option == spec.answerName;
    setState(() {
      _selectedOption = option;
      _answeredCount++;
      if (correct) {
        _score++;
        _streak++;
      } else {
        _streak = 0;
      }
    });
  }

  void _nextRiddle() {
    setState(() {
      _riddleIndex = (_riddleIndex + 1) % _riddles.length;
      _selectedOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final EspectroPalette p = context.palette;
    final _IdeologicalRiddleSpec spec = _riddles[_riddleIndex];
    final StudySubject? subject = widget.catalog.find(spec.subjectKey);
    final bool answered = _selectedOption != null;
    final bool isCorrect = _selectedOption == spec.answerName;

    final double scale = MediaQuery.textScalerOf(context).scale(16) / 16.0;
    final Widget titleBlock = Row(
      children: [
        Icon(Icons.psychology_alt_rounded, size: 22, color: p.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow('Desafio do observatório', color: p.accent),
              const SizedBox(height: 2),
              Text(
                'Quem pensa assim?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: p.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    final Widget scoreBadges = Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: p.poleRight.withValues(alpha: p.isDark ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: p.poleRight.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 14,
                color: p.poleRight,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Sequência: $_streak',
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: p.surfaceMuted,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: p.line),
          ),
          child: Text(
            'Acertos: $_score/$_answeredCount',
            style: TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: p.inkSoft,
            ),
          ),
        ),
      ],
    );

    return SectionCard(
      radius: 18,
      padding: const EdgeInsets.all(20),
      borderColor: p.accent.withValues(alpha: p.isDark ? 0.34 : 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 520 && scale <= 1.35) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 12),
                    scoreBadges,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleBlock,
                  const SizedBox(height: 10),
                  scoreBadges,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: p.accent, width: 2.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enigma ${_riddleIndex + 1} de ${_riddles.length}',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                    color: p.muted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '“${spec.clue}”',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: p.ink,
                  ),
                ),
                if (subject != null && subject.axes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Assinatura real nos 12 eixos',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: p.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TwelveAxisDnaStrip(axes: subject.axes),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final String option in spec.options)
                () {
                  final bool isPicked = _selectedOption == option;
                  final bool isAnswer = option == spec.answerName;
                  Color bg = p.surface;
                  Color border = p.line;
                  Color fg = p.ink;
                  if (answered) {
                    if (isAnswer) {
                      bg = p.success.withValues(alpha: p.isDark ? 0.20 : 0.12);
                      border = p.success;
                    } else if (isPicked) {
                      bg = p.warning.withValues(alpha: p.isDark ? 0.20 : 0.12);
                      border = p.warning;
                    } else {
                      fg = p.muted;
                    }
                  }
                  return TactilePress(
                    scale: 0.97,
                    enabled: !answered,
                    child: Material(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: answered ? null : () => _pick(option),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: border,
                              width: (answered && (isAnswer || isPicked))
                                  ? 1.5
                                  : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (answered && isAnswer) ...[
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: p.success,
                                ),
                                const SizedBox(width: 6),
                              ] else if (answered && isPicked) ...[
                                Icon(
                                  Icons.cancel_rounded,
                                  size: 16,
                                  color: p.warning,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSans',
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: fg,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }(),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: (isCorrect ? p.success : p.accent).withValues(
                  alpha: p.isDark ? 0.10 : 0.06,
                ),
                border: Border(
                  left: BorderSide(
                    color: isCorrect ? p.success : p.warning,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect
                        ? 'Leitura certeira! É ${spec.answerName}.'
                        : 'Quase! Na verdade é ${spec.answerName}.',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isCorrect ? p.success : p.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spec.paradoxExplanation,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.42,
                      color: p.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _nextRiddle,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('Próximo enigma →'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => widget.onOpenSubject(spec.subjectKey),
                        icon: const Icon(Icons.person_search_rounded, size: 16),
                        label: const Text('Ver ficha no Atlas'),
                      ),
                      TextButton(
                        onPressed: widget.onStartExpress,
                        child: const Text('Descobrir sua assinatura'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Passaporte do Cartógrafo (Progresso Dotado): converte a exploração pelo app
/// em 4 missões clicáveis que aumentam a retenção e incentivam descobertas novas.
class _ObservatoryPassportCard extends StatelessWidget {
  const _ObservatoryPassportCard({
    required this.appViewModel,
    required this.onStartExpress,
    required this.onStartTriads,
    required this.onOpenAtlas,
    required this.onOpenCompare,
  });

  final AppViewModel appViewModel;
  final VoidCallback onStartExpress;
  final VoidCallback onStartTriads;
  final VoidCallback onOpenAtlas;
  final VoidCallback onOpenCompare;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final bool hasAnyTest = appViewModel.history.isNotEmpty;
    final bool hasTriads = appViewModel.history.any(
      (EvaluationRecord r) => r.triads.isNotEmpty,
    );
    final bool hasAtlasExploration =
        appViewModel.studyRecent.length >= 3 ||
        appViewModel.studyFavorites.isNotEmpty;
    final bool hasCompare = appViewModel.studyComparison.length >= 2;

    final List<(String label, bool done, VoidCallback onTap)> missions = [
      ('Mapear 12 Eixos / Expressa', hasAnyTest, onStartExpress),
      ('Dominar as 6 Tríades', hasTriads, onStartTriads),
      ('Investigar o Atlas (3+ fichas)', hasAtlasExploration, onOpenAtlas),
      ('Duelo no Comparador', hasCompare, onOpenCompare),
    ];

    final int completedCount = missions.where((m) => m.$2).length;
    final String levelTitle = switch (completedCount) {
      0 => 'Etapa 1 — Exploração inicial',
      1 => 'Etapa 2 — Leitura em eixos',
      2 || 3 => 'Etapa 3 — Cartografia comparada',
      _ => 'Etapa 4 — Acervo completo',
    };
    // Efeito Progresso Dotado: começa visualmente em 15% para convidar à próxima conquista.
    final double progress = ((completedCount + 0.6) / 4.6).clamp(0.13, 1.0);

    return SectionCard(
      radius: 18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow('Caderno de campo', color: p.accent),
                  const SizedBox(height: 3),
                  Text(
                    levelTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: p.ink,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: p.accentSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$completedCount/4 marcos',
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: p.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressRail(value: progress, color: p.accent),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in missions)
                Material(
                  color: m.$2
                      ? p.success.withValues(alpha: p.isDark ? 0.16 : 0.10)
                      : p.surfaceMuted.withValues(alpha: p.isDark ? 0.7 : 0.8),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: m.$3,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: m.$2
                              ? p.success.withValues(alpha: 0.45)
                              : p.line,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            m.$2
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 15,
                            color: m.$2 ? p.success : p.accent,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              m.$1,
                              style: TextStyle(
                                fontFamily: 'IBMPlexSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: p.ink,
                              ),
                            ),
                          ),
                        ],
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
}

class _LatestEvaluationBentoCard extends StatelessWidget {
  const _LatestEvaluationBentoCard({
    required this.appViewModel,
    required this.record,
    required this.axesMeta,
    required this.onOpenResult,
    required this.onOpenHistory,
  });

  final AppViewModel appViewModel;
  final EvaluationRecord record;
  final List<data.Axis> axesMeta;
  final VoidCallback onOpenResult;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final CompatibilityReport compat = EspectroCompatibilityEngine.evaluate(
      catalog: appViewModel.data.catalog,
      axes: record.axes,
      triads: record.triads,
    );
    final CurrentCompatibility? topMatch = compat.primaryMatch;
    final StudySpectrum? spectrum = topMatch != null
        ? spectrumOf(StudySubject.fromCurrent(topMatch.current))
        : null;
    final Color accentColor = spectrum?.color ?? p.accent;
    final Color accentInk = spectrum?.ink(p.isDark) ?? p.accent;

    final List<_AxisMetaInfo> axisInfos = _resolveAxisInfos(axesMeta);
    final Map<String, double> axisMap = {
      for (final BipolarDimensionScore axis in record.axes)
        if (!axis.isIndeterminate) axis.axisId: axis.score,
    };
    final List<_DominantAxisReading> topTraits = _extractDominantTraits(
      axisMap,
      axisInfos,
      limit: 3,
    );
    final int coveragePct = (record.quality.coverage * 100).round();

    void openShare() => ShareableCardSheet.show(
      context,
      record: record,
      appViewModel: appViewModel,
    );

    final Widget detailsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            Eyebrow('Seu último retrato', color: accentInk),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: p.surfaceMuted,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: p.line),
              ),
              child: Text(
                '${record.suite.title} · ${record.depth.label}',
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: p.inkSoft,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topMatch != null
                        ? topMatch.current.name
                        : record.displayTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topMatch != null
                        ? topMatch.current.summary
                        : '${record.quality.totalAnswered} respostas registradas ($coveragePct% cobertura).',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: p.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            if (topMatch != null) ...[
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: p.isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withValues(alpha: 0.45)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          MetricPresentation.formatPercent(
                            topMatch.compatibilityPercent,
                          ),
                          style: TextStyle(
                            fontFamily: 'IBMPlexMono',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: accentInk,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const MetricInfoBadge(
                          tooltip: MetricPresentation.currentConvergenceTooltip,
                          semanticLabel:
                              'Explicação sobre convergência com a corrente',
                          size: 13,
                        ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 112),
                      child: Text(
                        'convergência com a corrente',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: p.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (topTraits.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final _DominantAxisReading t in topTraits)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: t.dominantColor.withValues(
                      alpha: p.isDark ? 0.14 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: t.dominantColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AxisColors.iconFor(t.axisId),
                        size: 12,
                        color: AxisColors.readableInk(
                          t.dominantColor,
                          isDark: p.isDark,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${t.axisLabel}: ${t.dominantPole} ${t.percent}%',
                          style: TextStyle(
                            fontFamily: 'IBMPlexMono',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: p.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: onOpenResult,
              child: const _SafeButtonContent(
                icon: Icons.insights_rounded,
                iconSize: 17,
                label: 'Abrir diagnóstico',
              ),
            ),
            OutlinedButton(
              onPressed: openShare,
              child: const _SafeButtonContent(
                icon: Icons.share_rounded,
                iconSize: 17,
                label: 'Compartilhar cartão',
              ),
            ),
            if (topMatch != null)
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StudyComparisonScreen(
                      appViewModel: appViewModel,
                      initialKeys: [
                        'evaluation:${record.id}',
                        'current:${topMatch.current.id}',
                      ],
                    ),
                  ),
                ),
                child: const _SafeButtonContent(
                  icon: Icons.compare_arrows_rounded,
                  iconSize: 17,
                  label: 'Comparar perfil',
                ),
              ),
            TextButton(
              onPressed: onOpenHistory,
              child: _SafeButtonContent(
                icon: Icons.history_rounded,
                iconSize: 17,
                label: 'Ver histórico (${appViewModel.history.length})',
              ),
            ),
          ],
        ),
      ],
    );

    return SectionCard(
      padding: const EdgeInsets.all(22),
      borderColor: accentColor.withValues(alpha: p.isDark ? 0.36 : 0.28),
      child: detailsColumn,
    );
  }
}

class _ObservatoryToolsCard extends StatelessWidget {
  const _ObservatoryToolsCard({
    required this.onOpenTeia,
    required this.onOpenCompare,
    required this.onOpenHistory,
    required this.onQuickCompare,
  });

  final VoidCallback onOpenTeia;
  final VoidCallback onOpenCompare;
  final VoidCallback onOpenHistory;
  final ValueChanged<List<String>> onQuickCompare;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SectionCard(
      radius: 16,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comparador de Perfis e Histórico',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: p.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Coloque correntes ou pensadores lado a lado com Raio-X matemático, explore a Teia 2D ou acompanhe sua evolução.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: p.inkSoft,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Confrontos sugeridos',
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: p.muted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickCompareChip(
                    label: 'Karl Marx × Rothbard',
                    onTap: () => onQuickCompare(const [
                      'personality:karl_marx',
                      'personality:murray_rothbard',
                    ]),
                  ),
                  _QuickCompareChip(
                    label: 'Liberalismo × Social-democracia',
                    onTap: () => onQuickCompare(const [
                      'current:liberalismo_classico',
                      'current:social_democracia',
                    ]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            key: const ValueKey<String>('home-tools-actions'),
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(
                onPressed: onOpenCompare,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      p.isDark ? const Color(0xFFE5A448) : p.accent,
                  foregroundColor: p.isDark
                      ? const Color(0xFF140D03)
                      : const Color(0xFFFAF9F6),
                  elevation: 0,
                  minimumSize: const Size(0, 44),
                  maximumSize: const Size(double.infinity, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const _SafeButtonContent(
                  icon: Icons.compare_arrows_rounded,
                  iconSize: 17,
                  label: 'Comparador',
                ),
              ),
              OutlinedButton(
                onPressed: onOpenTeia,
                style: OutlinedButton.styleFrom(
                  foregroundColor: p.ink,
                  side: BorderSide(color: p.line),
                  minimumSize: const Size(0, 44),
                  maximumSize: const Size(double.infinity, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const _SafeButtonContent(
                  icon: Icons.hub_outlined,
                  iconSize: 17,
                  label: 'Teia Política',
                ),
              ),
              OutlinedButton(
                onPressed: onOpenHistory,
                style: OutlinedButton.styleFrom(
                  foregroundColor: p.inkSoft,
                  side: BorderSide(color: p.line),
                  minimumSize: const Size(0, 44),
                  maximumSize: const Size(double.infinity, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const _SafeButtonContent(
                  icon: Icons.history_rounded,
                  iconSize: 17,
                  label: 'Histórico',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickCompareChip extends StatelessWidget {
  const _QuickCompareChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surfaceMuted.withValues(alpha: p.isDark ? 0.85 : 0.75),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.compare_arrows_rounded, size: 14, color: p.accent),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: p.ink,
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

class _DraftResumeCard extends StatelessWidget {
  const _DraftResumeCard({
    required this.draft,
    required this.onResume,
    required this.onDiscard,
    this.onPreview,
  });

  final ActiveQuizDraft draft;
  final VoidCallback onResume;
  final VoidCallback onDiscard;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final TextTheme text = Theme.of(context).textTheme;
    final int total = draft.questionUids.length;
    final int done = draft.answeredOrSkippedCount;
    final double progress = total == 0 ? 0 : (done / total).clamp(0.0, 1.0);

    return SectionCard(
      padding: const EdgeInsets.all(16),
      color: p.accentSoft,
      borderColor: p.accent.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.play_circle_outline_rounded,
                size: 18,
                color: p.accent,
              ),
              const SizedBox(width: 8),
              Expanded(child: Eyebrow('SESSÃO EM ANDAMENTO', color: p.accent)),
              Text(
                '$done / $total',
                style: text.labelSmall?.copyWith(color: p.accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            draft.completingRecordId != null
                ? 'Complemento das 6 Tríades · +18 perguntas'
                : '${draft.suite.title} · ${draft.depth.label}',
            style: text.titleLarge,
          ),
          const SizedBox(height: 10),
          ProgressRail(value: progress, color: p.accent),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton(
                onPressed: onResume,
                child: const _SafeButtonContent(
                  icon: Icons.play_arrow_rounded,
                  label: 'Continuar teste',
                ),
              ),
              if (onPreview != null)
                OutlinedButton(
                  onPressed: onPreview,
                  child: const _SafeButtonContent(
                    icon: Icons.insights_rounded,
                    iconSize: 16,
                    label: 'Ver resultado até aqui',
                  ),
                ),
              TextButton(
                onPressed: onDiscard,
                child: const _SafeButtonContent(
                  icon: Icons.close_rounded,
                  iconSize: 16,
                  label: 'Descartar',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FigmaShortcutRow extends StatefulWidget {
  const _FigmaShortcutRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.topRadius = 0,
    this.bottomRadius = 0,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double topRadius;
  final double bottomRadius;

  @override
  State<_FigmaShortcutRow> createState() => _FigmaShortcutRowState();
}

class _FigmaShortcutRowState extends State<_FigmaShortcutRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    final BorderRadius radius = BorderRadius.vertical(
      top: Radius.circular(widget.topRadius),
      bottom: Radius.circular(widget.bottomRadius),
    );
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: TactilePress(
        scale: 0.99,
        child: Material(
          color: _isHovered
              ? Color.alphaBlend(
                  p.accent.withValues(alpha: p.isDark ? 0.10 : 0.05),
                  p.surface,
                )
              : Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: radius,
            hoverColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 13,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    widget.icon,
                    size: 19,
                    color: _isHovered ? p.accent : p.inkSoft,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _isHovered ? p.accent : p.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 11.5,
                            color: p.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: _isHovered ? p.accent : p.muted,
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

class _HomeFeaturedSpotlight extends StatelessWidget {
  const _HomeFeaturedSpotlight({
    required this.appViewModel,
    required this.catalog,
    required this.axesMeta,
  });

  final AppViewModel appViewModel;
  final StudyCatalog catalog;
  final List<data.Axis> axesMeta;

  static const _featuredKeys = [
    'personality:karl_marx',
    'personality:friedrich_hayek',
    'personality:hannah_arendt',
    'personality:john_maynard_keynes',
    'personality:max_weber',
    'personality:murray_rothbard',
    'personality:rosa_luxemburgo',
    'personality:adam_smith',
    'personality:john_locke',
    'personality:mikhail_bakunin',
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final List<_AxisMetaInfo> axisInfos = _resolveAxisInfos(axesMeta);
    final featuredSubjects = [
      for (final key in _featuredKeys) ?catalog.find(key),
    ];
    if (featuredSubjects.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          runSpacing: 8,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow('Destaques do observatório', color: p.accent),
                const SizedBox(height: 4),
                Text(
                  'Personalidades em Evidência',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      AtlasExplorerScreen(appViewModel: appViewModel),
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        HorizontalAffordanceStrip(
          builder: (context, controller) => SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Row(
              children: [
                for (var i = 0; i < featuredSubjects.length; i++) ...[
                  if (i > 0) const SizedBox(width: 14),
                  _SpotlightCard(
                    subject: featuredSubjects[i],
                    axisInfos: axisInfos,
                    portrait:
                        appViewModel.data.portraits[featuredSubjects[i].key],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        settings: RouteSettings(
                          name: studyProfileRoute(featuredSubjects[i].key),
                        ),
                        builder: (_) => StudyProfileScreen(
                          appViewModel: appViewModel,
                          subjectKey: featuredSubjects[i].key,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotlightCard extends StatefulWidget {
  const _SpotlightCard({
    required this.subject,
    required this.axisInfos,
    required this.onTap,
    this.portrait,
  });

  final StudySubject subject;
  final List<_AxisMetaInfo> axisInfos;
  final VoidCallback onTap;
  final StudyPortrait? portrait;

  @override
  State<_SpotlightCard> createState() => _SpotlightCardState();
}

class _SpotlightCardState extends State<_SpotlightCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final subject = widget.subject;
    final spectrum = spectrumOf(subject);
    final accentColor = spectrum?.color ?? p.accent;
    final Color accentInk = spectrum?.ink(p.isDark) ?? accentColor;
    final double scaleFactor = MediaQuery.textScalerOf(context).scale(16) / 16.0;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final double cardHeight = math.max(
      288.0,
      186.0 + scaleFactor * 102.0,
    );
    final String? assetPath = _resolvePortraitAsset(subject, widget.portrait);
    final List<_DominantAxisReading> traits = _extractDominantTraits(
      subject.axes,
      widget.axisInfos,
      limit: 1,
    );
    final _DominantAxisReading? topTrait =
        traits.isNotEmpty ? traits.first : null;

    final Widget portraitFallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: p.isDark ? 0.36 : 0.24),
            p.heroBackground,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        subject.name
            .split(' ')
            .where((s) => s.isNotEmpty)
            .take(2)
            .map((s) => s.characters.first)
            .join(),
        style: TextStyle(
          fontFamily: 'IBMPlexSans',
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: TactilePress(
        scale: 0.975,
        child: AnimatedContainer(
          duration: reduceMotion ? Duration.zero : EspectroMotion.fast,
          curve: EspectroMotion.easeOut,
          transform: (!reduceMotion && _isHovered)
              ? Matrix4.translationValues(0, -2, 0)
              : Matrix4.identity(),
          width: 224,
          height: cardHeight,
          clipBehavior: Clip.antiAlias,
          decoration: EspectroElevation.cardDecoration(
            p,
            color: _isHovered
                ? Color.alphaBlend(
                    accentColor.withValues(alpha: p.isDark ? 0.11 : 0.045),
                    p.surface,
                  )
                : p.surface,
            borderColor: _isHovered
                ? accentColor.withValues(alpha: 0.72)
                : p.line.withValues(alpha: 0.88),
            tint: _isHovered ? accentColor : p.ink,
            radius: 17,
            borderWidth: _isHovered ? 1.4 : 1.0,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(17),
              hoverColor: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 112,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRect(
                          child: AnimatedScale(
                            scale: (!reduceMotion && _isHovered) ? 1.03 : 1.0,
                            duration: reduceMotion
                                ? Duration.zero
                                : EspectroMotion.fast,
                            curve: EspectroMotion.easeOut,
                            child: assetPath != null
                                ? buildResilientAssetImage(
                                    assetPath,
                                    fit: BoxFit.cover,
                                    alignment: const Alignment(0, -0.45),
                                    fallback: portraitFallback,
                                  )
                                : portraitFallback,
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.22),
                                Colors.transparent,
                                p.surface.withValues(alpha: 0.94),
                              ],
                              stops: const [0.0, 0.56, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(height: 3.5, color: accentColor),
                        ),
                        if (spectrum != null)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.68),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.75),
                                  width: 0.9,
                                ),
                              ),
                              child: Text(
                                spectrum.name,
                                style: const TextStyle(
                                  fontFamily: 'IBMPlexSans',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 4, 13, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'IBMPlexSans',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: _isHovered ? accentInk : p.ink,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subject.subtitle,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.32,
                              color: p.inkSoft,
                            ),
                          ),
                          if (topTrait != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: topTrait.dominantColor.withValues(
                                  alpha: p.isDark ? 0.16 : 0.08,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: topTrait.dominantColor.withValues(
                                    alpha: p.isDark ? 0.36 : 0.25,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    AxisColors.iconFor(topTrait.axisId),
                                    size: 11,
                                    color: AxisColors.readableInk(
                                      topTrait.dominantColor,
                                      isDark: p.isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${topTrait.dominantPole} · ${topTrait.percent}%',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'IBMPlexSans',
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: p.ink,
                                        fontFeatures: const <FontFeature>[
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                            const Spacer(),
                            if (subject.axes.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'DNA 12 eixos',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'IBMPlexSans',
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: p.muted,
                                      ),
                                    ),
                                  ),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: _isHovered ? accentInk : p.muted,
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            TwelveAxisDnaStrip(axes: subject.axes),
                          ],
                        ],
                      ),
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

class _HomeTwelveAxesShowcase extends StatelessWidget {
  const _HomeTwelveAxesShowcase({
    required this.axesMeta,
    required this.onTapAxis,
  });

  final List<data.Axis> axesMeta;
  final VoidCallback onTapAxis;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final List<_AxisMetaInfo> axisInfos = _resolveAxisInfos(axesMeta);
    final double scale = MediaQuery.textScalerOf(context).scale(16) / 16.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Framework de análise',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: p.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Os 12 Eixos do Espectro',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: onTapAxis,
                child: const _SafeButtonContent(
                  icon: Icons.play_arrow_rounded,
                  iconSize: 16,
                  label: 'Testar eixos',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ao contrário de testes que reduzem política a esquerda versus direita, o Espectro mede 12 dimensões bipolares independentes:',
            style: TextStyle(color: p.inkSoft, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const double gap = 12;
              final int cols = scale > 1.35 || constraints.maxWidth < 460
                  ? 1
                  : (constraints.maxWidth >= 780 ? 3 : 2);
              final double itemWidth = cols == 1
                  ? constraints.maxWidth
                  : ((constraints.maxWidth - gap * (cols - 1)) / cols)
                        .floorToDouble();

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < axisInfos.length; i++)
                    SizedBox(
                      width: itemWidth,
                      child: _AxisInstrumentTile(
                        index: i + 1,
                        info: axisInfos[i],
                        onTap: onTapAxis,
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

class _AxisInstrumentTile extends StatefulWidget {
  const _AxisInstrumentTile({
    required this.index,
    required this.info,
    required this.onTap,
  });

  final int index;
  final _AxisMetaInfo info;
  final VoidCallback onTap;

  @override
  State<_AxisInstrumentTile> createState() => _AxisInstrumentTileState();
}

class _AxisInstrumentTileState extends State<_AxisInstrumentTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final info = widget.info;
    final String idxText = widget.index.toString().padLeft(2, '0');
    final AxisColorStrategy colorStrategy = AxisColorStrategyScope.of(context);
    final bool primaryMode = colorStrategy == AxisColorStrategy.primaryAnchor;
    final Color anchorColor = AxisColors.primaryFor(info.id, p);
    final Color leftDisplayColor = primaryMode ? anchorColor : info.leftColor;
    final Color rightDisplayColor = primaryMode
        ? p.muted.withValues(alpha: p.isDark ? 0.50 : 0.42)
        : info.rightColor;
    final Color leftInk = AxisColors.readableInk(
      leftDisplayColor,
      isDark: p.isDark,
    );
    final Color rightInk = primaryMode
        ? p.inkSoft
        : AxisColors.readableInk(info.rightColor, isDark: p.isDark);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: '${info.label}: ${info.leftPole} ⟷ ${info.rightPole}',
        child: TactilePress(
          scale: 0.98,
          child: AnimatedContainer(
            duration: EspectroMotion.fast,
            curve: EspectroMotion.easeOut,
            decoration: BoxDecoration(
              color: _hovered
                  ? Color.alphaBlend(
                      leftDisplayColor.withValues(alpha: p.isDark ? 0.14 : 0.08),
                      p.surface,
                    )
                  : p.surfaceMuted.withValues(alpha: p.isDark ? 0.58 : 0.68),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hovered
                    ? leftInk.withValues(alpha: 0.65)
                    : leftDisplayColor.withValues(
                        alpha: p.isDark ? 0.28 : 0.22,
                      ),
                width: 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 11,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            AxisColors.iconFor(info.id),
                            size: 13,
                            color: leftInk,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            idxText,
                            style: TextStyle(
                              fontFamily: 'IBMPlexMono',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: p.muted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              info.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'IBMPlexSans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: p.ink,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_outward_rounded,
                            size: 13,
                            color: _hovered ? leftInk : p.muted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              info.leftPole,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'IBMPlexMono',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: leftInk,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              info.rightPole,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontFamily: 'IBMPlexMono',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: rightInk,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ColoredBox(
                                  color: leftDisplayColor.withValues(
                                    alpha: p.isDark ? 0.90 : 0.85,
                                  ),
                                ),
                              ),
                              Container(
                                width: 2.5,
                                color: p.surface,
                              ),
                              Expanded(
                                child: ColoredBox(
                                  color: rightDisplayColor.withValues(
                                    alpha: primaryMode
                                        ? 1.0
                                        : (p.isDark ? 0.90 : 0.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}

/// Carrossel editorial na Home destacando 1 cartão compartilhável grande por
/// vez entre 4 pensadores clássicos, com alternância Post 1:1 / Story 9:16.
class _HeroLiveSpectrumShowcase extends StatefulWidget {
  const _HeroLiveSpectrumShowcase({
    required this.catalog,
    required this.portraits,
    required this.axesMeta,
    required this.compact,
    required this.onStartQuiz,
    required this.onOpenSubject,
    this.latestRecord,
    this.onOpenShareSheet,
  });

  final StudyCatalog catalog;
  final Map<String, StudyPortrait> portraits;
  final List<data.Axis> axesMeta;
  final bool compact;
  final VoidCallback onStartQuiz;
  final void Function(String key) onOpenSubject;
  final EvaluationRecord? latestRecord;
  final VoidCallback? onOpenShareSheet;

  @override
  State<_HeroLiveSpectrumShowcase> createState() =>
      _HeroLiveSpectrumShowcaseState();
}

class _HeroLiveSpectrumShowcaseState extends State<_HeroLiveSpectrumShowcase> {
  static const List<(String key, String label)> _presets = [
    ('personality:hannah_arendt', 'Hannah Arendt'),
    ('personality:karl_marx', 'Karl Marx'),
    ('personality:murray_rothbard', 'Murray Rothbard'),
    ('personality:john_maynard_keynes', 'John Maynard Keynes'),
  ];

  int _selected = 0;
  int _direction = 1;
  bool _previewStory = false;
  bool _hovered = false;
  bool _focused = false;
  bool _userPaused = false;
  bool _timerStarted = false;
  Timer? _autoTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_timerStarted) {
      _timerStarted = true;
      _scheduleAutoAdvance();
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _autoTimer = null;
    super.dispose();
  }

  void _scheduleAutoAdvance() {
    _autoTimer?.cancel();
    _autoTimer = null;
    if (!mounted || _userPaused || _hovered || _focused) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    _autoTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || _userPaused || _hovered || _focused) return;
      setState(() {
        _direction = 1;
        _selected = (_selected + 1) % _presets.length;
      });
      _scheduleAutoAdvance();
    });
  }

  void _step(int delta, int count) {
    if (count <= 1) return;
    setState(() {
      _direction = delta >= 0 ? 1 : -1;
      _selected = (_selected + delta + count) % count;
    });
    _scheduleAutoAdvance();
  }

  void _jumpTo(int index) {
    if (index == _selected) return;
    setState(() {
      _direction = index > _selected ? 1 : -1;
      _selected = index;
    });
    _scheduleAutoAdvance();
  }

  void _togglePause() {
    setState(() => _userPaused = !_userPaused);
    if (_userPaused) {
      _autoTimer?.cancel();
      _autoTimer = null;
    } else {
      _scheduleAutoAdvance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final List<(StudySubject subject, String label)> exemplars = [
      for (final (String key, String label) in _presets)
        if (widget.catalog.find(key) case final StudySubject s) (s, label),
    ];
    if (exemplars.isEmpty) return const SizedBox.shrink();

    final int count = exemplars.length;
    final int safeIndex = _selected.clamp(0, count - 1);
    final StudySubject subject = exemplars[safeIndex].$1;
    final String activeLabel = exemplars[safeIndex].$2;
    final StudySpectrum? spectrum = spectrumOf(subject);
    final Color activeInk = spectrum?.ink(p.isDark) ?? p.accent;
    final Color activeDot = spectrum?.color ?? p.accent;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final double scale = MediaQuery.textScalerOf(context).scale(16) / 16.0;
    final bool compactLayout = widget.compact || scale > 1.35;
    final String cardKey = '${subject.key}:$_previewStory';

    Widget formatPill(bool isStory, String label) {
      final bool active = _previewStory == isStory;
      final Color toggleAccent =
          p.isDark ? const Color(0xFFE5A64B) : p.accent;
      return InkWell(
        onTap: () => setState(() => _previewStory = isStory),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? toggleAccent.withValues(alpha: p.isDark ? 0.18 : 0.10)
                : p.surfaceMuted.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? toggleAccent : p.line,
              width: active ? 1.25 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active ? p.ink : p.inkSoft,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget navCircleButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback onPressed,
    }) {
      return Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.surfaceMuted.withValues(alpha: p.isDark ? 0.72 : 0.85),
              shape: BoxShape.circle,
              border: Border.all(color: p.line),
            ),
            child: Icon(icon, size: 22, color: p.ink),
          ),
        ),
      );
    }

    final Widget specimenCard = HomeShareCardSpecimen(
      subject: subject,
      portrait: widget.portraits[subject.key],
      axesMeta: widget.axesMeta,
      storyFormat: _previewStory,
      compact: false,
      badgeLabel: _previewStory ? 'Story 9:16' : 'Post 1:1',
      footerCtaLabel:
          widget.latestRecord != null ? 'Abrir meu cartão' : 'Gerar meu cartão',
      onTapCard: () => widget.onOpenSubject(subject.key),
      onPrimaryAction:
          widget.latestRecord != null && widget.onOpenShareSheet != null
          ? widget.onOpenShareSheet
          : widget.onStartQuiz,
    );

    final Widget animatedSpecimen = AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 260),
      switchInCurve: EspectroMotion.easeOut,
      switchOutCurve: EspectroMotion.easeOut,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        if (reduceMotion) return child;
        final bool isIncoming = child.key == ValueKey<String>(cardKey);
        final Offset begin = isIncoming
            ? Offset(0.06 * _direction, 0)
            : Offset(-0.04 * _direction, 0);
        final Animation<Offset> slide = Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<String>(cardKey),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _previewStory ? 300 : 400,
          ),
          child: specimenCard,
        ),
      ),
    );

    final Widget dotsRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < count; i++)
          () {
            final bool isActive = i == safeIndex;
            final Color itemColor =
                spectrumOf(exemplars[i].$1)?.color ?? activeDot;
            return Tooltip(
              message: exemplars[i].$2,
              child: InkWell(
                onTap: () => _jumpTo(i),
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  width: isActive ? 34 : 28,
                  height: 44,
                  child: Center(
                    child: AnimatedContainer(
                      duration: reduceMotion
                          ? Duration.zero
                          : EspectroMotion.fast,
                      width: isActive ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? itemColor
                            : p.line.withValues(alpha: p.isDark ? 0.85 : 0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }(),
      ],
    );

    return MouseRegion(
      onEnter: (_) {
        _hovered = true;
        _autoTimer?.cancel();
        _autoTimer = null;
      },
      onExit: (_) {
        _hovered = false;
        _scheduleAutoAdvance();
      },
      child: Focus(
        onFocusChange: (bool hasFocus) {
          _focused = hasFocus;
          if (hasFocus) {
            _autoTimer?.cancel();
            _autoTimer = null;
          } else {
            _scheduleAutoAdvance();
          }
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(
            compactLayout ? 16 : 28,
            compactLayout ? 18 : 24,
            compactLayout ? 16 : 28,
            compactLayout ? 16 : 22,
          ),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: p.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  Text(
                    'Veja como fica o seu cartão',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.35,
                      color: p.ink,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      formatPill(false, 'Post 1:1'),
                      formatPill(true, 'Story 9:16'),
                      Tooltip(
                        message: _userPaused
                            ? 'Retomar carrossel'
                            : 'Pausar carrossel',
                        child: InkWell(
                          onTap: _togglePause,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 44,
                            height: 36,
                            decoration: BoxDecoration(
                              color: p.surfaceMuted.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: p.line),
                            ),
                            child: Icon(
                              _userPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              size: 18,
                              color: p.inkSoft,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: compactLayout ? 18 : 26),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints stageBox) {
                  final double cardMaxW = _previewStory ? 300 : 400;
                  final bool sideNav =
                      stageBox.maxWidth >= cardMaxW + 128 && scale <= 1.35;
                  final Widget cardFrame = Center(child: animatedSpecimen);
                  if (!sideNav) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        cardFrame,
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            navCircleButton(
                              icon: Icons.chevron_left_rounded,
                              tooltip: 'Exemplar anterior',
                              onPressed: () => _step(-1, count),
                            ),
                            const SizedBox(width: 8),
                            dotsRow,
                            const SizedBox(width: 8),
                            navCircleButton(
                              icon: Icons.chevron_right_rounded,
                              tooltip: 'Próximo exemplar',
                              onPressed: () => _step(1, count),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          navCircleButton(
                            icon: Icons.chevron_left_rounded,
                            tooltip: 'Exemplar anterior',
                            onPressed: () => _step(-1, count),
                          ),
                          const SizedBox(width: 24),
                          Flexible(child: cardFrame),
                          const SizedBox(width: 24),
                          navCircleButton(
                            icon: Icons.chevron_right_rounded,
                            tooltip: 'Próximo exemplar',
                            onPressed: () => _step(1, count),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      dotsRow,
                    ],
                  );
                },
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '$activeLabel · ${safeIndex + 1}/$count',
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: activeInk,
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
