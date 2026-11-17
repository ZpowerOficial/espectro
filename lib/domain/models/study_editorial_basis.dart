import '../../data/strict_json.dart';

/// Contexto da interpretação editorial, sem atribuir validação empírica aos números.
class StudyEditorialBasis {
  const StudyEditorialBasis({
    required this.reviewedAt,
    required this.scope,
    required this.coordinateMethod,
    required this.limitations,
    required this.sourceUrls,
    required this.empiricallyValidated,
    this.sourceTitles = const {},
    this.nativeMatchingEligible = true,
    this.dimensionEvidence = const {},
    this.classificationNote,
    this.sourceMetadata = const {},
    this.evidenceTier = 'tier3_preliminary_curation',
    this.dossierShard,
  });

  static const allowedTiers = <String>[
    'tier1_editorial_reconstruction',
    'tier2_institutional_record',
    'tier3_preliminary_curation',
  ];

  final String reviewedAt, scope, coordinateMethod, evidenceTier;
  final String? dossierShard;
  final List<String> limitations, sourceUrls;
  final bool empiricallyValidated;
  final Map<String, String> sourceTitles;
  final bool nativeMatchingEligible;
  final String? classificationNote;
  final Map<String, String> sourceMetadata;
  final Map<String, StudyDimensionEvidence> dimensionEvidence;

  String get evidenceTierBadge => switch (evidenceTier) {
    'tier1_editorial_reconstruction' => 'Nível 1 · Reconstrução primária',
    'tier2_institutional_record' =>
      'Nível 2 · Votações nominais / registro oficial',
    _ => 'Nível 3 · Curadoria preliminar',
  };

  String get evidenceTierShortLabel => switch (evidenceTier) {
    'tier1_editorial_reconstruction' => 'Nível 1',
    'tier2_institutional_record' => 'Nível 2',
    _ => 'Nível 3',
  };

  StudyEditorialBasis withDimensionEvidence(
    Map<String, StudyDimensionEvidence> loaded,
  ) {
    if (loaded.isEmpty) return this;
    return StudyEditorialBasis(
      reviewedAt: reviewedAt,
      scope: scope,
      coordinateMethod: coordinateMethod,
      limitations: limitations,
      sourceUrls: sourceUrls,
      empiricallyValidated: empiricallyValidated,
      sourceTitles: sourceTitles,
      nativeMatchingEligible: nativeMatchingEligible,
      dimensionEvidence: Map.unmodifiable({...loaded, ...dimensionEvidence}),
      classificationNote: classificationNote,
      sourceMetadata: sourceMetadata,
      evidenceTier: evidenceTier,
      dossierShard: dossierShard,
    );
  }

  static String _inferDefaultTier(
    Map<String, StudyDimensionEvidence> dimensions,
  ) {
    if (dimensions.values.any(
      (e) => e.hasPrimarySupport || e.isReconstructed,
    )) {
      return 'tier1_editorial_reconstruction';
    }
    if (dimensions.values.any((e) => e.isInstitutionalVote)) {
      return 'tier2_institutional_record';
    }
    return 'tier3_preliminary_curation';
  }

  static StudyEditorialBasis? parse(Object? raw, String path) {
    if (raw == null) return null;
    final row = readObject(raw, path);
    List<String> strings(String key) => List.unmodifiable(
      readArray(
        row[key],
        '$path.$key',
      ).asMap().entries.map((e) => readString(e.value, '$path.$key[${e.key}]')),
    );
    final urls = strings('sourceUrls');
    final dimensions = <String, StudyDimensionEvidence>{};
    if (row['dimensionEvidence'] case final rawDimensions?) {
      for (final e in readObject(
        rawDimensions,
        '$path.dimensionEvidence',
      ).entries) {
        if (!RegExp(r'^(axis:[a-z_]+|triad:[0-5])$').hasMatch(e.key)) {
          throw FormatException('$path.dimensionEvidence: dimensão inválida');
        }
        final evidence = StudyDimensionEvidence.parse(
          e.value,
          '$path.dimensionEvidence.${e.key}',
        );
        if (evidence.sourceUrls.any((url) => !urls.contains(url))) {
          throw FormatException('$path.dimensionEvidence: fonte não declarada');
        }
        dimensions[e.key] = evidence;
      }
    }
    if (urls.any((u) {
      final uri = Uri.tryParse(u);
      return uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty;
    })) {
      throw FormatException('$path: fonte inválida');
    }
    if (row['empiricallyValidated'] is! bool) {
      throw FormatException('$path: estado de validação inválido');
    }
    final rawTier = readStringOrNull(row['evidenceTier'], '$path.evidenceTier');
    if (rawTier != null && !allowedTiers.contains(rawTier)) {
      throw FormatException('$path.evidenceTier inválido: $rawTier');
    }
    final shard = readStringOrNull(row['dossierShard'], '$path.dossierShard');
    if (shard != null && !RegExp(r'^shard_[0-9]{2}$').hasMatch(shard)) {
      throw FormatException('$path.dossierShard inválido: $shard');
    }
    return StudyEditorialBasis(
      reviewedAt: readString(row['reviewedAt'], '$path.reviewedAt'),
      scope: readString(row['scope'], '$path.scope'),
      coordinateMethod: readString(
        row['coordinateMethod'],
        '$path.coordinateMethod',
      ),
      limitations: strings('limitations'),
      sourceUrls: urls,
      sourceTitles: readStudyCoordinateNotes(
        row['sourceTitles'],
        '$path.sourceTitles',
      ),
      sourceMetadata: readStudyCoordinateNotes(
        row['sourceMetadata'],
        '$path.sourceMetadata',
      ),
      classificationNote: readStringOrNull(
        row['classificationNote'],
        '$path.classificationNote',
      ),
      dimensionEvidence: Map.unmodifiable(dimensions),
      nativeMatchingEligible: row['nativeMatchingEligible'] != false,
      empiricallyValidated: row['empiricallyValidated'] as bool,
      evidenceTier: rawTier ?? _inferDefaultTier(dimensions),
      dossierShard: shard,
    );
  }
}

class StudyDimensionEvidence {
  const StudyDimensionEvidence({
    required this.status,
    required this.locator,
    required this.rationale,
    required this.sourceUrls,
    this.reconstructedAnswers = const [],
  });
  final String status, locator, rationale;
  final List<String> sourceUrls;
  final List<StudyReconstructedAnswer> reconstructedAnswers;
  bool get hasPrimarySupport => status == 'primary_supported';
  bool get isReconstructed => status == 'editorial_reconstruction';
  bool get isInstitutionalVote => status == 'institutional_vote';

  /// Leitura temática da doutrina ancorada em fonte registrada, sem alegar
  /// citação literal página a página. Não se confunde com leitura primária
  /// direta nem com respostas reconstruídas do questionário.
  bool get isSynthesis => status == 'editorial_synthesis';
  bool get hasDocumentedBasis =>
      hasPrimarySupport ||
      isReconstructed ||
      isInstitutionalVote ||
      isSynthesis;
  static StudyDimensionEvidence parse(Object? raw, String path) {
    final row = readObject(raw, path);
    final status = readString(row['status'], '$path.status');
    if (!const [
      'primary_supported',
      'editorial_reconstruction',
      'institutional_vote',
      'editorial_synthesis',
      'insufficient',
      'unreviewed',
    ].contains(status)) {
      throw FormatException('$path.status inválido');
    }
    final urls = readArray(
      row['sourceUrls'],
      '$path.sourceUrls',
    ).map((u) => readString(u, '$path.sourceUrls')).toList();
    if ((status == 'primary_supported' ||
            status == 'editorial_reconstruction' ||
            status == 'institutional_vote' ||
            status == 'editorial_synthesis') &&
        urls.isEmpty) {
      throw FormatException('$path: suporte sem fonte');
    }
    final answers = <StudyReconstructedAnswer>[
      if (row['reconstructedAnswers'] case final rawAnswers?)
        for (final rawAnswer in readArray(
          rawAnswers,
          '$path.reconstructedAnswers',
        ))
          StudyReconstructedAnswer.parse(
            rawAnswer,
            '$path.reconstructedAnswers',
          ),
    ];
    if ((status == 'editorial_reconstruction' && answers.isEmpty) ||
        (status != 'editorial_reconstruction' && answers.isNotEmpty) ||
        answers.map((a) => a.questionUid).toSet().length != answers.length) {
      throw FormatException('$path: reconstrução editorial inválida');
    }
    return StudyDimensionEvidence(
      status: status,
      locator: readString(row['locator'], '$path.locator'),
      rationale: readString(row['rationale'], '$path.rationale'),
      sourceUrls: List.unmodifiable(urls),
      reconstructedAnswers: List.unmodifiable(answers),
    );
  }
}

/// An attributed editorial reading, never an observation from a respondent.
class StudyReconstructedAnswer {
  const StudyReconstructedAnswer({
    required this.questionUid,
    required this.statement,
    required this.answer,
    required this.rationale,
  });
  final String questionUid, statement, rationale;
  final int answer;
  String get answerLabel => switch (answer) {
    -2 => 'Discordo totalmente',
    -1 => 'Discordo',
    0 => 'Neutro ou depende',
    1 => 'Concordo',
    _ => 'Concordo totalmente',
  };
  static StudyReconstructedAnswer parse(Object? raw, String path) {
    final row = readObject(raw, path);
    final uid = readString(row['questionUid'], '$path.questionUid');
    final statement = readString(row['statement'], '$path.statement');
    final rationale = readString(row['rationale'], '$path.rationale');
    final answer = row['answer'];
    if (answer is! int ||
        answer < -2 ||
        answer > 2 ||
        !RegExp(r'^(axis:[a-z_]+_[0-9]+|tri:[0-9]+)$').hasMatch(uid) ||
        statement.trim().isEmpty ||
        rationale.trim().isEmpty) {
      throw FormatException('$path: resposta editorial inválida');
    }
    return StudyReconstructedAnswer(
      questionUid: uid,
      statement: statement,
      answer: answer,
      rationale: rationale,
    );
  }
}

Map<String, String> readStudyCoordinateNotes(Object? raw, String path) =>
    raw == null
    ? const {}
    : Map.unmodifiable(
        readObject(
          raw,
          path,
        ).map((key, value) => MapEntry(key, readString(value, '$path.$key'))),
      );
Map<int, String> readStudyCompositionNotes(Object? raw, String path) {
  final out = <int, String>{};
  for (final e in readStudyCoordinateNotes(raw, path).entries) {
    final id = int.tryParse(e.key);
    if (id == null || id < 0 || id > 5) {
      throw FormatException('$path: tríade inválida');
    }
    out[id] = e.value;
  }
  return Map.unmodifiable(out);
}
