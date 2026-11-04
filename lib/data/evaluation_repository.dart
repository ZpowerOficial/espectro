import 'package:flutter/material.dart';

import '../domain/models/political_models.dart';
import 'local_storage_service.dart';
import 'strict_json.dart';

/// Preferências locais do usuário.
class UserPreferences {
  const UserPreferences({
    this.themeMode = ThemeMode.system,
    this.autoAdvance = true,
  });

  final ThemeMode themeMode;
  final bool autoAdvance;

  UserPreferences copyWith({ThemeMode? themeMode, bool? autoAdvance}) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      autoAdvance: autoAdvance ?? this.autoAdvance,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': 1,
    'themeMode': themeMode.name,
    'autoAdvance': autoAdvance,
  };

  factory UserPreferences.fromJson(Map<String, Object?> json) {
    final String rawTheme =
        readStringOrNull(json['themeMode'], 'prefs.themeMode') ?? 'system';
    final ThemeMode mode = switch (rawTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final bool autoAdv = json['autoAdvance'] is bool
        ? json['autoAdvance'] as bool
        : true;
    return UserPreferences(themeMode: mode, autoAdvance: autoAdv);
  }
}

/// Biblioteca pessoal de estudo. As chaves apontam para o catálogo local;
/// nenhuma resposta de questionário é incluída neste documento.
class StudyLibraryState {
  StudyLibraryState({
    Iterable<String> favorites = const <String>[],
    Iterable<String> recent = const <String>[],
    Iterable<String> comparison = const <String>[],
  }) : favorites = Set<String>.unmodifiable(_validKeys(favorites)),
       recent = List<String>.unmodifiable(_validKeys(recent).take(12)),
       comparison = List<String>.unmodifiable(_validKeys(comparison).take(3));

  final Set<String> favorites;
  final List<String> recent;
  final List<String> comparison;

  static final RegExp _keyPattern = RegExp(
    r'^(current|personality|party|history|book|country|evaluation):[a-zA-Z0-9_-]{1,160}$',
  );

  static Iterable<String> _validKeys(Iterable<String> values) =>
      values.where((value) => _keyPattern.hasMatch(value)).toSet();

  static bool validKey(String key) => _keyPattern.hasMatch(key);

  StudyLibraryState copyWith({
    Iterable<String>? favorites,
    Iterable<String>? recent,
    Iterable<String>? comparison,
  }) => StudyLibraryState(
    favorites: favorites ?? this.favorites,
    recent: recent ?? this.recent,
    comparison: comparison ?? this.comparison,
  );

  StudyLibraryState withoutEvaluations([String? id]) {
    bool keep(String key) =>
        id == null ? !key.startsWith('evaluation:') : key != 'evaluation:$id';
    return copyWith(
      favorites: favorites.where(keep),
      recent: recent.where(keep),
      comparison: comparison.where(keep),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': 1,
    'favorites': favorites.toList(),
    'recent': recent,
    'comparison': comparison,
  };

  factory StudyLibraryState.fromJson(Map<String, Object?> json) {
    if (json['schemaVersion'] != 1) return StudyLibraryState();
    Iterable<String> keys(String field) {
      final Object? value = json[field];
      return value is List<Object?>
          ? value.whereType<String>()
          : const <String>[];
    }

    return StudyLibraryState(
      favorites: keys('favorites'),
      recent: keys('recent'),
      comparison: keys('comparison'),
    );
  }
}

/// Repositório único para histórico de avaliações, rascunhos retomáveis e preferências.
class EvaluationRepository {
  EvaluationRepository({required this._storage});

  final LocalStorageService _storage;

  static const String _studyPath = 'study_library.json';
  static const String _prefsPath = 'preferences.json';
  static const String _draftPath = 'active_draft.json';
  static const String _recordsDir = 'records';

  String _sanitizeId(String id) =>
      id.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

  Future<UserPreferences> loadPreferences() async {
    final Map<String, Object?>? json = await _storage.readJsonOrNull(
      _prefsPath,
    );
    if (json == null) return const UserPreferences();
    try {
      return UserPreferences.fromJson(json);
    } on Object {
      return const UserPreferences();
    }
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    await _storage.writeJsonAtomic(_prefsPath, preferences.toJson());
  }

  Future<ActiveQuizDraft?> loadActiveDraft() async {
    final Map<String, Object?>? json = await _storage.readJsonOrNull(
      _draftPath,
    );
    if (json == null) return null;
    try {
      return ActiveQuizDraft.fromJson(json);
    } on Object {
      return null;
    }
  }

  Future<void> saveActiveDraft(ActiveQuizDraft draft) async {
    await _storage.writeJsonAtomic(_draftPath, draft.toJson());
  }

  Future<void> clearActiveDraft() async {
    await _storage.deleteFileIfExists(_draftPath);
  }

  Future<List<EvaluationRecord>> listRecords() async {
    final List<Map<String, Object?>> rawList = await _storage.listJsonDirectory(
      _recordsDir,
    );
    final List<EvaluationRecord> records = <EvaluationRecord>[];
    for (final Map<String, Object?> raw in rawList) {
      try {
        records.add(EvaluationRecord.fromJson(raw));
      } on Object {
        // Ignora arquivo inválido isoladamente.
      }
    }
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  Future<void> saveRecord(EvaluationRecord record) async {
    final String safe = _sanitizeId(record.id);
    await _storage.writeJsonAtomic('$_recordsDir/$safe.json', record.toJson());
  }

  Future<void> deleteRecord(String id) async {
    final String safe = _sanitizeId(id);
    await _storage.deleteFileIfExists('$_recordsDir/$safe.json');
  }

  Future<StudyLibraryState> loadStudyState() async {
    final Map<String, Object?>? json = await _storage.readJsonOrNull(
      _studyPath,
    );
    return json == null
        ? StudyLibraryState()
        : StudyLibraryState.fromJson(json);
  }

  Future<void> saveStudyState(StudyLibraryState state) =>
      _storage.writeJsonAtomic(_studyPath, state.toJson());

  Future<void> clearAllHistoryAndDrafts() async {
    final UserPreferences prefs = await loadPreferences();
    final StudyLibraryState study = (await loadStudyState())
        .withoutEvaluations();
    await _storage.wipeAll();
    await savePreferences(prefs);
    await saveStudyState(study);
  }
}
