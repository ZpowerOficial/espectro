import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/domain/models/study_result_link.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/features/share/shareable_card_sheet.dart';
import 'package:politico/ui/view_models/app_view_model.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  setUpAll(() async {
    data = await AppData.load();
    final FontLoader font = FontLoader('IBMPlexSans')
      ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Regular.ttf'));
    await font.load();
  });
  testWidgets(
    'copiar resultado exige confirmação e cancelar mantém clipboard intacto',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final EvaluationRepository repository = EvaluationRepository(
        storage: LocalStorageService.inMemory(),
      );
      final AppViewModel vm = AppViewModel(data: data, repository: repository);
      await vm.initialize();
      final QuizViewModel quiz = QuizViewModel.startNew(
        data: data,
        repository: repository,
        suite: TestSuite.espectroIntegrated,
        depth: TestDepth.quick,
        seed: 99,
      );
      for (var i = 0; i < quiz.totalCount; i++) {
        quiz.jumpTo(i);
        quiz.selectAnswer(LikertAnswer.agree);
      }
      final EvaluationRecord record = quiz.buildCompletedRecord();
      String? copied;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall call,
          ) async {
            if (call.method == 'Clipboard.setData') {
              copied =
                  (call.arguments as Map<Object?, Object?>)['text']! as String;
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(brightness: Brightness.light),
          home: Scaffold(
            body: ShareableCardSheet(record: record, appViewModel: vm),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final Finder action = find.text('Copiar link com minhas respostas');
      await tester.ensureVisible(action);
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.text('Copiar minhas respostas no link?'), findsOneWidget);
      expect(copied, isNull);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(copied, isNull);
      await tester.tap(action);
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Copiar link com minhas respostas'),
      );
      await tester.pumpAndSettle();
      expect(copied, isNotNull);
      final Uri parsed = Uri.parse(copied!);
      final Uri route = parsed.fragment.isEmpty
          ? parsed
          : Uri.parse(parsed.fragment);
      expect(route.path, '/shared');
      expect(route.queryParameters['v'], '1');
      expect(
        decodeStudyResult(route.queryParameters['data']!)!.rawAnswers,
        record.rawAnswers,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
