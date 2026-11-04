import 'package:flutter/material.dart';

import '../../../domain/models/political_models.dart';
import '../../../domain/models/study_models.dart';
import '../atlas/study_profile_screen.dart';
import '../compare/study_comparison_screen.dart';
import '../results/espectro_result_screen.dart';
import '../../../theme.dart';
import '../../../widgets/common.dart';
import '../../../widgets/editorial.dart';
import '../../../widgets/espectro_brand_mark.dart';
import '../../../widgets/espectro_scaffold.dart';
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

  void _openAtlas(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            AtlasExplorerScreen(appViewModel: appViewModel),
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
            maxWidth: 760,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
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
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                color: p.ink,
                              ),
                            ),
                            Text(
                              'Observatório político',
                              style: TextStyle(fontSize: 11, color: p.inkSoft),
                            ),
                          ],
                        ),
                      ),
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
                const SizedBox(height: 26),
                EditorialHero(
                  eyebrow: 'ESPECTRO / OBSERVATÓRIO POLÍTICO',
                  title: 'IDEIAS NÃO CABEM\nEM UM RÓTULO.',
                  description:
                      'Descubra as dimensões que formam sua visão de mundo através de questionários interativos, mapas de posicionamento e análise histórica de correntes de pensamento.',
                  badges: const <String>[
                    'PESQUISA',
                    'EXPLORAÇÃO',
                    'CLAREZA',
                  ],
                  footer: Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      AppButton(
                        label: 'Começar minha avaliação',
                        onDark: true,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => _openSuites(context),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF385566)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _openAtlas(context),
                        icon: const Icon(Icons.hub_outlined, size: 18),
                        label: const Text('Explorar o Atlas'),
                      ),
                    ],
                  ),
                ),
                if (draft != null) ...[
                  const SizedBox(height: 18),
                  _DraftResumeCard(
                    draft: draft,
                    onResume: () => _resumeDraft(context, draft),
                    onDiscard: () => appViewModel.discardActiveDraft(),
                  ),
                ],
                const SizedBox(height: 18),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow('ESTUDE NO SEU RITMO', color: p.accent),
                      const SizedBox(height: 12),
                      Text(
                        'Uma ideia leva a outra.',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Explore correntes, pessoas e obras. Descubra conexões na teia ou compare perfis lado a lado.',
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _openAtlas(context),
                            icon: const Icon(Icons.hub_outlined),
                            label: const Text('Explorar o Atlas'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => StudyComparisonScreen(
                                  appViewModel: appViewModel,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.compare_arrows),
                            label: const Text('Comparar ideias'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (appViewModel.history.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: p.line),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    tileColor: p.surface,
                    leading: Icon(Icons.insights, color: p.accent),
                    title: const Text('Seu último retrato'),
                    subtitle: Text(appViewModel.history.first.displayTitle),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => EspectroResultScreen(
                          appViewModel: appViewModel,
                          record: appViewModel.history.first,
                        ),
                      ),
                    ),
                  ),
                ],
                if (recent.isNotEmpty || saved.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Eyebrow('SUA BIBLIOTECA', color: p.accent),
                  const SizedBox(height: 12),
                  for (final subject in {...recent.take(3), ...saved.take(3)})
                    StudySubjectTile(
                      subject: subject,
                      portrait: appViewModel.data.portraits[subject.key],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          settings: RouteSettings(
                            name: studyProfileRoute(subject.key),
                          ),
                          builder: (_) => StudyProfileScreen(
                            appViewModel: appViewModel,
                            subjectKey: subject.key,
                          ),
                        ),
                      ),
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
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Eyebrow('Continue explorando', color: p.accent),
                ),
                const SizedBox(height: 14),
                _FigmaShortcutCard(
                  iconText: '◈',
                  iconBg: p.accentSoft,
                  iconColor: p.accent,
                  title: '12 EIXOS',
                  subtitle: 'Seu perfil multidimensional',
                  onTap: () => _openSuite(context, TestSuite.bipolarAxes),
                ),
                const SizedBox(height: 8),
                _FigmaShortcutCard(
                  iconText: '▣',
                  iconBg: p.isDark ? p.surfaceMuted : const Color(0xFFFFF0D7),
                  iconColor: p.accent,
                  title: 'ATLAS POLÍTICO',
                  subtitle: 'Pessoas, países e ideias',
                  onTap: () => _openAtlas(context),
                ),
                const SizedBox(height: 8),
                _FigmaShortcutCard(
                  iconText: '◷',
                  iconBg: p.accentSoft,
                  iconColor: p.accent,
                  title: 'HISTÓRICO',
                  subtitle: 'Sua evolução de respostas',
                  onTap: () => _openHistory(context),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _DraftResumeCard extends StatelessWidget {
  const _DraftResumeCard({
    required this.draft,
    required this.onResume,
    required this.onDiscard,
  });

  final ActiveQuizDraft draft;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

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
            '${draft.suite.title} · ${draft.depth.label}',
            style: text.titleLarge,
          ),
          const SizedBox(height: 10),
          ProgressRail(value: progress, color: p.accent),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Retomar'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onDiscard,
                child: const Text('Descartar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FigmaShortcutCard extends StatelessWidget {
  const _FigmaShortcutCard({
    required this.iconText,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String iconText;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final EspectroPalette p = context.palette;
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.line),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  switch (iconText) {
                    '◈' => Icons.diamond_outlined,
                    '▣' => Icons.crop_square_rounded,
                    _ => Icons.history_rounded,
                  },
                  size: 20,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSans',
                        fontSize: 11,
                        color: p.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.muted),
            ],
          ),
        ),
      ),
    );
  }
}
