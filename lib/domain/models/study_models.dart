import 'dart:math' as math;

import '../../data/app_data.dart';
import '../engine/realism_calibration.dart';
import 'atlas_models.dart';
import 'political_models.dart';
import 'twelve_axes_affinity.dart';

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
    this.photoUrl,
    this.current,
    this.entry,
    this.record,
  });

  final String? photoUrl;
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

  static final Map<String, String> _normalizedNameCache = <String, String>{};
  static final Expando<Map<String, double>> _displayAxesCache =
      Expando<Map<String, double>>('displayAxes');
  static final Expando<Map<int, List<double>>> _displayTrianglesCache =
      Expando<Map<int, List<double>>>('displayTriangles');

  /// Nome normalizado pré-computado sob demanda para ordenação O(N log N) rápida.
  String get normalizedName =>
      _normalizedNameCache.putIfAbsent(name, () => StudyCatalog.normalize(name));

  /// Eixos calibrados para exibição realista (evitando teto artificial de 100% em correntes teóricas,
  /// enquanto perfis do Atlas e avaliações pessoais mantêm suas coordenadas autênticas).
  Map<String, double> get displayAxes {
    if (record != null || entry != null) return axes;
    var cached = _displayAxesCache[this];
    if (cached == null) {
      cached = RealismCalibration.calibrateAxesMap(
        axes,
        sigmas: current != null
            ? {for (final e in current!.axes.entries) e.key: e.value.sigma}
            : null,
      );
      _displayAxesCache[this] = cached;
    }
    return cached;
  }

  /// Tríades calibradas para exibição realista temperada.
  Map<int, List<double>> get displayTriangles {
    if (record != null || entry != null) return triangles;
    var cached = _displayTrianglesCache[this];
    if (cached == null) {
      cached = RealismCalibration.calibrateTrianglesMap(triangles);
      _displayTrianglesCache[this] = cached;
    }
    return cached;
  }

  /// Dimensões efetivamente fornecidas pelo verbete (0..18). Não é uma
  /// estimativa de qualidade: é a cobertura numérica disponível para leitura e
  /// comparação.
  int get coveredDimensions => axes.length + triangles.length;

  bool get isCompleteProfile => axes.length >= 12 && triangles.length >= 6;

  String get coverageLabel =>
      '$coveredDimensions/18 dimensões${isCompleteProfile ? ' completas' : ''}';

  /// Vocação da personalidade quando aplicável.
  PersonalityVocation? get vocation =>
      entry?.kind == AtlasKind.personality ? entry?.vocation : null;

  /// Verdadeiro para correntes, países, livros, eras, partidos e personalidades canônicas
  /// (Filósofos, Economistas, Cientistas Políticos/Sociólogos/Juristas e Estadistas).
  /// Exclui parlamentares de voto nominal avulso e comunicadores de bolha.
  bool get isCanonicalSubject =>
      entry == null ||
      entry!.kind != AtlasKind.personality ||
      entry!.isCanonicalPersonality;

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
        if (e.value.relevance > 0) e.key: e.value.mu,
    }),
    ideas: List.unmodifiable(value.keyIdeas),
    current: value,
  );

  factory StudySubject.fromEntry(AtlasEntry value, {String? photoOverride}) =>
      StudySubject(
        key: '${value.kind.name}:${value.id}',
        spectrumId: value.spectrumId,
        name: value.name,
        kind: value.kind.name,
        kindLabel: value.kind.singularLabel,
        subtitle: value.subtitle,
        summary: value.summary,
        family: value.category,
        axes: Map.unmodifiable(value.axes),
        triangles: Map.unmodifiable(value.triangles),
        ideas: List.unmodifiable(value.highlights),
        photoUrl: photoOverride ?? value.photoUrl,
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
  StudyMatch({
    required this.subject,
    required this.similarity,
    required this.sharedAxes,
    required this.sharedTriads,
    required this.coverage,
    required List<String> similarities,
    required List<String> differences,
    TwelveAxesAffinity? twelveAxesAffinity,
  })  : _eagerSimilarities = similarities,
        _eagerDifferences = differences,
        _eagerTwelveAxes = twelveAxesAffinity,
        _rawDistances = null,
        _sourceAxes = null;

  StudyMatch._lazy({
    required this.subject,
    required this.similarity,
    required this.sharedAxes,
    required this.sharedTriads,
    required this.coverage,
    required List<(String, double)> rawDistances,
    required Map<String, double> sourceAxes,
  })  : _rawDistances = List.unmodifiable(rawDistances),
        _sourceAxes = Map.unmodifiable(sourceAxes),
        _eagerSimilarities = null,
        _eagerDifferences = null,
        _eagerTwelveAxes = null;

  final StudySubject subject;
  final double similarity;
  final int sharedAxes;
  final int sharedTriads;

  final List<(String, double)>? _rawDistances;
  final Map<String, double>? _sourceAxes;
  final List<String>? _eagerSimilarities;
  final List<String>? _eagerDifferences;
  final TwelveAxesAffinity? _eagerTwelveAxes;

  late final List<(String, double)> _sortedDistances = () {
    final list = List<(String, double)>.of(_rawDistances ?? const []);
    list.sort((a, b) {
      final byDistance = a.$2.compareTo(b.$2);
      return byDistance == 0 ? a.$1.compareTo(b.$1) : byDistance;
    });
    return list;
  }();

  /// Leitura complementar restrita aos 12 eixos, com cobertura explícita.
  late final TwelveAxesAffinity? twelveAxesAffinity = _sourceAxes != null
      ? TwelveAxesAffinity.between(_sourceAxes, subject.axes)
      : _eagerTwelveAxes;

  /// Fraction of the union of supplied dimensions shared by both profiles.
  /// This is overlap, not confidence or response coverage.
  final double coverage;

  /// A high score on a few shared topics is not a broad-profile suggestion.
  bool get supportsRanking => sharedAxes + sharedTriads >= 8 && coverage >= .6;

  late final List<String> similarities = _eagerSimilarities ??
      List.unmodifiable(
        _sortedDistances
            .where((e) => e.$2 <= 0.25)
            .take(3)
            .map(
              (e) =>
                  '${e.$1}: posições próximas (${(e.$2 * 100).round()}% da distância máxima).',
            ),
      );

  late final List<String> differences = _eagerDifferences ??
      List.unmodifiable(
        _sortedDistances.reversed
            .where((e) => e.$2 > 0.25)
            .take(3)
            .map(
              (e) =>
                  '${e.$1}: posições distintas (${(e.$2 * 100).round()}% da distância máxima).',
            ),
      );
}

class _BaseStudyCatalogCache {
  _BaseStudyCatalogCache(AppData data) {
    baseSubjects = List.unmodifiable([
      for (final current in data.catalog.currents)
        StudySubject.fromCurrent(current),
      for (final kind in AtlasKind.values)
        for (final entry in data.atlas.entriesFor(kind))
          StudySubject.fromEntry(
            entry,
            photoOverride:
                data.portraits['${kind.name}:${entry.id}']?.assetPath,
          ),
    ]);
    byKey = {for (final subject in baseSubjects) subject.key: subject};
    byRawId = {
      for (final subject in baseSubjects) ...{
        if (subject.current != null) subject.current!.id: subject,
        if (subject.entry != null) subject.entry!.id: subject,
      },
    };
  }

  late final List<StudySubject> baseSubjects;
  late final Map<String, StudySubject> byKey;
  late final Map<String, StudySubject> byRawId;
  final Map<String, String> searchText = {};
  final Map<String, List<StudyMatch>> relatedAllCache = {};
}

/// Search and comparison over the existing offline catalog, without changing
/// the scoring/compatibility engines used by personal evaluation reports.
class StudyCatalog {
  StudyCatalog(this.data, {List<EvaluationRecord> records = const []}) {
    final cache = _cacheFor(data);
    _cache = cache;
    if (records.isEmpty) {
      subjects = cache.baseSubjects;
      _byKey = cache.byKey;
    } else {
      final evalSubjects = [
        for (final record in records) StudySubject.fromEvaluation(record),
      ];
      subjects = List.unmodifiable([...cache.baseSubjects, ...evalSubjects]);
      _byKey = {
        ...cache.byKey,
        for (final s in evalSubjects) s.key: s,
      };
    }
  }

  static final Expando<_BaseStudyCatalogCache> _baseCaches =
      Expando<_BaseStudyCatalogCache>('StudyCatalogBaseCache');

  static _BaseStudyCatalogCache _cacheFor(AppData data) {
    var cached = _baseCaches[data];
    if (cached == null) {
      cached = _BaseStudyCatalogCache(data);
      _baseCaches[data] = cached;
    }
    return cached;
  }

  final AppData data;
  late final _BaseStudyCatalogCache _cache;
  late final List<StudySubject> subjects;
  late final Map<String, StudySubject> _byKey;

  String _searchTextFor(StudySubject subject) {
    return _cache.searchText.putIfAbsent(
      subject.key,
      () => normalize(
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
    );
  }

  static const methodDescription =
      'Proximidade exploratória: cada eixo compartilhado usa a diferença entre '
      'posições dividida por 2; cada tríade usa a distância euclidiana entre '
      'composições dividida por √2. A similaridade é 100 × (1 − raiz da média '
      'dos quadrados dessas distâncias), com peso igual por dimensão. '
      'Dimensões ausentes ou indeterminadas são excluídas. A sobreposição indica '
      'quantas dimensões são comuns. Sugestões automáticas exigem pelo menos '
      '8 dimensões comuns e 60% de sobreposição da união das dimensões disponíveis; '
      'a comparação manual pode ter cobertura menor. Isso não determina '
      'a confiança do resultado. Nas tríades, '
      'composição não mede apoio absoluto; a intensidade e a incerteza da '
      'avaliação continuam disponíveis no relatório pessoal. O índice não '
      'estabelece influência histórica, identidade política nem probabilidade.';

  StudySubject? find(String key) {
    final direct = _byKey[key] ?? _cache.byRawId[key];
    if (direct != null) return direct;
    for (final s in subjects) {
      if (s.entry?.id == key || s.current?.id == key || s.key == key) {
        return s;
      }
    }
    return null;
  }

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
              (terms.isEmpty ||
                  terms.every(
                    (term) => _searchTextFor(subject).contains(term),
                  )),
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
    var sumSquared = 0.0;
    for (final axis in data.twelveAxes.axes) {
      final av = a.axes[axis.id];
      final bv = b.axes[axis.id];
      final validA = _validAxis(av);
      final validB = _validAxis(bv);
      if (validA || validB) unionAxes++;
      if (!validA || !validB) continue;
      sharedAxes++;
      final d = ((av! - bv!).abs() / 2).clamp(0.0, 1.0);
      sumSquared += d * d;
      distances.add((axis.label, d));
    }
    for (final triad in data.sixTriangles.categories) {
      final av = a.triangles[triad.id];
      final bv = b.triangles[triad.id];
      final validA = _validComposition(av);
      final validB = _validComposition(bv);
      if (validA || validB) unionTriads++;
      if (!validA || !validB) continue;
      sharedTriads++;
      final d0 = av![0] - bv![0];
      final d1 = av[1] - bv[1];
      final d2 = av[2] - bv[2];
      final squared = d0 * d0 + d1 * d1 + d2 * d2;
      final d = math.sqrt(squared / 2).clamp(0.0, 1.0);
      sumSquared += d * d;
      distances.add((triad.label, d));
    }
    if (distances.isEmpty) return null;
    final meanSquared = sumSquared / distances.length;
    return StudyMatch._lazy(
      subject: b,
      similarity: ((1 - math.sqrt(meanSquared)) * 100).clamp(0, 100),
      sharedAxes: sharedAxes,
      sharedTriads: sharedTriads,
      coverage: distances.length / (unionAxes + unionTriads),
      rawDistances: distances,
      sourceAxes: a.axes,
    );
  }

  List<StudyMatch> related(StudySubject subject, {int limit = 6}) {
    if (limit <= 0) return const [];
    // Cache full canonical ranking for catalog entries when no personal evaluations are compared
    if (subject.record == null && subjects.length == _cache.baseSubjects.length) {
      final all = _cache.relatedAllCache.putIfAbsent(subject.key, () {
        final bool restrictToCanonical = subject.isCanonicalSubject;
        final matches = <StudyMatch>[
          for (final candidate in _cache.baseSubjects)
            if (candidate.key != subject.key &&
                (!restrictToCanonical || candidate.isCanonicalSubject))
              if (compare(subject, candidate) case final m? when m.supportsRanking)
                m,
        ];
        matches.sort((a, b) {
          final byScore = b.similarity.compareTo(a.similarity);
          return byScore == 0 ? a.subject.key.compareTo(b.subject.key) : byScore;
        });
        return List.unmodifiable(matches);
      });
      return limit >= all.length ? all : all.take(limit).toList(growable: false);
    }

    final bool restrictToCanonical = subject.isCanonicalSubject;
    final matches = <StudyMatch>[
      for (final candidate in subjects)
        if (candidate.key != subject.key &&
            (!restrictToCanonical || candidate.isCanonicalSubject))
          if (compare(subject, candidate) case final m? when m.supportsRanking)
            m,
    ];
    matches.sort((a, b) {
      final byScore = b.similarity.compareTo(a.similarity);
      return byScore == 0 ? a.subject.key.compareTo(b.subject.key) : byScore;
    });
    return limit >= matches.length
        ? matches
        : matches.take(limit).toList(growable: false);
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

  static final RegExp _diacriticsRegExp = RegExp(r'[\u0300-\u036f]');
  static final RegExp _nonAlphaNumRegExp = RegExp(r'[^a-z0-9]+');

  /// A compact offline fold; identifiers, punctuation and whitespace all use
  /// the same representation as visible text, so accents never block discovery.
  static String normalize(String text) {
    if (text.isEmpty) return '';
    const accented = 'àáâãäåèéêëìíîïòóôõöùúûüçñýÿ';
    const folded = 'aaaaaaeeeeiiiiooooouuuucnyy';
    var result = text.toLowerCase();
    for (var i = 0; i < accented.length; i++) {
      if (result.contains(accented[i])) {
        result = result.replaceAll(accented[i], folded[i]);
      }
    }
    return result
        .replaceAll(_diacriticsRegExp, '')
        .replaceAll(_nonAlphaNumRegExp, ' ')
        .trim();
  }

  /// Search aliases point exclusively to existing catalog IDs. They are names,
  /// abbreviations and spelling variants, not historical influence claims.
  static const searchAliases = <String, List<String>>{
    'personality:raphael_lima': [
      'Raphael Lima',
      'Rafael Lima',
      'Ideias Radicais',
    ],
    'personality:peter_turguniev': [
      'Ancapsu',
      'Ancap.su',
      'Ancap su',
      'Ancapsu Classic',
    ],
    'personality:gilson_marques': ['Gilson Marques NOVO SC'],
    'personality:jones_manoel': ['Jones Manuel', 'Jones Manoel da Silva'],
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
