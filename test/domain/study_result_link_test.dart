import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/domain/models/study_result_link.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  setUpAll(() async {
    data = await AppData.load();
  });

  EvaluationRecord build(TestSuite suite, TestDepth depth) {
    final QuizViewModel quiz = QuizViewModel.startNew(
      data: data,
      repository: EvaluationRepository(storage: LocalStorageService.inMemory()),
      suite: suite,
      depth: depth,
      seed: 47,
    );
    for (var i = 0; i < quiz.totalCount; i++) {
      quiz.jumpTo(i);
      if (i % 7 == 0) {
        quiz.skipCurrent();
      } else {
        quiz.selectAnswer(LikertAnswer.values[i % LikertAnswer.values.length]);
      }
    }
    return quiz.buildCompletedRecord(now: DateTime.utc(2026, 11, 3));
  }

  String token(Map<String, Object?> record, {int version = 1}) => base64Url
      .encode(
        utf8.encode(
          jsonEncode(<String, Object?>{'v': version, 'record': record}),
        ),
      )
      .replaceAll('=', '');

  test('round-trip mantém respostas, pulos, incerteza e apoio absoluto nas três modalidades', () {
    for (final TestSuite suite in TestSuite.values) {
      final EvaluationRecord original = build(
        suite,
        TestDepth.quick,
      ).copyWith(title: 'Minhas posições — ação');
      final EvaluationRecord? decoded = decodeStudyResult(
        encodeStudyResult(original),
      );
      expect(decoded, isNotNull);
      expect(decoded!.toJson(), original.toJson());
      expect(decoded.rawAnswers.values, contains(null));
    }
  });

  test('avaliação integral cabe no limite e reabre todas as respostas', () {
    final EvaluationRecord original = build(
      TestSuite.espectroIntegrated,
      TestDepth.exhaustive,
    );
    final String encoded = encodeStudyResult(original);
    expect(encoded.length, lessThanOrEqualTo(studyResultLinkLimit));
    expect(decodeStudyResult(encoded)!.rawAnswers, original.rawAnswers);
  });

  test(
    'versões desconhecidas, texto arbitrário e tokens grandes são rejeitados',
    () {
      final Map<String, Object?> json = build(
        TestSuite.bipolarAxes,
        TestDepth.quick,
      ).toJson();
      expect(decodeStudyResult(token(json, version: 2)), isNull);
      json['schemaVersion'] = 2;
      expect(decodeStudyResult(token(json)), isNull);
      for (final String value in <String>[
        '',
        '%%%%',
        'a',
        'a' * 100001,
        base64Url.encode(<int>[255]),
      ]) {
        expect(decodeStudyResult(value), isNull);
      }
    },
  );

  test(
    'recusa score adulterado em vez de aplicar clamp ou inventar dimensão',
    () {
      final Map<String, Object?> json = build(
        TestSuite.espectroIntegrated,
        TestDepth.quick,
      ).toJson();
      final List<Object?> axes = json['axes'] as List<Object?>;
      final Map<String, Object?> first = axes.first! as Map<String, Object?>;
      first['score'] = 12;
      expect(decodeStudyResult(token(json)), isNull);
      first['score'] = 0;
      first['axisId'] = 'inventado';
      expect(decodeStudyResult(token(json)), isNull);
      first['axisId'] = 'estrutura';
      axes.add(Map<String, Object?>.from(first));
      expect(decodeStudyResult(token(json)), isNull);
    },
  );

  test('recusa Likert, contagens e vetores fora dos limites', () {
    Map<String, Object?> fresh() =>
        build(TestSuite.espectroIntegrated, TestDepth.quick).toJson();
    final Map<String, Object?> invalidAnswer = fresh();
    final Map<String, int?> answers =
        invalidAnswer['rawAnswers']! as Map<String, int?>;
    answers[answers.keys.first] = 3;
    expect(decodeStudyResult(token(invalidAnswer)), isNull);
    final Map<String, Object?> invalidCount = fresh();
    (invalidCount['quality']! as Map<String, Object?>)['totalPresented'] = -1;
    expect(decodeStudyResult(token(invalidCount)), isNull);
    final Map<String, Object?> invalidTriad = fresh();
    ((invalidTriad['triads']! as List<Object?>).first!
        as Map<String, Object?>)['composition'] = <double>[
      1,
      1,
      1,
    ];
    expect(decodeStudyResult(token(invalidTriad)), isNull);
    final Map<String, Object?> invalidCategory = fresh();
    ((invalidCategory['triads']! as List<Object?>).first!
            as Map<String, Object?>)['categoryId'] =
        6;
    expect(decodeStudyResult(token(invalidCategory)), isNull);
  });

  test('limita bytes mesmo com muitos campos individualmente válidos', () {
    final Map<String, Object?> json = build(
      TestSuite.bipolarAxes,
      TestDepth.quick,
    ).toJson();
    json['rawAnswers'] = <String, int>{
      for (var i = 0; i < 2000; i++) 'axis:${'q' * 94}_$i': 1,
    };
    final Map<String, Object?> quality =
        json['quality']! as Map<String, Object?>;
    quality['totalPresented'] = 2000;
    quality['totalAnswered'] = 2000;
    quality['totalSkipped'] = 0;
    final EvaluationRecord large = EvaluationRecord.fromJson(json);
    expect(() => encodeStudyResult(large), throwsFormatException);
    expect(decodeStudyResult(token(json)), isNull);
  });

  test('exportação excessiva retorna erro tratável e não gera URL parcial', () {
    final EvaluationRecord original = build(TestSuite.triads, TestDepth.quick);
    expect(
      () => encodeStudyResult(original.copyWith(title: 'x' * 100001)),
      throwsFormatException,
    );
  });

  test('codec compacto v2 empacota 12 eixos e 6 tríades em ~34 caracteres preservando ausências', () {
    final EvaluationRecord integrated = build(
      TestSuite.espectroIntegrated,
      TestDepth.standard,
    );
    final String compact = encodeCompactProfile(integrated);
    expect(compact.length, lessThanOrEqualTo(36));
    expect(compact.length, greaterThanOrEqualTo(32));

    final EvaluationRecord? decoded = decodeStudyResult(compact);
    expect(decoded, isNotNull);
    expect(decoded!.rawAnswers, isEmpty);
    for (final axis in integrated.axes) {
      final restored = decoded.axisById(axis.axisId)!;
      expect(restored.isIndeterminate, axis.isIndeterminate);
      if (!axis.isIndeterminate) {
        expect(restored.score, closeTo(axis.score, 0.015));
      }
    }
    for (final triad in integrated.triads) {
      final restored = decoded.triadByCategoryId(triad.categoryId)!;
      expect(restored.isIndeterminate, triad.isIndeterminate);
      if (!triad.isIndeterminate) {
        for (var i = 0; i < 3; i++) {
          expect(restored.composition[i], closeTo(triad.composition[i], 0.02));
        }
      }
    }

    // Modalidade apenas 12 Eixos deve preservar tríades como indeterminadas (sem centro falso)
    final EvaluationRecord axesOnly = build(TestSuite.bipolarAxes, TestDepth.quick);
    final EvaluationRecord? decodedAxesOnly = decodeCompactProfile(
      encodeCompactProfile(axesOnly),
    );
    expect(decodedAxesOnly, isNotNull);
    expect(decodedAxesOnly!.triads.every((t) => t.isIndeterminate), isTrue);
    expect(decodeCompactProfile('invalid_token_xyz'), isNull);
  });
}
