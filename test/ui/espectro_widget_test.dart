import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/app.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/charts/interactive_triad_chart.dart';
import 'package:politico/ui/features/quiz/espectro_quiz_screen.dart';
import 'package:politico/ui/features/results/espectro_result_screen.dart';
import 'package:politico/ui/view_models/app_view_model.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';
import 'package:politico/widgets/common.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppData data;
  late EvaluationRepository repository;
  late AppViewModel appVm;

  setUpAll(() async {
    data = await AppData.load();
  });

  setUp(() async {
    repository = EvaluationRepository(storage: LocalStorageService.inMemory());
    appVm = AppViewModel(data: data, repository: repository);
    await appVm.initialize();
  });

  testWidgets(
    'alterna entre temas claro e escuro na tela inicial e abre metodologia',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await appVm.setThemeMode(ThemeMode.light);
      await tester.pumpWidget(EspectroApp(appViewModel: appVm));
      await tester.pumpAndSettle();

      expect(find.text('ESPECTRO'), findsOneWidget);
      expect(
        find.text('Fazer Avaliação Rápida (3 min)'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.text('12 EIXOS'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('12 EIXOS'), findsOneWidget);

      BuildContext scaffoldCtx = tester.element(find.byType(Scaffold).first);
      expect(
        Theme.of(scaffoldCtx).extension<EspectroPalette>()!.isDark,
        isFalse,
      );

      await appVm.setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();

      scaffoldCtx = tester.element(find.byType(Scaffold).first);
      expect(
        Theme.of(scaffoldCtx).extension<EspectroPalette>()!.isDark,
        isTrue,
      );

      // Volta ao topo para tocar no ícone de Metodologia.
      await tester.scrollUntilVisible(
        find.byIcon(Icons.science_outlined),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.science_outlined));
      await tester.pumpAndSettle();

      expect(find.textContaining('Metodologia'), findsWidgets);
    },
  );

  testWidgets(
    'inicia questionário, responde e pula item explicitamente com sucesso',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await appVm.setAutoAdvance(false);
      await tester.pumpWidget(EspectroApp(appViewModel: appVm));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('12 EIXOS'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('12 EIXOS'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12 EIXOS'));
      await tester.pumpAndSettle();

      final Finder startFinder = find.textContaining('Iniciar avaliação');
      await tester.scrollUntilVisible(
        startFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(startFinder.first);
      await tester.pumpAndSettle();
      await tester.tap(startFinder.first);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Concordo totalmente'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Concordo totalmente'), findsOneWidget);
      await tester.tap(find.text('Concordo totalmente'));
      await tester.pumpAndSettle();

      final Finder skipFinder = find.textContaining('Pular');
      expect(skipFinder, findsWidgets);
      await tester.tap(skipFinder.first);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'renderiza tela de resultados integrada com gráfico triangular interativo',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final QuizViewModel quizVm = QuizViewModel.startNew(
        data: data,
        repository: repository,
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.quick,
        seed: 55,
      );
      for (var i = 0; i < quizVm.totalCount; i++) {
        quizVm.jumpTo(i);
        quizVm.selectAnswer(
          i % 3 == 0 ? LikertAnswer.stronglyAgree : LikertAnswer.disagree,
        );
      }
      final EvaluationRecord record = quizVm.buildCompletedRecord();
      await appVm.recordCompletedEvaluation(record);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(brightness: Brightness.light),
          darkTheme: buildAppTheme(brightness: Brightness.dark),
          home: EspectroResultScreen(
            appViewModel: appVm,
            record: record,
            initialTabIndex: 2,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Composição relativa e apoio absoluto são apresentados separadamente,
      // com cobertura e confiança declaradas.
      expect(find.textContaining('Composição:'), findsWidgets);
      expect(find.textContaining('Apoio absoluto:'), findsWidgets);
      // Tag renderiza label.toUpperCase():
      expect(find.textContaining('COBERTURA'), findsWidgets);
      expect(find.textContaining('CONFIANÇA'), findsWidgets);
      expect(find.textContaining('APOIO MÉDIO I'), findsWidgets);

      final Finder triadChart = find.byType(InteractiveTriadChart);
      expect(triadChart, findsWidgets);
      await tester.ensureVisible(triadChart.first);
      await tester.pumpAndSettle();
      await tester.tap(triadChart.first);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'sinaliza vértice não avaliado e dimensão indeterminada nas tríades',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final QuizViewModel quizVm = QuizViewModel.startNew(
        data: data,
        repository: repository,
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.quick,
        seed: 55,
      );
      for (var i = 0; i < quizVm.totalCount; i++) {
        quizVm.jumpTo(i);
        final UnifiedQuestion q = quizVm.questions[i];
        // Omite o terceiro vértice de cada tríade: a dimensão fica indeterminada.
        if (q.kind == UnifiedQuestionKind.triad &&
            q.sixQuestion!.subcategory == 2) {
          continue;
        }
        quizVm.selectAnswer(LikertAnswer.agree);
      }
      final EvaluationRecord record = quizVm.buildCompletedRecord();
      await appVm.recordCompletedEvaluation(record);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(brightness: Brightness.light),
          home: EspectroResultScreen(
            appViewModel: appVm,
            record: record,
            initialTabIndex: 2,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Tríades (6)').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('não avaliado'), findsWidgets);
      expect(find.textContaining('Dimensão indeterminada'), findsWidgets);
      expect(find.textContaining('INDETERMINADO'), findsWidgets);
    },
  );

  testWidgets(
    'renderiza responsivamente em viewport largo (Desktop/Web) sem overflow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final QuizViewModel quizVm = QuizViewModel.startNew(
        data: data,
        repository: repository,
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.quick,
        seed: 42,
      );
      for (var i = 0; i < quizVm.totalCount; i++) {
        quizVm.jumpTo(i);
        quizVm.selectAnswer(LikertAnswer.agree);
      }
      final EvaluationRecord record = quizVm.buildCompletedRecord();
      await appVm.recordCompletedEvaluation(record);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(brightness: Brightness.light),
          home: EspectroResultScreen(
            appViewModel: appVm,
            record: record,
            initialTabIndex: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(InteractiveTriadChart), findsOneWidget);

      // Alterna para a aba de tríades em tela larga
      final Finder triadTab = find.text('Tríades (6)');
      expect(triadTab, findsOneWidget);
      await tester.tap(triadTab);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(InteractiveTriadChart), findsWidgets);
    },
  );

  for (final double width in const <double>[390.0, 1440.0]) {
    testWidgets(
      'Home executa Dilema Relâmpago e Desafio de Intuição Política sem erros em $width',
      (WidgetTester tester) async {
        tester.view.physicalSize = Size(width, width < 1100 ? 844 : 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(EspectroApp(appViewModel: appVm));
        await tester.pumpAndSettle();

        expect(find.text('DILEMA RELÂMPAGO · 1/24'), findsOneWidget);
        await tester.ensureVisible(find.text('Outro dilema'));
        await tester.tap(find.text('Outro dilema'));
        await tester.pumpAndSettle();
        expect(find.text('ECONOMIA · PÚBLICO VS. PRIVADO'), findsOneWidget);

        await tester.ensureVisible(find.text('Discordo'));
        await tester.tap(find.text('Discordo'));
        await tester.pumpAndSettle();
        expect(
          find.text('4% concluído (1/24) · Seu Arquétipo começou a emergir'),
          findsOneWidget,
        );

        final Finder homeScrollable = find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first;

        await tester.scrollUntilVisible(
          find.text('Quem pensa assim?'),
          220,
          scrollable: homeScrollable,
        );
        await tester.pumpAndSettle();

        final Finder riddleCard = find
            .ancestor(
              of: find.text('Quem pensa assim?'),
              matching: find.byType(SectionCard),
            )
            .first;
        final Finder arendtOption = find.descendant(
          of: riddleCard,
          matching: find.text('Hannah Arendt'),
        );
        await Scrollable.ensureVisible(
          tester.element(arendtOption),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(arendtOption);
        await tester.pumpAndSettle();

        expect(find.text('Sequência: 1'), findsOneWidget);
        expect(find.text('Acertos: 1/1'), findsOneWidget);
        expect(find.text('Leitura certeira! É Hannah Arendt.'), findsOneWidget);

        final Finder nextEnigma = find.text('Próximo enigma →');
        await Scrollable.ensureVisible(
          tester.element(nextEnigma),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(nextEnigma);
        await tester.pumpAndSettle();
        expect(find.text('Enigma 2 de 5'), findsOneWidget);

        // Retoma ao topo e confirma que o CTA do Dilema inicia o Expresso em 2/24.
        await tester.scrollUntilVisible(
          find.text('Continuar da pergunta 2/24 →'),
          -250,
          scrollable: homeScrollable,
        );
        await Scrollable.ensureVisible(
          tester.element(find.text('Continuar da pergunta 2/24 →')),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continuar da pergunta 2/24 →'));
        await tester.pumpAndSettle();

        expect(find.byType(EspectroQuizScreen), findsOneWidget);
        final EspectroQuizScreen quizWidget = tester.widget<EspectroQuizScreen>(
          find.byType(EspectroQuizScreen),
        );
        expect(quizWidget.quizViewModel.depth, TestDepth.express);
        expect(quizWidget.quizViewModel.answeredCount, 1);
        expect(quizWidget.quizViewModel.currentIndex, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
