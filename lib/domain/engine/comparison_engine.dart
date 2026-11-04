import 'dart:math' as math;

import '../models/political_models.dart';
import 'compatibility_engine.dart';

/// Comparação de um eixo bipolar entre duas avaliações `baseline` (anterior) e `target` (atual).
class AxisComparisonDelta {
  const AxisComparisonDelta({
    required this.axisId,
    required this.label,
    required this.leftPole,
    required this.rightPole,
    required this.baselineScore,
    required this.targetScore,
    required this.combinedSe,
  });

  final String axisId;
  final String label;
  final String leftPole;
  final String rightPole;
  final double baselineScore;
  final double targetScore;
  final double combinedSe;

  /// Mudança em unidades de `S` (`[-2, +2]`); negativo = moveu para `leftPole`,
  /// positivo = moveu para `rightPole`.
  double get deltaScore => targetScore - baselineScore;

  /// Mudança em pontos percentuais (`[-100, +100]`) em direção ao polo direito.
  double get deltaPercentPoints => deltaScore * 50.0;

  /// Verdadeiro quando `|ΔS| > 1.96 · √(SE_A² + SE_B²)`.
  bool get isSignificant =>
      deltaScore.abs() > 1.96 * math.max(0.05, combinedSe);

  String get shiftSummary {
    final int pts = deltaPercentPoints.abs().round();
    if (pts == 0) return 'Sem variação';
    final String toward = deltaScore < 0 ? leftPole : rightPole;
    final String sig = isSignificant
        ? 'mudança significativa'
        : 'dentro da margem';
    return '+$pts pp rumo a $toward ($sig)';
  }
}

/// Comparação de uma tríade entre duas avaliações.
class TriadComparisonDelta {
  const TriadComparisonDelta({
    required this.categoryId,
    required this.label,
    required this.vertices,
    required this.baselineComposition,
    required this.targetComposition,
    required this.baselineEngagement,
    required this.targetEngagement,
    required this.combinedSe,
  });

  final int categoryId;
  final String label;
  final List<String> vertices;
  final List<double> baselineComposition;
  final List<double> targetComposition;
  final double baselineEngagement;
  final double targetEngagement;
  final double combinedSe;

  /// Distância baricêntrica normalizada em `[0, 1]`.
  double get compositionDistance {
    var sq = 0.0;
    for (var i = 0; i < 3; i++) {
      final double d = targetComposition[i] - baselineComposition[i];
      sq += d * d;
    }
    return math.sqrt(sq / 2.0);
  }

  double get engagementDelta => targetEngagement - baselineEngagement;

  bool get isSignificant =>
      compositionDistance > 1.96 * math.max(0.05, combinedSe);
}

/// Mudança em uma pergunta idêntica respondida em ambas as sessões.
class QuestionAnswerShift {
  const QuestionAnswerShift({
    required this.questionUid,
    required this.statement,
    required this.previousAnswer,
    required this.currentAnswer,
  });

  final String questionUid;
  final String statement;
  final LikertAnswer previousAnswer;
  final LikertAnswer currentAnswer;

  int get stepDiff => (currentAnswer.value - previousAnswer.value).abs();
}

/// Mudança de compatibilidade ideológica entre duas avaliações (funciona inclusive
/// entre testes de modalidades diferentes, como 12 Eixos vs. 6 Tríades!).
class CurrentComparisonShift {
  const CurrentComparisonShift({
    required this.current,
    required this.baselineCompatibility,
    required this.targetCompatibility,
  });

  final IdeologicalCurrent current;
  final double baselineCompatibility;
  final double targetCompatibility;

  double get delta => targetCompatibility - baselineCompatibility;
}

/// Relatório completo de comparação entre duas avaliações `baseline` e `target`.
class EvaluationComparisonReport {
  const EvaluationComparisonReport({
    required this.baseline,
    required this.target,
    required this.sharedAxes,
    required this.sharedTriads,
    required this.currentShifts,
    required this.sharedAnsweredQuestions,
    required this.unchangedAnswersCount,
    required this.answerShifts,
  });

  final EvaluationRecord baseline;
  final EvaluationRecord target;
  final List<AxisComparisonDelta> sharedAxes;
  final List<TriadComparisonDelta> sharedTriads;
  final List<CurrentComparisonShift> currentShifts;
  final int sharedAnsweredQuestions;
  final int unchangedAnswersCount;
  final List<QuestionAnswerShift> answerShifts;

  int get significantAxesCount =>
      sharedAxes.where((a) => a.isSignificant).length;

  int get significantTriadsCount =>
      sharedTriads.where((t) => t.isSignificant).length;

  bool get hasDirectDimensionOverlap =>
      sharedAxes.isNotEmpty || sharedTriads.isNotEmpty;
}

/// Ponto cronológico de evolução em uma série temporal.
class EvolutionPoint {
  const EvolutionPoint({
    required this.recordId,
    required this.timestamp,
    required this.suite,
    required this.value,
    required this.standardError,
    required this.label,
  });

  final String recordId;
  final DateTime timestamp;
  final TestSuite suite;

  /// Em `[0, 100]` (% do polo direito no caso de eixo bipolar, ou % do vértice na tríade).
  final double value;
  final double standardError;
  final String label;
}

/// Motor de comparação entre avaliações e construção de séries históricas de evolução.
abstract final class EspectroComparisonEngine {
  static EvaluationComparisonReport compare({
    required EvaluationRecord baseline,
    required EvaluationRecord target,
    required IdeologicalCatalog catalog,
    Map<String, String> questionTextByUid = const <String, String>{},
  }) {
    final List<AxisComparisonDelta> sharedAxes = <AxisComparisonDelta>[];
    for (final BipolarDimensionScore bAxis in baseline.axes) {
      if (bAxis.isIndeterminate) continue;
      final BipolarDimensionScore? tAxis = target.axisById(bAxis.axisId);
      if (tAxis == null || tAxis.isIndeterminate) continue;
      final double combSe = math.sqrt(
        bAxis.standardError * bAxis.standardError +
            tAxis.standardError * tAxis.standardError,
      );
      sharedAxes.add(
        AxisComparisonDelta(
          axisId: bAxis.axisId,
          label: bAxis.label,
          leftPole: bAxis.leftPole,
          rightPole: bAxis.rightPole,
          baselineScore: bAxis.score,
          targetScore: tAxis.score,
          combinedSe: combSe,
        ),
      );
    }

    final List<TriadComparisonDelta> sharedTriads = <TriadComparisonDelta>[];
    for (final TriadDimensionScore bTri in baseline.triads) {
      if (bTri.isIndeterminate) continue;
      final TriadDimensionScore? tTri = target.triadByCategoryId(
        bTri.categoryId,
      );
      if (tTri == null || tTri.isIndeterminate) continue;
      final double combSe = math.sqrt(
        bTri.standardError * bTri.standardError +
            tTri.standardError * tTri.standardError,
      );
      sharedTriads.add(
        TriadComparisonDelta(
          categoryId: bTri.categoryId,
          label: bTri.label,
          vertices: bTri.vertices,
          baselineComposition: bTri.composition,
          targetComposition: tTri.composition,
          baselineEngagement: bTri.engagement,
          targetEngagement: tTri.engagement,
          combinedSe: combSe,
        ),
      );
    }

    final CompatibilityReport baseCompat = EspectroCompatibilityEngine.evaluate(
      catalog: catalog,
      axes: baseline.axes,
      triads: baseline.triads,
    );
    final CompatibilityReport targCompat = EspectroCompatibilityEngine.evaluate(
      catalog: catalog,
      axes: target.axes,
      triads: target.triads,
    );

    final Map<String, double> baseMap = <String, double>{
      for (final CurrentCompatibility c in baseCompat.ranked)
        c.current.id: c.compatibilityPercent,
    };
    final List<CurrentComparisonShift> currentShifts =
        <CurrentComparisonShift>[];
    for (final CurrentCompatibility c in targCompat.ranked) {
      final double? bVal = baseMap[c.current.id];
      if (bVal == null) continue;
      currentShifts.add(
        CurrentComparisonShift(
          current: c.current,
          baselineCompatibility: bVal,
          targetCompatibility: c.compatibilityPercent,
        ),
      );
    }
    currentShifts.sort(
      (a, b) => b.targetCompatibility.compareTo(a.targetCompatibility),
    );

    var sharedAnswered = 0;
    var unchanged = 0;
    final List<QuestionAnswerShift> shifts = <QuestionAnswerShift>[];
    for (final MapEntry<String, int?> entry in baseline.rawAnswers.entries) {
      final int? prevVal = entry.value;
      if (prevVal == null) continue;
      final int? currVal = target.rawAnswers[entry.key];
      if (currVal == null) continue;
      sharedAnswered++;
      if (prevVal == currVal) {
        unchanged++;
      } else {
        shifts.add(
          QuestionAnswerShift(
            questionUid: entry.key,
            statement: questionTextByUid[entry.key] ?? entry.key,
            previousAnswer: LikertAnswer.fromValue(prevVal),
            currentAnswer: LikertAnswer.fromValue(currVal),
          ),
        );
      }
    }
    shifts.sort((a, b) => b.stepDiff.compareTo(a.stepDiff));

    return EvaluationComparisonReport(
      baseline: baseline,
      target: target,
      sharedAxes: sharedAxes,
      sharedTriads: sharedTriads,
      currentShifts: currentShifts,
      sharedAnsweredQuestions: sharedAnswered,
      unchangedAnswersCount: unchanged,
      answerShifts: shifts,
    );
  }

  /// Extrai a evolução cronológica (`0..100` para o polo direito) de um eixo bipolar.
  static List<EvolutionPoint> axisSeries({
    required List<EvaluationRecord> records,
    required String axisId,
  }) {
    final List<EvaluationRecord> chronological = <EvaluationRecord>[...records]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final List<EvolutionPoint> out = <EvolutionPoint>[];
    for (final EvaluationRecord rec in chronological) {
      final BipolarDimensionScore? axis = rec.axisById(axisId);
      if (axis == null || axis.isIndeterminate) continue;
      out.add(
        EvolutionPoint(
          recordId: rec.id,
          timestamp: rec.createdAt,
          suite: rec.suite,
          value: axis.rightPercent,
          standardError: axis.standardError * 50.0,
          label: axis.summary,
        ),
      );
    }
    return out;
  }

  /// Extrai a evolução cronológica (`0..100` de participação) de um vértice triangular.
  static List<EvolutionPoint> triadVertexSeries({
    required List<EvaluationRecord> records,
    required int categoryId,
    required int vertexIndex,
  }) {
    final List<EvaluationRecord> chronological = <EvaluationRecord>[...records]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final List<EvolutionPoint> out = <EvolutionPoint>[];
    for (final EvaluationRecord rec in chronological) {
      final TriadDimensionScore? triad = rec.triadByCategoryId(categoryId);
      if (triad == null || triad.isIndeterminate) continue;
      out.add(
        EvolutionPoint(
          recordId: rec.id,
          timestamp: rec.createdAt,
          suite: rec.suite,
          value: triad.composition[vertexIndex] * 100.0,
          standardError: triad.standardError * 100.0,
          label:
              '${(triad.composition[vertexIndex] * 100).round()}% ${triad.vertices[vertexIndex]}',
        ),
      );
    }
    return out;
  }
}
