import 'dart:convert';
import 'dart:typed_data';

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

class _CompactAxisMeta {
  const _CompactAxisMeta(this.id, this.label, this.leftPole, this.rightPole);
  final String id, label, leftPole, rightPole;
}

const List<_CompactAxisMeta> _canonicalAxes = <_CompactAxisMeta>[
  _CompactAxisMeta('estrutura', 'Estrutura', 'Federal', 'Unitário'),
  _CompactAxisMeta('representacao', 'Representação', 'Democracia', 'Autocracia'),
  _CompactAxisMeta('poder', 'Poder', 'Segurança', 'Liberdade'),
  _CompactAxisMeta('imigracao', 'Imigração', 'Assimilação', 'Multicultura'),
  _CompactAxisMeta('diplomacia', 'Diplomacia', 'Militarista', 'Pacifista'),
  _CompactAxisMeta('intervencao', 'Intervenção', 'Não intervencionista', 'Nacionalista'),
  _CompactAxisMeta('economia', 'Economia', 'Público', 'Privado'),
  _CompactAxisMeta('controle', 'Controle', 'Planejamento', 'Livre mercado'),
  _CompactAxisMeta('comercio', 'Comércio', 'Protecionismo', 'Globalismo'),
  _CompactAxisMeta('religiao', 'Religião', 'Irreligioso', 'Religioso'),
  _CompactAxisMeta('moral', 'Moral', 'Progressista', 'Tradicionalista'),
  _CompactAxisMeta('tecnologia', 'Tecnologia', 'Tecnologia', 'Biologia'),
];

class _CompactTriadMeta {
  const _CompactTriadMeta(this.id, this.label, this.vertices);
  final int id;
  final String label;
  final List<String> vertices;
}

const List<_CompactTriadMeta> _canonicalTriads = <_CompactTriadMeta>[
  _CompactTriadMeta(0, 'Economia', <String>['Controle', 'Regulação', 'Mercados']),
  _CompactTriadMeta(1, 'Liberdade Individual', <String>['Liberdade', 'Segurança', 'Verdade']),
  _CompactTriadMeta(2, 'Cultura', <String>['Tradição', 'Progresso', 'Liberdade']),
  _CompactTriadMeta(3, 'Política Externa', <String>['Imperialismo', 'Isolacionismo', 'Globalismo']),
  _CompactTriadMeta(4, 'Governo', <String>['Democracia', 'Autoridade', 'Anarquismo']),
  _CompactTriadMeta(5, 'Igualdade', <String>['Oportunidade', 'Resultado', 'Responsabilidade Individual']),
];

/// Codifica o perfil resumido (12 eixos + 6 tríades) em 25 bytes (~34 chars Base64URL),
/// sem incluir respostas individuais, timestamps ou dados pessoais.
/// Eixos ausentes/indeterminados usam sentinela `127`; tríades usam `255`.
String encodeCompactProfile(EvaluationRecord record) {
  final Uint8List bytes = Uint8List(25);
  final ByteData data = ByteData.sublistView(bytes);
  bytes[0] = 2; // Protocolo v2 compacto

  for (var i = 0; i < _canonicalAxes.length; i++) {
    final axis = record.axisById(_canonicalAxes[i].id);
    if (axis == null || axis.isIndeterminate) {
      data.setInt8(1 + i, 127);
    } else {
      data.setInt8(1 + i, (axis.score * 100).round().clamp(-100, 100));
    }
  }

  for (var i = 0; i < _canonicalTriads.length; i++) {
    final triad = record.triadByCategoryId(_canonicalTriads[i].id);
    if (triad == null || triad.isIndeterminate) {
      bytes[13 + i * 2] = 255;
      bytes[14 + i * 2] = 255;
    } else {
      final b0 = (triad.composition[0] * 100).round().clamp(0, 100);
      final b1 = (triad.composition[1] * 100).round().clamp(0, 100 - b0);
      bytes[13 + i * 2] = b0;
      bytes[14 + i * 2] = b1;
    }
  }

  return base64Url.encode(bytes).replaceAll('=', '');
}

/// Decodifica um token compacto v2 (~34 chars) em um [EvaluationRecord] somente leitura.
EvaluationRecord? decodeCompactProfile(String token) {
  if (token.isEmpty ||
      token.length > 64 ||
      !RegExp(r'^[A-Za-z0-9_-]+={0,2}$').hasMatch(token)) {
    return null;
  }
  try {
    final Uint8List bytes = base64Url.decode(base64Url.normalize(token));
    if (bytes.length != 25 || bytes[0] != 2) return null;
    final ByteData data = ByteData.sublistView(bytes);

    final List<BipolarDimensionScore> axes = <BipolarDimensionScore>[];
    var observedAxes = 0;
    for (var i = 0; i < _canonicalAxes.length; i++) {
      final meta = _canonicalAxes[i];
      final raw = data.getInt8(1 + i);
      if (raw == 127) {
        axes.add(
          BipolarDimensionScore(
            axisId: meta.id,
            label: meta.label,
            leftPole: meta.leftPole,
            rightPole: meta.rightPole,
            score: 0.0,
            standardError: 1.0,
            coverage: 0.0,
            answeredCount: 0,
            presentedCount: 4,
            tensionScore: 0.0,
          ),
        );
        continue;
      }
      if (raw < -100 || raw > 100) return null;
      observedAxes++;
      axes.add(
        BipolarDimensionScore(
          axisId: meta.id,
          label: meta.label,
          leftPole: meta.leftPole,
          rightPole: meta.rightPole,
          score: (raw / 100.0).clamp(-1.0, 1.0),
          standardError: 0.12,
          coverage: 1.0,
          answeredCount: 4,
          presentedCount: 4,
          tensionScore: 0.0,
        ),
      );
    }

    final List<TriadDimensionScore> triads = <TriadDimensionScore>[];
    var observedTriads = 0;
    for (var i = 0; i < _canonicalTriads.length; i++) {
      final meta = _canonicalTriads[i];
      final b0 = bytes[13 + i * 2];
      final b1 = bytes[14 + i * 2];
      if (b0 == 255 || b1 == 255) {
        triads.add(
          TriadDimensionScore(
            categoryId: meta.id,
            label: meta.label,
            vertices: meta.vertices,
            vertexScores: const <double>[0.0, 0.0, 0.0],
            vertexSupport: const <double>[0.0, 0.0, 0.0],
            composition: const <double>[1 / 3, 1 / 3, 1 / 3],
            engagement: 0.0,
            standardError: 1.0,
            coverage: 0.0,
            answeredCount: 0,
            presentedCount: 6,
            classification: 'Indeterminado',
          ),
        );
        continue;
      }
      if (b0 > 100 || b1 > 100 || b0 + b1 > 100) return null;
      observedTriads++;
      final b2 = 100 - b0 - b1;
      final comp = <double>[b0 / 100.0, b1 / 100.0, b2 / 100.0];
      triads.add(
        TriadDimensionScore(
          categoryId: meta.id,
          label: meta.label,
          vertices: meta.vertices,
          vertexScores: const <double>[0.0, 0.0, 0.0],
          vertexSupport: comp,
          composition: comp,
          engagement: 1.0,
          standardError: 0.12,
          coverage: 1.0,
          answeredCount: 6,
          presentedCount: 6,
          classification: 'Perfil Compartilhado',
        ),
      );
    }

    final TestSuite suite = observedAxes > 0 && observedTriads > 0
        ? TestSuite.espectroIntegrated
        : (observedTriads > 0 ? TestSuite.triads : TestSuite.bipolarAxes);
    final int totalDims = observedAxes + observedTriads;

    return EvaluationRecord(
      id: 'shared_v2_$token',
      createdAt: DateTime.now(),
      suite: suite,
      depth: TestDepth.standard,
      seed: 0,
      engineVersion: '2.5.0',
      bankVersion: '1.2.0',
      title: 'Perfil Compartilhado',
      rawAnswers: const <String, int?>{},
      axes: axes,
      triads: triads,
      quality: ResponseQualityReport(
        totalPresented: 18,
        totalAnswered: totalDims,
        totalSkipped: 18 - totalDims,
        acquiescenceIndex: 0.0,
        extremeResponseRate: 0.2,
        neutralResponseRate: 0.1,
        axesInTension: const <String>[],
        answeredAxisCount: observedAxes,
      ),
    );
  } on Object {
    return null;
  }
}

/// Decodifica formato compacto v2 (~34 chars) ou formato completo v1 JSON.
/// Dados recebidos são uma cópia informada por quem compartilhou o link: não
/// substituem o histórico local e não são assinados pelo Espectro.
EvaluationRecord? decodeStudyResult(String token) {
  if (token.isEmpty ||
      token.length > studyResultLinkLimit ||
      !RegExp(r'^[A-Za-z0-9_-]+={0,2}$').hasMatch(token)) {
    return null;
  }
  if (token.length <= 64) {
    final compact = decodeCompactProfile(token);
    if (compact != null) return compact;
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
