import 'dart:convert';

import '../../data/strict_json.dart';
import 'political_models.dart';

/// Limite tanto do token recebido quanto do JSON decodificado. O formato contém
/// respostas pessoais e só deve ser exportado após uma ação explícita.
const int studyResultLinkLimit = 100000;

const Set<String> _axisIds = <String>{
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
};

/// Serialização portátil, sem autenticação ou alegação de resultado verificado.
/// Lança [FormatException] para registros incompatíveis ou grandes demais.
String encodeStudyResult(EvaluationRecord record) {
  final Map<String, Object?> json = record.toJson();
  _validateRecord(json);
  final List<int> bytes = utf8.encode(
    jsonEncode(<String, Object?>{'v': 1, 'record': json}),
  );
  if (bytes.length > studyResultLinkLimit) {
    throw const FormatException('Resultado grande demais para um link.');
  }
  final String token = base64Url.encode(bytes).replaceAll('=', '');
  if (token.length > studyResultLinkLimit) {
    throw const FormatException('Resultado grande demais para um link.');
  }
  return token;
}

/// Decodifica somente o formato v1, com limites antes de alocar/interpretar JSON.
/// Dados recebidos são uma cópia informada por quem compartilhou o link: não
/// substituem o histórico local e não são assinados pelo Espectro.
EvaluationRecord? decodeStudyResult(String token) {
  if (token.isEmpty ||
      token.length > studyResultLinkLimit ||
      !RegExp(r'^[A-Za-z0-9_-]+={0,2}$').hasMatch(token)) {
    return null;
  }
  try {
    final List<int> bytes = base64Url.decode(base64Url.normalize(token));
    if (bytes.length > studyResultLinkLimit) return null;
    final Map<String, Object?> envelope = readObject(
      jsonDecode(utf8.decode(bytes)),
      'shared',
    );
    if (envelope['v'] != 1) return null;
    final Map<String, Object?> json = readObject(
      envelope['record'],
      'shared.record',
    );
    _validateRecord(json);
    return EvaluationRecord.fromJson(json, 'shared.record');
  } on Object {
    return null;
  }
}

void _invalid() =>
    throw const FormatException('Resultado compartilhado inválido.');

void _boundedNumber(Object? value, double min, double max) {
  if (value is! num || !value.isFinite || value < min || value > max) {
    _invalid();
  }
}

void _count(Object? value) {
  if (value is! int || value < 0 || value > 2000) _invalid();
}

void _counts(Map<String, Object?> json, String answered, String presented) {
  _count(json[answered]);
  _count(json[presented]);
  if ((json[answered] as int) > (json[presented] as int)) _invalid();
}

void _vector(Object? value, double min, double max) {
  final List<Object?> values = readArray(value, 'vector');
  if (values.length != 3) _invalid();
  for (final Object? item in values) {
    _boundedNumber(item, min, max);
  }
}

void _strings(Object? value, [int depth = 0]) {
  if (depth > 12) _invalid();
  // JSON has a byte limit already; this also bounds labels rendered by widgets.
  if (value is String && value.length > 512) _invalid();
  if (value is Map<String, Object?>) {
    for (final MapEntry<String, Object?> entry in value.entries) {
      if (entry.key.length > 160) _invalid();
      _strings(entry.value, depth + 1);
    }
  } else if (value is List<Object?>) {
    for (final Object? item in value) {
      _strings(item, depth + 1);
    }
  }
}

void _validateRecord(Map<String, Object?> json) {
  if (json['schemaVersion'] != EvaluationRecord.currentSchemaVersion) {
    _invalid();
  }
  _strings(json);
  final String id = readString(json['id'], 'record.id');
  if (!RegExp(r'^[a-zA-Z0-9_-]{1,160}$').hasMatch(id)) _invalid();
  final Object? title = json['title'];
  if (title != null && (title is! String || title.length > 256)) _invalid();
  final Map<String, Object?> answers = readObject(
    json['rawAnswers'],
    'record.rawAnswers',
  );
  if (answers.length > 2000) _invalid();
  for (final MapEntry<String, Object?> answer in answers.entries) {
    if (!RegExp(r'^(axis|tri):[a-zA-Z0-9_-]{1,100}$').hasMatch(answer.key)) {
      _invalid();
    }
    if (answer.value != null &&
        (answer.value is! int ||
            (answer.value as int) < -2 ||
            (answer.value as int) > 2)) {
      _invalid();
    }
  }
  final List<Object?> axes = readArray(json['axes'], 'record.axes');
  final List<Object?> triads = readArray(json['triads'], 'record.triads');
  if (axes.length > 12 || triads.length > 6) _invalid();
  final Set<String> seenAxes = <String>{};
  for (final Object? raw in axes) {
    final Map<String, Object?> axis = readObject(raw, 'record.axis');
    final String id = readString(axis['axisId'], 'record.axis.axisId');
    if (!_axisIds.contains(id) || !seenAxes.add(id)) _invalid();
    _boundedNumber(axis['score'], -1, 1);
    _boundedNumber(axis['standardError'], 0, 2);
    _boundedNumber(axis['coverage'], 0, 1);
    _boundedNumber(axis['tensionScore'], 0, 2);
    _counts(axis, 'answeredCount', 'presentedCount');
    if (axis['poleBreakdownAvailable'] == true) {
      _counts(axis, 'answeredLeftCount', 'presentedLeftCount');
      _counts(axis, 'answeredRightCount', 'presentedRightCount');
      _boundedNumber(axis['leftPoleMean'], -1, 1);
      _boundedNumber(axis['rightPoleMean'], -1, 1);
    }
  }
  final Set<int> seenTriads = <int>{};
  for (final Object? raw in triads) {
    final Map<String, Object?> triad = readObject(raw, 'record.triad');
    final int id = readInt(triad['categoryId'], 'record.triad.categoryId');
    if (id < 0 || id > 5 || !seenTriads.add(id)) _invalid();
    _vector(triad['vertexScores'], -1, 1);
    _vector(triad['vertexSupport'], 0, 1);
    _vector(triad['composition'], 0, 1);
    final List<Object?> composition = readArray(
      triad['composition'],
      'composition',
    );
    final double sum = composition.fold<double>(
      0,
      (sum, item) => sum + (item as num).toDouble(),
    );
    if ((sum - 1).abs() > 0.000001) _invalid();
    for (final String field in <String>[
      'engagement',
      'standardError',
      'coverage',
    ]) {
      _boundedNumber(triad[field], 0, 1);
    }
    _counts(triad, 'answeredCount', 'presentedCount');
    if (triad['vertexBreakdownAvailable'] == true) {
      _vector(triad['vertexCoverage'], 0, 1);
      final List<Object?> answered = readArray(
        triad['vertexAnsweredCount'],
        'answered',
      );
      final List<Object?> presented = readArray(
        triad['vertexPresentedCount'],
        'presented',
      );
      if (answered.length != 3 || presented.length != 3) _invalid();
      for (var i = 0; i < 3; i++) {
        _count(answered[i]);
        _count(presented[i]);
        if ((answered[i] as int) > (presented[i] as int)) _invalid();
      }
    }
  }
  final Map<String, Object?> quality = readObject(json['quality'], 'quality');
  _counts(quality, 'totalAnswered', 'totalPresented');
  _count(quality['totalSkipped']);
  final int answered = answers.values.where((value) => value != null).length;
  if (quality['totalPresented'] != answers.length ||
      quality['totalAnswered'] != answered ||
      quality['totalSkipped'] != answers.length - answered) {
    _invalid();
  }
  _boundedNumber(quality['acquiescenceIndex'], -1, 1);
  _boundedNumber(quality['extremeResponseRate'], 0, 1);
  _boundedNumber(quality['neutralResponseRate'], 0, 1);
  final List<Object?> tensions = readArray(
    quality['axesInTension'],
    'axesInTension',
  );
  if (tensions.length > 12) _invalid();
  final Object? axisCount = quality['answeredAxisCount'];
  if (axisCount != null) _boundedNumber(axisCount, 0, 12);
  // Validate all required fields/enums/ISO dates and vector dimensions, too.
  EvaluationRecord.fromJson(json);
}
