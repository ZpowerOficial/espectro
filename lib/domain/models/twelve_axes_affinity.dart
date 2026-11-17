import 'dart:math' as math;

/// Identificadores canônicos dos 12 eixos bipolares. A ordem é estável para
/// que a afinidade possa ser explicada e comparada entre catálogos.
const List<String> twelveAxisIds = <String>[
  'estrutura',
  'representacao',
  'poder',
  'imigracao',
  'diplomacia',
  'intervencao',
  'economia',
  'controle',
  'comercio',
  'religiao',
  'moral',
  'tecnologia',
];

double _tanh(double value) {
  final double exponential = math.exp(2.0 * value);
  return (exponential - 1.0) / (exponential + 1.0);
}

/// Afinidade restrita aos 12 eixos bipolares.
///
/// É uma leitura complementar ao motor principal de 18 dimensões. O motor
/// principal continua usando incerteza (`sigma`/erro-padrão), relevância e as
/// seis tríades; esta classe responde apenas "quão próximos são os dois perfis
/// nos 12 eixos compartilhados?" e decompõe a resposta em quatro componentes.
///
/// A fórmula é uma implementação independente do Espectro, não uma cópia do
/// algoritmo de outro projeto:
/// - eixos: similaridade quadrática com penalidade suave para lados opostos;
/// - direção: cosseno aumentado, que evita direção indefinida perto do centro;
/// - magnitude: diferença média de intensidade em relação ao centro;
/// - outlier: maior divergência isolada, com queda polinomial.
///
/// Dimensões ausentes não são preenchidas com centro. O resultado só existe
/// quando há pelo menos [minimumSharedAxes] eixos em comum, e a cobertura é
/// exposta para que uma nota calculada com poucos eixos não seja lida como se
/// tivesse a mesma sustentação de uma nota com os 12.
class TwelveAxesAffinity {
  const TwelveAxesAffinity({
    required this.percent,
    required this.rawPercent,
    required this.axisSimilarity,
    required this.directionSimilarity,
    required this.magnitudeSimilarity,
    required this.outlierSimilarity,
    required this.sharedAxes,
    required this.coverage,
    required this.maxDifferenceAxis,
    required this.maxDifference,
  });

  static const int minimumSharedAxes = 6;

  /// Nota final após o fator de confiabilidade por cobertura.
  final double percent;

  /// Nota das quatro componentes antes do fator de cobertura.
  final double rawPercent;
  final double axisSimilarity;
  final double directionSimilarity;
  final double magnitudeSimilarity;
  final double outlierSimilarity;
  final int sharedAxes;

  /// `sharedAxes / 12`, em `[0, 1]`.
  final double coverage;

  /// Eixo com a maior diferença absoluta, quando existe.
  final String? maxDifferenceAxis;

  /// Maior diferença absoluta em pontos percentuais (`0..100`).
  final double maxDifference;

  double get reliabilityFactor => 0.80 + 0.20 * coverage;

  String get coverageLabel => '$sharedAxes/${twelveAxisIds.length} eixos';

  /// Calcula a afinidade a partir de dois mapas `axisId -> posição`.
  ///
  /// As posições devem estar em `[-1, 1]`. Valores ausentes são ignorados, e
  /// não convertidos em neutro. Devolve `null` quando há menos de
  /// [minimumSharedAxes] eixos em comum.
  static TwelveAxesAffinity? between(
    Map<String, double> userAxes,
    Map<String, double> targetAxes,
  ) {
    final List<String> shared = <String>[
      for (final String axisId in twelveAxisIds)
        if (userAxes[axisId] != null && targetAxes[axisId] != null) axisId,
    ];
    if (shared.length < minimumSharedAxes) return null;

    var axisSimilaritySum = 0.0;
    var dot = 0.0;
    var userNorm = 0.0;
    var targetNorm = 0.0;
    var userIntensity = 0.0;
    var targetIntensity = 0.0;
    var maxDifference = 0.0;
    String? maxDifferenceAxis;

    for (final String axisId in shared) {
      final double userValue =
          (50.0 * (1.0 + userAxes[axisId]!.clamp(-1.0, 1.0))).clamp(0.0, 100.0);
      final double targetValue =
          (50.0 * (1.0 + targetAxes[axisId]!.clamp(-1.0, 1.0))).clamp(
            0.0,
            100.0,
          );
      final double difference = (userValue - targetValue).abs();
      if (difference > maxDifference) {
        maxDifference = difference;
        maxDifferenceAxis = axisId;
      }

      final double normalized = (difference / 50.0).clamp(0.0, 1.0);
      var similarity = (1.0 - normalized * normalized).clamp(0.0, 1.0);
      if ((userValue - 50.0) * (targetValue - 50.0) < 0.0) {
        final double penalty =
            0.45 *
            _tanh((userValue - 50.0).abs() / 25.0) *
            _tanh((targetValue - 50.0).abs() / 25.0);
        similarity *= (1.0 - penalty).clamp(0.0, 1.0);
      }
      axisSimilaritySum += similarity;

      final double centeredUser = userValue - 50.0;
      final double centeredTarget = targetValue - 50.0;
      dot += centeredUser * centeredTarget;
      userNorm += centeredUser * centeredUser;
      targetNorm += centeredTarget * centeredTarget;
      userIntensity += centeredUser.abs();
      targetIntensity += centeredTarget.abs();
    }

    final int count = shared.length;
    final double axisSimilarity = 100.0 * axisSimilaritySum / count;

    // O termo constante evita que dois perfis próximos do centro tenham
    // direção indefinida (cosseno de vetores quase nulos).
    const double augmentRadius = 8.0;
    final double augment = count * augmentRadius * augmentRadius;
    final double cosine =
        (dot + augment) /
        math.sqrt((userNorm + augment) * (targetNorm + augment));
    final double directionSimilarity = (50.0 + 50.0 * cosine).clamp(0.0, 100.0);

    final double magnitudeSimilarity =
        (100.0 -
                2.0 *
                    ((userIntensity / count) - (targetIntensity / count)).abs())
            .clamp(0.0, 100.0);

    final double outlierSimilarity =
        (100.0 *
                math.max(
                  0.0,
                  1.0 - math.pow((maxDifference / 100.0).clamp(0.0, 1.0), 2.5),
                ))
            .clamp(0.0, 100.0);

    final double raw =
        0.45 * axisSimilarity +
        0.30 * directionSimilarity +
        0.17 * magnitudeSimilarity +
        0.08 * outlierSimilarity;
    final double coverage = count / twelveAxisIds.length;
    final double reliability = 0.80 + 0.20 * coverage;

    return TwelveAxesAffinity(
      percent: double.parse(
        (raw * reliability).clamp(0.0, 100.0).toStringAsFixed(2),
      ),
      rawPercent: double.parse(raw.clamp(0.0, 100.0).toStringAsFixed(2)),
      axisSimilarity: double.parse(axisSimilarity.toStringAsFixed(2)),
      directionSimilarity: double.parse(directionSimilarity.toStringAsFixed(2)),
      magnitudeSimilarity: double.parse(magnitudeSimilarity.toStringAsFixed(2)),
      outlierSimilarity: double.parse(outlierSimilarity.toStringAsFixed(2)),
      sharedAxes: count,
      coverage: coverage,
      maxDifferenceAxis: maxDifferenceAxis,
      maxDifference: double.parse(maxDifference.toStringAsFixed(2)),
    );
  }

  String get summary =>
      'Afinidade de 12 eixos ${percent.toStringAsFixed(1)}/100 '
      '($sharedAxes/12 eixos, cobertura ${(coverage * 100).round()}%).';
}
