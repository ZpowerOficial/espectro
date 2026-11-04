import 'dart:math' as math;

import '../../data/app_data.dart';
import 'atlas_models.dart';
import 'political_models.dart';

/// One inspectable subject in the study catalog. The maps contain only supplied
/// catalog positions or determined evaluation dimensions, never neutral fill.
class StudySubject {
  const StudySubject({
    required this.key,
    required this.name,
    required this.kind,
    required this.kindLabel,
    this.subtitle = '',
    this.summary = '',
    this.family = '',
    this.spectrumId,
    this.axes = const <String, double>{},
    this.triangles = const <int, List<double>>{},
    this.ideas = const <String>[],
    this.current,
    this.entry,
    this.record,
  });

  final String key;
  final String name;

  /// Stable machine kind: current, personality, party, history, book, country,
  /// or evaluation. [kindLabel] is the human readable label.
  final String kind;
  final String kindLabel;
  final String subtitle;
  final String summary;
  final String family;
  final String? spectrumId;
  final Map<String, double> axes;
  final Map<int, List<double>> triangles;
  final List<String> ideas;
  final IdeologicalCurrent? current;
  final AtlasEntry? entry;
  final EvaluationRecord? record;

  factory StudySubject.fromCurrent(IdeologicalCurrent value) => StudySubject(
    key: 'current:${value.id}',
    spectrumId: value.spectrumId,
    name: value.name,
    kind: 'current',
    kindLabel: 'Corrente',
    subtitle: value.family,
    summary: value.summary,
    family: value.family,
    axes: Map.unmodifiable({
      for (final e in value.axes.entries)
        if (e.value.relevance > 0) e.key: e.value.mu,
    }),
    triangles: Map.unmodifiable({
      for (final e in value.triangles.entries)
        if (e.value.relevance > 0) e.key: List<double>.unmodifiable(e.value.mu),
    }),
    ideas: List.unmodifiable(value.keyIdeas),
    current: value,
  );

  factory StudySubject.fromEntry(AtlasEntry value) => StudySubject(
    key: '${value.kind.name}:${value.id}',
    spectrumId: value.spectrumId,
    name: value.name,
    kind: value.kind.name,
    kindLabel: value.kind.singularLabel,
    subtitle: value.subtitle,
    summary: value.summary,
    family: value.category,
    axes: Map.unmodifiable(value.axes),
    triangles: Map.unmodifiable({
      for (final e in value.triangles.entries)
        e.key: List<double>.unmodifiable(e.value),
    }),
    ideas: List.unmodifiable(value.highlights),
    entry: value,
  );

  factory StudySubject.fromEvaluation(EvaluationRecord value) => StudySubject(
    key: 'evaluation:${value.id}',
    name: value.displayTitle,
    kind: 'evaluation',
    kindLabel: 'Minha avaliação',
    subtitle: '${value.suite.title} • ${value.depth.label}',
    summary:
        'Avaliação pessoal de ${value.createdAt.toLocal().toIso8601String().split('T').first}. '
        'Só dimensões com evidência suficiente entram na comparação.',
    family: 'Minhas avaliações',
    axes: Map.unmodifiable({
      for (final axis in value.axes)
        if (!axis.isIndeterminate) axis.axisId: axis.score,
    }),
    triangles: Map.unmodifiable({
      for (final triad in value.triads)
        if (!triad.isIndeterminate)
          triad.categoryId: List<double>.unmodifiable(triad.composition),
    }),
    record: value,
  );
}

/// Similarity is exploratory geometric proximity, not historical influence,
/// proof of agreement, or a psychometrically calibrated probability.
class StudyMatch {
  const StudyMatch({
    required this.subject,
    required this.similarity,
    required this.sharedAxes,
    required this.sharedTriads,
    required this.coverage,
    required this.similarities,
    required this.differences,
  });
  final StudySubject subject;
  final double similarity;
  final int sharedAxes;
  final int sharedTriads;

  /// Fraction of the union of supplied dimensions shared by both profiles.
  /// This is overlap, not confidence or response coverage.
  final double coverage;
  final List<String> similarities;
  final List<String> differences;
}

/// Search and comparison over the existing offline catalog, without changing
/// the scoring/compatibility engines used by personal evaluation reports.
class StudyCatalog {
  StudyCatalog(this.data, {List<EvaluationRecord> records = const []}) {
    subjects = List.unmodifiable([
      for (final current in data.catalog.currents)
        StudySubject.fromCurrent(current),
      for (final kind in AtlasKind.values)
        for (final entry in data.atlas.entriesFor(kind))
          StudySubject.fromEntry(entry),
      for (final record in records) StudySubject.fromEvaluation(record),
    ]);
    _byKey = {for (final subject in subjects) subject.key: subject};
    _searchText = {
      for (final subject in subjects)
        subject.key: normalize(
          [
            subject.key,
            subject.name,
            subject.subtitle,
            subject.summary,
            subject.kindLabel,
            subject.family,
            ...subject.ideas,
            if (subject.entry case final entry?) ...[
              entry.era,
              entry.origin,
              entry.quote ?? '',
            ],
            ...searchAliases[subject.key] ?? const <String>[],
          ].join(' '),
        ),
    };
  }

  final AppData data;
  late final List<StudySubject> subjects;
  late final Map<String, StudySubject> _byKey;
  late final Map<String, String> _searchText;

  static const methodDescription =
      'Proximidade exploratória: cada eixo compartilhado usa a diferença entre '
      'posições dividida por 2; cada tríade usa a distância euclidiana entre '
      'composições dividida por √2. A similaridade é 100 × (1 − raiz da média '
      'dos quadrados dessas distâncias), com peso igual por dimensão. '
      'Dimensões ausentes ou indeterminadas são excluídas. A sobreposição indica '
      'quantas dimensões são comuns, não a confiança do resultado. Nas tríades, '
      'composição não mede apoio absoluto; a intensidade e a incerteza da '
      'avaliação continuam disponíveis no relatório pessoal. O índice não '
      'estabelece influência histórica, identidade política nem probabilidade.';

  StudySubject? find(String key) => _byKey[key];

  List<String> get families =>
      (subjects.map((s) => s.family).where((f) => f.isNotEmpty).toSet().toList()
        ..sort());

  List<StudySubject> search(String query, {String? family, String? kind}) {
    final terms = normalize(query)
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();
    return subjects
        .where(
          (subject) =>
              (family == null || subject.family == family) &&
              (kind == null ||
                  subject.kind == kind ||
                  subject.kindLabel == kind) &&
              terms.every((term) => _searchText[subject.key]!.contains(term)),
        )
        .toList(growable: false);
  }

  /// Symmetric, bounded metric over the intersection of supplied dimensions.
  /// Returns null when there is no common dimension, rather than 50%.
  StudyMatch? compare(StudySubject a, StudySubject b) {
    final distances = <(String, double)>[];
    var sharedAxes = 0;
    var sharedTriads = 0;
    var unionAxes = 0;
    var unionTriads = 0;
    for (final axis in data.twelveAxes.axes) {
      final av = a.axes[axis.id];
      final bv = b.axes[axis.id];
      final validA = _validAxis(av);
      final validB = _validAxis(bv);
      if (validA || validB) unionAxes++;
      if (!validA || !validB) continue;
      sharedAxes++;
      distances.add((axis.label, ((av! - bv!).abs() / 2).clamp(0, 1)));
    }
    for (final triad in data.sixTriangles.categories) {
      final av = a.triangles[triad.id];
      final bv = b.triangles[triad.id];
      final validA = _validComposition(av);
      final validB = _validComposition(bv);
      if (validA || validB) unionTriads++;
      if (!validA || !validB) continue;
      sharedTriads++;
      final squared = List.generate(
        3,
        (i) => math.pow(av![i] - bv![i], 2),
      ).fold<double>(0, (sum, value) => sum + value);
      distances.add((triad.label, math.sqrt(squared / 2).clamp(0, 1)));
    }
    if (distances.isEmpty) return null;
    final meanSquared =
        distances.fold<double>(0, (sum, e) => sum + e.$2 * e.$2) /
        distances.length;
    distances.sort((a, b) {
      final byDistance = a.$2.compareTo(b.$2);
      return byDistance == 0 ? a.$1.compareTo(b.$1) : byDistance;
    });
    return StudyMatch(
      subject: b,
      similarity: ((1 - math.sqrt(meanSquared)) * 100).clamp(0, 100),
      sharedAxes: sharedAxes,
      sharedTriads: sharedTriads,
      coverage: distances.length / (unionAxes + unionTriads),
      similarities: List.unmodifiable(
        distances
            .where((e) => e.$2 <= 0.25)
            .take(3)
            .map(
              (e) =>
                  '${e.$1}: posições próximas (${(e.$2 * 100).round()}% da distância máxima).',
            ),
      ),
      differences: List.unmodifiable(
        distances.reversed
            .where((e) => e.$2 > 0.25)
            .take(3)
            .map(
              (e) =>
                  '${e.$1}: posições distintas (${(e.$2 * 100).round()}% da distância máxima).',
            ),
      ),
    );
  }

  List<StudyMatch> related(StudySubject subject, {int limit = 6}) {
    if (limit <= 0) return const [];
    final matches = <StudyMatch>[
      for (final candidate in subjects)
        if (candidate.key != subject.key) ?compare(subject, candidate),
    ];
    matches.sort((a, b) {
      final byScore = b.similarity.compareTo(a.similarity);
      return byScore == 0 ? a.subject.key.compareTo(b.subject.key) : byScore;
    });
    return matches.take(limit).toList(growable: false);
  }

  /// Links carry catalog keys only. Personal data are never serialized here;
  /// an evaluation key can reopen only where that local record exists.
  Uri uriFor(StudySubject subject) =>
      Uri(path: '/atlas', queryParameters: {'v': '1', 'subject': subject.key});

  StudySubject? subjectFromUri(Uri uri) {
    if (uri.toString().length > 4096 || uri.path != '/atlas') return null;
    try {
      // Uri.tryParse accepts percent-encoded bytes that are invalid UTF-8;
      // decoding queryParameters can still throw on an otherwise valid URI.
      final query = uri.queryParameters;
      if (query['v'] != '1') return null;
      return find(query['subject'] ?? '');
    } on FormatException {
      return null;
    }
  }

  static bool _validAxis(double? value) =>
      value != null && value.isFinite && value >= -1 && value <= 1;

  static bool _validComposition(List<double>? values) =>
      values != null &&
      values.length == 3 &&
      values.every((v) => v.isFinite && v >= 0 && v <= 1) &&
      (values.fold<double>(0, (s, v) => s + v) - 1).abs() < 1e-6;

  /// A compact offline fold; identifiers, punctuation and whitespace all use
  /// the same representation as visible text, so accents never block discovery.
  static String normalize(String text) {
    const accented = 'àáâãäåèéêëìíîïòóôõöùúûüçñýÿ';
    const folded = 'aaaaaaeeeeiiiiooooouuuucnyy';
    var result = text.toLowerCase();
    for (var i = 0; i < accented.length; i++) {
      result = result.replaceAll(accented[i], folded[i]);
    }
    return result
        .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  /// Search aliases point exclusively to existing catalog IDs. They are names,
  /// abbreviations and spelling variants, not historical influence claims.
  static const searchAliases = <String, List<String>>{
    'current:anarcocapitalismo': ['ancap', 'anarquismo de mercado'],
    'current:libertarianismo_minarquista': ['libertarismo', 'minarquismo'],
    'current:social_democracia': ['socialdemocracia'],
    'current:escola_austriaca': ['escola austríaca de economia'],
    'country:eua_founding': ['EUA', 'USA', 'United States'],
    'country:eua_new_deal': ['EUA', 'USA', 'United States'],
    'country:eua_reagan': ['EUA', 'USA', 'United States'],
    'country:reino_unido_attlee': ['UK', 'United Kingdom', 'Grã-Bretanha'],
    'country:reino_unido_thatcher': ['UK', 'United Kingdom', 'Grã-Bretanha'],
    'country:urss_nep': ['URSS', 'USSR', 'Soviet Union'],
    'country:urss_khrushchev': ['URSS', 'USSR', 'Soviet Union'],
    'personality:franklin_d_roosevelt': ['FDR'],
    'personality:juscelino_kubitschek': ['JK'],
    'personality:friedrich_hayek': ['Friedrich August von Hayek'],
    'personality:gk_chesterton': ['Gilbert Keith Chesterton'],
    'personality:vladimir_lenin': ['Vladimir Ilyich Ulyanov', 'Lenine'],
  };
}
