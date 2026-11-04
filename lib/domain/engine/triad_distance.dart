import 'dart:math' as math;

/// Peso `λ` do termo de apoio absoluto na distância triangular.
///
/// Calibração: `λ = 0.16` faz com que o afastamento máximo de engajamento
/// (apoio ou rejeição plenos dos três vértices) contribua com `0.4` — a mesma
/// ordem de grandeza de uma discordância composicional moderada. O valor é
/// heurístico e não pretende ser um parâmetro psicométrico validado.
const double kTriadEngagementWeight = 0.16;

/// Faixa de engajamento tratada como neutra (`|I - 0.5| <= 0.15`).
///
/// Evita que apoios ou rejeições moderadas sejam tratados como baixa
/// discriminação. A penalidade só cresce fora de `I ∈ [0.35, 0.65]`.
const double kTriadEngagementNeutralBand = 0.15;

/// Decomposição auditável da distância entre a composição do usuário e a
/// composição de um perfil do catálogo em uma tríade.
///
/// A métrica vive em um espaço "elevado" de quatro coordenadas:
/// três coordenadas composicionais (que somam 1) e uma coordenada de
/// engajamento. A distância é euclidiana nesse espaço, com a composição
/// normalizada por `√2` para que o máximo de discordância composicional
/// (vértices disjuntos) seja `1`.
///
/// ```text
/// d_comp = ||p − μ||₂ / √2                        ∈ [0, 1]
/// g      = clamp((|I − 0.5| − 0.15) / 0.35, 0, 1) ∈ [0, 1]
/// d      = √(d_comp² + 0.16 · g²)                 ∈ [0, 1.077]
/// ```
///
/// Propriedades matemáticas garantidas:
/// 1. `d = 0` se e somente se `p = μ` e `I ∈ [0.35, 0.65]`.
/// 2. `d >= d_comp`: a informação de apoio absoluto nunca aproxima o usuário
///    de um perfil; ela apenas pode afastá-lo quando há baixa discriminação.
/// 3. Para `p` e `μ` fixos, `d` é monótona não decrescente em `|I − 0.5|`.
/// 4. É invariante à permutação simultânea dos vértices de `p` e `μ`.
/// 5. É simétrica na troca `p ↔ μ`.
/// 6. Satisfaz a desigualdade triangular, pois é a norma de um vetor
///    `((p − μ)/√2, 0.4·g)` no espaço elevado.
///
/// Limitação declarada: os perfis do catálogo descrevem apenas ênfase
/// relativa (`μ`, soma 1); não declaram intensidade absoluta. Por isso a
/// coordenada de engajamento do perfil é fixada no plano neutro e a métrica é
/// invariante ao **sinal** de `I − 0.5`. Um padrão de apoio pleno e um padrão
/// de rejeição plena, com a mesma composição, produzem a mesma distância
/// escalar; eles são distinguidos por [engagementDirection], pela
/// classificação da tríade e pelas contribuições item a item — nunca por uma
/// intensidade de perfil inventada.
class TriadDistanceBreakdown {
  const TriadDistanceBreakdown({
    required this.compositionDistance,
    required this.engagement,
    required this.engagementDeviation,
    required this.engagementPenalty,
    required this.combinedDistance,
  });

  /// Distância apenas na composição relativa `p`, em `[0, 1]`.
  final double compositionDistance;

  /// Engajamento absoluto do usuário `I`, em `[0, 1]`.
  final double engagement;

  /// `|I − 0.5|`, em `[0, 0.5]`.
  final double engagementDeviation;

  /// Penalidade normalizada de engajamento `g`, em `[0, 1]`.
  final double engagementPenalty;

  /// Distância combinada, em `[0, 1.077]`.
  final double combinedDistance;

  /// `1` quando há apoio amplo (`I > 0.5`), `-1` quando há rejeição ampla
  /// (`I < 0.5`) e `0` no plano neutro.
  int get engagementDirection {
    if (engagementDeviation <= 1e-9) return 0;
    return engagement > 0.5 ? 1 : -1;
  }
}

/// Mede a distância entre a composição triangular do usuário e a composição
/// de um perfil, incorporando o apoio absoluto do usuário.
///
/// [composition] e [target] devem ter 3 coordenadas finitas que somam
/// aproximadamente 1. [engagement] deve estar em `[0, 1]`.
TriadDistanceBreakdown measureTriadDistance({
  required List<double> composition,
  required double engagement,
  required List<double> target,
}) {
  _validateComposition(composition, 'composition');
  _validateComposition(target, 'target');
  if (!engagement.isFinite || engagement < 0.0 || engagement > 1.0) {
    throw ArgumentError.value(
      engagement,
      'engagement',
      'deve ser finito e estar em [0, 1]',
    );
  }

  var sq = 0.0;
  for (var k = 0; k < 3; k++) {
    final double d = composition[k] - target[k];
    sq += d * d;
  }
  final double compositionDistance = math.sqrt(sq / 2.0);

  final double deviation = (engagement - 0.5).abs();
  final double penalty = ((deviation - kTriadEngagementNeutralBand) /
          (0.5 - kTriadEngagementNeutralBand))
      .clamp(0.0, 1.0);
  final double combined = math.sqrt(
    compositionDistance * compositionDistance +
        kTriadEngagementWeight * penalty * penalty,
  );

  return TriadDistanceBreakdown(
    compositionDistance: compositionDistance,
    engagement: engagement,
    engagementDeviation: deviation,
    engagementPenalty: penalty,
    combinedDistance: combined,
  );
}

void _validateComposition(List<double> values, String name) {
  if (values.length != 3) {
    throw ArgumentError.value(values, name, 'deve ter exatamente 3 valores');
  }
  var sum = 0.0;
  for (final double v in values) {
    if (!v.isFinite || v < 0.0 || v > 1.0) {
      throw ArgumentError.value(
        values,
        name,
        'cada coordenada deve ser finita e estar em [0, 1]',
      );
    }
    sum += v;
  }
  if ((sum - 1.0).abs() > 1e-6) {
    throw ArgumentError.value(values, name, 'as coordenadas devem somar 1');
  }
}
