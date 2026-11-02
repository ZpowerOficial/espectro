import 'dart:ui';

import 'strict_json.dart';

/// Um dos 12 eixos do teste 12 Axes. O percentual esquerdo é sempre o polo
/// [leftPole]; o direito é [rightPole].
class Axis {
  const Axis({
    required this.id,
    required this.label,
    required this.leftPole,
    required this.rightPole,
    required this.leftColor,
    required this.rightColor,
  });

  final String id;
  final String label;
  final String leftPole;
  final String rightPole;
  final Color leftColor;
  final Color rightColor;

  factory Axis.fromJson(Map<String, Object?> json, String path) {
    return Axis(
      id: readString(json['id'], '$path.id'),
      label: readString(json['label'], '$path.label'),
      leftPole: readString(json['leftPole'], '$path.leftPole'),
      rightPole: readString(json['rightPole'], '$path.rightPole'),
      leftColor: readColor(json['leftColor'], '$path.leftColor'),
      rightColor: readColor(json['rightColor'], '$path.rightColor'),
    );
  }
}

/// Opção de resposta do 12 Axes. [score] vai de 0 (discordo totalmente) a 1
/// (concordo totalmente); 0,5 é neutro.
class AnswerOption {
  const AnswerOption({
    required this.id,
    required this.label,
    required this.score,
  });

  final String id;
  final String label;
  final double score;

  factory AnswerOption.fromJson(Map<String, Object?> json, String path) {
    final score = readDouble(json['scoreTowardAgreement'], '$path.scoreTowardAgreement');
    if (score < 0 || score > 1) {
      throw FormatException('$path.scoreTowardAgreement: esperado 0..1, recebido $score');
    }
    return AnswerOption(
      id: readString(json['id'], '$path.id'),
      label: readString(json['label'], '$path.label'),
      score: score,
    );
  }
}

/// Trecho do enunciado com definição consultável.
class QuestionTerm {
  const QuestionTerm({
    required this.start,
    required this.end,
    required this.term,
    required this.definition,
  });

  final int start;
  final int end;
  final String term;
  final String definition;

  factory QuestionTerm.fromJson(Map<String, Object?> json, String path) {
    final start = readInt(json['start'], '$path.start');
    final end = readInt(json['end'], '$path.end');
    if (start < 0 || end < start) {
      throw FormatException('$path: intervalo inválido [$start, $end]');
    }
    return QuestionTerm(
      start: start,
      end: end,
      term: readString(json['term'], '$path.term'),
      definition: readString(json['definition'], '$path.definition'),
    );
  }
}

/// Explicação do que cada resposta significa na prática para a pergunta.
class QuestionHelp {
  const QuestionHelp({
    required this.agree,
    required this.disagree,
    this.note,
    required this.agreeExample,
    required this.disagreeExample,
  });

  final String agree;
  final String disagree;
  final String? note;
  final String agreeExample;
  final String disagreeExample;

  factory QuestionHelp.fromJson(Map<String, Object?> json, String path) {
    return QuestionHelp(
      agree: readString(json['agree'], '$path.agree'),
      disagree: readString(json['disagree'], '$path.disagree'),
      note: readStringOrNull(json['note'], '$path.note'),
      agreeExample: readString(json['agreeExample'], '$path.agreeExample'),
      disagreeExample: readString(json['disagreeExample'], '$path.disagreeExample'),
    );
  }
}

class AxisQuestion {
  const AxisQuestion({
    required this.id,
    required this.axisId,
    required this.text,
    required this.agreeIsLeft,
    required this.weight,
    required this.terms,
    required this.help,
  });

  final String id;
  final String axisId;
  final String text;

  /// Quando `true`, concordar empurra o resultado para [Axis.leftPole].
  final bool agreeIsLeft;
  final double weight;
  final List<QuestionTerm> terms;
  final QuestionHelp help;

  factory AxisQuestion.fromJson(Map<String, Object?> json, String path) {
    final rawTerms = readArray(json['terms'], '$path.terms');
    final agreePole = readString(json['agreePole'], '$path.agreePole');
    if (agreePole != 'LEFT' && agreePole != 'RIGHT') {
      throw FormatException('$path.agreePole: valor inesperado "$agreePole"');
    }
    final weight = readDouble(json['weight'], '$path.weight');
    if (weight <= 0) {
      throw FormatException('$path.weight: peso deve ser positivo, recebido $weight');
    }
    return AxisQuestion(
      id: readString(json['id'], '$path.id'),
      axisId: readString(json['axisId'], '$path.axisId'),
      text: readString(json['text'], '$path.text'),
      agreeIsLeft: agreePole == 'LEFT',
      weight: weight,
      terms: <QuestionTerm>[
        for (var i = 0; i < rawTerms.length; i++)
          QuestionTerm.fromJson(readObject(rawTerms[i], '$path.terms[$i]'), '$path.terms[$i]'),
      ],
      help: QuestionHelp.fromJson(readObject(json['help'], '$path.help'), '$path.help'),
    );
  }
}

class ArchetypeOption {
  const ArchetypeOption({required this.id, required this.text});

  final String id;
  final String text;

  factory ArchetypeOption.fromJson(Map<String, Object?> json, String path) {
    return ArchetypeOption(
      id: readString(json['id'], '$path.id'),
      text: readString(json['text'], '$path.text'),
    );
  }
}

class ArchetypeQuestion {
  const ArchetypeQuestion({
    required this.id,
    required this.label,
    required this.text,
    required this.options,
  });

  final String id;
  final String label;
  final String text;
  final List<ArchetypeOption> options;

  factory ArchetypeQuestion.fromJson(Map<String, Object?> json, String path) {
    final rawOptions = readArray(json['options'], '$path.options');
    if (rawOptions.isEmpty) {
      throw FormatException('$path.options: esperado ao menos uma opção');
    }
    return ArchetypeQuestion(
      id: readString(json['id'], '$path.id'),
      label: readString(json['label'], '$path.label'),
      text: readString(json['text'], '$path.text'),
      options: <ArchetypeOption>[
        for (var i = 0; i < rawOptions.length; i++)
          ArchetypeOption.fromJson(readObject(rawOptions[i], '$path.options[$i]'), '$path.options[$i]'),
      ],
    );
  }
}

class TwelveAxesData {
  TwelveAxesData({
    required this.axes,
    required this.answerOptions,
    required this.questions,
    required this.archetypeQuestions,
  }) : axisById = <String, Axis>{for (final axis in axes) axis.id: axis};

  final List<Axis> axes;
  final List<AnswerOption> answerOptions;
  final List<AxisQuestion> questions;
  final List<ArchetypeQuestion> archetypeQuestions;
  final Map<String, Axis> axisById;

  List<AxisQuestion> questionsFor(String axisId) => <AxisQuestion>[
        for (final question in questions)
          if (question.axisId == axisId) question,
      ];

  factory TwelveAxesData.fromJson(Map<String, Object?> json) {
    final rawAxes = readArray(json['axes'], 'axes');
    final rawOptions = readArray(json['answerOptions'], 'answerOptions');
    final rawQuestions = readArray(json['questions'], 'questions');
    final rawArchetypes = readArray(json['archetypeQuestions'], 'archetypeQuestions');
    final axes = <Axis>[
      for (var i = 0; i < rawAxes.length; i++)
        Axis.fromJson(readObject(rawAxes[i], 'axes[$i]'), 'axes[$i]'),
    ];
    final axisIds = axes.map((a) => a.id).toSet();
    final questions = <AxisQuestion>[
      for (var i = 0; i < rawQuestions.length; i++)
        AxisQuestion.fromJson(readObject(rawQuestions[i], 'questions[$i]'), 'questions[$i]'),
    ];
    for (var i = 0; i < questions.length; i++) {
      if (!axisIds.contains(questions[i].axisId)) {
        throw FormatException('questions[$i].axisId "${questions[i].axisId}" não existe nos eixos');
      }
    }
    return TwelveAxesData(
      axes: axes,
      answerOptions: <AnswerOption>[
        for (var i = 0; i < rawOptions.length; i++)
          AnswerOption.fromJson(readObject(rawOptions[i], 'answerOptions[$i]'), 'answerOptions[$i]'),
      ],
      questions: questions,
      archetypeQuestions: <ArchetypeQuestion>[
        for (var i = 0; i < rawArchetypes.length; i++)
          ArchetypeQuestion.fromJson(
            readObject(rawArchetypes[i], 'archetypeQuestions[$i]'),
            'archetypeQuestions[$i]',
          ),
      ],
    );
  }
}

/// Uma categoria do Six Triangles com suas três subcategorias (os vértices).
class SixCategory {
  const SixCategory({
    required this.id,
    required this.label,
    required this.color,
    required this.subcategories,
  });

  final int id;
  final String label;
  final Color color;
  final List<String> subcategories;

  factory SixCategory.fromJson(Map<String, Object?> json, String path) {
    final rawSubs = readArray(json['subcategories'], '$path.subcategories');
    if (rawSubs.length != 3) {
      throw FormatException('$path.subcategories: esperados 3 vértices');
    }
    final id = readInt(json['id'], '$path.id');
    if (id < 0 || id > 5) {
      throw FormatException('$path.id: esperado 0..5, recebido $id');
    }
    return SixCategory(
      id: id,
      label: readString(json['label'], '$path.label'),
      color: readColor(json['color'], '$path.color'),
      subcategories: <String>[
        for (var i = 0; i < rawSubs.length; i++) readString(rawSubs[i], '$path.subcategories[$i]'),
      ],
    );
  }
}

class SixQuestion {
  const SixQuestion({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.strength,
    required this.multiplier,
    required this.text,
  });

  final int id;
  final int category;
  final int subcategory;
  final int strength;

  /// `1` quando concordar aumenta o vértice; `-1` quando concordar o reduz.
  final int multiplier;
  final String text;

  bool get agreeRaisesWeight => multiplier == 1;

  factory SixQuestion.fromJson(Map<String, Object?> json, String path) {
    final multiplier = readInt(json['multiplier'], '$path.multiplier');
    if (multiplier != 1 && multiplier != -1) {
      throw FormatException('$path.multiplier: esperado 1 ou -1');
    }
    final strength = readInt(json['strength'], '$path.strength');
    if (strength < 1 || strength > 4) {
      throw FormatException('$path.strength: esperado 1..4');
    }
    final category = readInt(json['category'], '$path.category');
    if (category < 0 || category > 5) {
      throw FormatException('$path.category: esperado 0..5, recebido $category');
    }
    final subcategory = readInt(json['subcategory'], '$path.subcategory');
    if (subcategory < 0 || subcategory > 2) {
      throw FormatException('$path.subcategory: esperado 0..2, recebido $subcategory');
    }
    return SixQuestion(
      id: readInt(json['id'], '$path.id'),
      category: category,
      subcategory: subcategory,
      strength: strength,
      multiplier: multiplier,
      text: readString(json['text'], '$path.text'),
    );
  }
}

class SixTrianglesData {
  SixTrianglesData({required this.categories, required this.questions})
      : categoryById = <int, SixCategory>{for (final category in categories) category.id: category};

  final List<SixCategory> categories;
  final List<SixQuestion> questions;
  final Map<int, SixCategory> categoryById;

  factory SixTrianglesData.fromJson(Map<String, Object?> json) {
    final rawCategories = readArray(json['categories'], 'categories');
    final rawQuestions = readArray(json['questions'], 'questions');
    final categories = <SixCategory>[
      for (var i = 0; i < rawCategories.length; i++)
        SixCategory.fromJson(readObject(rawCategories[i], 'categories[$i]'), 'categories[$i]'),
    ];
    final categoryIds = categories.map((c) => c.id).toSet();
    final questions = <SixQuestion>[
      for (var i = 0; i < rawQuestions.length; i++)
        SixQuestion.fromJson(readObject(rawQuestions[i], 'questions[$i]'), 'questions[$i]'),
    ];
    for (var i = 0; i < questions.length; i++) {
      if (!categoryIds.contains(questions[i].category)) {
        throw FormatException('questions[$i].category ${questions[i].category} não existe nas categorias');
      }
    }
    return SixTrianglesData(
      categories: categories,
      questions: questions,
    );
  }
}
