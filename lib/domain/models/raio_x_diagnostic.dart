import 'package:flutter/foundation.dart';

/// Uma dimensão individual analisada pelo Raio-X de Convergências e Divergências.
@immutable
class RaioXDimensionItem {
  const RaioXDimensionItem({
    required this.dimensionId,
    required this.dimensionLabel,
    required this.isTriad,
    required this.userSummary,
    required this.targetSummary,
    required this.deltaDistance,
    required this.relevance,
    required this.mathematicalContribution,
    this.combinedDistance,
    this.compositionDistance,
    this.engagement,
    this.engagementPenalty,
    this.normalizedZ,
    this.weightedImpact,
    this.catalogNote,
    this.locator,
    this.sourceUrl,
  });

  /// Identificador do eixo (ex.: 'economia', 'poder') ou tríade ('tri_0').
  final String dimensionId;

  /// Rótulo legível da dimensão (ex.: 'Economia', 'Poder e Liberdade').
  final String dimensionLabel;

  /// `true` se for uma tríade baricêntrica, `false` se for eixo bipolar contínuo.
  final bool isTriad;

  /// Descrição objetiva da posição observada do usuário (ex.: '88% Livre Mercado').
  final String userSummary;

  /// Descrição da coordenada documentada no catálogo (ex.: '91% Livre Mercado').
  final String targetSummary;

  /// Distância calculada bruta entre as coordenadas em [0.0, 2.0] (composição).
  final double deltaDistance;

  /// Distância combinada efetiva usada para o cálculo de z (inclui engajamento nas tríades).
  final double? combinedDistance;

  /// Distância baricêntrica puramente composicional nas tríades (igual a deltaDistance).
  final double? compositionDistance;

  /// Intensidade de engajamento absoluto nas tríades [0.0, 1.0].
  final double? engagement;

  /// Penalidade de engajamento calculada [0.0, 1.0].
  final double? engagementPenalty;

  /// Relevância do eixo no catálogo (sempre > 0.0 para participar do Raio-X).
  final double relevance;

  /// Distância padronizada `z_d = dist / √(σ² + SE²)` se calculada pelo motor.
  final double? normalizedZ;

  /// Impacto relativo no desvio total `rel · z²`.
  final double? weightedImpact;

  /// Resumo do impacto matemático (ex.: "Δ = 0.08 · z = 0.28 · baixa dispersão").
  final String mathematicalContribution;

  /// Nota descritiva documental ou justificativa no acervo primário.
  final String? catalogNote;

  /// Localizador na obra primária (ex.: "Capítulo 3: Não Agressão").
  final String? locator;

  /// URL da fonte primária (se houver).
  final String? sourceUrl;
}

/// Bloco estruturado do Raio-X (Aproximação ou Divergência).
@immutable
class RaioXSection {
  const RaioXSection({
    required this.title,
    required this.description,
    required this.items,
    this.hasSufficientEvidence = true,
    this.insufficientReason,
  });

  final String title;
  final String description;
  final List<RaioXDimensionItem> items;
  final bool hasSufficientEvidence;
  final String? insufficientReason;
}

/// Diagnóstico completo e auditável do Raio-X de Convergências e Divergências.
///
/// Não inventa afinidades, respeita a relevância das fontes e cumpre estrita
/// honestidade epistêmica ao separar proximidade de coordenadas de concordância literal.
@immutable
class RaioXDiagnostic {
  const RaioXDiagnostic({
    required this.targetId,
    required this.targetName,
    required this.targetKindLabel,
    required this.compatibilityPercent,
    required this.approachingSection,
    required this.divergingSection,
    required this.conceptualDifferentiation,
    required this.evaluatedDimensionsCount,
    this.insufficientEvidence = false,
    this.insufficientEvidenceReason,
    this.methodologicalDisclaimer =
        'Esta análise baseia-se na distância matemática entre coordenadas calculadas '
        'e nos dados documentados no catálogo. Proximidade geométrica não equivale a '
        'concordância literal sobre afirmações específicas.',
  });

  final String targetId;
  final String targetName;
  final String targetKindLabel;

  /// Percentual de compatibilidade do motor oficial em [0.0, 100.0].
  final double? compatibilityPercent;

  /// Bloco 1: Onde vocês se aproximam
  final RaioXSection approachingSection;

  /// Bloco 2: Onde vocês divergem
  final RaioXSection divergingSection;

  /// Bloco 3: O que diferencia essas posições
  final String conceptualDifferentiation;

  /// Quantidade de dimensões válidas com relevância > 0 efetivamente comparadas.
  final int evaluatedDimensionsCount;

  /// `true` se não houver dados suficientes para uma leitura descritiva.
  final bool insufficientEvidence;

  /// Motivo objetivo da insuficiência de evidência.
  final String? insufficientEvidenceReason;

  /// Aviso de integridade epistêmica.
  final String methodologicalDisclaimer;
}
