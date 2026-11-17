import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/theme.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';
import 'package:politico/ui/features/share/share_card_content.dart';
import 'package:politico/ui/features/share/share_card_export.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  setUpAll(() async => data = await AppData.load());
  test('public entry link removes sensitive route and query', () {
    final link = shareCardEntryLink(
      base: Uri.parse(
        'https://example.test/app/?score=99#/shared?data=private',
      ),
    )!;
    expect(link, isNot(contains('private')));
    expect(link, isNot(contains('score')));
    expect(link, isNot(contains('shared')));
  });
  for (final story in [false, true]) {
    testWidgets(
      'PNG ${story ? "9:16" : "1:1"} has real dimensions and no false center',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final quiz = QuizViewModel.startNew(
          data: data,
          repository: EvaluationRepository(
            storage: LocalStorageService.inMemory(),
          ),
          suite: TestSuite.espectroIntegrated,
          depth: TestDepth.quick,
          seed: 4,
        );
        final record = quiz.buildCompletedRecord();
        expect(ShareCardEvidence.fromRecord(record).nolan, isNull);
        expect(ShareCardEvidence.fromRecord(record).discoveryAxis, isNull);
        final key = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness: Brightness.light),
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: key,
                  child: ShareCardCanvas(
                    record: record,
                    data: data,
                    story: story,
                    entryLink: 'https://espectro.example.test',
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Nolan indeterminado'), findsOneWidget);
        expect(find.textContaining('50%'), findsNothing);
        await tester.runAsync(() async {
          final bytes = await captureShareCardPng(key);
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          expect(frame.image.width, 1080);
          expect(frame.image.height, story ? 1920 : 1080);
          frame.image.dispose();
          codec.dispose();
        });
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final story in [false, true]) {
    testWidgets(
      'PNG ${story ? "9:16" : "1:1"} com respostas reais renderiza teia e eixos sem overflow',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 2200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final quiz = QuizViewModel.startNew(
          data: data,
          repository: EvaluationRepository(
            storage: LocalStorageService.inMemory(),
          ),
          suite: TestSuite.espectroIntegrated,
          depth: TestDepth.quick,
          seed: 4,
        );
        for (var i = 0; i < quiz.totalCount; i++) {
          quiz.jumpTo(i);
          quiz.selectAnswer(LikertAnswer.values[i % LikertAnswer.values.length]);
        }
        final record = quiz.buildCompletedRecord();
        final evidence = ShareCardEvidence.fromRecord(record);
        expect(evidence.axes, isNotEmpty);
        expect(evidence.nolan, isNotNull);
        final key = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness: Brightness.light),
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: key,
                  child: ShareCardCanvas(
                    record: record,
                    data: data,
                    story: story,
                    entryLink: 'https://espectro.example.test',
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Nolan indeterminado'), findsNothing);
        expect(find.byType(ShareCardCanvas), findsOneWidget);
        await tester.runAsync(() async {
          final bytes = await captureShareCardPng(key);
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          expect(frame.image.width, 1080);
          expect(frame.image.height, story ? 1920 : 1080);
          frame.image.dispose();
          codec.dispose();
        });
        expect(tester.takeException(), isNull);
      },
    );
  }
}
