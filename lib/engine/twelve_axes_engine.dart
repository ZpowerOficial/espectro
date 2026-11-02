import 'dart:math';

import '../data/models.dart';

enum TwelveVariant { short, complete, extreme }

extension TwelveVariantInfo on TwelveVariant {
  String get label => switch (this) {
        TwelveVariant.short => 'Curta',
        TwelveVariant.complete => 'Completa',
        TwelveVariant.extreme => 'Extrema',
      };

  int get questionCount => switch (this) {
        TwelveVariant.short => 36,
        TwelveVariant.complete => 60,
        TwelveVariant.extreme => 240,
      };

  int get perAxis => switch (this) {
        TwelveVariant.short => 3,
        TwelveVariant.complete => 5,
        TwelveVariant.extreme => 0,
      };

  String get duration => switch (this) {
        TwelveVariant.short => '± 5 min',
        TwelveVariant.complete => '± 9 min',
        TwelveVariant.extreme => '± 30 min',
      };

  String get description => switch (this) {
        TwelveVariant.short => 'Leitura rápida do seu perfil em 12 eixos.',
        TwelveVariant.complete => 'Mais perguntas por eixo para um retrato mais estável.',
        TwelveVariant.extreme => 'Todas as 240 perguntas do banco original.',
      };
}

/// Sorteia as perguntas da sessão. Reproduz o comportamento do site:
/// em cada eixo metade das perguntas vem de cada polo e o conjunto final é
/// intercalado entre esquerda e direita para não agrupar tendências.
List<AxisQuestion> selectTwelveQuestions(
  TwelveAxesData data,
  TwelveVariant variant,
  Random random,
) {
  if (variant == TwelveVariant.extreme) {
    return _interleave(<AxisQuestion>[...data.questions], random);
  }

  final int perAxis = variant.perAxis;
  final List<AxisQuestion> selected = <AxisQuestion>[];
  for (var axisIndex = 0; axisIndex < data.axes.length; axisIndex++) {
    final Axis axis = data.axes[axisIndex];
    final List<AxisQuestion> left = data.questionsFor(axis.id).where((q) => q.agreeIsLeft).toList()
      ..shuffle(random);
    final List<AxisQuestion> right = data.questionsFor(axis.id).where((q) => !q.agreeIsLeft).toList()
      ..shuffle(random);
    final int fromLeft = axisIndex.isEven ? (perAxis / 2).ceil() : perAxis ~/ 2;
    final int fromRight = perAxis - fromLeft;
    if (left.length < fromLeft || right.length < fromRight) {
      throw StateError('Eixo ${axis.id} sem perguntas suficientes para $perAxis itens');
    }
    selected
      ..addAll(left.take(fromLeft))
      ..addAll(right.take(fromRight));
  }
  return _interleave(selected, random);
}

List<AxisQuestion> _interleave(List<AxisQuestion> questions, Random random) {
  final List<AxisQuestion> left = questions.where((q) => q.agreeIsLeft).toList();
  final List<AxisQuestion> right = questions.where((q) => !q.agreeIsLeft).toList();
  final List<AxisQuestion> output = <AxisQuestion>[];
  var takeLeft = random.nextBool();
  var leftIndex = 0;
  var rightIndex = 0;
  while (output.length < questions.length) {
    final bool canLeft = leftIndex < left.length;
    final bool canRight = rightIndex < right.length;
    if (takeLeft && canLeft) {
      output.add(left[leftIndex++]);
    } else if (!takeLeft && canRight) {
      output.add(right[rightIndex++]);
    } else if (canLeft) {
      output.add(left[leftIndex++]);
    } else {
      output.add(right[rightIndex++]);
    }
    takeLeft = !takeLeft;
  }
  return output;
}

class AxisScore {
  const AxisScore({required this.axis, required this.leftPercent});

  final Axis axis;

  /// Percentual do polo esquerdo, de 0 a 100.
  final double leftPercent;

  double get rightPercent => 100 - leftPercent;

  bool get leansLeft => leftPercent >= 50;

  String get dominantPole => leansLeft ? axis.leftPole : axis.rightPole;

  double get dominantPercent => leansLeft ? leftPercent : rightPercent;

  int get dominantPercentRounded => dominantPercent.round();

  double get distanceFromCenter => (leftPercent - 50).abs();

  String get intensity {
    final double distance = distanceFromCenter;
    if (distance < 5) return 'Equilibrado';
    if (distance < 20) return 'Inclinado';
    if (distance < 40) return 'Forte';
    return 'Muito forte';
  }

  bool get isBalanced => intensity == 'Equilibrado';

  /// Ex.: `58% Privado`.
  String get summary => isBalanced ? 'Equilibrado' : '$dominantPercentRounded% $dominantPole';
}

class TwelveAxesResult {
  const TwelveAxesResult({
    required this.scores,
    required this.answeredCount,
    required this.questionCount,
  });

  final List<AxisScore> scores;
  final int answeredCount;
  final int questionCount;

  AxisScore get strongest {
    if (scores.isEmpty) {
      throw StateError('Não há pontuações para calcular o eixo mais forte');
    }
    var best = scores.first;
    for (final score in scores) {
      if (score.distanceFromCenter > best.distanceFromCenter) best = score;
    }
    return best;
  }

  AxisScore get mostBalanced {
    if (scores.isEmpty) {
      throw StateError('Não há pontuações para calcular o eixo mais equilibrado');
    }
    var best = scores.first;
    for (final score in scores) {
      if (score.distanceFromCenter < best.distanceFromCenter) best = score;
    }
    return best;
  }

  int get leaningLeftCount => scores.where((score) => score.leansLeft).length;

  String toShareText() {
    final buffer = StringBuffer('Espectro · 12 Eixos\n');
    for (final score in scores) {
      buffer.writeln('${score.axis.label}: ${score.summary}');
    }
    return buffer.toString().trimRight();
  }
}

/// Sessão de respostas do 12 Eixos. Mutável de propósito: a tela usa
/// `setState` e esta classe concentra toda a regra de pontuação.
class TwelveAxesSession {
  TwelveAxesSession({
    required this.data,
    required this.variant,
    Random? random,
  }) : _random = random ?? Random() {
    questions.addAll(selectTwelveQuestions(data, variant, _random));
    answers = List<int?>.filled(questions.length, null);
    _usedIds = questions.map((question) => question.id).toSet();
  }

  final TwelveAxesData data;
  final TwelveVariant variant;
  final Random _random;
  final List<AxisQuestion> questions = <AxisQuestion>[];
  late final List<int?> answers;
  late final Set<String> _usedIds;
  final Set<String> _skippedIds = <String>{};
  final Map<String, int> archetypeChoices = <String, int>{};
  String? religionId;
  int index = 0;

  AxisQuestion get current => questions[index];

  int? get currentAnswer => answers[index];

  int get answeredCount => answers.where((answer) => answer != null).length;

  bool get isComplete => answers.every((answer) => answer != null);

  bool get isFirst => index == 0;

  bool get isLast => index == questions.length - 1;

  Axis get currentAxis {
    final Axis? axis = data.axisById[current.axisId];
    if (axis == null) {
      throw StateError('Pergunta ${current.id} aponta para eixo inexistente');
    }
    return axis;
  }

  double get progress => questions.isEmpty ? 0 : answeredCount / questions.length;

  void select(int optionIndex) {
    if (optionIndex < 0 || optionIndex >= data.answerOptions.length) {
      throw RangeError.index(optionIndex, data.answerOptions, 'optionIndex');
    }
    answers[index] = optionIndex;
  }

  void next() {
    if (!isLast) index++;
  }

  void previous() {
    if (!isFirst) index--;
  }

  /// Troca a pergunta atual por outra do mesmo eixo ainda não usada. Devolve
  /// `false` quando o banco do eixo se esgotou.
  bool swapCurrent() {
    final String axisId = current.axisId;
    final List<AxisQuestion> candidates = data.questionsFor(axisId).where((question) {
      return !_usedIds.contains(question.id) && !_skippedIds.contains(question.id);
    }).toList();
    if (candidates.isEmpty) return false;
    final AxisQuestion replacement = candidates[_random.nextInt(candidates.length)];
    _skippedIds.add(questions[index].id);
    _usedIds.remove(questions[index].id);
    _usedIds.add(replacement.id);
    questions[index] = replacement;
    answers[index] = null;
    return true;
  }

  void setArchetypeChoice(String questionId, int optionIndex) {
    final ArchetypeQuestion? question = data.archetypeQuestions
        .where((q) => q.id == questionId)
        .firstOrNull;
    if (question == null) {
      throw ArgumentError.value(questionId, 'questionId', 'Pergunta de arquétipo inexistente');
    }
    if (optionIndex < 0 || optionIndex >= question.options.length) {
      throw RangeError.index(optionIndex, question.options, 'optionIndex');
    }
    archetypeChoices[questionId] = optionIndex;
  }

  void setReligion(String? religionId) {
    this.religionId = religionId;
  }

  TwelveAxesResult? result() {
    if (!isComplete) return null;
    final List<AxisScore> scores = <AxisScore>[];
    for (final Axis axis in data.axes) {
      var weighted = 0.0;
      var totalWeight = 0.0;
      for (var i = 0; i < questions.length; i++) {
        final AxisQuestion question = questions[i];
        if (question.axisId != axis.id) continue;
        final int? answerIndex = answers[i];
        if (answerIndex == null) continue;
        final double agreement = data.answerOptions[answerIndex].score;
        final double towardLeft = question.agreeIsLeft ? agreement : 1 - agreement;
        weighted += towardLeft * question.weight;
        totalWeight += question.weight;
      }
      final double leftPercent = totalWeight == 0 ? 50 : weighted / totalWeight * 100;
      scores.add(AxisScore(axis: axis, leftPercent: leftPercent));
    }
    return TwelveAxesResult(
      scores: scores,
      answeredCount: answeredCount,
      questionCount: questions.length,
    );
  }
}
