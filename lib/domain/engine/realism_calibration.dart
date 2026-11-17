import 'dart:math' as math;

/// Calibração de realismo para sujeitos de estudo do catálogo (correntes, personalidades,
/// países e partidos), inspirada na fluidez empírica do 12Axes e em psicometria política.
///
/// Previne o "efeito teto" (±1.0 / 100% artificial decorrente de reconstruções com poucos itens)
/// mantendo estritamente a monotonicidade, a ordenação dos polos e a identidade analítica
/// de cada corrente/figura histórica. NÃO altera as respostas pessoais do usuário.
abstract final class RealismCalibration {
  /// Calibra o valor de um eixo contínuo em [-1.0, 1.0].
  /// [sigma] representa a heterogeneidade/dispersão interna da corrente (se disponível).
  static double calibrateAxis(double mu, {double sigma = 0.0}) {
    if (mu == 0.0 || mu.isNaN) return 0.0;
    final double sign = mu > 0 ? 1.0 : -1.0;
    final double ax = mu.abs();

    // Curva progressiva: valores moderados (|mu| <= 0.40) mantêm-se lineares e naturais.
    // Conforme avança para posições doutrinárias radicais (|mu| >= 0.80 a 1.0),
    // a calibração respeita a radicalidade genuína da corrente, permitindo que
    // atinja até 0.82 (exibido como 91% na escala percentual), evitando o teto
    // achatado artificial de ~78% e preservando a firmeza de posições como o ancap
    // no livre mercado ou o ancom na socialização.
    double cal;
    if (ax <= 0.40) {
      cal = ax;
    } else {
      final double t = (ax - 0.40) / 0.60;
      cal = 0.40 + 0.42 * math.pow(t, 0.85);
    }

    if (sigma > 0.0) {
      cal *= (1.0 - 0.05 * sigma.clamp(0.0, 1.0));
    }

    // Teto estrito de 0.82 para que nenhuma corrente mostre 100% artificial
    final double clamped = sign * cal.clamp(0.0, 0.82);
    return double.parse(clamped.toStringAsFixed(3));
  }

  /// Calibra a composição de uma tríade (lista de 3 proporções somando 1.0),
  /// amenizando concentrações irrealistas de 100% enquanto preserva fielmente
  /// a dominância expressiva do vértice principal (atingindo até 85%).
  static List<double> calibrateTriad(List<double> comp, {double dispersion = 0.0}) {
    if (comp.length != 3) return comp;
    final double lambda = (0.10 + 0.04 * dispersion.clamp(0.0, 1.0)).clamp(0.10, 0.14);
    final List<double> tempered = [
      for (final c in comp) (1.0 - lambda) * c + lambda / 3.0,
    ];
    // Garante que nenhum vértice ultrapasse o teto estrito de 0.85
    for (var i = 0; i < 3; i++) {
      if (tempered[i] > 0.849) {
        final excess = tempered[i] - 0.849;
        tempered[i] = 0.849;
        final other1 = (i + 1) % 3;
        final other2 = (i + 2) % 3;
        tempered[other1] += excess / 2.0;
        tempered[other2] += excess / 2.0;
      }
    }
    final double sum = tempered.fold<double>(0.0, (a, b) => a + b);
    if (sum <= 0.0) return const [0.333, 0.333, 0.334];

    final List<double> normalized = [
      for (final t in tempered) double.parse((t / sum).toStringAsFixed(3)),
    ];
    // Ajuste de resíduo de arredondamento
    final double diff = 1.0 - normalized.fold<double>(0.0, (a, b) => a + b);
    normalized[0] = double.parse((normalized[0] + diff).toStringAsFixed(3));
    return List<double>.unmodifiable(normalized);
  }

  /// Calibra um mapa de eixos para um sujeito de estudo do catálogo.
  static Map<String, double> calibrateAxesMap(
    Map<String, double> axes, {
    Map<String, double>? sigmas,
  }) {
    return {
      for (final entry in axes.entries)
        entry.key: calibrateAxis(
          entry.value,
          sigma: sigmas?[entry.key] ?? 0.0,
        ),
    };
  }

  /// Calibra o mapa de tríades para um sujeito de estudo do catálogo.
  static Map<int, List<double>> calibrateTrianglesMap(
    Map<int, List<double>> triangles,
  ) {
    return {
      for (final entry in triangles.entries)
        entry.key: calibrateTriad(entry.value),
    };
  }
}
