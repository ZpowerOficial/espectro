import 'study_editorial_basis.dart';
import '../../data/models.dart';
import '../../data/strict_json.dart';

/// Versão atual do motor matemático do Espectro.
/// Versão do motor de pontuação. Deve ser incrementada sempre que a fórmula,
/// a regra de cobertura ou a ponderação mudarem, para que cada registro
/// histórico preserve a metodologia com que foi calculado.
///
/// Histórico:
/// - `2.0.0`: eixos com cobertura por polo e tríades com distância elevada
///   (composição + apoio absoluto) e regra estrita de indeterminação.
const String kEspectroEngineVersion = '2.2.0';

/// Versão atual do banco unificado de itens.
const String kEspectroBankVersion = '2.0.0';

/// Modalidade de avaliação disponível no aplicativo.
enum TestSuite {
  espectroIntegrated,
  bipolarAxes,
  triads;

  String get id => name;

  String get title => switch (this) {
    TestSuite.espectroIntegrated => 'Espectro Integrado',
    TestSuite.bipolarAxes => '12 Eixos Bipolares',
    TestSuite.triads => '6 Tríades Políticas',
  };

  String get subtitle => switch (this) {
    TestSuite.espectroIntegrated => 'Avalia simultaneamente os 12 eixos bipolares e as 6 tríades baricêntricas.',
    TestSuite.bipolarAxes => 'Mapeia tensões entre pares de polos opostos em 12 dimensões independentes.',
    TestSuite.triads => 'Avalia 6 arenas políticas com 3 vértices independentes cada, corrigindo o fechamento composicional.',
  };

  bool get includesAxes =>
      this == TestSuite.espectroIntegrated || this == TestSuite.bipolarAxes;

  bool get includesTriads =>
      this == TestSuite.espectroIntegrated || this == TestSuite.triads;

  static TestSuite fromId(String raw) {
    for (final TestSuite value in TestSuite.values) {
      if (value.name == raw) return value;
    }
    throw FormatException('Modalidade desconhecida: "$raw"');
  }
}

/// Extensão / profundidade da bateria de perguntas.
enum TestDepth {
  express,
  quick,
  standard,
  deep,
  exhaustive;

  String get id => name;

  String get label => switch (this) {
    TestDepth.express => 'Expresso',
    TestDepth.quick => 'Rápida',
    TestDepth.standard => 'Padrão',
    TestDepth.deep => 'Profunda',
    TestDepth.exhaustive => 'Integral',
  };

  /// Se esta combinação de modalidade e profundidade avalia os 12 eixos bipolares.
  bool includesAxesFor(TestSuite suite) => suite.includesAxes;

  /// Se esta combinação avalia as 6 tríades inicialmente.
  /// No modo [TestDepth.express] do [TestSuite.espectroIntegrated], avaliamos
  /// apenas os 12 eixos (24 perguntas, 1 por polo) para manter velocidade e
  /// confiabilidade psicométrica, permitindo completar as 6 tríades (+18) depois.
  bool includesTriadsFor(TestSuite suite) => switch ((suite, this)) {
    (TestSuite.espectroIntegrated, TestDepth.express) => false,
    _ => suite.includesTriads,
  };

  /// Quantidade por eixo bipolar quando a modalidade inclui eixos (`0` = todos).
  int axesPerDimension(TestSuite suite) => switch ((suite, this)) {
    (TestSuite.triads, _) => 0,
    (TestSuite.espectroIntegrated, TestDepth.express) => 2,
    (TestSuite.espectroIntegrated, TestDepth.quick) => 2,
    (TestSuite.espectroIntegrated, TestDepth.standard) => 4,
    (TestSuite.espectroIntegrated, TestDepth.deep) => 8,
    (TestSuite.espectroIntegrated, TestDepth.exhaustive) => 20,
    (TestSuite.bipolarAxes, TestDepth.express) => 2,
    (TestSuite.bipolarAxes, TestDepth.quick) => 3,
    (TestSuite.bipolarAxes, TestDepth.standard) => 6,
    (TestSuite.bipolarAxes, TestDepth.deep) => 20,
    (TestSuite.bipolarAxes, TestDepth.exhaustive) => 0,
  };

  /// Quantidade por vértice triangular quando a modalidade inclui tríades (`0` = todos).
  int triadPerVertex(TestSuite suite) => switch ((suite, this)) {
    (TestSuite.bipolarAxes, _) => 0,
    (TestSuite.espectroIntegrated, TestDepth.express) => 0,
    (TestSuite.espectroIntegrated, TestDepth.quick) => 2,
    (TestSuite.espectroIntegrated, TestDepth.standard) => 4,
    (TestSuite.espectroIntegrated, TestDepth.deep) => 8,
    (TestSuite.espectroIntegrated, TestDepth.exhaustive) => 16,
    (TestSuite.triads, TestDepth.express) => 1,
    (TestSuite.triads, TestDepth.quick) => 3,
    (TestSuite.triads, TestDepth.standard) => 6,
    (TestSuite.triads, TestDepth.deep) => 12,
    (TestSuite.triads, TestDepth.exhaustive) => 0,
  };

  int expectedCount(
    TestSuite suite, {
    required int totalAxesPool,
    required int totalTriadsPool,
  }) {
    final int perAxis = axesPerDimension(suite);
    final int perVert = triadPerVertex(suite);
    final int axesPart = !includesAxesFor(suite)
        ? 0
        : (perAxis == 0 ? totalAxesPool : 12 * perAxis);
    final int triadsPart = !includesTriadsFor(suite)
        ? 0
        : (perVert == 0 ? totalTriadsPool : 18 * perVert);
    return axesPart + triadsPart;
  }

  String estimatedDuration(int count) {
    // Oito segundos por item é uma referência conservadora. O limite anterior
    // de 40 min fazia a bateria de 528 itens parecer mais curta que a de 240.
    final int minutes = (count / 8.0).ceil().clamp(3, 90);
    return '~$minutes min';
  }

  String descriptionFor(TestSuite suite) => switch (this) {
    TestDepth.express =>
      suite == TestSuite.espectroIntegrated
          ? 'Foco nos 12 eixos (24 perguntas); você pode completar as 6 tríades (+18) depois.'
          : 'Cobertura mínima confiável por dimensão para diagnóstico rápido.',
    TestDepth.quick =>
      'Panorama ágil com itens balanceados; margem de incerteza maior.',
    TestDepth.standard =>
      'Equilíbrio ideal entre precisão estatística e tempo de resposta.',
    TestDepth.deep =>
      'Alta estabilidade por dimensão e detecção fina de tensões internas.',
    TestDepth.exhaustive =>
      'Bateria completa com todos os itens disponíveis nesta modalidade.',
  };

  static TestDepth fromId(String raw) {
    for (final TestDepth value in TestDepth.values) {
      if (value.name == raw) return value;
    }
    throw FormatException('Profundidade desconhecida: "$raw"');
  }
}

/// Escala Likert simétrica de 5 pontos usada pelo motor Espectro.
/// O ato de "pular" é representado por `null` (ausência de resposta), nunca por `neutral`.
enum LikertAnswer {
  stronglyAgree(2, 'Concordo totalmente'),
  agree(1, 'Concordo'),
  neutral(0, 'Neutro / depende'),
  disagree(-1, 'Discordo'),
  stronglyDisagree(-2, 'Discordo totalmente');

  const LikertAnswer(this.value, this.label);

  /// Inteiro em `{-2, -1, 0, +1, +2}`.
  final int value;
  final String label;

  /// Valor normalizado em `[-1.0, +1.0]`.
  double get normalized => value / 2.0;

  static LikertAnswer fromValue(int v) {
    for (final LikertAnswer option in LikertAnswer.values) {
      if (option.value == v) return option;
    }
    throw FormatException('Valor Likert inválido: $v');
  }
}

enum UnifiedQuestionKind { bipolar, triad, integrated }

/// Item unificado apresentado durante uma sessão do Espectro.
///
/// Pode ser puramente bipolar (avalia apenas um eixo), puramente triangular (avalia
/// apenas uma tríade) ou integrado (avalia simultaneamente um eixo bipolar e um
/// vértice de tríade com uma única resposta Likert do usuário).
class UnifiedQuestion {
  const UnifiedQuestion.bipolar(this.axisQuestion, {this.sixQuestion})
    : kind = UnifiedQuestionKind.bipolar;

  const UnifiedQuestion.triad(this.sixQuestion, {this.axisQuestion})
    : kind = UnifiedQuestionKind.triad;

  const UnifiedQuestion.integrated({
    required this.axisQuestion,
    required this.sixQuestion,
  }) : kind = UnifiedQuestionKind.integrated;

  final UnifiedQuestionKind kind;
  final AxisQuestion? axisQuestion;
  final SixQuestion? sixQuestion;

  String get uid => kind == UnifiedQuestionKind.triad
      ? 'tri:${sixQuestion!.id}'
      : 'axis:${axisQuestion!.id}';

  String get text => axisQuestion?.text ?? sixQuestion!.text;

  /// Peso positivo do item na agregação da sua dimensão.
  double get weight {
    if (axisQuestion != null) {
      return axisQuestion!.weight;
    }
    // Nos itens triangulares, a força (1..4) pondera suavemente de 1.0 a 1.75.
    return 0.75 + 0.25 * sixQuestion!.strength;
  }

  /// Sinal de chaveamento:
  /// - Em eixo bipolar: `-1` quando concordar aponta para `leftPole` (`S -> -1`),
  ///   `+1` quando concordar aponta para `rightPole` (`S -> +1`).
  /// - Em tríade: `+1` quando concordar apoia o vértice, `-1` quando concordar o rejeita.
  int get polaritySign {
    if (axisQuestion != null) {
      return axisQuestion!.agreeIsLeft ? -1 : 1;
    }
    return sixQuestion!.multiplier;
  }

  String get dimensionKey {
    if (axisQuestion != null && sixQuestion != null) {
      return '${axisQuestion!.axisId}+tri_${sixQuestion!.category}';
    }
    return axisQuestion != null
        ? axisQuestion!.axisId
        : 'tri_${sixQuestion!.category}';
  }
}

/// Contribuição auditável de uma pergunta respondida para o cálculo de uma dimensão.
class ItemContribution {
  const ItemContribution({
    required this.questionUid,
    required this.statement,
    required this.answer,
    required this.weight,
    required this.signedContribution,
    required this.targetLabel,
  });

  final String questionUid;
  final String statement;
  final LikertAnswer answer;
  final double weight;

  /// Em `[-1.0, +1.0]`.
  final double signedContribution;
  final String targetLabel;

  double get weightedMagnitude => (weight * signedContribution).abs();
}

/// Nível de sustentação de um escore, derivado de cobertura e erro-padrão.
///
/// Não é um intervalo psicométrico validado: é um rótulo auditável para
/// comunicar quanta evidência sustenta o número exibido.
enum ScoreConfidence {
  insufficient,
  low,
  moderate,
  high;

  String get label => switch (this) {
    ScoreConfidence.insufficient => 'Indeterminado',
    ScoreConfidence.low => 'Baixa',
    ScoreConfidence.moderate => 'Moderada',
    ScoreConfidence.high => 'Alta',
  };
}

/// Resultado de um eixo bipolar em `[-1.0, +1.0]`, onde `-1` = 100% polo esquerdo
/// e `+1` = 100% polo direito.
class BipolarDimensionScore {
  const BipolarDimensionScore({
    required this.axisId,
    required this.label,
    required this.leftPole,
    required this.rightPole,
    required this.score,
    required this.standardError,
    required this.coverage,
    required this.answeredCount,
    required this.presentedCount,
    required this.tensionScore,
    this.topContributions = const <ItemContribution>[],
    this.poleBreakdownAvailable = false,
    this.answeredLeftCount = 0,
    this.presentedLeftCount = 0,
    this.answeredRightCount = 0,
    this.presentedRightCount = 0,
    this.leftPoleMean = 0.0,
    this.rightPoleMean = 0.0,
  });

  final String axisId;
  final String label;
  final String leftPole;
  final String rightPole;

  /// Escore `S` em `[-1.0, +1.0]`.
  final double score;

  /// Erro-padrão estimado em unidades de `S` (`0..1`).
  final double standardError;

  /// Fração do peso apresentado que foi efetivamente respondida (`0..1`).
  final double coverage;
  final int answeredCount;
  final int presentedCount;

  /// Diferença entre as médias dos itens chaveados à esquerda e à direita (`0..2`).
  /// Valores acima de `0.75` indicam respostas simultaneamente favoráveis (ou contrárias)
  /// a ambos os polos, revelando tensão ou posição híbrida no tema.
  final double tensionScore;

  final List<ItemContribution> topContributions;

  /// Se `true`, os campos de cobertura por polo foram calculados pelo motor
  /// atual. Registros antigos mantêm `false` e preservam a regra de
  /// indeterminação original.
  final bool poleBreakdownAvailable;
  final int answeredLeftCount;
  final int presentedLeftCount;
  final int answeredRightCount;
  final int presentedRightCount;

  /// Média assinada das contribuições dos itens chaveados a cada polo.
  /// Permite explicar *por que* há tensão (ex.: concordância com ambos).
  final double leftPoleMean;
  final double rightPoleMean;

  double get leftPoleCoverage => presentedLeftCount == 0
      ? 0.0
      : (answeredLeftCount / presentedLeftCount).clamp(0.0, 1.0);

  double get rightPoleCoverage => presentedRightCount == 0
      ? 0.0
      : (answeredRightCount / presentedRightCount).clamp(0.0, 1.0);

  double get minimumPoleCoverage {
    if (!poleBreakdownAvailable) return coverage;
    return leftPoleCoverage < rightPoleCoverage
        ? leftPoleCoverage
        : rightPoleCoverage;
  }

  bool get hasBothPoles =>
      !poleBreakdownAvailable ||
      (answeredLeftCount > 0 && answeredRightCount > 0);

  bool get isIndeterminate =>
      answeredCount == 0 ||
      coverage < 0.5 ||
      (poleBreakdownAvailable && (!hasBothPoles || answeredCount < 2));

  ScoreConfidence get confidence {
    if (isIndeterminate) return ScoreConfidence.insufficient;
    if (coverage < 0.70 || minimumPoleCoverage < 0.34 || standardError > 0.30) {
      return ScoreConfidence.low;
    }
    if (coverage < 0.90 || standardError > 0.18) {
      return ScoreConfidence.moderate;
    }
    return ScoreConfidence.high;
  }

  String get confidenceLabel => confidence.label;

  bool get hasInternalTension => !isIndeterminate && tensionScore > 0.75;

  /// Percentual do polo esquerdo (`0..100`).
  double get leftPercent => (50.0 * (1.0 - score)).clamp(0.0, 100.0);

  /// Percentual do polo direito (`0..100`).
  double get rightPercent => (50.0 * (1.0 + score)).clamp(0.0, 100.0);

  /// Limites da faixa indicativa de incerteza (`S ± 1.96·SE`), em `[-1, 1]`.
  double get scoreLow => (score - 1.96 * standardError).clamp(-1.0, 1.0);
  double get scoreHigh => (score + 1.96 * standardError).clamp(-1.0, 1.0);

  /// Mesma faixa convertida para percentual do polo direito (`0..100`).
  double get rightPercentLow => (50.0 * (1.0 + scoreLow)).clamp(0.0, 100.0);
  double get rightPercentHigh => (50.0 * (1.0 + scoreHigh)).clamp(0.0, 100.0);

  bool get leansLeft => score <= 0;

  String get dominantPole => leansLeft ? leftPole : rightPole;

  double get dominantPercent => leansLeft ? leftPercent : rightPercent;

  String get intensityLabel {
    if (isIndeterminate) return 'Indeterminado';
    final double absS = score.abs();
    if (absS < 0.15) return 'Equilibrado';
    if (absS < 0.45) return 'Inclinado';
    if (absS < 0.75) return 'Forte';
    return 'Muito forte';
  }

  String get summary {
    if (isIndeterminate) return 'Dados insuficientes';
    if (score.abs() < 0.15) {
      return 'Equilibrado (${leftPercent.toStringAsFixed(2)}% / ${rightPercent.toStringAsFixed(2)}%)';
    }
    return '${dominantPercent.toStringAsFixed(2)}% $dominantPole';
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'axisId': axisId,
    'label': label,
    'leftPole': leftPole,
    'rightPole': rightPole,
    'score': score,
    'standardError': standardError,
    'coverage': coverage,
    'answeredCount': answeredCount,
    'presentedCount': presentedCount,
    'tensionScore': tensionScore,
    'poleBreakdownAvailable': poleBreakdownAvailable,
    'answeredLeftCount': answeredLeftCount,
    'presentedLeftCount': presentedLeftCount,
    'answeredRightCount': answeredRightCount,
    'presentedRightCount': presentedRightCount,
    'leftPoleMean': leftPoleMean,
    'rightPoleMean': rightPoleMean,
  };

  factory BipolarDimensionScore.fromJson(
    Map<String, Object?> json,
    String path,
  ) {
    final bool hasPoleBreakdown = json['poleBreakdownAvailable'] == true;
    return BipolarDimensionScore(
      axisId: readString(json['axisId'], '$path.axisId'),
      label: readString(json['label'], '$path.label'),
      leftPole: readString(json['leftPole'], '$path.leftPole'),
      rightPole: readString(json['rightPole'], '$path.rightPole'),
      score: readDouble(json['score'], '$path.score').clamp(-1.0, 1.0),
      standardError: readDouble(
        json['standardError'],
        '$path.standardError',
      ).clamp(0.0, 2.0),
      coverage: readDouble(json['coverage'], '$path.coverage').clamp(0.0, 1.0),
      answeredCount: readInt(json['answeredCount'], '$path.answeredCount'),
      presentedCount: readInt(json['presentedCount'], '$path.presentedCount'),
      tensionScore: readDouble(
        json['tensionScore'],
        '$path.tensionScore',
      ).clamp(0.0, 2.0),
      poleBreakdownAvailable: hasPoleBreakdown,
      answeredLeftCount: hasPoleBreakdown
          ? readInt(json['answeredLeftCount'], '$path.answeredLeftCount')
          : 0,
      presentedLeftCount: hasPoleBreakdown
          ? readInt(json['presentedLeftCount'], '$path.presentedLeftCount')
          : 0,
      answeredRightCount: hasPoleBreakdown
          ? readInt(json['answeredRightCount'], '$path.answeredRightCount')
          : 0,
      presentedRightCount: hasPoleBreakdown
          ? readInt(json['presentedRightCount'], '$path.presentedRightCount')
          : 0,
      leftPoleMean: hasPoleBreakdown
          ? readDouble(
              json['leftPoleMean'],
              '$path.leftPoleMean',
            ).clamp(-1.0, 1.0)
          : 0.0,
      rightPoleMean: hasPoleBreakdown
          ? readDouble(
              json['rightPoleMean'],
              '$path.rightPoleMean',
            ).clamp(-1.0, 1.0)
          : 0.0,
    );
  }
}

/// Resultado de uma dimensão triangular (tríade), preservando tanto o apoio absoluto
/// a cada vértice quanto a composição baricêntrica no triângulo.
class TriadDimensionScore {
  const TriadDimensionScore({
    required this.categoryId,
    required this.label,
    required this.vertices,
    required this.vertexScores,
    required this.vertexSupport,
    required this.composition,
    required this.engagement,
    required this.standardError,
    required this.coverage,
    required this.answeredCount,
    required this.presentedCount,
    required this.classification,
    this.topContributions = const <ItemContribution>[],
    this.vertexBreakdownAvailable = false,
    this.vertexCoverage = const <double>[1.0, 1.0, 1.0],
    this.vertexObserved = const <bool>[true, true, true],
    this.vertexAnsweredCount = const <int>[0, 0, 0],
    this.vertexPresentedCount = const <int>[0, 0, 0],
  }) : assert(vertices.length == 3),
       assert(vertexScores.length == 3),
       assert(vertexSupport.length == 3),
       assert(composition.length == 3),
       assert(vertexCoverage.length == 3),
       assert(vertexObserved.length == 3),
       assert(vertexAnsweredCount.length == 3),
       assert(vertexPresentedCount.length == 3);

  final int categoryId;
  final String label;
  final List<String> vertices;

  /// Escores assinados `v_k` em `[-1.0, +1.0]` por vértice.
  final List<double> vertexScores;

  /// Apoio absoluto `u_k = (v_k + 1)/2` em `[0.0, 1.0]` por vértice.
  final List<double> vertexSupport;

  /// Participação relativa `p_k = u_k / Σu` em `[0.0, 1.0]`, somando `1.0`.
  final List<double> composition;

  /// Engajamento médio `I = média(u_k)` em `[0.0, 1.0]`.
  /// Permite distinguir quem apoia fortemente os 3 vértices (`I >= 0.65`) de
  /// quem rejeita os 3 (`I <= 0.35`), mesmo ambos tendo composição `[1/3, 1/3, 1/3]`.
  final double engagement;

  /// Erro-padrão médio da composição baricêntrica (`0..1`).
  final double standardError;
  final double coverage;
  final int answeredCount;
  final int presentedCount;
  final String classification;
  final List<ItemContribution> topContributions;

  /// Se `true`, cobertura e observação por vértice foram calculadas pelo motor
  /// atual. Registros antigos mantêm `false` e a regra de indeterminação original.
  final bool vertexBreakdownAvailable;

  /// Cobertura ponderada de cada vértice (`0..1`).
  final List<double> vertexCoverage;

  /// Se o vértice teve ao menos uma resposta. Quando `false`, [vertexSupport]
  /// contém apenas o preenchimento neutro de `0.5` e **não** representa uma
  /// observação do usuário.
  final List<bool> vertexObserved;
  final List<int> vertexAnsweredCount;
  final List<int> vertexPresentedCount;

  bool get hasAllVerticesObserved =>
      !vertexBreakdownAvailable || vertexObserved.every((bool o) => o);

  double get minimumVertexCoverage {
    if (!vertexBreakdownAvailable) return coverage;
    var min = vertexCoverage[0];
    for (var i = 1; i < 3; i++) {
      if (vertexCoverage[i] < min) min = vertexCoverage[i];
    }
    return min;
  }

  int get observedVertexCount => !vertexBreakdownAvailable
      ? 3
      : vertexObserved.where((bool o) => o).length;

  bool get isIndeterminate =>
      answeredCount == 0 ||
      coverage < 0.5 ||
      (vertexBreakdownAvailable &&
          (!hasAllVerticesObserved || answeredCount < 3));

  ScoreConfidence get confidence {
    if (isIndeterminate) return ScoreConfidence.insufficient;
    final minItems = vertexBreakdownAvailable
        ? vertexAnsweredCount.reduce((a, b) => a < b ? a : b)
        : answeredCount ~/ 3;
    if (minItems < 3) return ScoreConfidence.low;
    if (coverage < 0.70 ||
        minimumVertexCoverage < 0.34 ||
        standardError > 0.30) {
      return ScoreConfidence.low;
    }
    if (minItems < 4 || coverage < 0.90 || standardError > 0.18) {
      return ScoreConfidence.moderate;
    }
    return ScoreConfidence.high;
  }

  String get confidenceLabel => confidence.label;

  double get differentiation {
    var minP = composition[0];
    var maxP = composition[0];
    for (final double p in composition) {
      if (p < minP) minP = p;
      if (p > maxP) maxP = p;
    }
    return maxP - minP;
  }

  List<double> get compositionPercents => <double>[
    for (final double p in composition) p * 100.0,
  ];

  List<double> get supportPercents => <double>[
    for (final double u in vertexSupport) u * 100.0,
  ];

  int get dominantVertexIndex {
    var best = 0;
    for (var i = 1; i < composition.length; i++) {
      if (composition[i] > composition[best]) {
        best = i;
      }
    }
    return best;
  }

  String get dominantVertexName => vertices[dominantVertexIndex];

  Map<String, Object?> toJson() => <String, Object?>{
    'categoryId': categoryId,
    'label': label,
    'vertices': vertices,
    'vertexScores': vertexScores,
    'vertexSupport': vertexSupport,
    'composition': composition,
    'engagement': engagement,
    'standardError': standardError,
    'coverage': coverage,
    'answeredCount': answeredCount,
    'presentedCount': presentedCount,
    'classification': classification,
    'vertexBreakdownAvailable': vertexBreakdownAvailable,
    'vertexCoverage': vertexCoverage,
    'vertexObserved': vertexObserved,
    'vertexAnsweredCount': vertexAnsweredCount,
    'vertexPresentedCount': vertexPresentedCount,
  };

  factory TriadDimensionScore.fromJson(Map<String, Object?> json, String path) {
    List<double> readVec3(Object? raw, String field) {
      final List<Object?> arr = readArray(raw, '$path.$field');
      if (arr.length != 3) {
        throw FormatException('$path.$field: esperados 3 valores');
      }
      return <double>[
        for (var i = 0; i < 3; i++) readDouble(arr[i], '$path.$field[$i]'),
      ];
    }

    List<bool> readBools3(Object? raw, String field) {
      final List<Object?> arr = readArray(raw, '$path.$field');
      if (arr.length != 3) {
        throw FormatException('$path.$field: esperados 3 valores');
      }
      return <bool>[
        for (var i = 0; i < 3; i++) readBool(arr[i], '$path.$field[$i]'),
      ];
    }

    List<int> readInts3(Object? raw, String field) {
      final List<Object?> arr = readArray(raw, '$path.$field');
      if (arr.length != 3) {
        throw FormatException('$path.$field: esperados 3 valores');
      }
      return <int>[
        for (var i = 0; i < 3; i++) readInt(arr[i], '$path.$field[$i]'),
      ];
    }

    final List<Object?> rawVerts = readArray(
      json['vertices'],
      '$path.vertices',
    );
    if (rawVerts.length != 3) {
      throw FormatException('$path.vertices: esperados 3 rótulos');
    }
    final bool hasVertexBreakdown = json['vertexBreakdownAvailable'] == true;
    return TriadDimensionScore(
      categoryId: readInt(json['categoryId'], '$path.categoryId'),
      label: readString(json['label'], '$path.label'),
      vertices: <String>[
        for (var i = 0; i < 3; i++)
          readString(rawVerts[i], '$path.vertices[$i]'),
      ],
      vertexScores: readVec3(json['vertexScores'], 'vertexScores'),
      vertexSupport: readVec3(json['vertexSupport'], 'vertexSupport'),
      composition: readVec3(json['composition'], 'composition'),
      engagement: readDouble(
        json['engagement'],
        '$path.engagement',
      ).clamp(0.0, 1.0),
      standardError: readDouble(
        json['standardError'],
        '$path.standardError',
      ).clamp(0.0, 1.0),
      coverage: readDouble(json['coverage'], '$path.coverage').clamp(0.0, 1.0),
      answeredCount: readInt(json['answeredCount'], '$path.answeredCount'),
      presentedCount: readInt(json['presentedCount'], '$path.presentedCount'),
      classification: readString(
        json['classification'],
        '$path.classification',
      ),
      vertexBreakdownAvailable: hasVertexBreakdown,
      vertexCoverage: hasVertexBreakdown
          ? readVec3(json['vertexCoverage'], 'vertexCoverage')
          : const <double>[1.0, 1.0, 1.0],
      vertexObserved: hasVertexBreakdown
          ? readBools3(json['vertexObserved'], 'vertexObserved')
          : const <bool>[true, true, true],
      vertexAnsweredCount: hasVertexBreakdown
          ? readInts3(json['vertexAnsweredCount'], 'vertexAnsweredCount')
          : const <int>[0, 0, 0],
      vertexPresentedCount: hasVertexBreakdown
          ? readInts3(json['vertexPresentedCount'], 'vertexPresentedCount')
          : const <int>[0, 0, 0],
    );
  }
}

/// Diagnóstico de qualidade e consistência das respostas da sessão.
class ResponseQualityReport {
  const ResponseQualityReport({
    required this.totalPresented,
    required this.totalAnswered,
    required this.totalSkipped,
    required this.acquiescenceIndex,
    required this.extremeResponseRate,
    required this.neutralResponseRate,
    required this.axesInTension,
    this.answeredAxisCount = 0,
  });

  final int totalPresented;
  final int totalAnswered;
  final int totalSkipped;

  /// Média bruta das respostas normalizadas `x` sem inversão de sinal (`[-1, 1]`).
  /// Como os itens são balanceados entre polos opostos, valores acima de `+0.45`
  /// indicam tendência a concordar com afirmações contraditórias (viés de aquiescência).
  final double acquiescenceIndex;
  final double extremeResponseRate;
  final double neutralResponseRate;
  final List<String> axesInTension;

  /// Número de eixos com ao menos uma resposta. Usado para contextualizar a
  /// proporção de eixos em tensão e evitar que um único eixo dispare o aviso
  /// global de baixa discriminação.
  final int answeredAxisCount;

  double get coverage => totalPresented == 0
      ? 0.0
      : (totalAnswered / totalPresented).clamp(0.0, 1.0);

  /// Proporção de eixos respondidos que exibem conflito real entre polos.
  double get tensionAxisRatio => answeredAxisCount == 0
      ? 0.0
      : (axesInTension.length / answeredAxisCount).clamp(0.0, 1.0);

  /// Evidência de baixa discriminação: ao menos dois eixos com ambos os polos
  /// respondidos e conflito entre eles, cobrindo metade ou mais dos eixos
  /// respondidos. Não pune concordância alta por si só: exige que a própria
  /// estrutura balanceada do banco revele respostas mutuamente incompatíveis.
  bool get hasLowDiscriminationWarning =>
      answeredAxisCount >= 2 &&
      axesInTension.length >= 2 &&
      tensionAxisRatio >= 0.5;

  /// Alerta de aquiescência agora condicionado a conflito real em pelo menos
  /// um eixo. Alto índice de concordância isolado não basta.
  bool get hasAcquiescenceWarning =>
      totalAnswered >= 12 &&
      acquiescenceIndex.abs() > 0.45 &&
      axesInTension.isNotEmpty;

  bool get hasLowCoverageWarning => coverage < 0.70;

  /// Modalidades só de tríades não têm eixos para revelar tensão. Nesse caso,
  /// marcar sempre o mesmo extremo não diferencia as três perspectivas e deve
  /// ser sinalizado explicitamente, em vez de virar um perfil ideológico.
  bool get hasUniformExtremeWarning =>
      answeredAxisCount == 0 &&
      totalAnswered >= 12 &&
      extremeResponseRate >= 0.90 &&
      acquiescenceIndex.abs() >= 0.90;

  /// Padrão de respostas integralmente neutras: o resultado reflete o centro
  /// do instrumento. Distinto do aviso de conflito, pois não há contradição —
  /// há ausência de diferenciação entre os polos.
  bool get hasAllNeutralWarning =>
      totalAnswered >= 12 && neutralResponseRate >= 0.90;

  List<String> get warnings {
    final List<String> out = <String>[];
    if (hasLowCoverageWarning) {
      out.add(
        'Cobertura reduzida (${(coverage * 100).round()}% de itens respondidos): '
        'dimensões com muitos pulos apresentam incerteza maior.',
      );
    }
    if (hasAllNeutralWarning) {
      out.add(
        'Você marcou "neutro" em ${(neutralResponseRate * 100).round()}% dos '
        'itens respondidos. O resultado fica no centro do instrumento por '
        'ausência de diferenciação entre os polos, o que não é o mesmo que '
        'moderação convicta. Se essa não for sua intenção, revise os itens em '
        'que você tem preferência.',
      );
    }
    if (hasUniformExtremeWarning) {
      out.add(
        'Você escolheu o mesmo extremo em ${(extremeResponseRate * 100).round()}% '
        'dos itens. Nesta modalidade de tríades, isso não diferencia as três '
        'perspectivas: o resultado deve ser lido como preferência fraca ou '
        'padrão de resposta, não como posição ideológica firmada.',
      );
    }
    if (hasLowDiscriminationWarning) {
      final String direction = acquiescenceIndex >= 0
          ? 'concordou fortemente com'
          : 'discordou fortemente de';
      out.add(
        'Você $direction propostas que representam polos políticos divergentes '
        'em ${axesInTension.length} de $answeredAxisCount eixos avaliados. '
        'Isso não é uma reprovação: significa que algumas dimensões podem não '
        'discriminar claramente suas preferências, e o resultado deve ser lido '
        'com cautela.',
      );
    } else if (hasAcquiescenceWarning) {
      final String direction = acquiescenceIndex > 0
          ? 'concordar com'
          : 'discordar de';
      out.add(
        'Viés de resposta detectado: houve tendência sistemática a $direction '
        'afirmações de polos opostos (índice ${(acquiescenceIndex * 100).round()}%).',
      );
    }
    if (axesInTension.isNotEmpty && !hasLowDiscriminationWarning) {
      out.add(
        'Tensão interna em ${axesInTension.join(", ")}: suas respostas apoiaram '
        'simultaneamente aspectos dos dois polos, indicando posição híbrida ou contextual.',
      );
    }
    return out;
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'totalPresented': totalPresented,
    'totalAnswered': totalAnswered,
    'totalSkipped': totalSkipped,
    'acquiescenceIndex': acquiescenceIndex,
    'extremeResponseRate': extremeResponseRate,
    'neutralResponseRate': neutralResponseRate,
    'axesInTension': axesInTension,
    'answeredAxisCount': answeredAxisCount,
  };

  factory ResponseQualityReport.fromJson(
    Map<String, Object?> json,
    String path,
  ) {
    final List<Object?> rawTensions = readArray(
      json['axesInTension'],
      '$path.axesInTension',
    );
    return ResponseQualityReport(
      totalPresented: readInt(json['totalPresented'], '$path.totalPresented'),
      totalAnswered: readInt(json['totalAnswered'], '$path.totalAnswered'),
      totalSkipped: readInt(json['totalSkipped'], '$path.totalSkipped'),
      acquiescenceIndex: readDouble(
        json['acquiescenceIndex'],
        '$path.acquiescenceIndex',
      ),
      extremeResponseRate: readDouble(
        json['extremeResponseRate'],
        '$path.extremeResponseRate',
      ),
      neutralResponseRate: readDouble(
        json['neutralResponseRate'],
        '$path.neutralResponseRate',
      ),
      axesInTension: <String>[
        for (var i = 0; i < rawTensions.length; i++)
          readString(rawTensions[i], '$path.axesInTension[$i]'),
      ],
      answeredAxisCount: json['answeredAxisCount'] == null
          ? 0
          : readInt(json['answeredAxisCount'], '$path.answeredAxisCount'),
    );
  }
}

/// Parâmetro esperado de uma corrente ideológica em um eixo bipolar.
class CurrentAxisProfile {
  const CurrentAxisProfile({
    required this.mu,
    required this.sigma,
    required this.relevance,
    required this.note,
  });

  final double mu;
  final double sigma;
  final double relevance;
  final String note;

  factory CurrentAxisProfile.fromJson(Map<String, Object?> json, String path) {
    final double mu = readDouble(json['mu'], '$path.mu');
    final double sigma = readDouble(json['sigma'], '$path.sigma');
    final double relevance = readDouble(json['relevance'], '$path.relevance');
    if (mu < -1.0 || mu > 1.0) {
      throw FormatException('$path.mu fora de [-1, 1]: $mu');
    }
    if (sigma <= 0.05 || sigma > 1.5) {
      throw FormatException('$path.sigma fora de (0.05, 1.5]: $sigma');
    }
    if (relevance < 0.0 || relevance > 1.0) {
      throw FormatException('$path.relevance fora de [0, 1]: $relevance');
    }
    return CurrentAxisProfile(
      mu: mu,
      sigma: sigma,
      relevance: relevance,
      note: readString(json['note'], '$path.note'),
    );
  }
}

/// Parâmetro esperado de uma corrente ideológica em uma tríade.
class CurrentTriadProfile {
  const CurrentTriadProfile({
    required this.mu,
    required this.sigma,
    required this.relevance,
    required this.note,
  }) : assert(mu.length == 3);

  final List<double> mu;
  final double sigma;
  final double relevance;
  final String note;

  factory CurrentTriadProfile.fromJson(Map<String, Object?> json, String path) {
    final List<Object?> rawMu = readArray(json['mu'], '$path.mu');
    if (rawMu.length != 3) {
      throw FormatException('$path.mu deve ter 3 coordenadas');
    }
    final List<double> mu = <double>[
      for (var i = 0; i < 3; i++) readDouble(rawMu[i], '$path.mu[$i]'),
    ];
    final double sum = mu[0] + mu[1] + mu[2];
    if (mu.any((v) => v < 0) || (sum - 1.0).abs() > 0.01) {
      throw FormatException('$path.mu deve somar 1.0 (recebido $sum)');
    }
    final double sigma = readDouble(json['sigma'], '$path.sigma');
    final double relevance = readDouble(json['relevance'], '$path.relevance');
    if (sigma <= 0.05 || sigma > 1.5) {
      throw FormatException('$path.sigma fora de (0.05, 1.5]: $sigma');
    }
    if (relevance < 0.0 || relevance > 1.0) {
      throw FormatException('$path.relevance fora de [0, 1]: $relevance');
    }
    return CurrentTriadProfile(
      mu: <double>[mu[0] / sum, mu[1] / sum, mu[2] / sum],
      sigma: sigma,
      relevance: relevance,
      note: readString(json['note'], '$path.note'),
    );
  }
}

/// Corrente ideológica do catálogo do Espectro.
class IdeologicalCurrent {
  const IdeologicalCurrent({
    required this.id,
    required this.name,
    required this.family,
    required this.summary,
    required this.keyIdeas,
    required this.axes,
    required this.triangles,
    this.spectrumId,
    this.editorialBasis,
  });

  final String? spectrumId;
  final StudyEditorialBasis? editorialBasis;
  final String id;
  final String name;
  final String family;
  final String summary;
  final List<String> keyIdeas;
  final Map<String, CurrentAxisProfile> axes;
  final Map<int, CurrentTriadProfile> triangles;

  factory IdeologicalCurrent.fromJson(Map<String, Object?> json, String path) {
    final List<Object?> rawIdeas = readArray(
      json['keyIdeas'],
      '$path.keyIdeas',
    );
    final Map<String, Object?> rawAxes = readObject(json['axes'], '$path.axes');
    final Map<String, Object?> rawTris = readObject(
      json['triangles'],
      '$path.triangles',
    );
    final Map<String, CurrentAxisProfile> axes = <String, CurrentAxisProfile>{};
    for (final MapEntry<String, Object?> entry in rawAxes.entries) {
      axes[entry.key] = CurrentAxisProfile.fromJson(
        readObject(entry.value, '$path.axes.${entry.key}'),
        '$path.axes.${entry.key}',
      );
    }
    final Map<int, CurrentTriadProfile> triangles =
        <int, CurrentTriadProfile>{};
    for (final MapEntry<String, Object?> entry in rawTris.entries) {
      final int? catId = int.tryParse(entry.key);
      if (catId == null || catId < 0 || catId > 5) {
        throw FormatException('$path.triangles: chave inválida "${entry.key}"');
      }
      triangles[catId] = CurrentTriadProfile.fromJson(
        readObject(entry.value, '$path.triangles.${entry.key}'),
        '$path.triangles.${entry.key}',
      );
    }
    return IdeologicalCurrent(
      spectrumId: readStringOrNull(json['spectrumId'], '$path.spectrumId'),
      editorialBasis: StudyEditorialBasis.parse(
        json['editorialBasis'],
        '$path.editorialBasis',
      ),
      id: readString(json['id'], '$path.id'),
      name: readString(json['name'], '$path.name'),
      family: readString(json['family'], '$path.family'),
      summary: readString(json['summary'], '$path.summary'),
      keyIdeas: <String>[
        for (var i = 0; i < rawIdeas.length; i++)
          readString(rawIdeas[i], '$path.keyIdeas[$i]'),
      ],
      axes: axes,
      triangles: triangles,
    );
  }
}

/// Catálogo completo de correntes ideológicas.
class IdeologicalCatalog {
  const IdeologicalCatalog({
    required this.schemaVersion,
    required this.catalogVersion,
    required this.currents,
  });

  final int schemaVersion;
  final String catalogVersion;
  final List<IdeologicalCurrent> currents;

  factory IdeologicalCatalog.fromJson(Map<String, Object?> json) {
    final List<Object?> rawList = readArray(json['currents'], 'currents');
    if (rawList.isEmpty) {
      throw const FormatException('currents: catálogo vazio');
    }
    return IdeologicalCatalog(
      schemaVersion: readInt(json['schemaVersion'], 'schemaVersion'),
      catalogVersion: readString(json['catalogVersion'], 'catalogVersion'),
      currents: <IdeologicalCurrent>[
        for (var i = 0; i < rawList.length; i++)
          IdeologicalCurrent.fromJson(
            readObject(rawList[i], 'currents[$i]'),
            'currents[$i]',
          ),
      ],
    );
  }
}

/// Registro persistido de uma avaliação concluída.
class EvaluationRecord {
  const EvaluationRecord({
    required this.id,
    required this.createdAt,
    required this.suite,
    required this.depth,
    required this.seed,
    required this.engineVersion,
    required this.bankVersion,
    required this.rawAnswers,
    required this.axes,
    required this.triads,
    required this.quality,
    this.title,
    this.isPreliminary = false,
  });

  static const int currentSchemaVersion = 1;

  final String id;
  final DateTime createdAt;
  final TestSuite suite;
  final TestDepth depth;
  final int seed;
  final String engineVersion;
  final String bankVersion;

  /// Mapa `questionUid -> valor Likert (-2..+2)` ou `null` quando pulada.
  final Map<String, int?> rawAnswers;
  final List<BipolarDimensionScore> axes;
  final List<TriadDimensionScore> triads;
  final ResponseQualityReport quality;
  final String? title;
  final bool isPreliminary;

  String get displayTitle => (title != null && title!.trim().isNotEmpty)
      ? title!.trim()
      : '${suite.title} (${depth.label})';

  BipolarDimensionScore? axisById(String id) {
    for (final BipolarDimensionScore axis in axes) {
      if (axis.axisId == id) return axis;
    }
    return null;
  }

  TriadDimensionScore? triadByCategoryId(int categoryId) {
    for (final TriadDimensionScore triad in triads) {
      if (triad.categoryId == categoryId) return triad;
    }
    return null;
  }

  EvaluationRecord copyWith({String? title, bool? isPreliminary}) {
    return EvaluationRecord(
      id: id,
      createdAt: createdAt,
      suite: suite,
      depth: depth,
      seed: seed,
      engineVersion: engineVersion,
      bankVersion: bankVersion,
      rawAnswers: rawAnswers,
      axes: axes,
      triads: triads,
      quality: quality,
      title: title ?? this.title,
      isPreliminary: isPreliminary ?? this.isPreliminary,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': currentSchemaVersion,
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'suite': suite.id,
    'depth': depth.id,
    'seed': seed,
    'engineVersion': engineVersion,
    'bankVersion': bankVersion,
    'title': title,
    'isPreliminary': isPreliminary,
    'rawAnswers': rawAnswers,
    'axes': <Object?>[for (final BipolarDimensionScore a in axes) a.toJson()],
    'triads': <Object?>[for (final TriadDimensionScore t in triads) t.toJson()],
    'quality': quality.toJson(),
  };

  factory EvaluationRecord.fromJson(
    Map<String, Object?> json, [
    String path = 'record',
  ]) {
    final int schema = json['schemaVersion'] == null
        ? 1
        : readInt(json['schemaVersion'], '$path.schemaVersion');
    if (schema < 1) {
      throw FormatException('$path.schemaVersion inválido: $schema');
    }
    final Map<String, Object?> rawAnsObj = readObject(
      json['rawAnswers'],
      '$path.rawAnswers',
    );
    final Map<String, int?> rawAnswers = <String, int?>{};
    for (final MapEntry<String, Object?> entry in rawAnsObj.entries) {
      rawAnswers[entry.key] = entry.value == null
          ? null
          : readInt(entry.value, '$path.rawAnswers.${entry.key}');
    }
    final List<Object?> rawAxes = readArray(json['axes'], '$path.axes');
    final List<Object?> rawTriads = readArray(json['triads'], '$path.triads');
    final DateTime? parsedDate = DateTime.tryParse(
      readString(json['createdAt'], '$path.createdAt'),
    );
    if (parsedDate == null) {
      throw FormatException('$path.createdAt: data ISO-8601 inválida');
    }
    final bool isPrelim = json['isPreliminary'] is bool
        ? json['isPreliminary'] as bool
        : false;
    return EvaluationRecord(
      id: readString(json['id'], '$path.id'),
      createdAt: parsedDate,
      suite: TestSuite.fromId(readString(json['suite'], '$path.suite')),
      depth: TestDepth.fromId(readString(json['depth'], '$path.depth')),
      seed: readInt(json['seed'], '$path.seed'),
      engineVersion: readString(json['engineVersion'], '$path.engineVersion'),
      bankVersion: readString(json['bankVersion'], '$path.bankVersion'),
      title: readStringOrNull(json['title'], '$path.title'),
      isPreliminary: isPrelim,
      rawAnswers: rawAnswers,
      axes: <BipolarDimensionScore>[
        for (var i = 0; i < rawAxes.length; i++)
          BipolarDimensionScore.fromJson(
            readObject(rawAxes[i], '$path.axes[$i]'),
            '$path.axes[$i]',
          ),
      ],
      triads: <TriadDimensionScore>[
        for (var i = 0; i < rawTriads.length; i++)
          TriadDimensionScore.fromJson(
            readObject(rawTriads[i], '$path.triads[$i]'),
            '$path.triads[$i]',
          ),
      ],
      quality: ResponseQualityReport.fromJson(
        readObject(json['quality'], '$path.quality'),
        '$path.quality',
      ),
    );
  }
}

/// Estado persistível de uma sessão em andamento (permite retomar de onde parou).
class ActiveQuizDraft {
  const ActiveQuizDraft({
    required this.suite,
    required this.depth,
    required this.seed,
    required this.questionUids,
    required this.answers,
    required this.skippedSet,
    required this.currentIndex,
    required this.updatedAt,
    this.completingRecordId,
  });

  final TestSuite suite;
  final TestDepth depth;
  final int seed;
  final List<String> questionUids;

  /// Valores Likert (`-2..+2`) ou `null` quando ainda não respondida ou pulada.
  final List<int?> answers;

  /// UIDs explicitamente pulados pelo usuário.
  final Set<String> skippedSet;
  final int currentIndex;
  final DateTime updatedAt;

  /// Quando preenchido, indica que esta sessão de +18 perguntas complementa
  /// as 6 tríades de um [EvaluationRecord] já concluído apenas nos 12 eixos.
  final String? completingRecordId;

  int get answeredOrSkippedCount {
    var count = 0;
    for (var i = 0; i < questionUids.length; i++) {
      if (answers[i] != null || skippedSet.contains(questionUids[i])) {
        count++;
      }
    }
    return count;
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': 1,
    'suite': suite.id,
    'depth': depth.id,
    'seed': seed,
    'questionUids': questionUids,
    'answers': answers,
    'skippedUids': skippedSet.toList(),
    'currentIndex': currentIndex,
    'updatedAt': updatedAt.toIso8601String(),
    if (completingRecordId != null) 'completingRecordId': completingRecordId,
  };

  factory ActiveQuizDraft.fromJson(
    Map<String, Object?> json, [
    String path = 'draft',
  ]) {
    final List<Object?> rawUids = readArray(
      json['questionUids'],
      '$path.questionUids',
    );
    final List<Object?> rawAns = readArray(json['answers'], '$path.answers');
    final List<Object?> rawSkipped = readArray(
      json['skippedUids'],
      '$path.skippedUids',
    );
    if (rawUids.length != rawAns.length || rawUids.isEmpty) {
      throw FormatException(
        '$path: tamanho inconsistente de questionUids/answers',
      );
    }
    final DateTime? updated = DateTime.tryParse(
      readString(json['updatedAt'], '$path.updatedAt'),
    );
    if (updated == null) {
      throw FormatException('$path.updatedAt inválido');
    }
    return ActiveQuizDraft(
      suite: TestSuite.fromId(readString(json['suite'], '$path.suite')),
      depth: TestDepth.fromId(readString(json['depth'], '$path.depth')),
      seed: readInt(json['seed'], '$path.seed'),
      questionUids: <String>[
        for (var i = 0; i < rawUids.length; i++)
          readString(rawUids[i], '$path.questionUids[$i]'),
      ],
      answers: <int?>[
        for (var i = 0; i < rawAns.length; i++)
          rawAns[i] == null ? null : readInt(rawAns[i], '$path.answers[$i]'),
      ],
      skippedSet: <String>{
        for (var i = 0; i < rawSkipped.length; i++)
          readString(rawSkipped[i], '$path.skippedUids[$i]'),
      },
      currentIndex: readInt(
        json['currentIndex'],
        '$path.currentIndex',
      ).clamp(0, rawUids.length - 1),
      updatedAt: updated,
      completingRecordId: readStringOrNull(
        json['completingRecordId'],
        '$path.completingRecordId',
      ),
    );
  }
}
