import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../domain/models/atlas_models.dart';
import '../domain/models/study_media.dart';
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
  }) : questionByUid = _buildIndex(twelveAxes, sixTriangles);

  final TwelveAxesData twelveAxes;
  final SixTrianglesData sixTriangles;
  final IdeologicalCatalog catalog;
  final PoliticalAtlas atlas;
  final Map<String, StudyPortrait> portraits;
  final Map<String, UnifiedQuestion> questionByUid;

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
    final IdeologicalCatalog catalog = IdeologicalCatalog.fromJson(
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

    final PoliticalAtlas atlas = PoliticalAtlas(
      personalities: await loadAtlas('personalities', AtlasKind.personality),
      partiesAndMovements: await loadAtlas(
        'parties_movements',
        AtlasKind.party,
      ),
      historicalEras: await loadAtlas('historical_eras', AtlasKind.history),
      books: await loadAtlas('books_catalog', AtlasKind.book),
      countries: await loadAtlas('countries', AtlasKind.country),
    );

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
    return AppData(
      portraits: Map.unmodifiable(portraits),
      twelveAxes: mergedTwelve,
      sixTriangles: mergedSix,
      catalog: catalog,
      atlas: atlas,
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
