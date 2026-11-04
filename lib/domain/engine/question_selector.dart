import 'dart:math';

import '../../data/models.dart';
import '../models/political_models.dart';

/// Selecionador estratificado e determinístico por semente para o banco unificado.
///
/// Garante:
/// 1. Balanceamento de polaridade (50% polo esquerdo / 50% polo direito nos eixos,
///    e 50% `multiplier == +1` / 50% `multiplier == -1` nos vértices triangulares,
///    quando o número por estrato é par; alternância compensada quando ímpar).
/// 2. Embaralhamento intercalado para evitar blocos monotemáticos ou de mesma direção.
List<UnifiedQuestion> selectUnifiedQuestions({
  required TwelveAxesData axesData,
  required SixTrianglesData trianglesData,
  required TestSuite suite,
  required TestDepth depth,
  required int seed,
}) {
  final Random random = Random(seed);
  final List<UnifiedQuestion> positivePool = <UnifiedQuestion>[];
  final List<UnifiedQuestion> negativePool = <UnifiedQuestion>[];

  if (suite.includesAxes) {
    final int perAxis = depth.axesPerDimension(suite);
    for (var axisIndex = 0; axisIndex < axesData.axes.length; axisIndex++) {
      final Axis axis = axesData.axes[axisIndex];
      final List<AxisQuestion> allAxis = axesData.questionsFor(axis.id);
      final List<AxisQuestion> left =
          allAxis.where((q) => q.agreeIsLeft).toList()..shuffle(random);
      final List<AxisQuestion> right =
          allAxis.where((q) => !q.agreeIsLeft).toList()..shuffle(random);

      if (perAxis == 0) {
        for (final AxisQuestion q in left) {
          negativePool.add(UnifiedQuestion.bipolar(q));
        }
        for (final AxisQuestion q in right) {
          positivePool.add(UnifiedQuestion.bipolar(q));
        }
      } else {
        final int fromLeft = axisIndex.isEven
            ? (perAxis + 1) ~/ 2
            : perAxis ~/ 2;
        final int fromRight = perAxis - fromLeft;
        if (left.length < fromLeft || right.length < fromRight) {
          throw StateError(
            'Banco insuficiente no eixo ${axis.id}: necessário ($fromLeft L, $fromRight R), '
            'disponível (${left.length} L, ${right.length} R).',
          );
        }
        for (final AxisQuestion q in left.take(fromLeft)) {
          negativePool.add(UnifiedQuestion.bipolar(q));
        }
        for (final AxisQuestion q in right.take(fromRight)) {
          positivePool.add(UnifiedQuestion.bipolar(q));
        }
      }
    }
  }

  if (suite.includesTriads) {
    final int perVertex = depth.triadPerVertex(suite);
    final Map<int, List<SixQuestion>> byVertexPos = <int, List<SixQuestion>>{};
    final Map<int, List<SixQuestion>> byVertexNeg = <int, List<SixQuestion>>{};

    for (final SixQuestion q in trianglesData.questions) {
      final int key = q.category * 3 + q.subcategory;
      if (q.multiplier == 1) {
        byVertexPos.putIfAbsent(key, () => <SixQuestion>[]).add(q);
      } else {
        byVertexNeg.putIfAbsent(key, () => <SixQuestion>[]).add(q);
      }
    }

    for (var cat = 0; cat < trianglesData.categories.length; cat++) {
      for (var sub = 0; sub < 3; sub++) {
        final int key = cat * 3 + sub;
        final List<SixQuestion> pos = <SixQuestion>[...?byVertexPos[key]]
          ..shuffle(random);
        final List<SixQuestion> neg = <SixQuestion>[...?byVertexNeg[key]]
          ..shuffle(random);

        if (perVertex == 0) {
          for (final SixQuestion q in pos) {
            positivePool.add(UnifiedQuestion.triad(q));
          }
          for (final SixQuestion q in neg) {
            negativePool.add(UnifiedQuestion.triad(q));
          }
        } else {
          int wantPos = key.isEven ? (perVertex + 1) ~/ 2 : perVertex ~/ 2;
          int wantNeg = perVertex - wantPos;
          // Caso o banco base sem expansão tenha menos negativos em algum vértice,
          // compensa de forma graciosa com o outro polo sem falhar se houver total suficiente.
          if (neg.length < wantNeg) {
            final int deficit = wantNeg - neg.length;
            wantNeg = neg.length;
            wantPos += deficit;
          } else if (pos.length < wantPos) {
            final int deficit = wantPos - pos.length;
            wantPos = pos.length;
            wantNeg += deficit;
          }
          if (pos.length < wantPos || neg.length < wantNeg) {
            throw StateError(
              'Banco insuficiente na tríade cat=$cat sub=$sub para $perVertex itens.',
            );
          }
          for (final SixQuestion q in pos.take(wantPos)) {
            positivePool.add(UnifiedQuestion.triad(q));
          }
          for (final SixQuestion q in neg.take(wantNeg)) {
            negativePool.add(UnifiedQuestion.triad(q));
          }
        }
      }
    }
  }

  positivePool.shuffle(random);
  negativePool.shuffle(random);

  final List<UnifiedQuestion> interleaved = <UnifiedQuestion>[];
  var takePositive = random.nextBool();
  var pIdx = 0;
  var nIdx = 0;
  final int total = positivePool.length + negativePool.length;
  while (interleaved.length < total) {
    final bool hasPos = pIdx < positivePool.length;
    final bool hasNeg = nIdx < negativePool.length;
    if (takePositive && hasPos) {
      interleaved.add(positivePool[pIdx++]);
    } else if (!takePositive && hasNeg) {
      interleaved.add(negativePool[nIdx++]);
    } else if (hasPos) {
      interleaved.add(positivePool[pIdx++]);
    } else {
      interleaved.add(negativePool[nIdx++]);
    }
    takePositive = !takePositive;
  }

  return interleaved;
}
