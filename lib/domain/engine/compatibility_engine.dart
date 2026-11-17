import 'dart:math' as math;

import '../models/political_models.dart';
import 'triad_distance.dart';

/// Divergência ou convergência explicada em uma dimensão específica.
class DimensionAlignmentDetail {
  const DimensionAlignmentDetail({
    required this.dimensionId,
    required this.dimensionLabel,
    required this.isTriad,
    required this.normalizedZ,
    required this.relevance,
    required this.userSummary,
    required this.currentSummary,
    required this.note,
    this.rawDistance = 0.0,
    this.compositionDistance = 0.0,
    this.engagement = 0.5,
    this.engagementPenalty = 0.0,
    this.combinedDistance = 0.0,
    this.effectiveZ2,
    this.locator,
    this.sourceUrl,
  });

  final String dimensionId;
  final String dimensionLabel;
  final bool isTriad;

  /// Distância padronizada `z_d = dist / √(σ² + SE²)`.
  /// `z_d < 0.8` = proximidade relativa; `z_d > 1.3` = divergência relevante.
  final double normalizedZ;
  final double relevance;
  final String userSummary;
  final String currentSummary;
  final String note;

  /// Distância bruta real medida na dimensão (sem normalização e sem constantes artificiais).
  /// Nos eixos bipolares: |score - mu| ∈ [0.0, 2.0].
  /// Nas tríades: distância baricêntrica de composição d_comp ∈ [0.0, √2].
  final double rawDistance;

  /// Distância apenas na composição relativa (tríades) ou no eixo (eixos).
  final double compositionDistance;

  /// Apoio absoluto médio do usuário na dimensão (tríades; `0.5` nos eixos).
  final double engagement;

  /// Penalidade normalizada de engajamento `g ∈ [0, 1]` (tríades).
  final double engagementPenalty;

  /// Distância efetivamente usada no cálculo de `z` (composição + engajamento).
  final double combinedDistance;

  /// Contribuição quadrática efetiva (usada pelo Atlas: effZ2 = z² / (1 + z²/8)).
  final double? effectiveZ2;

  final String? locator;
  final String? sourceUrl;

  double get weightedImpact => effectiveZ2 != null
      ? (relevance * effectiveZ2!)
      : (relevance * normalizedZ * normalizedZ);
}

/// Resultado de compatibilidade do usuário com uma corrente ideológica.
class CurrentCompatibility {
  const CurrentCompatibility({
    required this.current,
    required this.compatibilityPercent,
    required this.rmsZ,
    required this.evaluatedDimensions,
    required this.convergences,
    required this.divergences,
    this.details = const <DimensionAlignmentDetail>[],
    this.evaluatedTriads = 0,
    this.meanTriadEngagement = 0.5,
    this.meanEngagementPenalty = 0.0,
  });

  final IdeologicalCurrent current;

  /// Decomposição analítica completa de todas as dimensões válidas avaliadas.
  final List<DimensionAlignmentDetail> details;

  /// Nota contínua em `[0.0, 100.0]`: `100 · exp(-D² / 2)`.
  /// Interpretação direta:
  /// - ~100%: coincidência plena com o centro da corrente
  /// - ~61%: distância média de 1 tolerância (`D = 1`)
  /// - ~14%: distância média de 2 tolerâncias (`D = 2`)
  final double compatibilityPercent;

  /// Raiz da distância quadrática média ponderada `D = √(Σ rel·z² / Σ rel)`.
  final double rmsZ;
  final int evaluatedDimensions;
  final List<DimensionAlignmentDetail> convergences;
  final List<DimensionAlignmentDetail> divergences;

  /// Número de tríades efetivamente comparadas (não indeterminadas).
  final int evaluatedTriads;

  /// Média do apoio absoluto do usuário nas tríades comparadas.
  final double meanTriadEngagement;

  /// Média da penalidade de engajamento `g` nas tríades comparadas.
  final double meanEngagementPenalty;
}

/// Síntese transparente da estimativa ideológica (nunca força rótulo único).
class CompatibilityReport {
  const CompatibilityReport({
    required this.ranked,
    required this.isHybridProfile,
    required this.isTechnicalTie,
    required this.headline,
    required this.explanation,
    this.isLowDiscrimination = false,
    this.tensionAxisCount = 0,
    this.evaluatedAxisCount = 0,
  });

  final List<CurrentCompatibility> ranked;
  final bool isHybridProfile;
  final bool isTechnicalTie;
  final String headline;
  final String explanation;

  /// `true` quando a própria estrutura balanceada do banco revelou respostas
  /// mutuamente incompatíveis em ao menos metade dos eixos avaliados.
  final bool isLowDiscrimination;
  final int tensionAxisCount;
  final int evaluatedAxisCount;

  List<CurrentCompatibility> get topMatches => ranked.take(6).toList();

  CurrentCompatibility? get primaryMatch =>
      ranked.isNotEmpty ? ranked.first : null;
}

/// Motor transparente de compatibilidade ideológica.
///
/// Fórmula única:
/// ```text
/// z_d    = dist(x_d, μ_d) / √(σ_d² + SE_d²)
/// D²     = Σ (rel_d · z_d²) / Σ rel_d
/// compat = 100 · exp(-D² / 2)
/// ```
/// Nos eixos bipolares, `dist = |S - μ|`. Nas tríades baricêntricas,
/// `dist` combina composição relativa e apoio absoluto conforme
/// [measureTriadDistance]:
/// ```text
/// d_comp = √(Σ(p_k - μ_k)² / 2)
/// g      = clamp((|I - 0.5| - 0.15) / 0.35, 0, 1)
/// dist   = √(d_comp² + 0.16 · g²)
/// ```
/// A inclusão de `g` penaliza respostas com engajamento extremo (apoio ou rejeição
/// total) em relação ao ponto de referência neutro (`I = 0.5`). Como os perfis do
/// catálogo definem apenas a composição relativa e não intensidades absolutas,
/// a distância escalar é simétrica em torno de `I = 0.5` (isto é, `I = 1.0` e `I = 0.0`
/// produzem a mesma penalidade `g`). Portanto, a distinção entre apoio militante e
/// rejeição veemente é comunicada qualitativamente na classificação da tríade e no
/// sumário de apoio aos vértices, e não na magnitude da distância escalar.
abstract final class EspectroCompatibilityEngine {
  static const double hybridThresholdPercent = 52.0;
  static const double tieMarginPercent = 4.5;
  static const double minimumComparisonCoverage = .60;

  static CompatibilityReport evaluate({
    required IdeologicalCatalog catalog,
    required List<BipolarDimensionScore> axes,
    required List<TriadDimensionScore> triads,
  }) {
    final List<BipolarDimensionScore> validAxes = axes
        .where((a) => !a.isIndeterminate)
        .toList();
    final List<TriadDimensionScore> validTriads = triads
        .where((t) => !t.isIndeterminate)
        .toList();

    if (validAxes.isEmpty && validTriads.isEmpty) {
      return const CompatibilityReport(
        ranked: <CurrentCompatibility>[],
        isHybridProfile: true,
        isTechnicalTie: false,
        headline: 'Dados insuficientes para estimar compatibilidade',
        explanation:
            'Responda a pelo menos metade das perguntas das dimensões para calcular '
            'a proximidade com correntes políticas.',
      );
    }

    final List<CurrentCompatibility> list = <CurrentCompatibility>[];
    for (final IdeologicalCurrent current in catalog.currents) {
      // New qualitative archive entries remain explorable without becoming
      // native diagnostic candidates before their dimensional review.
      if (current.editorialBasis?.nativeMatchingEligible == false) continue;
      var weightedZ2Sum = 0.0;
      var relevanceSum = 0.0;
      var triadCount = 0;
      var triangleEngagementSum = 0.0;
      var trianglePenaltySum = 0.0;
      final List<DimensionAlignmentDetail> details =
          <DimensionAlignmentDetail>[];

      for (final BipolarDimensionScore axis in validAxes) {
        final CurrentAxisProfile? prof = current.axes[axis.axisId];
        if (prof == null || prof.relevance <= 0) continue;

        final double dist = (axis.score - prof.mu).abs();
        final double denom = math.sqrt(
          prof.sigma * prof.sigma + axis.standardError * axis.standardError,
        );
        final double z = dist / math.max(0.05, denom);
        weightedZ2Sum += prof.relevance * z * z;
        relevanceSum += prof.relevance;

        details.add(
          DimensionAlignmentDetail(
            dimensionId: axis.axisId,
            dimensionLabel: axis.label,
            isTriad: false,
            normalizedZ: z,
            relevance: prof.relevance,
            rawDistance: dist,
            compositionDistance: dist,
            combinedDistance: dist,
            userSummary: axis.summary,
            currentSummary: _describeAxisMu(
              prof.mu,
              axis.leftPole,
              axis.rightPole,
            ),
            note: prof.note,
          ),
        );
      }

      for (final TriadDimensionScore triad in validTriads) {
        final CurrentTriadProfile? prof = current.triangles[triad.categoryId];
        if (prof == null || prof.relevance <= 0) continue;

        final TriadDistanceBreakdown breakdown = measureTriadDistance(
          composition: triad.composition,
          engagement: triad.engagement,
          target: prof.mu,
        );
        final double dist = breakdown.combinedDistance;
        final double denom = math.sqrt(
          prof.sigma * prof.sigma + triad.standardError * triad.standardError,
        );
        final double z = dist / math.max(0.05, denom);
        weightedZ2Sum += prof.relevance * z * z;
        relevanceSum += prof.relevance;
        triadCount++;
        triangleEngagementSum += triad.engagement;
        trianglePenaltySum += breakdown.engagementPenalty;

        details.add(
          DimensionAlignmentDetail(
            dimensionId: 'tri_${triad.categoryId}',
            dimensionLabel: triad.label,
            isTriad: true,
            normalizedZ: z,
            relevance: prof.relevance,
            rawDistance: breakdown.compositionDistance,
            compositionDistance: breakdown.compositionDistance,
            engagement: breakdown.engagement,
            engagementPenalty: breakdown.engagementPenalty,
            combinedDistance: breakdown.combinedDistance,
            userSummary: _describeTriadShares(
              triad.composition,
              triad.vertices,
            ),
            currentSummary: _describeTriadShares(prof.mu, triad.vertices),
            note: prof.note,
          ),
        );
      }

      if (relevanceSum <= 0) continue;
      // A sparse reference must not win by omitting the user's divergences.
      // Missing dimensions are never imputed as neutral or as disagreement.
      if (details.length / (validAxes.length + validTriads.length) <
          minimumComparisonCoverage) {
        continue;
      }
      final double d2 = weightedZ2Sum / relevanceSum;
      final double compat = double.parse(
        (100.0 * math.exp(-d2 / 2.0)).clamp(0.0, 100.0).toStringAsFixed(2),
      );

      final List<DimensionAlignmentDetail> meaningful = details
          .where((d) => d.relevance >= 0.35)
          .toList();
      final List<DimensionAlignmentDetail> pool = meaningful.length >= 3
          ? meaningful
          : details;

      final List<DimensionAlignmentDetail> conv = <DimensionAlignmentDetail>[
        ...pool,
      ]..sort((a, b) => a.normalizedZ.compareTo(b.normalizedZ));
      final List<DimensionAlignmentDetail> div = <DimensionAlignmentDetail>[
        ...pool,
      ]..sort((a, b) => b.weightedImpact.compareTo(a.weightedImpact));

      list.add(
        CurrentCompatibility(
          current: current,
          compatibilityPercent: compat,
          rmsZ: math.sqrt(d2),
          evaluatedDimensions: details.length,
          details: List<DimensionAlignmentDetail>.unmodifiable(details),
          convergences: conv.take(3).toList(),
          divergences: div.where((d) => d.normalizedZ > 0.65).take(3).toList(),
          evaluatedTriads: triadCount,
          meanTriadEngagement: triadCount == 0
              ? 0.5
              : triangleEngagementSum / triadCount,
          meanEngagementPenalty: triadCount == 0
              ? 0.0
              : trianglePenaltySum / triadCount,
        ),
      );
    }

    list.sort((a, b) {
      final int cmp = b.compatibilityPercent.compareTo(a.compatibilityPercent);
      if (cmp != 0) return cmp;
      return a.current.name.compareTo(b.current.name);
    });

    if (list.isEmpty) {
      return const CompatibilityReport(
        ranked: <CurrentCompatibility>[],
        isHybridProfile: true,
        isTechnicalTie: false,
        headline: 'Catálogo sem correspondência',
        explanation:
            'Nenhuma corrente pôde ser avaliada nas dimensões selecionadas.',
      );
    }

    final CurrentCompatibility first = list.first;
    final CurrentCompatibility? second = list.length > 1 ? list[1] : null;
    final int tensionAxisCount = validAxes
        .where((BipolarDimensionScore a) => a.hasInternalTension)
        .length;
    final bool lowDiscrimination =
        validAxes.length >= 2 &&
        tensionAxisCount >= 2 &&
        tensionAxisCount / validAxes.length >= 0.5;
    final bool isHybrid =
        !lowDiscrimination &&
        first.compatibilityPercent < hybridThresholdPercent;
    final bool isTie =
        !lowDiscrimination &&
        !isHybrid &&
        second != null &&
        (first.compatibilityPercent - second.compatibilityPercent) <
            tieMarginPercent;

    final String headline;
    final String explanation;
    final String engagementNote = first.meanEngagementPenalty >= 0.35
        ? ' Atenção: seu apoio absoluto médio nas tríades é de '
              '${(first.meanTriadEngagement * 100).round()}%, fora da faixa '
              'neutra; parte da proximidade pode refletir baixa discriminação '
              'entre alternativas, não uma posição ideológica definida.'
        : '';
    if (lowDiscrimination) {
      headline = 'Resultado com baixa discriminação entre alternativas';
      explanation =
          'Você respondeu de forma semelhante a afirmações que representam '
          'polos opostos em $tensionAxisCount de ${validAxes.length} eixos '
          'avaliados. As compatibilidades abaixo ainda descrevem proximidade '
          'geométrica no espaço medido (a maior é ${first.current.name}, '
          '${first.compatibilityPercent.toStringAsFixed(1)}%), mas não devem ser '
          'lidas como afinidade ideológica definida. Isso não é uma reprovação: '
          'indica que o questionário não conseguiu separar claramente suas '
          'preferências.$engagementNote';
    } else if (isHybrid) {
      headline = 'Perfil híbrido / independente';
      explanation =
          'Sua combinação de respostas cruza fronteiras doutrinárias clássicas: '
          'mesmo a corrente menos distante (${first.current.name}, '
          '${first.compatibilityPercent.toStringAsFixed(1)}%) apresenta divergências '
          'importantes em relação às suas escolhas.$engagementNote';
    } else if (isTie) {
      headline =
          'Proximidade compartilhada: ${first.current.name} e ${second.current.name}';
      explanation =
          'Suas posições situam-se na interseção entre ${first.current.name} '
          '(${first.compatibilityPercent.toStringAsFixed(1)}%) e ${second.current.name} '
          '(${second.compatibilityPercent.toStringAsFixed(1)}%), dentro da margem de empate técnico.$engagementNote';
    } else {
      headline = 'Maior afinidade estimada: ${first.current.name}';
      explanation =
          'Compatibilidade de ${first.compatibilityPercent.toStringAsFixed(1)}% '
          '(distância média de ${first.rmsZ.toStringAsFixed(2)} tolerâncias). '
          'Isso indica proximidade relativa no espaço medido, não adesão integral — '
          'confira abaixo onde você converge e onde diverge.$engagementNote';
    }

    return CompatibilityReport(
      ranked: list,
      isHybridProfile: isHybrid,
      isTechnicalTie: isTie,
      headline: headline,
      explanation: explanation,
      isLowDiscrimination: lowDiscrimination,
      tensionAxisCount: tensionAxisCount,
      evaluatedAxisCount: validAxes.length,
    );
  }

  static String _describeAxisMu(double mu, String leftPole, String rightPole) {
    final int rightPct = (50.0 * (1.0 + mu)).round().clamp(0, 100);
    final int leftPct = 100 - rightPct;
    if (mu.abs() < 0.15) return 'Equilíbrio ($leftPct/$rightPct)';
    return mu < 0 ? '$leftPct% $leftPole' : '$rightPct% $rightPole';
  }

  static String _describeTriadShares(
    List<double> shares,
    List<String> vertices,
  ) {
    final List<int> idx = <int>[0, 1, 2]
      ..sort((a, b) => shares[b].compareTo(shares[a]));
    final int top = idx.first;
    return '${vertices[top]} ${(shares[top] * 100).round()}%';
  }
}
