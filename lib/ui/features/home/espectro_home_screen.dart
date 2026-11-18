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
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/espectro_brand_mark.dart';
import '../../../widgets/espectro_scaffold.dart';
import '../quiz/espectro_suites_screen.dart';
import '../../ads/espectro_ad_units.dart';
import '../../ads/espectro_banner_ad.dart';
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
            maxWidth: wide ? 1040 : 760,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool twoColBento = constraints.maxWidth >= 820;

                final Widget toolsBentoCard = _ObservatoryToolsCard(
                  onOpenTeia: () => _openAtlas(context, initialMap: true),
                  onOpenCompare: () => _openComparison(context),
                  onQuickCompare: (List<String> keys) =>
                      _openComparison(context, initialKeys: keys),
                );

                final Widget shortcutsGroup = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Eyebrow('Acesso direto', color: p.accent),
                    ),
                    const SizedBox(height: 12),
                    SectionCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _FigmaShortcutRow(
                            icon: Icons.tune_rounded,
                            iconBg: p.accentSoft,
                            iconColor: p.accent,
                            title: '12 EIXOS',
                            subtitle: 'Federalismo, economia, cultura e poder',
                            topRadius: 17,
                            onTap: () =>
                                _openSuite(context, TestSuite.bipolarAxes),
                          ),
                          Divider(
                            height: 1,
                            color: p.line.withValues(alpha: 0.7),
                          ),
                          _FigmaShortcutRow(
                            icon: Icons.change_history_rounded,
                            iconBg: p.isDark
                                ? p.surfaceMuted
                                : const Color(0xFFFFF0D7),
                            iconColor: p.warning,
                            title: '6 TRÍADES',
                            subtitle: 'Arenas baricêntricas com 3 vértices',
                            onTap: () => _openSuite(context, TestSuite.triads),
                          ),
                          Divider(
                            height: 1,
                            color: p.line.withValues(alpha: 0.7),
                          ),
                          _FigmaShortcutRow(
                            icon: Icons.history_rounded,
                            iconBg: p.accentSoft,
                            iconColor: p.accent,
                            title: 'HISTÓRICO',
                            subtitle: 'Compare avaliações ao longo do tempo',
                            bottomRadius: 17,
                            onTap: () => _openHistory(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final EvaluationRecord? latestRecord =
                    appViewModel.history.isNotEmpty
                    ? appViewModel.history.first
                    : null;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          if (!wide) ...<Widget>[
                            const EspectroBrandMark(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ESPECTRO',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: p.ink,
                                    ),
                                  ),
                                  Text(
                                    'Observatório político',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: p.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...<Widget>[
                            Expanded(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Eyebrow(
                                    'OBSERVATÓRIO POLÍTICO · OFFLINE',
                                    color: p.accent,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: p.surfaceMuted.withValues(
                                        alpha: 0.7,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: p.line),
                                    ),
                                    child: Text(
                                      '${appViewModel.data.catalog.currents.length} correntes · ${catalog.subjects.where((s) => s.kind != 'evaluation').length} perfis',
                                      style: TextStyle(
                                        fontFamily: 'IBMPlexMono',
                                        fontSize: 10,
                                        color: p.muted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (wide) ...[
                            TextButton.icon(
                              onPressed: () =>
                                  _openAtlas(context, initialMap: true),
                              icon: const Icon(Icons.hub_outlined, size: 17),
                              label: const Text('Abrir Teia'),
                            ),
                            const SizedBox(width: 4),
                          ],
                          IconButton(
                            icon: const Icon(Icons.science_outlined, size: 20),
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
                    if (draft != null) ...[
                      _DraftResumeCard(
                        draft: draft,
                        onResume: () => _resumeDraft(context, draft),
                        onDiscard: () => appViewModel.discardActiveDraft(),
                        onPreview: draft.answeredOrSkippedCount >= 4
                            ? () => _openDraftPreview(context, draft)
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _ObservatoryCoverHero(
                      totalProfiles: catalog.subjects
                          .where((s) => s.kind != 'evaluation')
                          .length,
                      totalCurrents: appViewModel.data.catalog.currents.length,
                      twoColumn: twoColBento,
                      onStartQuiz: () => _openSuites(context),
                      onOpenAtlas: () => _openAtlas(context),
                      showcase: _HeroLiveSpectrumShowcase(
                        catalog: catalog,
                        portraits: appViewModel.data.portraits,
                        axesMeta: appViewModel.data.twelveAxes.axes,
                        compact: !twoColBento,
                        onStartQuiz: () => _openSuites(context),
                        onOpenSubject: (String key) =>
                            _openSubject(context, key),
                      ),
                    ),
                    if (latestRecord != null) ...[
                      const SizedBox(height: 18),
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
                    const SizedBox(height: 24),
                    _HomeFeaturedSpotlight(
                      appViewModel: appViewModel,
                      catalog: catalog,
                      axesMeta: appViewModel.data.twelveAxes.axes,
                    ),
                    if (twoColBento) ...[
                      const SizedBox(height: 22),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 6, child: toolsBentoCard),
                            const SizedBox(width: 18),
                            Expanded(flex: 5, child: shortcutsGroup),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 20),
                      toolsBentoCard,
                      const SizedBox(height: 22),
                      shortcutsGroup,
                    ],
                    const SizedBox(height: 24),
                    _HomeTwelveAxesShowcase(
                      axesMeta: appViewModel.data.twelveAxes.axes,
                      onTapAxis: () =>
                          _openSuite(context, TestSuite.bipolarAxes),
                    ),
                    if (recent.isNotEmpty || saved.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Eyebrow('SUA BIBLIOTECA', color: p.accent),
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
                    EspectroBannerAdWidget(
                      adUnitId: EspectroAdUnits.atlasBannerId,
                      padding: const EdgeInsets.only(top: 18),
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
    leftPole: 'Liberdade',
    rightPole: 'Segurança',
    leftColor: Color(0xFFAD7A06),
    rightColor: Color(0xFF3C5A80),
  ),
  _AxisMetaInfo(
    id: 'imigracao',
    label: 'Imigração',
    leftPole: 'Aberta',
    rightPole: 'Restrita',
    leftColor: Color(0xFF6A45C0),
    rightColor: Color(0xFFCC3456),
  ),
  _AxisMetaInfo(
    id: 'diplomacia',
    label: 'Diplomacia',
    leftPole: 'Pacifista',
    rightPole: 'Militarista',
    leftColor: Color(0xFF2D86C8),
    rightColor: Color(0xFF6A8425),
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
    rightPole: 'Mercado',
    leftColor: Color(0xFF8A3AA0),
    rightColor: Color(0xFF1A8A56),
  ),
  _AxisMetaInfo(
    id: 'comercio',
    label: 'Comércio',
    leftPole: 'Protecionismo',
    rightPole: 'Livre-comércio',
    leftColor: Color(0xFF9C5E2A),
    rightColor: Color(0xFF0E86B0),
  ),
  _AxisMetaInfo(
    id: 'religiao',
    label: 'Religião',
    leftPole: 'Laicismo',
    rightPole: 'Confessional',
    leftColor: Color(0xFFC65E0E),
    rightColor: Color(0xFF3B50B5),
  ),
  _AxisMetaInfo(
    id: 'moral',
    label: 'Moral',
    leftPole: 'Progressista',
    rightPole: 'Tradicional',
    leftColor: Color(0xFFD23E84),
    rightColor: Color(0xFF74502C),
  ),
  _AxisMetaInfo(
    id: 'tecnologia',
    label: 'Tecnologia',
    leftPole: 'Aceleração',
    rightPole: 'Precaução',
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

class _SubjectAvatarMini extends StatelessWidget {
  const _SubjectAvatarMini({
    required this.subject,
    required this.accent,
    this.portrait,
    this.size = 20,
  });

  final StudySubject subject;
  final StudyPortrait? portrait;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final String? assetPath = _resolvePortraitAsset(subject, portrait);
    final String initials = subject.name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s.characters.first.toUpperCase())
        .join();
    final Widget fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: p.isDark ? 0.28 : 0.16),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'IBMPlexMono',
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: p.ink,
        ),
      ),
    );
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: assetPath != null
            ? Image.asset(
                assetPath,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.45),
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => fallback,
              )
            : fallback,
      ),
    );
  }
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

class _ObservatoryCoverHero extends StatelessWidget {
  const _ObservatoryCoverHero({
    required this.totalProfiles,
    required this.totalCurrents,
    required this.twoColumn,
    required this.onStartQuiz,
    required this.onOpenAtlas,
    required this.showcase,
  });

  final int totalProfiles;
  final int totalCurrents;
  final bool twoColumn;
  final VoidCallback onStartQuiz;
  final VoidCallback onOpenAtlas;
  final Widget showcase;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final double scale = MediaQuery.textScalerOf(context).scale(16) / 16.0;
    final Color surfaceBase = p.isDark ? p.heroBackground : p.surface;
    final Color borderColor = p.isDark
        ? Colors.white.withValues(alpha: 0.13)
        : p.line;

    final Widget thesisColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: p.accent.withValues(alpha: p.isDark ? 0.16 : 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: p.accent.withValues(alpha: p.isDark ? 0.36 : 0.22),
            ),
          ),
          child: Wrap(
            spacing: 7,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: p.accent,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                'OBSERVATÓRIO POLÍTICO MULTIDIMENSIONAL',
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.45,
                  color: p.accent,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: twoColumn ? 16 : 12),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontFamily: 'IBMPlexSans',
              fontSize: twoColumn ? 32 : 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.75,
              height: 1.12,
              color: p.ink,
            ),
            children: [
              const TextSpan(text: 'Onde você realmente se situa '),
              TextSpan(
                text: 'além dos rótulos?',
                style: TextStyle(color: p.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Mapeie suas posições em 12 eixos independentes e 6 tríades históricas '
          'e descubra afinidades reais com correntes, pensadores e figuras públicas.',
          style: TextStyle(
            fontSize: twoColumn ? 14.5 : 13.5,
            height: 1.46,
            color: p.inkSoft,
          ),
        ),
        SizedBox(height: twoColumn ? 20 : 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton(
              onPressed: onStartQuiz,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                textStyle: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const _SafeButtonContent(
                icon: Icons.arrow_forward_rounded,
                label: 'Começar minha avaliação',
              ),
            ),
            OutlinedButton(
              onPressed: onOpenAtlas,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                side: BorderSide(color: p.line),
                foregroundColor: p.ink,
                textStyle: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const _SafeButtonContent(
                icon: Icons.hub_outlined,
                label: 'Explorar o Atlas',
              ),
            ),
          ],
        ),
        SizedBox(height: twoColumn ? 20 : 14),
        Divider(height: 1, color: p.line.withValues(alpha: 0.75)),
        SizedBox(height: twoColumn ? 14 : 12),
        Wrap(
          spacing: scale > 1.35 ? 16 : (twoColumn ? 26 : 18),
          runSpacing: 10,
          children: [
            const _HeroMetricTile(value: '12 + 6', label: 'Eixos & tríades'),
            _HeroMetricTile(
              value: '$totalCurrents',
              label: 'Correntes',
            ),
            _HeroMetricTile(
              value: '$totalProfiles',
              label: 'Perfis no Atlas',
            ),
          ],
        ),
      ],
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surfaceBase,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: EspectroElevation.cardShadows(p, elevated: true),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: p.isDark
              ? [
                  Color.alphaBlend(
                    p.accent.withValues(alpha: 0.11),
                    p.heroBackground,
                  ),
                  p.heroBackground,
                  Color.alphaBlend(
                    p.poleRight.withValues(alpha: 0.08),
                    p.heroBackground,
                  ),
                ]
              : [
                  Color.alphaBlend(
                    p.accent.withValues(alpha: 0.045),
                    p.surface,
                  ),
                  p.surface,
                  Color.alphaBlend(
                    p.poleRight.withValues(alpha: 0.035),
                    p.surface,
                  ),
                ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SpectrumGradientRule(height: 3.0, radius: 0),
          Padding(
            padding: EdgeInsets.all(twoColumn ? 26 : 16),
            child: twoColumn
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 7, child: thesisColumn),
                      const SizedBox(width: 24),
                      Expanded(flex: 6, child: showcase),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      thesisColumn,
                      const SizedBox(height: 20),
                      showcase,
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IBMPlexMono',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: p.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: p.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

    return SectionCard(
      padding: EdgeInsets.zero,
      borderColor: accentColor.withValues(alpha: p.isDark ? 0.36 : 0.28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 3.5, color: accentColor),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      Eyebrow('SEU ÚLTIMO RETRATO', color: accentInk),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
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
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: p.ink,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topMatch != null
                                  ? topMatch.current.summary
                                  : '${record.quality.totalAnswered} respostas registradas ($coveragePct% cobertura).',
                              maxLines: 2,
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
                            color: accentColor.withValues(
                              alpha: p.isDark ? 0.18 : 0.10,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${topMatch.compatibilityPercent.round()}%',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: accentInk,
                                ),
                              ),
                              Text(
                                'afinidade',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: p.muted,
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
                  ],
                  const SizedBox(height: 14),
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
                          label:
                              'Ver histórico (${appViewModel.history.length})',
                        ),
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
  }
}

class _ObservatoryToolsCard extends StatelessWidget {
  const _ObservatoryToolsCard({
    required this.onOpenTeia,
    required this.onOpenCompare,
    required this.onQuickCompare,
  });

  final VoidCallback onOpenTeia;
  final VoidCallback onOpenCompare;
  final ValueChanged<List<String>> onQuickCompare;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SectionCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 104,
              width: double.infinity,
              decoration: BoxDecoration(
                color: p.isDark
                    ? Color.alphaBlend(
                        p.accent.withValues(alpha: 0.12),
                        p.heroBackground,
                      )
                    : Color.alphaBlend(
                        p.accent.withValues(alpha: 0.06),
                        p.surfaceMuted,
                      ),
                border: Border(
                  bottom: BorderSide(color: p.line.withValues(alpha: 0.8)),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _MiniConstellationPreviewPainter(
                      isDark: p.isDark,
                      accent: p.accent,
                      lineColor: p.line,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: p.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: p.line),
                      ),
                      child: Text(
                        'TEIA & CONFRONTO',
                        style: TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: p.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navegue pela Teia ou confronte perfis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Visualize proximidades entre 8 famílias políticas ou coloque dois perfis lado a lado com Raio-X matemático.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.42,
                      color: p.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Duelos prontos',
                    style: TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 10.5,
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
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: onOpenTeia,
                        child: const _SafeButtonContent(
                          icon: Icons.hub_outlined,
                          iconSize: 17,
                          label: 'Abrir Teia Política',
                        ),
                      ),
                      OutlinedButton(
                        onPressed: onOpenCompare,
                        child: const _SafeButtonContent(
                          icon: Icons.compare_arrows_rounded,
                          iconSize: 17,
                          label: 'Comparador',
                        ),
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
      color: p.surfaceMuted.withValues(alpha: p.isDark ? 0.85 : 0.72),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: p.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, size: 14, color: p.accent),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 11.5,
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

class _MiniConstellationPreviewPainter extends CustomPainter {
  const _MiniConstellationPreviewPainter({
    required this.isDark,
    required this.accent,
    required this.lineColor,
  });

  final bool isDark;
  final Color accent;
  final Color lineColor;

  static const List<(double x, double y, Color color)> _nodes = [
    (0.18, 0.34, Color(0xFFD6373E)),
    (0.28, 0.62, Color(0xFFC75D70)),
    (0.42, 0.28, Color(0xFF30343A)),
    (0.50, 0.54, Color(0xFF718096)),
    (0.64, 0.36, Color(0xFF2B79B7)),
    (0.76, 0.66, Color(0xFFF2C534)),
    (0.86, 0.30, Color(0xFF81533E)),
    (0.36, 0.78, Color(0xFF0E7C58)),
    (0.62, 0.78, Color(0xFF1A4FD6)),
    (0.10, 0.74, Color(0xFFC75D70)),
  ];

  static const List<(int a, int b)> _edges = [
    (0, 1),
    (0, 2),
    (1, 3),
    (1, 7),
    (1, 9),
    (2, 3),
    (3, 4),
    (3, 8),
    (4, 5),
    (4, 6),
    (5, 8),
    (7, 8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = lineColor.withValues(alpha: isDark ? 0.35 : 0.65)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height * 0.52),
      Offset(size.width, size.height * 0.52),
      gridPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.50, 0),
      Offset(size.width * 0.50, size.height),
      gridPaint,
    );

    final Paint edgePaint = Paint()
      ..color = accent.withValues(alpha: isDark ? 0.28 : 0.22)
      ..strokeWidth = 1.25;
    for (final (int a, int b) in _edges) {
      final pA = Offset(_nodes[a].$1 * size.width, _nodes[a].$2 * size.height);
      final pB = Offset(_nodes[b].$1 * size.width, _nodes[b].$2 * size.height);
      canvas.drawLine(pA, pB, edgePaint);
    }

    for (var i = 0; i < _nodes.length; i++) {
      final (double nx, double ny, Color col) = _nodes[i];
      final Offset center = Offset(nx * size.width, ny * size.height);
      final double r = i == 3 || i == 4 || i == 1 ? 6.5 : 4.8;
      canvas.drawCircle(center, r + 4, Paint()..color = col.withValues(alpha: 0.16));
      canvas.drawCircle(center, r, Paint()..color = col);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = isDark ? Colors.white.withValues(alpha: 0.65) : Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniConstellationPreviewPainter oldDelegate) =>
      oldDelegate.isDark != isDark ||
      oldDelegate.accent != accent ||
      oldDelegate.lineColor != lineColor;
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
              Expanded(child: Eyebrow('Sessão em andamento', color: p.accent)),
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
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      widget.icon,
                      size: 19,
                      color: widget.iconColor,
                    ),
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
                Eyebrow('DESTAQUES DO OBSERVATÓRIO', color: p.accent),
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
    final double cardHeight = math.max(
      274.0,
      182.0 + scaleFactor * 92.0,
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
          duration: EspectroMotion.fast,
          curve: EspectroMotion.easeOut,
          width: 216,
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
                        if (assetPath != null)
                          Image.asset(
                            assetPath,
                            fit: BoxFit.cover,
                            alignment: const Alignment(0, -0.45),
                            excludeFromSemantics: true,
                            errorBuilder: (_, _, _) => portraitFallback,
                          )
                        else
                          portraitFallback,
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
                                spectrum.name.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
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
                            maxLines: 2,
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
                              ),
                              child: Text(
                                '${topTrait.axisLabel}: ${topTrait.dominantPole} ${topTrait.percent}%',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'IBMPlexMono',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: p.ink,
                                ),
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
                                    'DNA 12 EIXOS',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexMono',
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
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

    return SectionCard(
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
                  Eyebrow('FRAMEWORK DE ANÁLISE', color: p.accent),
                  const SizedBox(height: 6),
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
              const double gap = 10;
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
                      info.leftColor.withValues(alpha: p.isDark ? 0.14 : 0.06),
                      p.surface,
                    )
                  : p.surfaceMuted.withValues(alpha: p.isDark ? 0.65 : 0.55),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hovered
                    ? info.leftColor.withValues(alpha: 0.55)
                    : p.line,
                width: _hovered ? 1.2 : 1.0,
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
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
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
                            color: _hovered ? p.accent : p.muted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              info.leftPole,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'IBMPlexMono',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: p.inkSoft,
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
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: p.inkSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Row(
                            children: [
                              Expanded(
                                child: ColoredBox(color: info.leftColor),
                              ),
                              Container(
                                width: 2,
                                color: p.surface,
                              ),
                              Expanded(
                                child: ColoredBox(color: info.rightColor),
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

/// Prévia interativa dentro do Hero mostrando como o motor mapeia perfis reais
/// em 12 eixos, dando ao visitante uma amostra tangível antes de iniciar o teste.
class _HeroLiveSpectrumShowcase extends StatefulWidget {
  const _HeroLiveSpectrumShowcase({
    required this.catalog,
    required this.portraits,
    required this.axesMeta,
    required this.compact,
    required this.onStartQuiz,
    required this.onOpenSubject,
  });

  final StudyCatalog catalog;
  final Map<String, StudyPortrait> portraits;
  final List<data.Axis> axesMeta;
  final bool compact;
  final VoidCallback onStartQuiz;
  final void Function(String key) onOpenSubject;

  @override
  State<_HeroLiveSpectrumShowcase> createState() =>
      _HeroLiveSpectrumShowcaseState();
}

class _HeroLiveSpectrumShowcaseState extends State<_HeroLiveSpectrumShowcase> {
  static const List<(String key, String shortName)> _presets = [
    ('personality:hannah_arendt', 'Arendt'),
    ('personality:karl_marx', 'Marx'),
    ('personality:murray_rothbard', 'Rothbard'),
  ];

  static const List<(String id, String label)> _radarAxes = [
    ('estrutura', 'EST'),
    ('representacao', 'REP'),
    ('poder', 'POD'),
    ('imigracao', 'IMI'),
    ('diplomacia', 'DIP'),
    ('intervencao', 'INT'),
    ('economia', 'ECO'),
    ('controle', 'CON'),
    ('comercio', 'COM'),
    ('religiao', 'REL'),
    ('moral', 'MOR'),
    ('tecnologia', 'TEC'),
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final List<StudySubject> subjects = [
      for (final (key, _) in _presets) ?widget.catalog.find(key),
    ];
    if (subjects.isEmpty) return const SizedBox.shrink();
    final int safeIndex = _selected.clamp(0, subjects.length - 1);
    final StudySubject subject = subjects[safeIndex];
    final StudySpectrum? spectrum = spectrumOf(subject);
    final Color accent = spectrum?.color ?? p.accent;
    final Color accentInk = spectrum?.ink(p.isDark) ?? accent;
    final double scale = MediaQuery.textScalerOf(context).scale(16) / 16.0;
    final bool compactView = widget.compact || scale > 1.35;

    final List<_AxisMetaInfo> axisInfos = _resolveAxisInfos(widget.axesMeta);
    final List<_DominantAxisReading> topTraits = _extractDominantTraits(
      subject.axes,
      axisInfos,
      limit: 2,
    );

    final List<double> values = [
      for (final (id, _) in _radarAxes)
        ((subject.axes[id] ?? 0.0).clamp(-1.0, 1.0) + 1.0) / 2.0,
    ];

    final Color panelBg = p.isDark
        ? Color.alphaBlend(
            accent.withValues(alpha: 0.08),
            const Color(0xFF0A0F1A),
          )
        : Color.alphaBlend(
            accent.withValues(alpha: 0.03),
            const Color(0xFFF7F4EC),
          );
    final Color panelBorder = p.isDark
        ? Colors.white.withValues(alpha: 0.14)
        : p.line;

    final Widget switcherPills = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (int i = 0; i < subjects.length; i++)
          () {
            final bool isActive = i == safeIndex;
            final Color itemColor =
                spectrumOf(subjects[i])?.color ?? p.accent;
            final Color itemInk =
                spectrumOf(subjects[i])?.ink(p.isDark) ?? itemColor;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selected = i),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: EspectroMotion.fast,
                  curve: EspectroMotion.easeOut,
                  padding: const EdgeInsets.fromLTRB(5, 4, 10, 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? itemColor.withValues(alpha: p.isDark ? 0.24 : 0.13)
                        : p.surface.withValues(alpha: p.isDark ? 0.08 : 0.85),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isActive
                          ? itemColor.withValues(alpha: 0.85)
                          : panelBorder,
                      width: isActive ? 1.3 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SubjectAvatarMini(
                        subject: subjects[i],
                        portrait: widget.portraits[subjects[i].key],
                        accent: itemColor,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _presets[i].$2,
                          style: TextStyle(
                            fontFamily: 'IBMPlexSans',
                            fontSize: 11.5,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w600,
                            color: isActive
                                ? (p.isDark ? Colors.white : itemInk)
                                : p.inkSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }(),
      ],
    );

    final double radarSize = compactView ? 128 : 154;
    final Widget radarWidget = SizedBox(
      width: radarSize,
      height: radarSize,
      child: CustomPaint(
        painter: _HeroMiniRadarPainter(
          values: values,
          accent: accent,
          showLabels: scale <= 1.35,
          labels: [for (final (_, lbl) in _radarAxes) lbl],
          gridColor: p.isDark
              ? Colors.white.withValues(alpha: 0.14)
              : p.ink.withValues(alpha: 0.12),
          labelColor: p.muted,
          centerDotColor: p.isDark ? Colors.white : p.surface,
        ),
      ),
    );

    final Widget subjectDetails = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => widget.onOpenSubject(subject.key),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              subject.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: p.ink,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subject.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            height: 1.32,
            color: p.inkSoft,
          ),
        ),
        if (topTraits.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (var j = 0; j < topTraits.length; j++) ...[
            if (j > 0) const SizedBox(height: 7),
            _ShowcaseTraitBar(trait: topTraits[j]),
          ],
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            InkWell(
              onTap: () => widget.onOpenSubject(subject.key),
              borderRadius: BorderRadius.circular(6),
              child: Text(
                'Ver ficha',
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: p.inkSoft,
                ),
              ),
            ),
            InkWell(
              onTap: widget.onStartQuiz,
              borderRadius: BorderRadius.circular(6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Veja o seu mapa',
                      style: TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: p.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: p.accent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(compactView ? 14 : 18),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                'PRÉVIA EM 12 EIXOS',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: p.accent,
                  letterSpacing: 0.7,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: p.isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: accent.withValues(alpha: 0.55)),
                ),
                child: Text(
                  spectrum?.name.toUpperCase() ?? 'ESPECTRO',
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: accentInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          switcherPills,
          const SizedBox(height: 14),
          if (compactView)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: radarWidget),
                const SizedBox(height: 12),
                subjectDetails,
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                radarWidget,
                const SizedBox(width: 16),
                Expanded(child: subjectDetails),
              ],
            ),
        ],
      ),
    );
  }
}

class _ShowcaseTraitBar extends StatelessWidget {
  const _ShowcaseTraitBar({required this.trait});

  final _DominantAxisReading trait;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${trait.axisLabel} · ${trait.dominantPole}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: p.ink,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${trait.percent}%',
              style: TextStyle(
                fontFamily: 'IBMPlexMono',
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: p.inkSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: p.line.withValues(alpha: p.isDark ? 0.55 : 0.75),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (trait.percent / 100.0).clamp(0.5, 1.0),
                  child: ColoredBox(color: trait.dominantColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroMiniRadarPainter extends CustomPainter {
  const _HeroMiniRadarPainter({
    required this.values,
    required this.accent,
    required this.showLabels,
    required this.labels,
    required this.gridColor,
    required this.labelColor,
    required this.centerDotColor,
  });

  final List<double> values;
  final Color accent;
  final bool showLabels;
  final List<String> labels;
  final Color gridColor;
  final Color labelColor;
  final Color centerDotColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxR = size.shortestSide / 2 - (showLabels ? 18 : 6);
    if (maxR <= 6) return;

    final Paint ringPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    for (final double f in const [0.35, 0.65, 1.0]) {
      canvas.drawCircle(center, maxR * f, ringPaint);
    }

    final int n = values.length;
    final Path poly = Path();
    final List<Offset> pts = <Offset>[];
    for (var i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + i * 2 * math.pi / n;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center, center + dir * maxR, ringPaint);
      final double norm = values[i].clamp(0.12, 0.98);
      final Offset pt = center + dir * (maxR * norm);
      pts.add(pt);
      if (i == 0) {
        poly.moveTo(pt.dx, pt.dy);
      } else {
        poly.lineTo(pt.dx, pt.dy);
      }

      if (showLabels && i < labels.length && i.isEven) {
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: labels[i],
            style: TextStyle(
              fontFamily: 'IBMPlexMono',
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final Offset lblCenter = center + dir * (maxR + 11);
        tp.paint(
          canvas,
          Offset(lblCenter.dx - tp.width / 2, lblCenter.dy - tp.height / 2),
        );
      }
    }
    poly.close();

    canvas.drawPath(poly, Paint()..color = accent.withValues(alpha: 0.24));
    canvas.drawPath(
      poly,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
    final Paint dotCore = Paint()..color = centerDotColor;
    final Paint dotRing = Paint()..color = accent;
    for (final Offset pt in pts) {
      canvas.drawCircle(pt, 2.5, dotRing);
      canvas.drawCircle(pt, 1.15, dotCore);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroMiniRadarPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.values != values ||
      oldDelegate.showLabels != showLabels ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.labelColor != labelColor ||
      oldDelegate.centerDotColor != centerDotColor;
}
