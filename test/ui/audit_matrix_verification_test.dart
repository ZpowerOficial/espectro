import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/engine/atlas_and_nolan_engine.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/ads/espectro_ad_state.dart';
import 'package:politico/ui/ads/espectro_banner_ad.dart';
import 'package:politico/ui/charts/axis_colors.dart';
import 'package:politico/ui/charts/diverging_axis_bar.dart';
import 'package:politico/ui/charts/study_constellation.dart';
import 'package:politico/ui/charts/teia_cartographic_layer.dart';
import 'package:politico/ui/features/atlas/atlas_explorer_screen.dart';
import 'package:politico/ui/features/atlas/current_emblem.dart';
import 'package:politico/ui/features/atlas/study_identity.dart';
import 'package:politico/ui/features/atlas/study_map_screen.dart';
import 'package:politico/ui/features/atlas/study_profile_screen.dart';
import 'package:politico/ui/features/atlas/study_taxonomy.dart';
import 'package:politico/ui/features/compare/entity_comparison_screen.dart';
import 'package:politico/ui/features/compare/study_comparison_screen.dart';
import 'package:politico/ui/features/history/history_evolution_screen.dart';
import 'package:politico/ui/features/home/espectro_home_screen.dart';
import 'package:politico/ui/features/methodology/methodology_screen.dart';
import 'package:politico/ui/features/quiz/espectro_intro_screen.dart';
import 'package:politico/ui/features/quiz/espectro_quiz_screen.dart';
import 'package:politico/ui/features/quiz/espectro_suites_screen.dart';
import 'package:politico/ui/features/results/espectro_result_screen.dart';
import 'package:politico/ui/features/share/home_share_card_specimen.dart';
import 'package:politico/ui/features/share/share_card_content.dart';
import 'package:politico/ui/features/share/share_card_export.dart';
import 'package:politico/ui/features/share/shareable_card_sheet.dart';
import 'package:politico/ui/shared/metric_presentation.dart';
import 'package:politico/ui/view_models/app_view_model.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';
import 'package:politico/widgets/common.dart';
import 'package:politico/widgets/espectro_scaffold.dart';

double _contrastRatio(Color fg, Color bg) {
  final double l1 = fg.computeLuminance();
  final double l2 = bg.computeLuminance();
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppData data;

  setUpAll(() async {
    data = await AppData.load();
  });

  Future<({EvaluationRepository repo, AppViewModel vm, EvaluationRecord record})>
  createInitializedState({
    bool withRecord = true,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    final repo = EvaluationRepository(storage: LocalStorageService.inMemory());
    final vm = AppViewModel(data: data, repository: repo);
    await vm.initialize();
    await vm.setThemeMode(themeMode);

    final quiz = QuizViewModel.startNew(
      data: data,
      repository: repo,
      suite: TestSuite.espectroIntegrated,
      depth: TestDepth.express,
      seed: 55,
    );
    for (var i = 0; i < quiz.totalCount; i++) {
      quiz.jumpTo(i);
      quiz.selectAnswer(
        i.isEven ? LikertAnswer.agree : LikertAnswer.disagree,
      );
    }
    final record = EvaluationRecord.fromJson({
      ...quiz.buildCompletedRecord().toJson(),
      'createdAt': '2026-11-03T12:00:00.000Z',
    });
    if (withRecord) {
      await vm.recordCompletedEvaluation(record);
    }
    return (repo: repo, vm: vm, record: record);
  }

  Future<void> setViewport(
    WidgetTester tester,
    Size size, {
    double textScale = 1.0,
    bool disableAnimations = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: disableAnimations);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
    });
  }

  Widget wrapScreen({
    required Widget child,
    required bool isDark,
    MediaQueryData? mediaQueryOverride,
  }) {
    final Widget app = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(brightness: isDark ? Brightness.dark : Brightness.light),
      home: child,
    );
    if (mediaQueryOverride != null) {
      return MediaQuery(data: mediaQueryOverride, child: app);
    }
    return app;
  }

  testWidgets('P1.1: Métricas padronizadas em 1 casa pt-BR e referentes explícitos', (
    tester,
  ) async {
    expect(MetricPresentation.formatPercent(49.04), '49,0%');
    expect(MetricPresentation.formatPercent(61.96), '62,0%');
    expect(MetricPresentation.formatScore(49.04), '49,0');

    await setViewport(tester, const Size(1440, 900));
    final state = await createInitializedState(withRecord: true);

    await tester.pumpWidget(
      wrapScreen(
        isDark: false,
        child: EspectroResultScreen(
          appViewModel: state.vm,
          record: state.record,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('convergência com a corrente'), findsWidgets);
    expect(find.textContaining('afinidade com você'), findsNothing);
    expect(find.textContaining('% afim'), findsNothing);

    await tester.pumpWidget(
      wrapScreen(
        isDark: false,
        child: EspectroHomeScreen(appViewModel: state.vm),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('convergência com a corrente'), findsWidgets);
    expect(find.text('afinidade'), findsNothing);
  });

  testWidgets('P1.2: Comparação diferencia Economia Eixo bipolar vs Tríade econômica', (
    tester,
  ) async {
    await setViewport(tester, const Size(1440, 900));
    final state = await createInitializedState(withRecord: false);

    await tester.pumpWidget(
      wrapScreen(
        isDark: true,
        child: StudyComparisonScreen(
          appViewModel: state.vm,
          initialKeys: const [
            'current:liberalismo_classico',
            'current:social_democracia',
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Economia — Eixo bipolar'), findsOneWidget);
    expect(find.text('Economia — Tríade econômica'), findsOneWidget);
    expect(find.text('EIXO BIPOLAR'), findsWidgets);
    expect(find.text('TRÍADE'), findsWidgets);
    expect(find.textContaining('prox. exploratória'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('P1.3: Atlas esclarece 1.405 parlamentares (2003–2024) e filtra períodos', (
    tester,
  ) async {
    await setViewport(tester, const Size(1440, 900));
    final state = await createInitializedState(withRecord: false);

    await tester.pumpWidget(
      wrapScreen(
        isDark: true,
        child: AtlasExplorerScreen(appViewModel: state.vm),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('bancada parlamentar'), findsNothing);
    expect(find.text('parlamentares (2003–2024)'), findsOneWidget);
    expect(find.text('1405'), findsOneWidget);

    await tester.tap(find.text('Parlamentares · Voto Nominal (1405)'));
    await tester.pumpAndSettle();

    expect(find.text('Todos (2003–2024 · 1405)'), findsOneWidget);
    expect(find.textContaining('Atuação recente (2023–2024'), findsOneWidget);
    expect(
      find.textContaining('Legislaturas anteriores (2003–2022'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('P1.4: Profundidade Expressa padronizada e ShareCard mostra modalidade/profundidade', (
    tester,
  ) async {
    expect(TestDepth.express.label, 'Expressa');

    await setViewport(tester, const Size(1440, 900));
    final state = await createInitializedState(withRecord: true);

    await tester.pumpWidget(
      wrapScreen(
        isDark: false,
        child: EspectroHomeScreen(appViewModel: state.vm),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Fazer Avaliação Expressa (3 min)'), findsOneWidget);
    expect(find.text('Fazer Avaliação Rápida (3 min)'), findsNothing);

    await tester.pumpWidget(
      wrapScreen(
        isDark: false,
        child: EspectroIntroScreen(
          appViewModel: state.vm,
          suite: TestSuite.espectroIntegrated,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Expressa'), findsOneWidget);
    expect(find.textContaining('Avaliação Expressa:'), findsOneWidget);

    await tester.pumpWidget(
      wrapScreen(
        isDark: true,
        child: Center(
          child: ShareCardCanvas(
            record: state.record,
            data: data,
            story: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('${state.record.suite.title} · ${state.record.depth.label}'),
      findsOneWidget,
    );
    expect(find.text('12 Eixos Bipolares · Expressa'), findsOneWidget);
  });

  testWidgets('P1.5: Scaffold oculta barra fixa mobile quando o teclado virtual está aberto', (
    tester,
  ) async {
    await setViewport(tester, const Size(390, 844));
    final state = await createInitializedState(withRecord: false);

    await tester.pumpWidget(
      wrapScreen(
        isDark: false,
        child: EspectroScaffold(
          appViewModel: state.vm,
          selectedIndex: 0,
          body: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Histórico'), findsOneWidget);

    await tester.pumpWidget(
      wrapScreen(
        isDark: false,
        mediaQueryOverride: const MediaQueryData(
          size: Size(390, 844),
          viewInsets: EdgeInsets.only(bottom: 300),
        ),
        child: EspectroScaffold(
          appViewModel: state.vm,
          selectedIndex: 0,
          body: const SizedBox.expand(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Histórico'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('P1.6: StudyIdentityAvatar e StudyIdentityHero exibem fallback imediato', (
    tester,
  ) async {
    await setViewport(tester, const Size(390, 844));
    final current = data.catalog.currents.first;
    final subject = StudySubject.fromCurrent(current);
    const brokenBook = StudySubject(
      key: 'book:teste_sem_capa',
      name: 'Obra Sem Imagem',
      kind: 'book',
      kindLabel: 'Obra Clássica',
      photoUrl: 'assets/currents/inexistente_404.png',
    );

    await tester.pumpWidget(
      wrapScreen(
        isDark: false,
        child: Scaffold(
          body: ListView(
            children: [
              StudyIdentityAvatar(subject: subject, size: 72),
              StudyIdentityHero(subject: brokenBook),
            ],
          ),
        ),
      ),
    );
    // Verifica renderização imediata no primeiro quadro (antes de decodificação assíncrona).
    await tester.pump();
    expect(find.byType(CurrentHeraldicEmblem), findsWidgets);
    expect(find.byType(StudyIdentityAvatar), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('P2.1: Teia mobile abre inspetor em detent peek compacta e alterna sem sobreposição', (
    tester,
  ) async {
    await setViewport(tester, const Size(390, 844));
    final state = await createInitializedState(withRecord: false);

    await tester.pumpWidget(
      wrapScreen(
        isDark: true,
        child: AtlasExplorerScreen(
          appViewModel: state.vm,
          initialMap: true,
          initialQuery: 'liberalismo',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final graph = tester.widget<StudyConstellation>(
      find.byType(StudyConstellation).first,
    );
    final subject = graph.subjects.firstWhere(
      (s) => s.key == 'current:liberalismo_classico',
    );
    graph.onSelected(subject);
    await tester.pumpAndSettle();

    final inspectorFinder = find.byKey(const ValueKey('teia-mobile-inspector'));
    expect(inspectorFinder, findsOneWidget);
    final peekHeight = tester.getSize(inspectorFinder).height;
    expect(peekHeight, lessThanOrEqualTo(160.0));

    await tester.tap(find.byTooltip('Expandir detalhes'));
    await tester.pumpAndSettle();
    final halfHeight = tester.getSize(inspectorFinder).height;
    expect(halfHeight, greaterThan(220.0));

    await tester.tap(find.byTooltip('Expandir detalhes'));
    await tester.pumpAndSettle();
    final fullHeight = tester.getSize(inspectorFinder).height;
    expect(fullHeight, greaterThan(420.0));
    expect(tester.takeException(), isNull);
  });

  test('P2.2 & P2.4: Contraste WCAG 2.2 AA (>= 4.5:1) nas paletas clara/escura e selos Obsidian', () {
    for (final EspectroPalette p in const <EspectroPalette>[
      EspectroPalette.light,
      EspectroPalette.dark,
    ]) {
      final surfaces = <Color>[p.canvas, p.surface, p.surfaceMuted];
      final foregrounds = <String, Color>{
        'ink': p.ink,
        'inkSoft': p.inkSoft,
        'muted': p.muted,
        'accent': p.accent,
        'poleLeft': p.poleLeft,
        'poleRight': p.poleRight,
        'warning': p.warning,
        'success': p.success,
      };
      for (final entry in foregrounds.entries) {
        for (final bg in surfaces) {
          final ratio = _contrastRatio(entry.value, bg);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                '${p.isDark ? 'dark' : 'light'} ${entry.key} on $bg had contrast $ratio',
          );
        }
      }
    }

    // CTAs primários aprovados: Íris #44378F (claro) e Latão #E5A448 (escuro).
    expect(EspectroPalette.light.accent, const Color(0xFF44378F));
    expect(EspectroPalette.dark.accent, const Color(0xFF9A92F0));
    expect(
      _contrastRatio(const Color(0xFFFAF9F6), const Color(0xFF44378F)),
      greaterThanOrEqualTo(8.5),
    );
    expect(
      _contrastRatio(const Color(0xFF140D03), const Color(0xFFE5A448)),
      greaterThanOrEqualTo(8.5),
    );

    const bgObsidian = Color(0xFF0B101A);
    for (final spectrum in studySpectra) {
      final ratio = _contrastRatio(spectrum.ink(true), bgObsidian);
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: 'Spectrum ${spectrum.id}.ink(true) on Obsidian had contrast $ratio',
      );
    }
  });

  testWidgets('Matriz 5 viewports x 2 temas x 13 telas + cenários extras sem overflow', (
    tester,
  ) async {
    const viewports = <Size>[
      Size(1440, 900),
      Size(1024, 768),
      Size(768, 1024),
      Size(390, 844),
      Size(320, 568),
    ];

    final state = await createInitializedState(withRecord: true);
    final entityComparison = EspectroAtlasEngine.compareWithCurrent(
      current: data.catalog.currents.first,
      userAxes: state.record.axes,
      userTriads: state.record.triads,
    );

    final failures = <String>[];
    final prevOnError = FlutterError.onError;
    final currentErrors = <String>[];
    FlutterError.onError = (FlutterErrorDetails details) {
      final preview = details.toString().split('\n').take(14).join(' | ');
      currentErrors.add(preview);
    };

    try {
      for (final isDark in [false, true]) {
        for (final size in viewports) {
          await setViewport(tester, size);

          final quiz = QuizViewModel.startNew(
            data: data,
            repository: state.repo,
            suite: TestSuite.espectroIntegrated,
            depth: TestDepth.express,
            seed: 55,
          );

          final screens = <String, Widget>{
            'home': EspectroHomeScreen(appViewModel: state.vm),
            'suites': EspectroSuitesScreen(appViewModel: state.vm),
            'intro': EspectroIntroScreen(
              appViewModel: state.vm,
              suite: TestSuite.espectroIntegrated,
            ),
            'quiz': EspectroQuizScreen(
              appViewModel: state.vm,
              quizViewModel: quiz,
            ),
            'result': EspectroResultScreen(
              appViewModel: state.vm,
              record: state.record,
            ),
            'atlas': AtlasExplorerScreen(appViewModel: state.vm),
            'teia': AtlasExplorerScreen(
              appViewModel: state.vm,
              initialMap: true,
              initialQuery: 'liberalismo',
            ),
            'profile': StudyProfileScreen(
              appViewModel: state.vm,
              subjectKey: 'current:liberalismo_classico',
            ),
            'study_comparison': StudyComparisonScreen(
              appViewModel: state.vm,
              initialKeys: const [
                'current:liberalismo_classico',
                'current:social_democracia',
              ],
            ),
            'entity_comparison': EntityComparisonScreen(
              comparison: entityComparison,
              appViewModel: state.vm,
            ),
            'history': HistoryEvolutionScreen(appViewModel: state.vm),
            'methodology': MethodologyScreen(
              data: data,
              appViewModel: state.vm,
            ),
            'share_sheet': Scaffold(
              body: ShareableCardSheet(
                record: state.record,
                appViewModel: state.vm,
              ),
            ),
          };

          for (final entry in screens.entries) {
            currentErrors.clear();
            await tester.pumpWidget(
              wrapScreen(isDark: isDark, child: entry.value),
            );
            await tester.pumpAndSettle();
            final ex = tester.takeException();
            if (ex != null || currentErrors.isNotEmpty) {
              failures.add(
                '[${entry.key} ${isDark ? 'dark' : 'light'} $size] $ex :: ${currentErrors.join(' || ')}',
              );
            }
          }

          // Extra check: ShareCardCanvas 1:1 & 9:16 fit cleanly at compact widths
          for (final story in [false, true]) {
            currentErrors.clear();
            await tester.pumpWidget(
              wrapScreen(
                isDark: isDark,
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ShareCardCanvas(
                          record: state.record,
                          data: data,
                          story: story,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            final ex = tester.takeException();
            if (ex != null || currentErrors.isNotEmpty) {
              failures.add(
                '[ShareCardCanvas story=$story ${isDark ? 'dark' : 'light'} $size] $ex :: ${currentErrors.join(' || ')}',
              );
            }
          }
        }
      }

      // Extra scenarios: 320px compact with textScaler 1.3 and reduced motion
      await setViewport(
        tester,
        const Size(320, 568),
        textScale: 1.3,
        disableAnimations: true,
      );
      for (final entry in <String, Widget>{
        'home_1.3x': EspectroHomeScreen(appViewModel: state.vm),
        'result_1.3x': EspectroResultScreen(
          appViewModel: state.vm,
          record: state.record,
        ),
        'study_comparison_1.3x': StudyComparisonScreen(
          appViewModel: state.vm,
          initialKeys: const [
            'current:liberalismo_classico',
            'current:social_democracia',
          ],
        ),
        'entity_comparison_1.3x': EntityComparisonScreen(
          comparison: entityComparison,
          appViewModel: state.vm,
        ),
      }.entries) {
        currentErrors.clear();
        await tester.pumpWidget(wrapScreen(isDark: false, child: entry.value));
        await tester.pumpAndSettle();
        final ex = tester.takeException();
        if (ex != null || currentErrors.isNotEmpty) {
          failures.add('[${entry.key}] $ex :: ${currentErrors.join(' || ')}');
        }
      }
    } finally {
      FlutterError.onError = prevOnError;
    }
    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets(
    'Expressa preliminary & share card never claim unobserved 6 tríades as measured',
    (tester) async {
      await setViewport(tester, const Size(1440, 900));
      final state = await createInitializedState(withRecord: false);

      final expressQuiz = QuizViewModel.startNew(
        data: data,
        repository: state.repo,
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.express,
        seed: 42,
      );
      for (var i = 0; i < 20 && i < expressQuiz.totalCount; i++) {
        expressQuiz.jumpTo(i);
        expressQuiz.selectAnswer(
          i.isEven ? LikertAnswer.agree : LikertAnswer.disagree,
        );
      }
      final expressPrelim = expressQuiz.buildPreliminaryRecord();
      expect(
        expressPrelim.triads.where((t) => !t.isIndeterminate),
        isEmpty,
      );

      await tester.pumpWidget(
        wrapScreen(
          isDark: false,
          child: EspectroResultScreen(
            appViewModel: state.vm,
            record: expressPrelim,
            quizViewModel: expressQuiz,
            isPreliminary: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('12 eixos bipolares foram estimadas'),
        findsOneWidget,
      );
      expect(
        find.textContaining('as 6 tríades não foram medidas nesta etapa'),
        findsOneWidget,
      );
      expect(find.textContaining('12 eixos e 6 tríades'), findsNothing);
      expect(
        find.text('Bússola política (Projeção de Nolan)'),
        findsOneWidget,
      );

      for (final story in [false, true]) {
        await tester.pumpWidget(
          wrapScreen(
            isDark: false,
            child: SingleChildScrollView(
              child: Center(
                child: ShareCardCanvas(
                  record: expressPrelim,
                  data: state.vm.data,
                  story: story,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('12 eixos bipolares'), findsOneWidget);
        expect(find.text('12 eixos · 6 tríades'), findsNothing);
        expect(find.textContaining('0/0 tríades'), findsNothing);
      }

      final quickQuiz = QuizViewModel.startNew(
        data: data,
        repository: state.repo,
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.quick,
        seed: 42,
      );
      for (var i = 0; i < quickQuiz.totalCount; i++) {
        quickQuiz.jumpTo(i);
        quickQuiz.selectAnswer(
          i % 3 == 0
              ? LikertAnswer.stronglyAgree
              : (i.isEven ? LikertAnswer.agree : LikertAnswer.disagree),
        );
      }
      final quickRecord = quickQuiz.buildCompletedRecord();
      expect(
        quickRecord.triads.where((t) => !t.isIndeterminate),
        isNotEmpty,
      );

      await tester.pumpWidget(
        wrapScreen(
          isDark: false,
          child: Center(
            child: ShareCardCanvas(
              record: quickRecord,
              data: state.vm.data,
              story: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('12 eixos · 6 tríades'), findsOneWidget);
    },
  );

  testWidgets(
    'Item 2: Dual-Pole padrão na Home/Atlas/Comparador; Primary-Anchor apenas em inclinação observada no Resultado',
    (tester) async {
      await setViewport(tester, const Size(1440, 900));
      final state = await createInitializedState(withRecord: true);

      // Home, Atlas e Comparador preservam Dual-Pole como estratégia padrão.
      await tester.pumpWidget(
        wrapScreen(
          isDark: false,
          child: EspectroHomeScreen(appViewModel: state.vm),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        AxisColorStrategyScope.of(tester.element(find.byType(EspectroHomeScreen))),
        AxisColorStrategy.dualPole,
      );

      await tester.pumpWidget(
        wrapScreen(
          isDark: false,
          child: StudyComparisonScreen(
            appViewModel: state.vm,
            initialKeys: const [
              'current:liberalismo_classico',
              'current:social_democracia',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        AxisColorStrategyScope.of(
          tester.element(find.byType(StudyComparisonScreen)),
        ),
        AxisColorStrategy.dualPole,
      );

      // No Resultado pessoal, DivergingAxisBar recebe Primary-Anchor e nunca
      // privilegia polos em estados equilibrados (|score| < 0.15) ou indeterminados.
      const leaningAxis = BipolarDimensionScore(
        axisId: 'estrutura',
        label: 'Estrutura',
        leftPole: 'Federal',
        rightPole: 'Unitário',
        score: -0.5,
        standardError: 0.12,
        coverage: 1.0,
        answeredCount: 4,
        presentedCount: 4,
        tensionScore: 0.1,
      );
      const balancedAxis = BipolarDimensionScore(
        axisId: 'economia',
        label: 'Economia',
        leftPole: 'Público',
        rightPole: 'Privado',
        score: 0.06,
        standardError: 0.14,
        coverage: 1.0,
        answeredCount: 4,
        presentedCount: 4,
        tensionScore: 0.1,
      );
      const indeterminateAxis = BipolarDimensionScore(
        axisId: 'moral',
        label: 'Moral',
        leftPole: 'Progressista',
        rightPole: 'Tradicionalista',
        score: -0.4,
        standardError: 0.3,
        coverage: 0.2,
        answeredCount: 1,
        presentedCount: 4,
        tensionScore: 0.0,
      );

      await tester.pumpWidget(
        wrapScreen(
          isDark: false,
          child: AxisColorStrategyScope(
            strategy: AxisColorStrategy.primaryAnchor,
            child: Scaffold(
              body: Column(
                children: const [
                  DivergingAxisBar(dimension: leaningAxis),
                  DivergingAxisBar(dimension: balancedAxis),
                  DivergingAxisBar(dimension: indeterminateAxis),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final pills = tester.widgetList<PolePill>(find.byType(PolePill)).toList();
      expect(pills, hasLength(6));
      // Inclinação observada: apenas polo esquerdo ativo
      expect(pills[0].isActive, isTrue);
      expect(pills[1].isActive, isFalse);
      // Equilibrado: nenhum polo ativo
      expect(pills[2].isActive, isFalse);
      expect(pills[3].isActive, isFalse);
      expect(find.text('Equilibrado'), findsOneWidget);
      // Indeterminado: nenhum polo ativo e nenhum percentual ilusório
      expect(pills[4].isActive, isFalse);
      expect(pills[5].isActive, isFalse);
      expect(find.text('Dados insuficientes'), findsOneWidget);
    },
  );

  testWidgets(
    'Item 5: AdSense states (filled, unfilled, unfill-optimized, unavailable) sem caixa cinza nem selo AD falso',
    (tester) async {
      expect(parseWebAdStatus('filled'), EspectroAdSlotStatus.filled);
      expect(parseWebAdStatus('unfilled'), EspectroAdSlotStatus.unfilled);
      expect(
        parseWebAdStatus('unfill-optimized'),
        EspectroAdSlotStatus.unfillOptimized,
      );
      expect(parseWebAdStatus(null), EspectroAdSlotStatus.loading);

      await setViewport(tester, const Size(390, 844));

      // unfilled -> 0x0, sem "AD", sem "Publicidade"
      await tester.pumpWidget(
        wrapScreen(
          isDark: true,
          child: const Scaffold(
            body: Center(
              child: EspectroInlineAdSlot(
                placementId: 'test_unfilled',
                testStatusOverride: EspectroAdSlotStatus.unfilled,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(EspectroInlineAdSlot)),
        Size.zero,
      );
      expect(find.text('Publicidade'), findsNothing);
      expect(find.text('AD'), findsNothing);

      // unavailable -> 0x0
      await tester.pumpWidget(
        wrapScreen(
          isDark: true,
          child: const Scaffold(
            body: Center(
              child: EspectroInlineAdSlot(
                placementId: 'test_unavailable',
                testStatusOverride: EspectroAdSlotStatus.unavailable,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(EspectroInlineAdSlot)),
        Size.zero,
      );

      // filled -> exibe rótulo "Publicidade" e altura observada
      await tester.pumpWidget(
        wrapScreen(
          isDark: true,
          child: const Scaffold(
            body: Center(
              child: EspectroInlineAdSlot(
                placementId: 'test_filled',
                testStatusOverride: EspectroAdSlotStatus.filled,
                testObservedHeight: 100,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Publicidade'), findsOneWidget);
      expect(
        tester.getSize(
          find.byKey(const ValueKey<String>('ad-test-surface-test_filled')),
        ).height,
        100,
      );
      expect(
        find.descendant(
          of: find.byType(EspectroInlineAdSlot),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(EspectroInlineAdSlot),
          matching: find.byType(IgnorePointer),
        ),
        findsNothing,
      );

      // unfill-optimized com altura > 0 -> renderiza sem ocultar; altura 0 -> 0x0 sem forçar estilo
      await tester.pumpWidget(
        wrapScreen(
          isDark: true,
          child: const Scaffold(
            body: Center(
              child: EspectroInlineAdSlot(
                placementId: 'test_opt_open',
                testStatusOverride: EspectroAdSlotStatus.unfillOptimized,
                testObservedHeight: 120,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Publicidade'), findsOneWidget);
      expect(
        tester.getSize(
          find.byKey(const ValueKey<String>('ad-test-surface-test_opt_open')),
        ).height,
        120,
      );
      expect(
        find.descendant(
          of: find.byType(EspectroInlineAdSlot),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(EspectroInlineAdSlot),
          matching: find.byType(IgnorePointer),
        ),
        findsNothing,
      );

      await tester.pumpWidget(
        wrapScreen(
          isDark: true,
          child: const Scaffold(
            body: Center(
              child: EspectroInlineAdSlot(
                placementId: 'test_opt_zero',
                testStatusOverride: EspectroAdSlotStatus.unfillOptimized,
                testObservedHeight: 0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(EspectroInlineAdSlot)),
        Size.zero,
      );
    },
  );

  testWidgets(
    'Item 7: URL pública de produção no ShareCardCanvas 1:1 e 9:16 sem overflow',
    (tester) async {
      await setViewport(tester, const Size(1200, 2200));
      final state = await createInitializedState(withRecord: true);
      final prodLink = shareCardEntryLink(
        base: Uri.parse('https://espectro-politico.web.app/#/result?temp=1'),
      );
      expect(prodLink, 'https://espectro-politico.web.app/#/');

      for (final story in [false, true]) {
        await tester.pumpWidget(
          wrapScreen(
            isDark: true,
            child: Center(
              child: ShareCardCanvas(
                record: state.record,
                data: state.vm.data,
                story: story,
                entryLink: prodLink,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('https://espectro-politico.web.app/#/'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Cycle 3: Atlas mobile 390x844 usa trilho horizontal e mantém Tradições e espectros na primeira dobra',
    (tester) async {
      await setViewport(tester, const Size(390, 844));
      final state = await createInitializedState(withRecord: false);
      await tester.pumpWidget(
        wrapScreen(
          isDark: true,
          child: AtlasExplorerScreen(appViewModel: state.vm),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('atlas-mobile-filter-rail')),
        findsOneWidget,
      );
      final traditionsFinder = find.text('Tradições e espectros');
      expect(traditionsFinder, findsOneWidget);
      expect(tester.getTopLeft(traditionsFinder).dy, lessThan(844.0));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Cycle 3: StudyIdentityHero mantém kindLabel e dim. agrupados sem overflow em mobile',
    (tester) async {
      final marx = StudyCatalog(data).find('personality:karl_marx')!;
      await setViewport(tester, const Size(720, 844));
      await tester.pumpWidget(
        wrapScreen(
          isDark: false,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: StudyIdentityHero(
                subject: marx,
                portrait: data.portraits[marx.key],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Rect kindRect = tester.getRect(find.text('Personalidade'));
      final Rect dimRect = tester.getRect(find.text('· 18/18 dim.'));
      expect((kindRect.center.dy - dimRect.center.dy).abs(), lessThan(4.0));
      expect(tester.takeException(), isNull);

      await setViewport(tester, const Size(390, 844));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await setViewport(tester, const Size(320, 568));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Cycle 3: Histórico mobile 390x844 sem botão Voltar redundante e com guia para 1 avaliação',
    (tester) async {
      await setViewport(tester, const Size(390, 844));
      final state = await createInitializedState(withRecord: true);
      await tester.pumpWidget(
        wrapScreen(
          isDark: true,
          child: HistoryEvolutionScreen(appViewModel: state.vm),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Voltar'), findsNothing);
      expect(
        find.text('Comparação temporal disponível a partir de 2 avaliações'),
        findsOneWidget,
      );
      expect(find.text('Nova avaliação'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Cycle 4 (break-ui): ShareCardCanvas 1:1 e 9:16 renderizam Mustafa Kemal Atatürk e 87,5% Assimilação sem truncar',
    (tester) async {
      final sansLoader = FontLoader('IBMPlexSans')
        ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Medium.ttf'))
        ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-SemiBold.ttf'))
        ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Bold.ttf'));
      final monoLoader = FontLoader('IBMPlexMono')
        ..addFont(rootBundle.load('assets/fonts/IBMPlexMono-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/IBMPlexMono-Bold.ttf'));
      await Future.wait(<Future<void>>[sansLoader.load(), monoLoader.load()]);

      await setViewport(tester, const Size(1000, 900));
      final state = await createInitializedState(withRecord: true);
      final ataturk = data.atlas.canonicalPersonalities.firstWhere(
        (p) => p.id == 'mustafa_kemal_ataturk',
      );
      final List<BipolarDimensionScore> stressedAxes = <BipolarDimensionScore>[
        for (final BipolarDimensionScore ax in state.record.axes)
          BipolarDimensionScore(
            axisId: ax.axisId,
            label: ax.label,
            leftPole: ax.leftPole,
            rightPole: ax.rightPole,
            score: ax.axisId == 'imigracao'
                ? -0.75
                : (ataturk.axes[ax.axisId] ?? ax.score).clamp(-0.68, 0.68),
            standardError: 0.14,
            coverage: 1.0,
            answeredCount: 2,
            presentedCount: 2,
            tensionScore: 0.0,
          ),
      ];
      final EvaluationRecord stressedRecord = EvaluationRecord(
        id: state.record.id,
        createdAt: state.record.createdAt,
        suite: state.record.suite,
        depth: state.record.depth,
        seed: state.record.seed,
        engineVersion: state.record.engineVersion,
        bankVersion: state.record.bankVersion,
        rawAnswers: state.record.rawAnswers,
        axes: stressedAxes,
        triads: state.record.triads,
        quality: state.record.quality,
      );

      for (final bool story in <bool>[false, true]) {
        await tester.pumpWidget(
          wrapScreen(
            isDark: true,
            child: Center(
              child: ShareCardCanvas(
                record: stressedRecord,
                data: data,
                story: story,
                entryLink: 'https://espectro-politico.web.app/#/',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final RenderParagraph nameParagraph = tester
            .renderObject<RenderParagraph>(find.text('Mustafa Kemal Atatürk'));
        final RenderParagraph axisParagraph = tester
            .renderObject<RenderParagraph>(find.text('87,5% Assimilação'));
        expect(nameParagraph.didExceedMaxLines, isFalse);
        expect(axisParagraph.didExceedMaxLines, isFalse);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Cycle 4 (choreograph): Quiz troca instantaneamente via teclado e anima via ponteiro',
    (tester) async {
      await setViewport(
        tester,
        const Size(1440, 900),
        disableAnimations: false,
      );
      final state = await createInitializedState(withRecord: false);
      await state.vm.setAutoAdvance(false);
      final quizVm = QuizViewModel.startNew(
        data: data,
        repository: state.repo,
        suite: TestSuite.bipolarAxes,
        depth: TestDepth.express,
        seed: 55,
      );

      await tester.pumpWidget(
        wrapScreen(
          isDark: true,
          child: EspectroQuizScreen(
            appViewModel: state.vm,
            quizViewModel: quizVm,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(quizVm.currentIndex, 1);
      final AnimatedSwitcher keyboardSwitcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );
      expect(keyboardSwitcher.duration, Duration.zero);
      expect(keyboardSwitcher.reverseDuration, Duration.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Anterior'));
      await tester.pump();
      expect(quizVm.currentIndex, 0);
      final AnimatedSwitcher backSwitcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );
      expect(backSwitcher.duration, EspectroMotion.fast);
      expect(
        backSwitcher.reverseDuration,
        const Duration(milliseconds: 135),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Próxima'));
      await tester.pump();
      expect(quizVm.currentIndex, 1);
      final AnimatedSwitcher nextSwitcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );
      expect(nextSwitcher.duration, EspectroMotion.fast);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Cycle 5 (spacing): Atlas, Comparação, Histórico e Metodologia alinham coluna, AppBar e respiro em 1440px e 390px',
    (tester) async {
      await setViewport(tester, const Size(1440, 900));
      final state = await createInitializedState(withRecord: true);

      Future<({Offset title, Offset heading})> measureScreen(
        Widget screen,
        String appBarTitle,
        String eyebrow,
      ) async {
        await tester.pumpWidget(wrapScreen(isDark: true, child: screen));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        return (
          title: tester.getTopLeft(
            find.descendant(
              of: find.byType(AppBar),
              matching: find.text(appBarTitle),
            ),
          ),
          heading: tester.getTopLeft(find.text(eyebrow)),
        );
      }

      final atlas = await measureScreen(
        AtlasExplorerScreen(appViewModel: state.vm),
        'Atlas político',
        'Catálogo e personalidades',
      );
      final compare = await measureScreen(
        StudyComparisonScreen(
          appViewModel: state.vm,
          initialKeys: const <String>[
            'current:liberalismo_classico',
            'current:social_democracia',
          ],
        ),
        'Comparação livre',
        'Comparação lado a lado',
      );
      final history = await measureScreen(
        HistoryEvolutionScreen(appViewModel: state.vm),
        'Histórico',
        'Histórico / Comparação',
      );
      final methodology = await measureScreen(
        MethodologyScreen(data: data, appViewModel: state.vm),
        'Metodologia',
        'Método / Privacidade',
      );

      for (final m in [atlas, compare, history, methodology]) {
        expect((m.title.dx - m.heading.dx).abs(), lessThanOrEqualTo(1.0));
      }
      expect((atlas.heading.dx - compare.heading.dx).abs(), lessThanOrEqualTo(0.5));
      expect((atlas.heading.dx - history.heading.dx).abs(), lessThanOrEqualTo(0.5));
      expect((atlas.heading.dx - methodology.heading.dx).abs(), lessThanOrEqualTo(0.5));
      expect((atlas.heading.dy - compare.heading.dy).abs(), lessThanOrEqualTo(0.5));
      expect((history.heading.dy - methodology.heading.dy).abs(), lessThanOrEqualTo(0.5));

      await setViewport(tester, const Size(390, 844));
      final atlasMobile = await measureScreen(
        AtlasExplorerScreen(appViewModel: state.vm),
        'Atlas político',
        'Catálogo e personalidades',
      );
      final compareMobile = await measureScreen(
        StudyComparisonScreen(
          appViewModel: state.vm,
          initialKeys: const <String>[
            'current:liberalismo_classico',
            'current:social_democracia',
          ],
        ),
        'Comparação livre',
        'Comparação lado a lado',
      );

      expect(atlasMobile.heading.dx, EspectroLayout.pageHorizontalPadding);
      expect(compareMobile.heading.dx, EspectroLayout.pageHorizontalPadding);
      expect(
        (atlasMobile.heading.dy - compareMobile.heading.dy).abs(),
        lessThanOrEqualTo(0.5),
      );
      expect(
        find.byKey(const Key('comparacao-mobile-suggestions-rail')),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(find.text('Proximidade por par')).dy,
        lessThan(844.0),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Home polish: proporções exatas 1:1 e 9:16, equilíbrio do Hero e botões uniformes do Comparador',
    (tester) async {
      final sansLoader = FontLoader('IBMPlexSans')
        ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Medium.ttf'))
        ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-SemiBold.ttf'))
        ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Bold.ttf'));
      final monoLoader = FontLoader('IBMPlexMono')
        ..addFont(rootBundle.load('assets/fonts/IBMPlexMono-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/IBMPlexMono-Bold.ttf'));
      await Future.wait(<Future<void>>[sansLoader.load(), monoLoader.load()]);

      final state = await createInitializedState(withRecord: false);

      // 1440x900 desktop
      await setViewport(tester, const Size(1440, 900));
      await tester.pumpWidget(
        wrapScreen(
          isDark: false,
          child: EspectroHomeScreen(appViewModel: state.vm),
        ),
      );
      await tester.pumpAndSettle();

      // Hero título ampliado e botões na mesma linha com altura igual
      final Text heroTitle = tester.widget<Text>(
        find.text('Onde você realmente se situa além dos rótulos?'),
      );
      expect(heroTitle.style?.fontSize ?? 0, greaterThanOrEqualTo(48.0));

      final Finder expressBtnFinder = find.ancestor(
        of: find.text('Fazer Avaliação Expressa (3 min)'),
        matching: find.byType(FilledButton),
      );
      final Finder atlasBtnFinder = find.ancestor(
        of: find.text('Explorar o Atlas'),
        matching: find.byType(OutlinedButton),
      );
      final Rect expressRect = tester.getRect(expressBtnFinder);
      final Rect atlasRect = tester.getRect(atlasBtnFinder);
      expect((expressRect.center.dy - atlasRect.center.dy).abs(), lessThanOrEqualTo(2.0));
      expect((expressRect.height - atlasRect.height).abs(), lessThanOrEqualTo(0.5));

      // Post 1:1 (padrão inicial do showcase: _previewStory == false)
      final Finder specimenFinder = find.byType(HomeShareCardSpecimen);
      expect(specimenFinder, findsOneWidget);
      final Size postSizeDesktop = tester.getSize(specimenFinder);
      expect(postSizeDesktop.width / postSizeDesktop.height, closeTo(1.0, 0.02));

      // Alternar para Story 9:16
      final Finder storyToggle = find.text('Story 9:16');
      await tester.ensureVisible(storyToggle);
      await tester.tap(storyToggle);
      await tester.pumpAndSettle();
      final Size storySizeDesktop = tester.getSize(specimenFinder);
      expect(storySizeDesktop.width / storySizeDesktop.height, closeTo(9 / 16, 0.02));

      // Card Comparador de Perfis e Histórico: rolar até Beat 5 e validar botões de 44 px
      final Finder toolsActions = find.byKey(const ValueKey<String>('home-tools-actions'));
      await tester.scrollUntilVisible(
        toolsActions,
        400.0,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(toolsActions, findsOneWidget);
      final Finder compBtn = find.descendant(
        of: toolsActions,
        matching: find.ancestor(
          of: find.text('Comparador'),
          matching: find.byType(FilledButton),
        ),
      );
      final Finder teiaBtn = find.descendant(
        of: toolsActions,
        matching: find.ancestor(
          of: find.text('Teia Política'),
          matching: find.byType(OutlinedButton),
        ),
      );
      final Finder histBtn = find.descendant(
        of: toolsActions,
        matching: find.ancestor(
          of: find.text('Histórico'),
          matching: find.byType(OutlinedButton),
        ),
      );
      final double compH = tester.getSize(compBtn).height;
      final double teiaH = tester.getSize(teiaBtn).height;
      final double histH = tester.getSize(histBtn).height;
      expect(compH, closeTo(44.0, 0.5));
      expect(teiaH, closeTo(44.0, 0.5));
      expect(histH, closeTo(44.0, 0.5));
      expect(tester.takeException(), isNull);

      // Viewports compactos: 390x844 e 320x568 em Post 1:1 e Story 9:16 sem overflow
      for (final Size mobileSize in const <Size>[Size(390, 844), Size(320, 568)]) {
        await setViewport(tester, mobileSize);
        await tester.pumpWidget(
          wrapScreen(
            isDark: false,
            child: EspectroHomeScreen(
              key: ValueKey<Size>(mobileSize),
              appViewModel: state.vm,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('Story 9:16'),
          300.0,
          scrollable: find
              .descendant(
                of: find.byType(ListView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.ensureVisible(find.text('Story 9:16'));
        await tester.pumpAndSettle();

        final Size mobilePostSize = tester.getSize(specimenFinder);
        expect(mobilePostSize.width / mobilePostSize.height, closeTo(1.0, 0.02));

        await tester.tap(find.text('Story 9:16'));
        await tester.pumpAndSettle();

        final Size mobileStorySize = tester.getSize(specimenFinder);
        expect(mobileStorySize.width / mobileStorySize.height, closeTo(9 / 16, 0.02));
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Teia cartográfica: triângulo equilátero em Tríades e selos ancorados sem colisão com ESPECTROS',
    (tester) async {
      // 1. Geometria equilátera exata dos 3 vértices do simplex ternário
      final double edgeBase =
          (TeiaCartographicLayer.triadV1 - TeiaCartographicLayer.triadV0).distance;
      final double edgeLeft =
          (TeiaCartographicLayer.triadV2 - TeiaCartographicLayer.triadV0).distance;
      final double edgeRight =
          (TeiaCartographicLayer.triadV2 - TeiaCartographicLayer.triadV1).distance;
      expect((edgeBase - edgeLeft).abs(), lessThanOrEqualTo(1.0));
      expect((edgeBase - edgeRight).abs(), lessThanOrEqualTo(1.0));
      expect((edgeLeft - edgeRight).abs(), lessThanOrEqualTo(1.0));

      final sansLoader = FontLoader('IBMPlexSans')
        ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Regular.ttf'))
        ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-SemiBold.ttf'))
        ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Bold.ttf'));
      await sansLoader.load();

      await setViewport(tester, const Size(1440, 900));
      final state = await createInitializedState(withRecord: false);
      await tester.pumpWidget(
        wrapScreen(
          isDark: false,
          child: StudyMapScreen(appViewModel: state.vm),
        ),
      );
      await tester.pumpAndSettle();

      final Finder legendBox = find
          .ancestor(
            of: find.text('ESPECTROS'),
            matching: find.byType(ConstrainedBox),
          )
          .first;
      final Rect legendRect = tester.getRect(legendBox);
      const Rect viewportRect = Rect.fromLTWH(0, 0, 1440, 900);

      // Nolan clássico: 4 selos visíveis dentro da viewport e sem colidir com legenda
      for (final String nolanLabel in const <String>[
        'AUTORITARISMO ↑',
        'ANARQUISMO ↓',
        '← ESQUERDA',
        'DIREITA →',
      ]) {
        final Finder f = find.text(nolanLabel);
        expect(f, findsOneWidget);
        final Rect r = tester.getRect(f);
        expect(viewportRect.contains(r.center), isTrue);
        expect(r.overlaps(legendRect), isFalse);
      }

      // Alternar para Tríade: Política Externa via seletor de projeção
      await tester.tap(find.byTooltip('Trocar eixos desta teia'));
      await tester.pumpAndSettle();
      final Finder extItem = find.text('Tríade: Política Externa');
      await tester.ensureVisible(extItem);
      await tester.tap(extItem);
      await tester.pumpAndSettle();

      for (final String triadLabel in const <String>[
        'GLOBALISMO ↑',
        '← IMPERIALISMO',
        'ISOLACIONISMO →',
      ]) {
        final Finder f = find.text(triadLabel);
        expect(f, findsOneWidget);
        final Rect r = tester.getRect(f);
        expect(viewportRect.contains(r.center), isTrue);
        expect(
          r.overlaps(legendRect),
          isFalse,
          reason: '$triadLabel não deve colidir com o painel ESPECTROS ($r vs $legendRect)',
        );
      }
      expect(tester.takeException(), isNull);
    },
  );
}
