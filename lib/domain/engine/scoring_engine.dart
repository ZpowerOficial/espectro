import 'dart:math' as math;

import '../../data/models.dart';
import '../models/political_models.dart';

/// Resultado completo produzido pelo motor de pontuação do Espectro.
class ScoredEvaluation {
  const ScoredEvaluation({
    required this.axes,
    required this.triads,
    required this.quality,
  });

  final List<BipolarDimensionScore> axes;
  final List<TriadDimensionScore> triads;
  final ResponseQualityReport quality;
}

/// Motor matemático puro de avaliação política do Espectro.
///
/// Propriedades garantidas:
/// - **Invariância à ordem**: permutar perguntas e respostas não altera nenhum número.
/// - **Simetria de inversão**: inverter todas as respostas (`r -> -r`) inverte exatamente
///   os escores bipolares (`S -> -S`) e os escores de vértice (`v_k -> -v_k`).
/// - **Separação entre neutro e pulo**: `LikertAnswer.neutral` (`0`) puxa para o centro
///   e aumenta a cobertura; `null` (pular) não enviesa o escore e reduz a cobertura.
/// - **Superação do fechamento composicional nas tríades**: preserva `engagement` (`I`)
///   além da composição baricêntrica `p`, distinguindo apoio amplo de rejeição ampla.
abstract final class EspectroScoringEngine {
  static ScoredEvaluation evaluate({
    required TwelveAxesData axesData,
    required SixTrianglesData trianglesData,
    required TestSuite suite,
    required List<UnifiedQuestion> questions,
    required Map<String, int?> rawAnswersByUid,
  }) {
    final List<BipolarDimensionScore> axes = suite.includesAxes
        ? _scoreAxes(axesData, questions, rawAnswersByUid)
        : const <BipolarDimensionScore>[];

    final List<TriadDimensionScore> triads = suite.includesTriads
        ? _scoreTriads(trianglesData, questions, rawAnswersByUid)
        : const <TriadDimensionScore>[];

    final ResponseQualityReport quality = _computeQuality(
      questions: questions,
      rawAnswersByUid: rawAnswersByUid,
      axes: axes,
    );

    return ScoredEvaluation(axes: axes, triads: triads, quality: quality);
  }

  static List<BipolarDimensionScore> _scoreAxes(
    TwelveAxesData axesData,
    List<UnifiedQuestion> questions,
    Map<String, int?> rawAnswersByUid,
  ) {
    final Map<String, List<UnifiedQuestion>> byAxis =
        <String, List<UnifiedQuestion>>{};
    for (final UnifiedQuestion q in questions) {
      if (q.kind == UnifiedQuestionKind.bipolar ||
          (q.kind == UnifiedQuestionKind.integrated && q.axisQuestion != null)) {
        byAxis
            .putIfAbsent(q.axisQuestion!.axisId, () => <UnifiedQuestion>[])
            .add(q);
      }
    }

    final List<BipolarDimensionScore> results = <BipolarDimensionScore>[];
    for (final Axis axis in axesData.axes) {
      final List<UnifiedQuestion> items =
          byAxis[axis.id] ?? const <UnifiedQuestion>[];
      var presentedWeight = 0.0;
      var answeredWeight = 0.0;
      var weightedSum = 0.0;
      var weightSqSum = 0.0;
      var answeredCount = 0;
      var presentedLeftCount = 0;
      var presentedRightCount = 0;
      var answeredLeftCount = 0;
      var answeredRightCount = 0;

      // Acumuladores separados por direção de chaveamento para detectar tensão interna:
      // se o usuário concorda fortemente com itens de AMBOS os polos, leftKeyedRawMean e
      // rightKeyedRawMean ficam ambos altos, elevando tensionScore!
      var leftKeyedWeight = 0.0;
      var leftKeyedContributionSum = 0.0;
      var rightKeyedWeight = 0.0;
      var rightKeyedContributionSum = 0.0;

      final List<({double weight, double contribution})> samples =
          <({double weight, double contribution})>[];
      final List<ItemContribution> contributions = <ItemContribution>[];

      for (final UnifiedQuestion item in items) {
        final AxisQuestion aq = item.axisQuestion!;
        final double w = item.weight;
        presentedWeight += w;
        if (aq.agreeIsLeft) {
          presentedLeftCount++;
        } else {
          presentedRightCount++;
        }

        final int? rawVal = rawAnswersByUid[item.uid];
        if (rawVal == null) continue;
        final LikertAnswer ans = LikertAnswer.fromValue(rawVal);
        final double x = ans.normalized;
        // Se agreeIsLeft, concordar (x > 0) empurra S para -1 (leftPole).
        final double c = aq.agreeIsLeft ? -x : x;

        answeredCount++;
        answeredWeight += w;
        weightedSum += w * c;
        weightSqSum += w * w;
        samples.add((weight: w, contribution: c));

        if (aq.agreeIsLeft) {
          answeredLeftCount++;
          leftKeyedWeight += w;
          leftKeyedContributionSum += w * c;
        } else {
          answeredRightCount++;
          rightKeyedWeight += w;
          rightKeyedContributionSum += w * c;
        }

        contributions.add(
          ItemContribution(
            questionUid: item.uid,
            statement: aq.text,
            answer: ans,
            weight: w,
            signedContribution: c,
            targetLabel: c <= 0 ? axis.leftPole : axis.rightPole,
          ),
        );
      }

      final double score = answeredWeight == 0
          ? 0.0
          : (weightedSum / answeredWeight).clamp(-1.0, 1.0);
      final double coverage = presentedWeight == 0
          ? 0.0
          : (answeredWeight / presentedWeight).clamp(0.0, 1.0);
      final double se = _estimateStandardError(
        samples: samples,
        mean: score,
        answeredWeight: answeredWeight,
        weightSqSum: weightSqSum,
      );

      double tension = 0.0;
      final double leftPoleMean = leftKeyedWeight == 0
          ? 0.0
          : leftKeyedContributionSum / leftKeyedWeight;
      final double rightPoleMean = rightKeyedWeight == 0
          ? 0.0
          : rightKeyedContributionSum / rightKeyedWeight;
      if (leftKeyedWeight > 0 && rightKeyedWeight > 0) {
        tension = (rightPoleMean - leftPoleMean).abs().clamp(0.0, 2.0);
      }

      contributions.sort(
        (a, b) => b.weightedMagnitude.compareTo(a.weightedMagnitude),
      );

      results.add(
        BipolarDimensionScore(
          axisId: axis.id,
          label: axis.label,
          leftPole: axis.leftPole,
          rightPole: axis.rightPole,
          score: score,
          standardError: se,
          coverage: coverage,
          answeredCount: answeredCount,
          presentedCount: items.length,
          tensionScore: tension,
          topContributions: contributions.take(6).toList(),
          poleBreakdownAvailable: true,
          answeredLeftCount: answeredLeftCount,
          presentedLeftCount: presentedLeftCount,
          answeredRightCount: answeredRightCount,
          presentedRightCount: presentedRightCount,
          leftPoleMean: leftPoleMean,
          rightPoleMean: rightPoleMean,
        ),
      );
    }

    return results;
  }

  static List<TriadDimensionScore> _scoreTriads(
    SixTrianglesData trianglesData,
    List<UnifiedQuestion> questions,
    Map<String, int?> rawAnswersByUid,
  ) {
    final Map<int, List<UnifiedQuestion>> byCat =
        <int, List<UnifiedQuestion>>{};
    for (final UnifiedQuestion q in questions) {
      if (q.kind == UnifiedQuestionKind.triad ||
          (q.kind == UnifiedQuestionKind.integrated && q.sixQuestion != null)) {
        byCat
            .putIfAbsent(q.sixQuestion!.category, () => <UnifiedQuestion>[])
            .add(q);
      }
    }

    final List<TriadDimensionScore> results = <TriadDimensionScore>[];
    for (final SixCategory category in trianglesData.categories) {
      final List<UnifiedQuestion> catItems =
          byCat[category.id] ?? const <UnifiedQuestion>[];
      final List<double> vScores = List<double>.filled(3, 0.0);
      final List<double> uSupports = List<double>.filled(3, 0.5);
      final List<double> vertexSes = List<double>.filled(3, 0.5);
      final List<double> vertexCoverage = List<double>.filled(3, 0.0);
      final List<bool> vertexObserved = List<bool>.filled(3, false);
      final List<int> vertexAnswered = List<int>.filled(3, 0);
      final List<int> vertexPresented = List<int>.filled(3, 0);

      var totalPresentedWeight = 0.0;
      var totalAnsweredWeight = 0.0;
      var totalAnsweredCount = 0;
      final List<ItemContribution> contributions = <ItemContribution>[];

      for (var sub = 0; sub < 3; sub++) {
        var subAnsW = 0.0;
        var subPresentedW = 0.0;
        var subWSq = 0.0;
        var subSum = 0.0;
        var subPresentedCount = 0;
        var subAnsweredCount = 0;
        final List<({double weight, double contribution})> subSamples =
            <({double weight, double contribution})>[];

        for (final UnifiedQuestion item in catItems) {
          final SixQuestion sq = item.sixQuestion!;
          if (sq.subcategory != sub) continue;
          final double w = item.weight;
          subPresentedCount++;
          subPresentedW += w;
          totalPresentedWeight += w;

          final int? rawVal = rawAnswersByUid[item.uid];
          if (rawVal == null) continue;
          final LikertAnswer ans = LikertAnswer.fromValue(rawVal);
          final double x = ans.normalized;
          final double c = sq.multiplier * x;

          subAnsweredCount++;
          totalAnsweredCount++;
          totalAnsweredWeight += w;
          subAnsW += w;
          subWSq += w * w;
          subSum += w * c;
          subSamples.add((weight: w, contribution: c));

          contributions.add(
            ItemContribution(
              questionUid: item.uid,
              statement: sq.text,
              answer: ans,
              weight: w,
              signedContribution: c,
              targetLabel: category.subcategories[sub],
            ),
          );
        }

        vertexPresented[sub] = subPresentedCount;
        vertexAnswered[sub] = subAnsweredCount;
        vertexObserved[sub] = subAnsweredCount > 0;
        vertexCoverage[sub] = subPresentedW == 0
            ? 0.0
            : (subAnsW / subPresentedW).clamp(0.0, 1.0);

        if (!vertexObserved[sub]) {
          // Preenchimento neutro explícito, nunca apresentado como observação.
          vScores[sub] = 0.0;
          uSupports[sub] = 0.5;
          vertexSes[sub] = 0.5;
          continue;
        }

        final double v = (subSum / subAnsW).clamp(-1.0, 1.0);
        vScores[sub] = v;
        uSupports[sub] = ((v + 1.0) / 2.0).clamp(0.0, 1.0);
        vertexSes[sub] =
            _estimateStandardError(
              samples: subSamples,
              mean: v,
              answeredWeight: subAnsW,
              weightSqSum: subWSq,
            ) /
            2.0;
      }

      final int observedCount = vertexObserved
          .where((bool observed) => observed)
          .length;
      var sumObservedU = 0.0;
      var sumObservedSe = 0.0;
      for (var k = 0; k < 3; k++) {
        if (!vertexObserved[k]) continue;
        sumObservedU += uSupports[k];
        sumObservedSe += vertexSes[k];
      }

      final double engagement;
      final List<double> composition;
      if (observedCount == 3) {
        // Todos os vértices observados: composição baricêntrica completa.
        final double sumU = uSupports[0] + uSupports[1] + uSupports[2];
        composition = sumU <= 1e-9
            ? const <double>[1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0]
            : <double>[
                uSupports[0] / sumU,
                uSupports[1] / sumU,
                uSupports[2] / sumU,
              ];
        engagement = (sumU / 3.0).clamp(0.0, 1.0);
      } else if (observedCount == 2) {
        // Composição condicional aos vértices observados; o vértice sem
        // evidência recebe participação zero e o resultado é indeterminado.
        composition = sumObservedU <= 1e-9
            ? const <double>[1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0]
            : <double>[
                for (var k = 0; k < 3; k++)
                  vertexObserved[k] ? uSupports[k] / sumObservedU : 0.0,
              ];
        engagement = (sumObservedU / observedCount).clamp(0.0, 1.0);
      } else {
        // Com menos de dois vértices não há triângulo determinável; usa-se a
        // posição neutra apenas como placeholder visual.
        composition = const <double>[1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0];
        engagement = observedCount == 1
            ? uSupports[vertexObserved.indexOf(true)].clamp(0.0, 1.0)
            : 0.5;
      }

      final double coverage = totalPresentedWeight == 0
          ? 0.0
          : (totalAnsweredWeight / totalPresentedWeight).clamp(0.0, 1.0);

      // Propagação aproximada do erro-padrão para a composição baricêntrica.
      final double meanVertexSe = observedCount == 0
          ? 0.5
          : sumObservedSe / observedCount;
      final double denom = math.max(
        0.6,
        sumObservedU <= 1e-9 ? 1.5 : sumObservedU,
      );
      final double compSe = observedCount < 3
          ? 0.50
          : (meanVertexSe / denom).clamp(0.02, 0.50);

      final bool indeterminate =
          totalAnsweredCount == 0 ||
          coverage < 0.5 ||
          observedCount < 3 ||
          totalAnsweredCount < 3;
      final String classification = classifyTriadTransparent(
        vertices: category.subcategories,
        composition: composition,
        vertexSupport: uSupports,
        engagement: engagement,
        isIndeterminate: indeterminate,
      );

      contributions.sort(
        (a, b) => b.weightedMagnitude.compareTo(a.weightedMagnitude),
      );

      results.add(
        TriadDimensionScore(
          categoryId: category.id,
          label: category.label,
          vertices: category.subcategories,
          vertexScores: vScores,
          vertexSupport: uSupports,
          composition: composition,
          engagement: engagement,
          standardError: compSe,
          coverage: coverage,
          answeredCount: totalAnsweredCount,
          presentedCount: catItems.length,
          classification: classification,
          topContributions: contributions.take(6).toList(),
          vertexBreakdownAvailable: true,
          vertexCoverage: vertexCoverage,
          vertexObserved: vertexObserved,
          vertexAnsweredCount: vertexAnswered,
          vertexPresentedCount: vertexPresented,
        ),
      );
    }

    return results;
  }

  /// Classificação geométrica transparente que resolve o problema do fechamento
  /// composicional: diferencia apoio simultâneo aos 3 vértices, rejeição aos 3,
  /// equilíbrio moderado, síntese de 2 vértices e predomínio de 1 vértice.
  static String classifyTriadTransparent({
    required List<String> vertices,
    required List<double> composition,
    required List<double> vertexSupport,
    required double engagement,
    required bool isIndeterminate,
  }) {
    if (isIndeterminate) return 'Dados insuficientes';

    final List<int> order = <int>[0, 1, 2]
      ..sort((a, b) => composition[b].compareTo(composition[a]));
    final int idxMax = order[0];
    final int idxMid = order[1];
    final int idxMin = order[2];

    final double pMax = composition[idxMax];
    final double pMid = composition[idxMid];
    final double pMin = composition[idxMin];
    final double diff = pMax - pMin;

    if (diff < 0.14) {
      if (engagement >= 0.65) {
        return 'Apoio amplo aos 3 vértices';
      }
      if (engagement <= 0.35) {
        return 'Ceticismo nos 3 vértices';
      }
      return 'Equilíbrio entre os 3 vértices';
    }

    if (pMax - pMid >= 0.14) {
      final String dominant = vertices[idxMax];
      final double uDom = vertexSupport[idxMax];
      if (pMax >= 0.52 && uDom >= 0.72) {
        return 'Predomínio forte de $dominant';
      }
      if (pMax >= 0.42 && uDom >= 0.55) {
        return 'Predomínio de $dominant';
      }
      return 'Inclinação a $dominant';
    }

    if (pMid - pMin >= 0.14) {
      return 'Síntese ${vertices[idxMax]} + ${vertices[idxMid]}';
    }

    return 'Equilíbrio com tendência a ${vertices[idxMax]}';
  }

  static double _estimateStandardError({
    required List<({double weight, double contribution})> samples,
    required double mean,
    required double answeredWeight,
    required double weightSqSum,
  }) {
    if (samples.isEmpty || answeredWeight <= 0) return 0.55;
    final double nEff =
        (answeredWeight * answeredWeight) / math.max(1e-9, weightSqSum);
    if (samples.length == 1 || nEff <= 1.05) {
      return 0.40;
    }
    var varNum = 0.0;
    for (final ({double weight, double contribution}) s in samples) {
      final double d = s.contribution - mean;
      varNum += s.weight * d * d;
    }
    final double unbiasedFactor = nEff / math.max(0.25, nEff - 1.0);
    final double sampleVar = (varNum / answeredWeight) * unbiasedFactor;
    // Piso bayesiano leve (0.04 de variância prévia) para que 3 respostas idênticas
    // não exibam erro-padrão zero irrealista num teste curto.
    final double regularizedVar = (sampleVar * (nEff - 1.0) + 0.12) / nEff;
    return math.sqrt(regularizedVar / nEff).clamp(0.02, 0.55);
  }

  static ResponseQualityReport _computeQuality({
    required List<UnifiedQuestion> questions,
    required Map<String, int?> rawAnswersByUid,
    required List<BipolarDimensionScore> axes,
  }) {
    var answered = 0;
    var skipped = 0;
    var rawSum = 0.0;
    var extremeCount = 0;
    var neutralCount = 0;

    for (final UnifiedQuestion q in questions) {
      final int? val = rawAnswersByUid[q.uid];
      if (val == null) {
        skipped++;
        continue;
      }
      answered++;
      final LikertAnswer ans = LikertAnswer.fromValue(val);
      rawSum += ans.normalized;
      if (ans.value.abs() == 2) extremeCount++;
      if (ans.value == 0) neutralCount++;
    }

    final List<String> tensions = <String>[
      for (final BipolarDimensionScore axis in axes)
        if (axis.hasInternalTension) axis.label,
    ];
    final int answeredAxisCount = axes
        .where((BipolarDimensionScore axis) => axis.answeredCount > 0)
        .length;

    return ResponseQualityReport(
      totalPresented: questions.length,
      totalAnswered: answered,
      totalSkipped: skipped,
      acquiescenceIndex: answered == 0
          ? 0.0
          : (rawSum / answered).clamp(-1.0, 1.0),
      extremeResponseRate: answered == 0 ? 0.0 : extremeCount / answered,
      neutralResponseRate: answered == 0 ? 0.0 : neutralCount / answered,
      axesInTension: tensions,
      answeredAxisCount: answeredAxisCount,
    );
  }
}
