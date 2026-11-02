import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/models.dart';
import 'package:politico/engine/six_triangles_engine.dart';
import 'package:politico/engine/twelve_axes_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppData data;

  setUpAll(() async {
    data = await AppData.load();
  });

  test('12 Eixos tem 12 eixos e 240 perguntas íntegras', () {
    final TwelveAxesData twelve = data.twelveAxes;
    expect(twelve.axes.length, 12);
    expect(twelve.questions.length, 240);
    expect(twelve.answerOptions.length, 5);
    expect(twelve.archetypeQuestions.length, 5);

    final Set<String> axisIds = twelve.axes.map((axis) => axis.id).toSet();
    for (final Axis axis in twelve.axes) {
      final List<AxisQuestion> questions = twelve.questionsFor(axis.id);
      expect(questions.length, 20, reason: axis.id);
      expect(questions.where((q) => q.agreeIsLeft).length, 10, reason: axis.id);
    }
    for (final AxisQuestion question in twelve.questions) {
      expect(axisIds, contains(question.axisId));
      expect(question.text.trim(), isNotEmpty);
      expect(question.help.agree.trim(), isNotEmpty);
    }
    for (final ArchetypeQuestion question in twelve.archetypeQuestions) {
      expect(question.options.length, greaterThanOrEqualTo(5));
    }
  });

  test('variantes do 12 Eixos respeitam a contagem por eixo', () {
    for (final TwelveVariant variant in TwelveVariant.values) {
      final TwelveAxesSession session = TwelveAxesSession(
        data: data.twelveAxes,
        variant: variant,
        random: Random(11),
      );
      expect(session.questions.length, variant.questionCount, reason: variant.name);
      if (variant != TwelveVariant.extreme) {
        for (final Axis axis in data.twelveAxes.axes) {
          expect(
            session.questions.where((q) => q.axisId == axis.id).length,
            variant.perAxis,
            reason: '${variant.name}/${axis.id}',
          );
        }
      }
    }
  });

  test('respostas neutras no 12 Eixos resultam em todos os eixos no centro', () {
    final TwelveAxesSession session = TwelveAxesSession(
      data: data.twelveAxes,
      variant: TwelveVariant.short,
      random: Random(12),
    );
    for (var i = 0; i < session.questions.length; i++) {
      session.answers[i] = 2;
    }
    final TwelveAxesResult result = session.result()!;
    expect(result.scores.length, 12);
    for (final AxisScore score in result.scores) {
      expect(score.leftPercent, closeTo(50, 0.001), reason: score.axis.id);
      expect(score.intensity, 'Equilibrado');
    }
  });

  test('Six Triangles tem 6 categorias e 193 perguntas traduzidas', () {
    final SixTrianglesData six = data.sixTriangles;
    expect(six.categories.length, 6);
    expect(six.questions.length, 193);
    for (final SixCategory category in six.categories) {
      expect(category.subcategories.length, 3);
      expect(category.label.trim(), isNotEmpty);
    }
    for (final SixQuestion question in six.questions) {
      expect(question.category, inInclusiveRange(0, 5));
      expect(question.subcategory, inInclusiveRange(0, 2));
      expect(question.text.trim(), isNotEmpty);
    }
    expect(six.questions.map((q) => q.text).toSet().length, 193);
  });

  test('variantes do Six Triangles têm 72 e 144 perguntas', () {
    for (final SixVariant variant in SixVariant.values) {
      final SixTrianglesSession session = SixTrianglesSession(
        data: data.sixTriangles,
        variant: variant,
        random: Random(13),
      );
      expect(session.questions.length, variant.questionCount, reason: variant.name);
      expect(session.questions.map((q) => q.id).toSet().length, variant.questionCount);
    }
  });

  test('respostas neutras no Six Triangles resultam em triângulos centristas', () {
    for (final SixVariant variant in SixVariant.values) {
      final SixTrianglesSession session = SixTrianglesSession(
        data: data.sixTriangles,
        variant: variant,
        random: Random(14),
      );
      for (var i = 0; i < session.questions.length; i++) {
        session.answers[i] = 2;
      }
      final SixTrianglesResult result = session.result()!;
      expect(result.triangles.length, 6);
      for (final TriangleScore triangle in result.triangles) {
        for (final int point in triangle.points) {
          expect(point, closeTo(333.33, 0.7));
        }
        expect(triangle.classification, 'Centrista', reason: triangle.category.label);
      }
    }
  });

  test('validações de contrato e bounds rejeitam JSON corrompido', () {
    expect(
      () => AnswerOption.fromJson(const {
        'id': 'BAD',
        'label': 'Ruim',
        'scoreTowardAgreement': 1.5,
      }, 'test'),
      throwsA(isA<FormatException>()),
    );

    expect(
      () => SixQuestion.fromJson(const {
        'id': 1,
        'category': 8,
        'subcategory': 0,
        'strength': 2,
        'multiplier': 1,
        'text': 'Inválido',
      }, 'test'),
      throwsA(isA<FormatException>()),
    );

    expect(
      () => SixCategory.fromJson(const {
        'id': 9,
        'label': 'Inválido',
        'color': '#FFFFFF',
        'subcategories': ['A', 'B', 'C'],
      }, 'test'),
      throwsA(isA<FormatException>()),
    );

    expect(
      () => QuestionTerm.fromJson(const {
        'start': 10,
        'end': 5,
        'term': 'T',
        'definition': 'D',
      }, 'test'),
      throwsA(isA<FormatException>()),
    );
  });
}
