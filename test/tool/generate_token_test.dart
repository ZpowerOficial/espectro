import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/domain/models/study_result_link.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generate valid fixture token for capture script with full quality payload', () async {
    final appData = await AppData.load();
    final repo = EvaluationRepository(storage: LocalStorageService.inMemory());
    final quiz = QuizViewModel.startNew(
      data: appData,
      repository: repo,
      suite: TestSuite.espectroIntegrated,
      depth: TestDepth.quick,
      seed: 42,
    );

    for (var i = 0; i < quiz.totalCount; i++) {
      quiz.jumpTo(i);
      if (i % 8 == 0) {
        quiz.skipCurrent();
      } else if (i % 3 == 0) {
        quiz.selectAnswer(LikertAnswer.stronglyAgree);
      } else if (i % 3 == 1) {
        quiz.selectAnswer(LikertAnswer.agree);
      } else {
        quiz.selectAnswer(LikertAnswer.disagree);
      }
    }

    final record = quiz.buildCompletedRecord(now: DateTime.utc(2026, 11, 11));
    final token = encodeStudyResult(record);

    final decoded = decodeStudyResult(token);
    expect(decoded, isNotNull);
    expect(decoded!.quality.totalAnswered, greaterThan(0));

    final outputFile = File('tool/valid_shared_token.txt');
    await outputFile.writeAsString(token);
    // ignore: avoid_print
    print('VALID_TOKEN_GENERATED: $token');
  });
}
