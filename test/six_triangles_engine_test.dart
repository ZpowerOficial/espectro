import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/models.dart';
import 'package:politico/engine/six_triangles_engine.dart';

SixTrianglesData _fixture() {
  final List<SixCategory> categories = <SixCategory>[
    for (var i = 0; i < 6; i++)
      SixCategory(
        id: i,
        label: 'Categoria $i',
        color: const Color(0xFF8DD3C7),
        subcategories: <String>['A$i', 'B$i', 'C$i'],
      ),
  ];
  final List<SixQuestion> questions = <SixQuestion>[];
  for (var category = 0; category < 6; category++) {
    for (var sub = 0; sub < 3; sub++) {
      for (var bucket = 0; bucket < 4; bucket++) {
        final bool positive = bucket.isEven;
        questions.add(
          SixQuestion(
            id: questions.length,
            category: category,
            subcategory: sub,
            strength: positive ? bucket + 1 : 4 - bucket,
            multiplier: positive ? 1 : -1,
            text: 'Pergunta $category-$sub-$bucket',
          ),
        );
      }
    }
  }
  return SixTrianglesData(categories: categories, questions: questions);
}

void main() {
  group('seleção do Six Triangles', () {
    test('curta usa 1 pergunta por célula e totaliza 72', () {
      final List<SixQuestion> questions = selectSixQuestions(
        _fixture(),
        SixVariant.short,
        Random(3),
      );
      expect(questions.length, 72);
      expect(questions.map((q) => q.id).toSet().length, 72);
    });

    test('curta falha quando uma célula está vazia', () {
      final SixTrianglesData data = _fixture();
      final SixTrianglesData incomplete = SixTrianglesData(
        categories: data.categories,
        questions: data.questions.where((q) => q.id != 0).toList(),
      );
      expect(
        () => selectSixQuestions(incomplete, SixVariant.short, Random(1)),
        throwsStateError,
      );
    });
  });

  group('pontuação do Six Triangles', () {
    test('agrega contribuições com o multiplicador e normaliza em 1000', () {
      final SixTrianglesSession session = SixTrianglesSession(
        data: _fixture(),
        variant: SixVariant.short,
        random: Random(9),
      );
      for (var i = 0; i < session.questions.length; i++) {
        session.answers[i] = 0;
      }
      final SixTrianglesResult result = session.result()!;
      expect(result.triangles.length, 6);

      final List<int> expected = List<int>.filled(18, 1);
      for (final SixQuestion question in session.questions) {
        expected[question.category * 3 + question.subcategory] +=
            question.multiplier == 1 ? 4 : 0;
      }
      final List<int> totals = List<int>.filled(6, 0);
      for (var i = 0; i < 18; i++) {
        totals[i ~/ 3] += expected[i];
      }
      for (final TriangleScore triangle in result.triangles) {
        for (var sub = 0; sub < 3; sub++) {
          final int raw = expected[triangle.category.id * 3 + sub];
          expect(
            triangle.points[sub],
            closeTo(raw * 1000 / totals[triangle.category.id], 1),
          );
        }
        expect(triangle.points.reduce((a, b) => a + b), closeTo(1000, 2));
        expect(triangle.classification, isNotEmpty);
      }
    });

    test('resultado nulo enquanto faltar resposta', () {
      final SixTrianglesSession session = SixTrianglesSession(
        data: _fixture(),
        variant: SixVariant.short,
        random: Random(10),
      );
      expect(session.result(), isNull);
      for (var i = 0; i < session.questions.length - 1; i++) {
        session.answers[i] = 2;
      }
      expect(session.result(), isNull);
      session.answers[session.questions.length - 1] = 2;
      expect(session.result(), isNotNull);
    });
  });

  group('classificação dos triângulos', () {
    const List<String> subs = <String>['Um', 'Dois', 'Três'];

    test('vértice dominante acima de 900 é fanático', () {
      expect(classifyTriangle(<int>[900, 60, 40], subs), 'Fanático por Um');
    });

    test('vértice dominante entre 750 e 900 é extremo', () {
      expect(classifyTriangle(<int>[760, 150, 90], subs), 'Extremo em Um');
    });

    test('vértice dominante entre 500 e 750 fica em destaque', () {
      expect(classifyTriangle(<int>[600, 300, 100], subs), 'Um em destaque');
    });

    test('vértice dominante abaixo de 500 é moderado', () {
      expect(classifyTriangle(<int>[450, 300, 250], subs), 'Moderado em Um');
    });

    test('vértice quase nulo vira anti', () {
      expect(classifyTriangle(<int>[100, 500, 400], subs), 'Anti-Um');
    });

    test('vértice praticamente zerado é fanático anti', () {
      expect(classifyTriangle(<int>[5, 500, 495], subs), 'Fanático anti-Um');
    });

    test('vértice entre 10 e 50 é extremo anti', () {
      expect(classifyTriangle(<int>[30, 500, 470], subs), 'Extremo anti-Um');
    });

    test('três vértices próximos são centristas', () {
      expect(classifyTriangle(<int>[340, 330, 330], subs), 'Centrista');
    });
  });
}
