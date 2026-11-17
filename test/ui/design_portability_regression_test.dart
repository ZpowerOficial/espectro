import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/features/history/history_evolution_screen.dart';
import 'package:politico/ui/features/home/espectro_home_screen.dart';
import 'package:politico/ui/features/quiz/espectro_quiz_screen.dart';
import 'package:politico/ui/view_models/app_view_model.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';
import 'package:politico/widgets/common.dart';
import 'package:politico/widgets/quiz_chrome.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;

  setUpAll(() async {
    data = await AppData.load();
  });

  Future<AppViewModel> createVm({bool withRecord = false}) async {
    final EvaluationRepository repo = EvaluationRepository(
      storage: LocalStorageService.inMemory(),
    );
    final AppViewModel vm = AppViewModel(
      data: data,
      repository: repo,
    );
    await vm.initialize();
    if (withRecord) {
      final QuizViewModel quiz = QuizViewModel.startNew(
        data: data,
        repository: repo,
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.quick,
        seed: 7,
      );
      for (int i = 0; i < quiz.totalCount; i++) {
        quiz.selectAnswer(LikertAnswer.agree);
        if (!quiz.isLast) quiz.next();
      }
      final EvaluationRecord rec = quiz.buildCompletedRecord();
      await vm.recordCompletedEvaluation(rec);
    }
    return vm;
  }

  testWidgets('Historico expoe cartao e exclusao como botoes semanticos independentes', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    final AppViewModel vm = await createVm(withRecord: true);
    addTearDown(vm.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(brightness: Brightness.light),
        home: HistoryEvolutionScreen(appViewModel: vm),
      ),
    );
    await tester.pumpAndSettle();

    final Finder cardFinder = find.byWidgetPredicate(
      (Widget w) =>
          w is Semantics &&
          w.properties.button == true &&
          (w.properties.label?.startsWith('Abrir avaliação ') ?? false),
    );
    expect(cardFinder, findsOneWidget);

    final SemanticsNode cardNode = tester.getSemantics(cardFinder);
    expect(cardNode.flagsCollection.isButton, isTrue);
    expect(cardNode.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    final Finder deleteBtn = find.byTooltip('Excluir');
    expect(deleteBtn, findsOneWidget);
    final SemanticsNode deleteNode = tester.getSemantics(deleteBtn);
    expect(deleteNode.flagsCollection.isButton, isTrue);
    handle.dispose();
  });

  testWidgets('Quiz chrome adapta superficies ao tema escuro sem vazar claro', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(brightness: Brightness.dark),
        home: Scaffold(
          body: Column(
            children: <Widget>[
              QuizTopBar(onBack: () {}, progress: 0.4, counter: '1 / 10'),
              AxisChip(axis: data.twelveAxes.axes.first),
              CategoryChip(category: data.sixTriangles.categories.first),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder axisContainer = find.descendant(
      of: find.byType(AxisChip),
      matching: find.byWidgetPredicate(
        (Widget w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == EspectroPalette.dark.surface,
      ),
    );
    expect(axisContainer, findsOneWidget);
  });

  testWidgets('Quiz desktop responde a atalhos de teclado 1..5 e setas', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppViewModel vm = await createVm();
    addTearDown(vm.dispose);

    final QuizViewModel quizVm = QuizViewModel.startNew(
      data: data,
      repository: EvaluationRepository(storage: LocalStorageService.inMemory()),
      suite: TestSuite.bipolarAxes,
      depth: TestDepth.quick,
      seed: 1,
    );
    addTearDown(quizVm.dispose);
    vm.setAutoAdvance(false);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(brightness: Brightness.light),
        home: EspectroQuizScreen(
          appViewModel: vm,
          quizViewModel: quizVm,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Atalhos: teclas 1–5'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pumpAndSettle();
    expect(quizVm.currentAnswer, LikertAnswer.stronglyAgree);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(quizVm.currentIndex, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(quizVm.currentIndex, 0);
  });

  testWidgets('Home nao transborda em mobile e desktop mesmo com fonte em 2.0x', (
    WidgetTester tester,
  ) async {
    final AppViewModel vm = await createVm(withRecord: true);
    addTearDown(vm.dispose);

    for (final Size viewport in const <Size>[Size(390, 844), Size(1366, 768)]) {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(brightness: Brightness.light),
          home: MediaQuery(
            data: MediaQueryData(
              size: viewport,
              textScaler: const TextScaler.linear(2.0),
            ),
            child: EspectroHomeScreen(appViewModel: vm),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Overflow inesperado no viewport $viewport em 2.0x',
      );
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('HorizontalAffordanceStrip exibe seta de rolagem no desktop quando ha corte', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(brightness: Brightness.light),
        home: Scaffold(
          body: SizedBox(
            width: 240,
            height: 80,
            child: HorizontalAffordanceStrip(
              builder: (BuildContext context, ScrollController controller) {
                return SingleChildScrollView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      for (int i = 0; i < 8; i++)
                        SizedBox(width: 90, child: Text('Item $i')),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder nextArrow = find.byTooltip('Rolar para a direita');
    expect(nextArrow, findsOneWidget);
    await tester.tap(nextArrow);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Rolar para a esquerda'), findsOneWidget);
  });

  testWidgets('Hero showcase alterna arquetipos em 12 eixos sem erro', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppViewModel vm = await createVm();
    addTearDown(vm.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(brightness: Brightness.light),
        home: EspectroHomeScreen(appViewModel: vm),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PRÉVIA EM 12 EIXOS'), findsOneWidget);
    expect(find.text('Hannah Arendt'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Marx'));
    await tester.pumpAndSettle();
    expect(find.text('Karl Marx'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Rothbard'));
    await tester.pumpAndSettle();
    expect(find.text('Murray N. Rothbard'), findsAtLeastNWidgets(1));
    expect(tester.takeException(), isNull);
  });
}
