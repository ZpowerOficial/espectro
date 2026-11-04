import 'dart:math';

import '../data/models.dart';

enum SixVariant { short, long }

extension SixVariantInfo on SixVariant {
  String get label => switch (this) {
    SixVariant.short => 'Curta',
    SixVariant.long => 'Longa',
  };

  int get questionsPerBucket => switch (this) {
    SixVariant.short => 1,
    SixVariant.long => 2,
  };

  int get questionCount => 72 * questionsPerBucket;

  String get duration => switch (this) {
    SixVariant.short => '± 10 min',
    SixVariant.long => '± 20 min',
  };
}

/// Escala de 5 pontos usada nos dois testes, do mais concorde ao mais discorde.
const List<String> agreementLabels = <String>[
  'Concordo totalmente',
  'Concordo',
  'Neutro ou depende',
  'Discordo',
  'Discordo totalmente',
];

int _bucketOf(SixQuestion question) {
  final int strength = question.multiplier == 1
      ? question.strength
      : 5 - question.strength;
  return strength - 1;
}

/// Sorteia `perBucket` perguntas de cada uma das 72 células
/// (6 categorias × 3 subcategorias × 4 faixas de força), como no site.
List<SixQuestion> selectSixQuestions(
  SixTrianglesData data,
  SixVariant variant,
  Random random,
) {
  final Map<int, List<SixQuestion>> buckets = <int, List<SixQuestion>>{};
  for (final SixQuestion question in data.questions) {
    final int key =
        (question.category * 3 + question.subcategory) * 4 +
        _bucketOf(question);
    buckets.putIfAbsent(key, () => <SixQuestion>[]).add(question);
  }

  final List<SixQuestion> selected = <SixQuestion>[];
  for (var category = 0; category < 6; category++) {
    for (var subcategory = 0; subcategory < 3; subcategory++) {
      for (var bucket = 0; bucket < 4; bucket++) {
        final int key = (category * 3 + subcategory) * 4 + bucket;
        final List<SixQuestion> pool = <SixQuestion>[...?buckets[key]]
          ..shuffle(random);
        if (pool.length < variant.questionsPerBucket) {
          throw StateError(
            'Célula $key sem perguntas suficientes para ${variant.label}',
          );
        }
        selected.addAll(pool.take(variant.questionsPerBucket));
      }
    }
  }
  selected.shuffle(random);
  return selected;
}

class TriangleScore {
  const TriangleScore({
    required this.category,
    required this.points,
    required this.classification,
  }) : assert(points.length == 3, 'TriangleScore exige exatamente 3 pontos');

  final SixCategory category;

  /// Pesos normalizados para 1000, na ordem das subcategorias.
  final List<int> points;
  final String classification;

  List<double> get percents => <double>[for (final point in points) point / 10];
}

String classifyTriangle(List<int> points, List<String> subcategories) {
  if (points.length != 3 || subcategories.length != 3) {
    throw ArgumentError('classificação exige exatamente 3 vértices');
  }
  final List<int> sorted = <int>[...points]..sort();
  final int highest = sorted[2];
  final int middle = sorted[1];
  final int lowest = sorted[0];

  if (middle < 0.7 * highest) {
    final int index = points.indexOf(highest);
    final String sub = subcategories[index];
    if (highest >= 900) return 'Fanático por $sub';
    if (highest >= 750) return 'Extremo em $sub';
    if (highest >= 500) return '$sub em destaque';
    return 'Moderado em $sub';
  }
  if (lowest < 0.5 * middle) {
    final int index = points.indexOf(lowest);
    final String sub = subcategories[index];
    if (lowest < 10) return 'Fanático anti-$sub';
    if (lowest < 50) return 'Extremo anti-$sub';
    return 'Anti-$sub';
  }
  return 'Centrista';
}

class SixTrianglesResult {
  const SixTrianglesResult({
    required this.triangles,
    required this.answeredCount,
  });

  final List<TriangleScore> triangles;
  final int answeredCount;

  String toShareText() {
    final buffer = StringBuffer('Espectro · Six Triangles\n');
    for (final TriangleScore triangle in triangles) {
      buffer.writeln('${triangle.category.label}: ${triangle.classification}');
      for (var i = 0; i < 3; i++) {
        buffer.writeln(
          '  ${triangle.category.subcategories[i]}: ${triangle.percents[i].toStringAsFixed(1)}%',
        );
      }
    }
    return buffer.toString().trimRight();
  }
}

class SixTrianglesSession {
  SixTrianglesSession({
    required this.data,
    required this.variant,
    Random? random,
  }) : _random = random ?? Random() {
    questions.addAll(selectSixQuestions(data, variant, _random));
    answers = List<int?>.filled(questions.length, null);
  }

  final SixTrianglesData data;
  final SixVariant variant;
  final Random _random;
  final List<SixQuestion> questions = <SixQuestion>[];
  late final List<int?> answers;
  int index = 0;

  SixQuestion get current => questions[index];

  int? get currentAnswer => answers[index];

  int get answeredCount => answers.where((answer) => answer != null).length;

  bool get isFirst => index == 0;

  bool get isLast => index == questions.length - 1;

  double get progress =>
      questions.isEmpty ? 0 : answeredCount / questions.length;

  void select(int optionIndex) {
    if (optionIndex < 0 || optionIndex >= agreementLabels.length) {
      throw RangeError.index(optionIndex, agreementLabels, 'optionIndex');
    }
    answers[index] = optionIndex;
  }

  void next() {
    if (!isLast) index++;
  }

  void previous() {
    if (!isFirst) index--;
  }

  SixTrianglesResult? result() {
    if (answers.any((answer) => answer == null)) return null;

    final List<int> sums = List<int>.filled(18, 1);
    for (var i = 0; i < questions.length; i++) {
      final SixQuestion question = questions[i];
      final int answer = answers[i]!;
      final int contribution = question.multiplier == 1 ? 4 - answer : answer;
      sums[question.category * 3 + question.subcategory] += contribution;
    }

    final List<TriangleScore> triangles = <TriangleScore>[];
    for (final SixCategory category in data.categories) {
      final List<int> raw = <int>[
        sums[category.id * 3],
        sums[category.id * 3 + 1],
        sums[category.id * 3 + 2],
      ];
      final int total = raw[0] + raw[1] + raw[2];
      final List<int> points = <int>[
        for (final value in raw) (value * 1000 / total).round(),
      ];
      triangles.add(
        TriangleScore(
          category: category,
          points: points,
          classification: classifyTriangle(points, category.subcategories),
        ),
      );
    }
    return SixTrianglesResult(
      triangles: triangles,
      answeredCount: answeredCount,
    );
  }
}
