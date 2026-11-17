import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../domain/models/atlas_models.dart';
import '../domain/models/study_editorial_basis.dart';
import '../domain/models/study_media.dart';
import '../domain/models/study_relations.dart';
import '../domain/models/political_models.dart';
import 'models.dart';
import 'strict_json.dart';

/// Conteúdo embarcado do Espectro: dimensões bipolares, tríades, banco expandido
/// de perguntas, catálogo calibrado de correntes ideológicas e Atlas Político
/// offline (Personalidades, Partidos/Movimentos, História e Livros).
class AppData {
  AppData({
    required this.twelveAxes,
    required this.sixTriangles,
    required this.catalog,
    this.atlas = const PoliticalAtlas(),
    this.portraits = const <String, StudyPortrait>{},
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle,
       questionByUid = _buildIndex(twelveAxes, sixTriangles);

  final TwelveAxesData twelveAxes;
  final SixTrianglesData sixTriangles;
  final IdeologicalCatalog catalog;
  final PoliticalAtlas atlas;
  final Map<String, StudyPortrait> portraits;
  final Map<String, UnifiedQuestion> questionByUid;
  final AssetBundle _bundle;
  final Map<String, Map<String, Object?>> _dossierShardCache =
      <String, Map<String, Object?>>{};

  /// Carrega sob demanda o detalhamento documental (`dimensionEvidence`) de uma
  /// ficha estendida armazenada em `assets/data/dossiers/$shard.json`.
  Future<Map<String, StudyDimensionEvidence>> loadDossierEvidence(
    String subjectKey, {
    required String shard,
    required List<String> allowedSourceUrls,
  }) async {
    if (!RegExp(r'^shard_[0-9]{2}$').hasMatch(shard)) {
      throw FormatException('Shard de dossiê inválido: $shard');
    }
    Map<String, Object?>? profiles = _dossierShardCache[shard];
    if (profiles == null) {
      final String? raw = await _tryLoad(
        _bundle,
        'assets/data/dossiers/$shard.json',
      );
      if (raw == null) return const <String, StudyDimensionEvidence>{};
      final Map<String, Object?> shardObj = readObject(
        jsonDecode(raw),
        'dossiers.$shard',
      );
      profiles = readObject(shardObj['profiles'], 'dossiers.$shard.profiles');
      _dossierShardCache[shard] = profiles;
    }
    final Object? rawDimensions = profiles[subjectKey];
    if (rawDimensions == null) return const <String, StudyDimensionEvidence>{};
    final Map<String, StudyDimensionEvidence> out =
        <String, StudyDimensionEvidence>{};
    for (final MapEntry<String, Object?> entry in readObject(
      rawDimensions,
      'dossiers.$shard.$subjectKey',
    ).entries) {
      if (!RegExp(r'^(axis:[a-z_]+|triad:[0-5])$').hasMatch(entry.key)) {
        throw FormatException(
          'dossiers.$shard.$subjectKey: dimensão inválida ${entry.key}',
        );
      }
      final StudyDimensionEvidence evidence = StudyDimensionEvidence.parse(
        entry.value,
        'dossiers.$shard.$subjectKey.${entry.key}',
      );
      if (evidence.sourceUrls.any((url) => !allowedSourceUrls.contains(url))) {
        throw FormatException(
          'dossiers.$shard.$subjectKey.${entry.key}: fonte não declarada',
        );
      }
      out[entry.key] = evidence;
    }
    return Map.unmodifiable(out);
  }

  int get totalQuestionCount =>
      twelveAxes.questions.length + sixTriangles.questions.length;

  Map<String, String> get questionTextByUid => <String, String>{
    for (final MapEntry<String, UnifiedQuestion> entry in questionByUid.entries)
      entry.key: entry.value.text,
  };

  static Map<String, UnifiedQuestion> _buildIndex(
    TwelveAxesData axes,
    SixTrianglesData triads,
  ) {
    final Map<String, UnifiedQuestion> index = <String, UnifiedQuestion>{};
    for (final AxisQuestion q in axes.questions) {
      final UnifiedQuestion u = UnifiedQuestion.bipolar(q);
      index[u.uid] = u;
    }
    for (final SixQuestion q in triads.questions) {
      final UnifiedQuestion u = UnifiedQuestion.triad(q);
      index[u.uid] = u;
    }
    return index;
  }

  static Future<AppData> load({AssetBundle? bundle}) async {
    final AssetBundle source = bundle ?? rootBundle;

    final Object? twelveRaw = jsonDecode(
      await source.loadString('assets/data/twelve_axes.json'),
    );
    final TwelveAxesData baseTwelve = TwelveAxesData.fromJson(
      readObject(twelveRaw, 'twelve_axes'),
    );

    final List<AxisQuestion> allAxisQuestions = <AxisQuestion>[
      ...baseTwelve.questions,
    ];
    final String? twelveExtraStr = await _tryLoad(
      source,
      'assets/data/twelve_axes_extra.json',
    );
    if (twelveExtraStr != null) {
      final Map<String, Object?> extraObj = readObject(
        jsonDecode(twelveExtraStr),
        'twelve_axes_extra',
      );
      final List<Object?> rawExtra = readArray(
        extraObj['questions'],
        'twelve_axes_extra.questions',
      );
      final Set<String> axisIds = baseTwelve.axes.map((a) => a.id).toSet();
      final Set<String> seenIds = allAxisQuestions.map((q) => q.id).toSet();
      for (var i = 0; i < rawExtra.length; i++) {
        final AxisQuestion q = AxisQuestion.fromJson(
          readObject(rawExtra[i], 'twelve_axes_extra.questions[$i]'),
          'twelve_axes_extra.questions[$i]',
        );
        if (!axisIds.contains(q.axisId)) {
          throw FormatException('Eixo inexistente em extra: "${q.axisId}"');
        }
        if (!seenIds.add(q.id)) {
          throw FormatException('ID duplicado em twelve_axes_extra: "${q.id}"');
        }
        allAxisQuestions.add(q);
      }
    }

    final TwelveAxesData mergedTwelve = TwelveAxesData(
      axes: baseTwelve.axes,
      answerOptions: baseTwelve.answerOptions,
      questions: allAxisQuestions,
      archetypeQuestions: baseTwelve.archetypeQuestions,
    );

    final Object? sixRaw = jsonDecode(
      await source.loadString('assets/data/six_triangles.json'),
    );
    final SixTrianglesData baseSix = SixTrianglesData.fromJson(
      readObject(sixRaw, 'six_triangles'),
    );

    final List<SixQuestion> allSixQuestions = <SixQuestion>[
      ...baseSix.questions,
    ];
    final String? sixExtraStr = await _tryLoad(
      source,
      'assets/data/six_triangles_extra.json',
    );
    if (sixExtraStr != null) {
      final Map<String, Object?> extraObj = readObject(
        jsonDecode(sixExtraStr),
        'six_triangles_extra',
      );
      final List<Object?> rawExtra = readArray(
        extraObj['questions'],
        'six_triangles_extra.questions',
      );
      final Set<int> seenIds = allSixQuestions.map((q) => q.id).toSet();
      for (var i = 0; i < rawExtra.length; i++) {
        final SixQuestion q = SixQuestion.fromJson(
          readObject(rawExtra[i], 'six_triangles_extra.questions[$i]'),
          'six_triangles_extra.questions[$i]',
        );
        if (!seenIds.add(q.id)) {
          throw FormatException('ID duplicado em six_triangles_extra: ${q.id}');
        }
        allSixQuestions.add(q);
      }
    }

    final SixTrianglesData mergedSix = SixTrianglesData(
      categories: baseSix.categories,
      questions: allSixQuestions,
    );

    final Object? currentsRaw = jsonDecode(
      await source.loadString('assets/data/ideological_currents.json'),
    );
    IdeologicalCatalog catalog = IdeologicalCatalog.fromJson(
      readObject(currentsRaw, 'ideological_currents'),
    );

    Future<List<AtlasEntry>> loadAtlas(String file, AtlasKind kind) async {
      final String? raw = await _tryLoad(source, 'assets/data/$file.json');
      if (raw == null) return const <AtlasEntry>[];
      return PoliticalAtlas.parseEntriesJson(
        readObject(jsonDecode(raw), file),
        kind,
        file,
      );
    }

    final List<AtlasEntry> corePersonalities = await loadAtlas(
      'personalities',
      AtlasKind.personality,
    );
    final List<AtlasEntry> extendedPersonalities = await loadAtlas(
      'personalities_extended',
      AtlasKind.personality,
    );
    final Set<String> seenPersonIds = <String>{
      for (final AtlasEntry entry in corePersonalities) entry.id,
    };
    for (final AtlasEntry entry in extendedPersonalities) {
      if (!seenPersonIds.add(entry.id)) {
        throw FormatException(
          'Personalidade duplicada entre catálogo base e estendido: "${entry.id}"',
        );
      }
    }

    PoliticalAtlas atlas = PoliticalAtlas(
      personalities: List<AtlasEntry>.unmodifiable(<AtlasEntry>[
        ...corePersonalities,
        ...extendedPersonalities,
      ]),
      partiesAndMovements: await loadAtlas(
        'parties_movements',
        AtlasKind.party,
      ),
      historicalEras: await loadAtlas('historical_eras', AtlasKind.history),
      books: await loadAtlas('books_catalog', AtlasKind.book),
      countries: await loadAtlas('countries', AtlasKind.country),
    );

    // Catálogo opcional de dados licenciados. Fica separado dos arquivos
    // editoriais para que uma importação nunca sobrescreva uma ficha revisada.
    final String? externalRaw = await _tryLoad(
      source,
      'assets/data/external_catalog.json',
    );
    if (externalRaw != null) {
      final Map<String, Object?> external = readObject(
        jsonDecode(externalRaw),
        'external_catalog',
      );
      catalog = _mergeExternalCurrents(catalog, external);
      atlas = _mergeExternalAtlas(atlas, external);
    }

    final portraits = <String, StudyPortrait>{};
    final mediaRaw = await _tryLoad(source, 'assets/data/study_media.json');
    if (mediaRaw != null) {
      final media = readObject(jsonDecode(mediaRaw), 'study_media');
      for (final raw in readArray(
        media['portraits'],
        'study_media.portraits',
      )) {
        final row = readObject(raw, 'portrait');
        final key = readString(row['key'], 'portrait.key');
        if (portraits.containsKey(key)) {
          throw FormatException('Retrato duplicado: $key');
        }
        portraits[key] = StudyPortrait.fromJson(row);
      }
    }
    final relRaw = await _tryLoad(
      source,
      'assets/data/study_relations_extended.json',
    );
    if (relRaw != null) {
      final obj = jsonDecode(relRaw) as Map<String, Object?>?;
      final list = obj?['relations'] as List<Object?>?;
      if (list != null) {
        final parsed = <StudyRelation>[];
        for (final item in list) {
          if (item is Map<String, Object?>) {
            parsed.add(StudyRelation.fromJson(item));
          }
        }
        registerExtendedStudyRelations(parsed);
      }
    }
    return AppData(
      portraits: Map.unmodifiable(portraits),
      twelveAxes: mergedTwelve,
      sixTriangles: mergedSix,
      catalog: catalog,
      atlas: atlas.withPortraits(portraits),
      bundle: source,
    );
  }

  static IdeologicalCatalog _mergeExternalCurrents(
    IdeologicalCatalog base,
    Map<String, Object?> external,
  ) {
    final List<Object?> raw = readArray(
      external['currents'],
      'external_catalog.currents',
    );
    if (raw.isEmpty) return base;
    final Set<String> seen = <String>{
      for (final IdeologicalCurrent current in base.currents) current.id,
    };
    final List<IdeologicalCurrent> merged = <IdeologicalCurrent>[
      ...base.currents,
    ];
    for (var i = 0; i < raw.length; i++) {
      final IdeologicalCurrent current = IdeologicalCurrent.fromJson(
        readObject(raw[i], 'external_catalog.currents[$i]'),
        'external_catalog.currents[$i]',
      );
      if (seen.add(current.id)) merged.add(current);
    }
    if (merged.length == base.currents.length) return base;
    final String? version = readStringOrNull(
      external['catalogVersion'],
      'external_catalog.catalogVersion',
    );
    return IdeologicalCatalog(
      schemaVersion: base.schemaVersion,
      catalogVersion: version == null
          ? base.catalogVersion
          : '${base.catalogVersion}+$version',
      currents: List<IdeologicalCurrent>.unmodifiable(merged),
    );
  }

  static PoliticalAtlas _mergeExternalAtlas(
    PoliticalAtlas base,
    Map<String, Object?> external,
  ) {
    final Map<String, Object?> entries = readObject(
      external['entries'],
      'external_catalog.entries',
    );

    List<AtlasEntry> parse(String key, AtlasKind kind) {
      final List<Object?> raw = readArray(
        entries[key],
        'external_catalog.entries.$key',
      );
      return <AtlasEntry>[
        for (var i = 0; i < raw.length; i++)
          AtlasEntry.fromJson(
            readObject(raw[i], 'external_catalog.entries.$key[$i]'),
            kind,
            'external_catalog.entries.$key[$i]',
          ),
      ];
    }

    List<AtlasEntry> merge(List<AtlasEntry> current, List<AtlasEntry> extra) {
      if (extra.isEmpty) return current;
      final Set<String> seen = <String>{for (final e in current) e.id};
      return List<AtlasEntry>.unmodifiable(<AtlasEntry>[
        ...current,
        ...extra.where((e) => seen.add(e.id)),
      ]);
    }

    return PoliticalAtlas(
      personalities: merge(
        base.personalities,
        parse('personalities', AtlasKind.personality),
      ),
      partiesAndMovements: merge(
        base.partiesAndMovements,
        parse('parties', AtlasKind.party),
      ),
      historicalEras: merge(
        base.historicalEras,
        parse('history', AtlasKind.history),
      ),
      books: merge(base.books, parse('books', AtlasKind.book)),
      countries: merge(base.countries, parse('countries', AtlasKind.country)),
    );
  }

  static Future<String?> _tryLoad(AssetBundle source, String key) async {
    try {
      return await source.loadString(key);
    } on Object {
      return null;
    }
  }
}
