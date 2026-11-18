import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/app.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/domain/models/study_models.dart';
import 'package:politico/ui/ads/espectro_banner_ad.dart';
import 'package:politico/ui/charts/study_constellation.dart';
import 'package:politico/ui/features/atlas/atlas_explorer_screen.dart';
import 'package:politico/ui/features/atlas/study_profile_screen.dart';
import 'package:politico/ui/features/home/espectro_home_screen.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/engine/atlas_and_nolan_engine.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/domain/models/atlas_models.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/features/quiz/espectro_intro_screen.dart';
import 'package:politico/ui/features/quiz/espectro_suites_screen.dart';
import 'package:politico/ui/features/results/espectro_result_screen.dart';
import 'package:politico/ui/view_models/app_view_model.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';
import 'package:politico/widgets/espectro_scaffold.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  setUpAll(() async {
    data = await AppData.load();
    final FontLoader font = FontLoader('IBMPlexSans')
      ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Regular.ttf'));
    await font.load();
  });

  Future<AppViewModel> model() async {
    final AppViewModel vm = AppViewModel(
      data: data,
      repository: EvaluationRepository(storage: LocalStorageService.inMemory()),
    );
    await vm.initialize();
    return vm;
  }

  for (final double width in <double>[390, 1440]) {
    for (final suite in TestSuite.values) {
      testWidgets(
        'navegação de Testes permanece em ${suite.name} e profundidade em $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final AppViewModel vm = await model();
          addTearDown(vm.dispose);
          await tester.pumpWidget(
            MaterialApp(
              theme: buildAppTheme(brightness: Brightness.light),
              home: EspectroScaffold(
                appViewModel: vm,
                body: const Text('Raiz'),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text(width >= 1100 ? 'Meus testes' : 'Testes'));
          await tester.pumpAndSettle();
          expect(find.byType(EspectroSuitesScreen), findsOneWidget);
          expect(find.byType(EspectroScaffold), findsOneWidget);
          expect(
            find.text(width >= 1100 ? 'Meus testes' : 'Testes'),
            findsOneWidget,
          );
          final String choice = switch (suite) {
            TestSuite.espectroIntegrated => 'Espectro integrado',
            TestSuite.bipolarAxes => '12 eixos bipolares',
            TestSuite.triads => '6 tríades políticas',
          };
          await tester.ensureVisible(find.text(choice));
          await tester.tap(find.text(choice));
          await tester.ensureVisible(find.text('Continuar'));
          await tester.tap(find.text('Continuar'));
          await tester.pumpAndSettle();
          expect(find.byType(EspectroIntroScreen), findsOneWidget);
          expect(
            tester
                .widget<EspectroIntroScreen>(find.byType(EspectroIntroScreen))
                .suite,
            suite,
          );
          expect(find.byType(EspectroScaffold), findsOneWidget);
          expect(
            find.text(width >= 1100 ? 'Meus testes' : 'Testes'),
            findsOneWidget,
          );
          await tester.tap(
            find.text(width >= 1100 ? 'Atlas político' : 'Atlas'),
          );
          await tester.pumpAndSettle();
          expect(find.byType(EspectroIntroScreen), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'valores preservam arena e título completo em linhas distintas com fonte 2x',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final AppViewModel vm = await model();
      addTearDown(vm.dispose);
      final QuizViewModel quiz = QuizViewModel.startNew(
        data: data,
        repository: vm.repository,
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.quick,
        seed: 90,
      );
      for (var i = 0; i < quiz.totalCount; i++) {
        quiz.jumpTo(i);
        quiz.selectAnswer(LikertAnswer.agree);
      }
      final EvaluationRecord record = quiz.buildCompletedRecord();
      final syntheses = EspectroAtlasEngine.computeSyntheses(
        axes: record.axes,
        triads: record.triads,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(brightness: Brightness.light),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: FundamentalValuesSection(syntheses: syntheses),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final Rect arena = tester.getRect(find.text(syntheses.first.arena));
      final Rect title = tester.getRect(find.text(syntheses.first.title));
      expect(title.top, greaterThanOrEqualTo(arena.bottom));
      expect(title.left, greaterThanOrEqualTo(0));
      expect(title.right, lessThanOrEqualTo(390));
      expect(
        (tester.widget<Text>(find.text(syntheses.first.title))).maxLines,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final double scale in <double>[1, 2]) {
    testWidgets(
      'títulos longos usam largura disponível no desktop e fonte $scale',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        const List<ThematicSynthesis> values = <ThematicSynthesis>[
          ThematicSynthesis(
            arena: 'Estado, Poder e Garantias',
            title: 'Constitucionalismo de Freios e Contrapesos',
            summary: 'Participação democrática e proteção das garantias fundamentais.',
            intensity: .5,
          ),
          ThematicSynthesis(
            arena: 'Sociedade, Moral e Laicidade',
            title: 'Emancipação Progressista e Laicidade Estrita',
            summary: 'Autonomia corporal e separação rigorosa entre igrejas e Estado.',
            intensity: .5,
          ),
        ];
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness: Brightness.light),
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: 760,
                      child: FundamentalValuesSection(syntheses: values),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final Rect first = tester.getRect(find.text(values.first.title));
        final Rect second = tester.getRect(find.text(values.last.title));
        if (scale == 1) {
          expect(second.left, greaterThan(first.right));
        } else {
          expect(second.left, first.left);
          expect(second.top, greaterThan(first.bottom));
        }
        for (final ThematicSynthesis value in values) {
          final Rect arena = tester.getRect(find.text(value.arena));
          final Rect title = tester.getRect(find.text(value.title));
          expect(title.top, greaterThan(arena.bottom));
          expect(title.left, greaterThanOrEqualTo(340));
          expect(title.right, lessThanOrEqualTo(1100));
          expect(
            tester.widget<Text>(find.text(value.title)).overflow,
            isNot(TextOverflow.ellipsis),
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  test(
    'sínteses mantêm diferença entre respostas neutras e dados ausentes',
    () async {
      final AppViewModel vm = await model();
      addTearDown(vm.dispose);
      final QuizViewModel quiz = QuizViewModel.startNew(
        data: data,
        repository: vm.repository,
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.quick,
        seed: 90,
      );
      final EvaluationRecord absent = quiz.buildCompletedRecord();
      expect(
        EspectroAtlasEngine.computeSyntheses(
          axes: absent.axes,
          triads: absent.triads,
        ),
        isEmpty,
      );
      for (var i = 0; i < quiz.totalCount; i++) {
        quiz.jumpTo(i);
        quiz.selectAnswer(LikertAnswer.neutral);
      }
      final EvaluationRecord neutral = quiz.buildCompletedRecord();
      expect(neutral.axes.every((axis) => !axis.isIndeterminate), isTrue);
      expect(
        EspectroAtlasEngine.computeSyntheses(
          axes: neutral.axes,
          triads: neutral.triads,
        ),
        isNotEmpty,
      );
    },
  );

  for (var tab = 0; tab < 5; tab++) {
    testWidgets(
      'relatório integral: aba $tab percorre todo conteúdo em 390 e fonte 2x',
      (tester) async {
        tester.view.physicalSize = const Size(390, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final AppViewModel vm = await model();
        addTearDown(vm.dispose);
        final QuizViewModel quiz = QuizViewModel.startNew(
          data: data,
          repository: vm.repository,
          suite: TestSuite.espectroIntegrated,
          depth: TestDepth.exhaustive,
          seed: 99,
        );
        for (var i = 0; i < quiz.totalCount; i++) {
          quiz.jumpTo(i);
          quiz.selectAnswer(
            i.isEven ? LikertAnswer.agree : LikertAnswer.disagree,
          );
        }
        final EvaluationRecord record = quiz.buildCompletedRecord();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness: Brightness.light),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: EspectroResultScreen(
              appViewModel: vm,
              record: record,
              initialTabIndex: tab,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final Finder vertical = find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first;
        final ScrollPosition position = tester
            .state<ScrollableState>(vertical)
            .position;
        for (
          var i = 0;
          i < 100 && position.pixels < position.maxScrollExtent - 1;
          i++
        ) {
          await tester.drag(vertical, const Offset(0, -650));
          await tester.pumpAndSettle();
        }
        expect(position.pixels, closeTo(position.maxScrollExtent, 1));
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final double width in <double>[390, 1440]) {
    testWidgets(
      'tab Testes ativo não empilha e Intro recupera a modalidade em $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final AppViewModel vm = await model();
        addTearDown(vm.dispose);
        final _NavigationObserver observer = _NavigationObserver();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness: Brightness.light),
            navigatorObservers: <NavigatorObserver>[observer],
            home: EspectroScaffold(appViewModel: vm, body: const Text('Raiz')),
          ),
        );
        await tester.pumpAndSettle();
        final String tab = width >= 1100 ? 'Meus testes' : 'Testes';
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        final original = tester.state(find.byType(EspectroSuitesScreen));
        final int pushesAtRoot = observer.pushes;
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(observer.pushes, pushesAtRoot);
        expect(
          identical(tester.state(find.byType(EspectroSuitesScreen)), original),
          isTrue,
        );
        await tester.ensureVisible(find.text('12 eixos bipolares'));
        await tester.tap(find.text('12 eixos bipolares'));
        await tester.ensureVisible(find.text('Continuar'));
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();
        expect(find.byType(EspectroIntroScreen), findsOneWidget);
        final int pushesAtIntro = observer.pushes;
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(find.byType(EspectroIntroScreen), findsNothing);
        expect(
          identical(tester.state(find.byType(EspectroSuitesScreen)), original),
          isTrue,
        );
        expect(observer.pushes, pushesAtIntro);
        await tester.ensureVisible(find.text('Continuar'));
        await tester.tap(find.text('Continuar'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<EspectroIntroScreen>(find.byType(EspectroIntroScreen))
              .suite,
          TestSuite.bipolarAxes,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'tab Atlas do perfil recupera filtro seleção e câmera existentes em $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final AppViewModel vm = await model();
        addTearDown(vm.dispose);
        final _NavigationObserver observer = _NavigationObserver();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness: Brightness.light),
            navigatorObservers: <NavigatorObserver>[observer],
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: AtlasExplorerScreen(
              appViewModel: vm,
              initialMap: true,
              initialQuery: 'Karl Marx',
            ),
          ),
        );
        await tester.pumpAndSettle();
        final original = tester.state(find.byType(AtlasExplorerScreen));
        final StudySubject marx = StudyCatalog(data)
            .find('personality:karl_marx')!;
        tester
            .widget<StudyConstellation>(find.byType(StudyConstellation))
            .onSelected(marx);
        await tester.pumpAndSettle();
        final TransformationController camera = tester
            .widget<InteractiveViewer>(find.byType(InteractiveViewer))
            .transformationController!;
        camera.value = Matrix4.diagonal3Values(1.2, 1.2, 1)
          ..setTranslationRaw(23, -14, 0);
        await tester.pump();
        final List<double> before = camera.value.storage.toList();
        tester
            .widget<StudyConstellation>(find.byType(StudyConstellation))
            .onOpen!(marx);
        await tester.pumpAndSettle();
        expect(find.byType(StudyProfileScreen), findsOneWidget);
        final int pushesAtProfile = observer.pushes;
        await tester.tap(find.text(width >= 1100 ? 'Atlas político' : 'Atlas'));
        await tester.pumpAndSettle();
        expect(find.byType(StudyProfileScreen), findsNothing);
        expect(
          identical(tester.state(find.byType(AtlasExplorerScreen)), original),
          isTrue,
        );
        expect(observer.pushes, pushesAtProfile);
        // A Teia em tela cheia só exibe o campo de busca inline em larguras
        // >= 500; no mobile ele vive na folha "Buscar e filtrar". Em ambos os
        // casos o controlador é o mesmo e deve preservar o filtro.
        final bool inlineSearch = find.byType(TextField).evaluate().isNotEmpty;
        if (!inlineSearch) {
          await tester.tap(find.byTooltip('Buscar e filtrar'));
          await tester.pumpAndSettle();
        }
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          'Karl Marx',
        );
        if (!inlineSearch) {
          Navigator.of(tester.element(find.text('Explorar a teia'))).pop();
          await tester.pumpAndSettle();
        }
        expect(
          tester
              .widget<StudyConstellation>(find.byType(StudyConstellation))
              .selected
              ?.key,
          marx.key,
        );
        final TransformationController recovered = tester
            .widget<InteractiveViewer>(find.byType(InteractiveViewer))
            .transformationController!;
        expect(identical(camera, recovered), isTrue);
        expect(recovered.value.storage, before);
        // A Teia oculta a navegação global por design; ao voltar para a lista,
        // a aba Atlas ativa não deve empilhar uma nova rota.
        await tester.tap(find.byTooltip('Voltar à lista'));
        await tester.pumpAndSettle();
        expect(
          identical(tester.state(find.byType(AtlasExplorerScreen)), original),
          isTrue,
        );
        // A folha modal de busca (mobile) conta como push; a base de
        // comparação passa a ser o estado após fechá-la.
        final int pushesBeforeTab = observer.pushes;
        await tester.tap(
          find.text(width >= 1100 ? 'Atlas político' : 'Atlas').last,
        );
        await tester.pumpAndSettle();
        expect(observer.pushes, pushesBeforeTab);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'perfil aberto por deep link cria raiz Atlas quando não há rota anterior',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.defaultRouteNameTestValue = studyProfileRoute(
        'personality:karl_marx',
      );
      addTearDown(tester.platformDispatcher.clearDefaultRouteNameTestValue);
      final AppViewModel vm = await model();
      addTearDown(vm.dispose);
      await tester.pumpWidget(EspectroApp(appViewModel: vm));
      await tester.pumpAndSettle();
      expect(find.byType(StudyProfileScreen), findsOneWidget);
      await tester.tap(find.text('Atlas'));
      await tester.pumpAndSettle();
      expect(find.byType(AtlasExplorerScreen), findsOneWidget);
      expect(find.byType(StudyProfileScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'desktop 1100/1440 exibe todos os itens do rail sem cortes nem banners duplicados',
    (tester) async {
      for (final double width in <double>[1100, 1440]) {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final AppViewModel vm = await model();
        addTearDown(vm.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness: Brightness.light),
            home: EspectroScaffold(
              appViewModel: vm,
              isSectionRoot: true,
              body: const Text('Conteúdo'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        for (final String label in const <String>[
          'Visão geral',
          'Meus testes',
          'Atlas político',
          'Comparar',
          'Histórico',
          'Método aberto',
        ]) {
          final Finder finder = find.text(label);
          expect(finder, findsOneWidget);
          final Rect rect = tester.getRect(finder);
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(236));
          expect(rect.bottom, lessThanOrEqualTo(1000));
          final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
            finder,
          );
          expect(paragraph.didExceedMaxLines, isFalse);
        }

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness: Brightness.light),
            home: AtlasExplorerScreen(appViewModel: vm),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(EspectroFloatingAdBar), findsOneWidget);
        expect(find.byType(EspectroBannerAdWidget), findsNothing);
        expect(find.byType(BackButton), findsNothing);
        expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness: Brightness.light),
            home: EspectroHomeScreen(appViewModel: vm),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(EspectroFloatingAdBar), findsOneWidget);
        expect(find.byType(EspectroBannerAdWidget), findsNothing);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness: Brightness.light),
            home: StudyProfileScreen(
              appViewModel: vm,
              subjectKey: 'personality:karl_marx',
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(EspectroFloatingAdBar), findsOneWidget);
        expect(find.byType(EspectroBannerAdWidget), findsNothing);
        expect(tester.takeException(), isNull);
      }
    },
  );
}

class _NavigationObserver extends NavigatorObserver {
  int pushes = 0;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
    super.didPush(route, previousRoute);
  }
}
