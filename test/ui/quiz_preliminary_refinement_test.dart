import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/app.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/ui/features/quiz/espectro_quiz_screen.dart';
import 'package:politico/ui/features/results/espectro_result_screen.dart';
import 'package:politico/ui/view_models/app_view_model.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';

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
    'permite ver resultado preliminar após x perguntas e voltar ao teste para refinar',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 2000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final QuizViewModel quizVm = QuizViewModel.startNew(
        data: data,
        repository: repository,
        suite: TestSuite.bipolarAxes,
        depth: TestDepth.standard,
        seed: 42,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: EspectroQuizScreen(
            appViewModel: appVm,
            quizViewModel: quizVm,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Antes de 4 respostas, canPreview é falso e a opção não aparece no menu.
      expect(quizVm.canPreview, isFalse);
      await tester.tap(find.byTooltip('Opções da avaliação'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Ver prévia'), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Responde 5 afirmações
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('Concordo totalmente'));
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
      }

      // Agora canPreview é verdadeiro e a opção aparece no menu discreto.
      expect(quizVm.canPreview, isTrue);
      expect(quizVm.answeredCount, equals(5));
      await tester.tap(find.byTooltip('Opções da avaliação'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Ver prévia (5/'), findsOneWidget);

      // Clica para ver o resultado preliminar
      await tester.tap(find.textContaining('Ver prévia (5/'));
      await tester.pumpAndSettle();

      // Estamos agora na tela de resultados com o banner preliminar
      expect(find.byType(EspectroResultScreen), findsOneWidget);
      expect(find.text('RESULTADO PRELIMINAR'), findsWidgets);
      expect(
        find.textContaining('5 de ${quizVm.totalCount} afirmações respondidas'),
        findsOneWidget,
      );
      expect(find.textContaining('Continuar teste e refinar'), findsWidgets);

      // Toca em "Continuar teste e refinar"
      await tester.tap(find.textContaining('Continuar teste e refinar').first);
      await tester.pumpAndSettle();

      // Deve ter retornado exatamente para a tela do questionário
      expect(find.byType(EspectroQuizScreen), findsOneWidget);
      expect(find.byType(EspectroResultScreen), findsNothing);

      // Responde mais afirmações para ir refinando o resultado
      await tester.tap(find.text('Discordo totalmente'));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(quizVm.answeredCount, equals(6));

      // Abre a prévia novamente pelo menu discreto, agora com 6 respondidas
      await tester.tap(find.byTooltip('Opções da avaliação'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Ver prévia (6/'));
      await tester.pumpAndSettle();

      expect(find.byType(EspectroResultScreen), findsOneWidget);
      expect(
        find.textContaining('6 de ${quizVm.totalCount} afirmações respondidas'),
        findsOneWidget,
      );

      // Usa o botão de voltar da AppBar que tem o tooltip "Voltar ao teste"
      await tester.tap(find.byTooltip('Voltar ao teste'));
      await tester.pumpAndSettle();

      expect(find.byType(EspectroQuizScreen), findsOneWidget);
    },
  );

  testWidgets(
    'resumo de rascunho na tela inicial permite continuar teste ou ver resultado preliminar',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Cria um rascunho ativo com 6 perguntas respondidas
      final QuizViewModel quizVm = QuizViewModel.startNew(
        data: data,
        repository: repository,
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.quick,
        seed: 77,
      );
      for (var i = 0; i < 6; i++) {
        quizVm.jumpTo(i);
        quizVm.selectAnswer(LikertAnswer.agree);
      }
      await quizVm.saveDraftAsync();
      await appVm.refreshDraft();

      await tester.pumpWidget(EspectroApp(appViewModel: appVm));
      await tester.pumpAndSettle();

      // Confere o card de rascunho na Home
      expect(find.text('SESSÃO EM ANDAMENTO'), findsOneWidget);
      expect(find.text('Continuar teste'), findsOneWidget);
      expect(find.text('Ver resultado até aqui'), findsOneWidget);

      // Toca em "Ver resultado até aqui" a partir da Home
      await tester.tap(find.text('Ver resultado até aqui'));
      await tester.pumpAndSettle();

      expect(find.byType(EspectroResultScreen), findsOneWidget);
      expect(find.text('RESULTADO PRELIMINAR'), findsWidgets);

      // Toca em "Continuar teste e refinar" na tela de resultados
      await tester.tap(find.textContaining('Continuar teste e refinar').first);
      await tester.pumpAndSettle();

      // Abre a tela de Quiz direto para continuar respondendo!
      expect(find.byType(EspectroQuizScreen), findsOneWidget);
    },
  );

  testWidgets(
    'modo Expresso exibe CTA para completar com as Tríades (+18 perguntas) e destrava aba Tríades ao concluir',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 2000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await appVm.setAutoAdvance(false);

      final QuizViewModel expressVm = QuizViewModel.startNew(
        data: data,
        repository: repository,
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.express,
        seed: 77,
      );
      for (var i = 0; i < expressVm.totalCount; i++) {
        expressVm.jumpTo(i);
        expressVm.selectAnswer(
          i.isEven ? LikertAnswer.agree : LikertAnswer.disagree,
        );
      }
      final EvaluationRecord expressRecord = expressVm.buildCompletedRecord();
      await appVm.recordCompletedEvaluation(expressRecord);

      await tester.pumpWidget(
        MaterialApp(
          home: EspectroResultScreen(
            appViewModel: appVm,
            record: expressRecord,
          ),
        ),
      );
      await tester.pumpAndSettle();

      const String ctaLabel =
          'Completar o perfil com as Tríades (+18 perguntas)';
      expect(find.text(ctaLabel), findsOneWidget);
      expect(find.text('Tríades (6)'), findsNothing);

      await tester.ensureVisible(find.text(ctaLabel));
      await tester.tap(find.text(ctaLabel));
      await tester.pumpAndSettle();

      expect(find.byType(EspectroQuizScreen), findsOneWidget);
      final EspectroQuizScreen supplementQuiz = tester.widget(
        find.byType(EspectroQuizScreen),
      );
      expect(supplementQuiz.quizViewModel.totalCount, 18);

      // Responde as 18 afirmações das tríades
      for (var i = 0; i < 18; i++) {
        await tester.tap(
          find.text(i.isEven ? 'Concordo' : 'Discordo'),
        );
        await tester.pumpAndSettle();
        if (i < 17) {
          await tester.tap(find.text('Próxima'));
          await tester.pumpAndSettle();
        }
      }
      await tester.tap(find.text('Concluir'));
      await tester.pumpAndSettle();

      // Volta para a tela de resultado atualizada com 12 Eixos + 6 Tríades
      expect(find.byType(EspectroResultScreen), findsOneWidget);
      expect(find.text(ctaLabel), findsNothing);
      expect(find.text('Tríades (6)'), findsOneWidget);
      expect(appVm.history.first.triads, hasLength(6));
      expect(appVm.history.first.suite, TestSuite.espectroIntegrated);
    },
  );
}
