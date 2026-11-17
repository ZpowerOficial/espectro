// Editorial answers share the scoring formula, never the status of observations.
import 'dart:convert';
import 'dart:io';

import 'package:politico/data/models.dart';
import 'package:politico/domain/engine/scoring_engine.dart';
import 'package:politico/domain/models/political_models.dart';

Map<String, Object?> read(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

void main(List<String> args) {
  if (args.length != 2) {
    throw ArgumentError(
      'Expected input and output paths; invoke through the Flutter generation test.',
    );
  }
  final axesJson = read('assets/data/twelve_axes.json');
  final triadsJson = read('assets/data/six_triangles.json');
  axesJson['questions'] = [
    ...axesJson['questions'] as List,
    ...read('assets/data/twelve_axes_extra.json')['questions'] as List,
  ];
  triadsJson['questions'] = [
    ...triadsJson['questions'] as List,
    ...read('assets/data/six_triangles_extra.json')['questions'] as List,
  ];
  final axes = TwelveAxesData.fromJson(axesJson);
  final triads = SixTrianglesData.fromJson(triadsJson);
  final bank = <String, UnifiedQuestion>{
    for (final q in axes.questions) 'axis:${q.id}': UnifiedQuestion.bipolar(q),
    for (final q in triads.questions) 'tri:${q.id}': UnifiedQuestion.triad(q),
  };
  final output = <String, Object?>{};
  final usedUids = <String>{};
  for (final raw in read(args[0])['profiles'] as List) {
    final profile = (raw as Map).cast<String, Object?>();
    final key = profile['key'] as String;
    if (output.containsKey(key)) {
      throw FormatException(
        'Repeated subject: $key; merge disjoint supplements before scoring',
      );
    }
    final dimensions = (profile['dimensions'] as Map).keys
        .cast<String>()
        .toSet();
    final partial = profile['mode'] == 'supplement';
    if (!partial && dimensions.length != 18) {
      throw const FormatException('Incomplete full reconstruction');
    }
    final questions = <UnifiedQuestion>[];
    final answers = <String, int?>{};
    for (final rawAnswer in profile['answers'] as List) {
      final answer = rawAnswer as Map;
      final uid = answer['questionUid'] as String;
      final q = bank[uid];
      if (q == null ||
          answers.containsKey(uid) ||
          q.text != answer['statement']) {
        throw FormatException('Unknown, repeated or changed anchor: $uid');
      }
      final dimension = q.axisQuestion != null
          ? 'axis:${q.axisQuestion!.axisId}'
          : 'triad:${q.sixQuestion!.category}';
      if (!dimensions.contains(dimension) || answer['dimension'] != dimension) {
        throw FormatException('Wrong dimension for $uid');
      }
      final value = answer['answer'];
      if (value is! int || value < -2 || value > 2) {
        throw FormatException('Invalid editorial answer: $uid');
      }
      questions.add(q);
      usedUids.add(uid);
      answers[uid] = value;
    }
    // A complete reconstruction requires both keyed poles, and every vertex.
    for (final axis in axes.axes) {
      if (partial && !dimensions.contains('axis:${axis.id}')) continue;
      final signs = questions
          .where((q) => q.axisQuestion?.axisId == axis.id)
          .map((q) => q.polaritySign)
          .toSet();
      if (!signs.containsAll([-1, 1])) {
        throw FormatException('Missing keyed pole: ${axis.id}');
      }
    }
    for (final category in triads.categories) {
      if (partial && !dimensions.contains('triad:${category.id}')) continue;
      for (var vertex = 0; vertex < 3; vertex++) {
        if (questions
                .where(
                  (q) =>
                      q.sixQuestion?.category == category.id &&
                      q.sixQuestion?.subcategory == vertex,
                )
                .length <
            2) {
          throw FormatException(
            'Missing vertex anchors: ${category.id}:$vertex',
          );
        }
      }
    }
    final result = EspectroScoringEngine.evaluate(
      axesData: axes,
      trianglesData: triads,
      suite: TestSuite.espectroIntegrated,
      questions: questions,
      rawAnswersByUid: answers,
    );
    output[key] = {
      'axes': {
        for (final a in result.axes)
          if (dimensions.contains('axis:${a.axisId}')) a.axisId: a.score,
      },
      'triangles': {
        for (final t in result.triads)
          if (dimensions.contains('triad:${t.categoryId}'))
            '${t.categoryId}': t.composition,
      },
      'triadVertexScores': {
        for (final t in result.triads)
          if (dimensions.contains('triad:${t.categoryId}'))
            '${t.categoryId}': t.vertexScores,
      },
      'triadEngagement': {
        for (final t in result.triads)
          if (dimensions.contains('triad:${t.categoryId}'))
            '${t.categoryId}': t.engagement,
      },
      // No session, respondent counts, standard errors, confidence or validity
      // claims are exported from an editorial simulation.
    };
  }
  output['_provenance'] = {
    'input': read(args[0]),
    'engineVersion': kEspectroEngineVersion,
    'bankVersion': kEspectroBankVersion,
    'anchors': {
      for (final uid in usedUids)
        uid: {
          'statement': bank[uid]!.text,
          'weight': bank[uid]!.weight,
          'polarity': bank[uid]!.polaritySign,
          'dimension': bank[uid]!.dimensionKey,
        },
    },
  };
  File(args[1]).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(output)}\n',
  );
}
