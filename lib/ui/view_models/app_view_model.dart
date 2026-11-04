import 'package:flutter/material.dart';

import '../../data/app_data.dart';
import '../../data/evaluation_repository.dart';
import '../../domain/models/political_models.dart';

/// ViewModel global da aplicação: gerencia tema, preferências, histórico local
/// e rascunho de sessão retomável.
class AppViewModel extends ChangeNotifier {
  AppViewModel({
    required this.data,
    required this.repository,
    this.storageNotice,
  });

  final AppData data;
  final EvaluationRepository repository;

  /// Aviso permanente da sessão quando a persistência durável está indisponível.
  /// Não é salvo como preferência nem pode ser descartado por uma gravação.
  final String? storageNotice;

  UserPreferences _preferences = const UserPreferences();
  UserPreferences get preferences => _preferences;

  ThemeMode get themeMode => _preferences.themeMode;
  bool get autoAdvance => _preferences.autoAdvance;

  List<EvaluationRecord> _history = const <EvaluationRecord>[];
  List<EvaluationRecord> get history => _history;

  ActiveQuizDraft? _activeDraft;
  ActiveQuizDraft? get activeDraft => _activeDraft;

  StudyLibraryState _study = StudyLibraryState();
  Set<String> get studyFavorites => _study.favorites;
  List<String> get studyRecent => _study.recent;
  List<String> get studyComparison => _study.comparison;

  String? _studyStorageError;
  String? get studyStorageError => _studyStorageError;

  Future<void> _saveStudy(StudyLibraryState state) async {
    _study = state;
    _studyStorageError = null;
    notifyListeners();
    try {
      await repository.saveStudyState(state);
    } on Object {
      _studyStorageError =
          'Não foi possível salvar sua biblioteca. '
          'Verifique o espaço e a permissão de armazenamento local.';
      notifyListeners();
    }
  }

  Future<void> toggleStudyFavorite(String key) async {
    if (!StudyLibraryState.validKey(key)) return;
    final Set<String> updated = <String>{..._study.favorites};
    if (!updated.remove(key)) updated.add(key);
    await _saveStudy(_study.copyWith(favorites: updated));
  }

  Future<void> visitStudySubject(String key) async {
    if (!StudyLibraryState.validKey(key)) return;
    await _saveStudy(
      _study.copyWith(
        recent: <String>[key, ..._study.recent.where((value) => value != key)],
      ),
    );
  }

  Future<void> toggleStudyComparison(String key) async {
    if (!StudyLibraryState.validKey(key)) return;
    final List<String> updated = <String>[..._study.comparison];
    if (!updated.remove(key)) {
      if (updated.length >= 3) return;
      updated.add(key);
    }
    await _saveStudy(_study.copyWith(comparison: updated));
  }

  Future<void> clearStudyComparison() =>
      _saveStudy(_study.copyWith(comparison: const <String>[]));

  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    _preferences = await repository.loadPreferences();
    _history = await repository.listRecords();
    _study = await repository.loadStudyState();
    final ActiveQuizDraft? draft = await repository.loadActiveDraft();
    // Só mantém o rascunho se todos os UIDs existirem no banco atual.
    if (draft != null &&
        draft.questionUids.every(
          (uid) => data.questionByUid.containsKey(uid),
        )) {
      _activeDraft = draft;
    } else {
      _activeDraft = null;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_preferences.themeMode == mode) return;
    _preferences = _preferences.copyWith(themeMode: mode);
    notifyListeners();
    await repository.savePreferences(_preferences);
  }

  Future<void> setAutoAdvance(bool enabled) async {
    if (_preferences.autoAdvance == enabled) return;
    _preferences = _preferences.copyWith(autoAdvance: enabled);
    notifyListeners();
    await repository.savePreferences(_preferences);
  }

  Future<void> refreshDraft() async {
    final ActiveQuizDraft? draft = await repository.loadActiveDraft();
    if (draft != null &&
        draft.questionUids.every(
          (uid) => data.questionByUid.containsKey(uid),
        )) {
      _activeDraft = draft;
    } else {
      _activeDraft = null;
    }
    notifyListeners();
  }

  Future<void> discardActiveDraft() async {
    _activeDraft = null;
    notifyListeners();
    await repository.clearActiveDraft();
  }

  Future<void> recordCompletedEvaluation(EvaluationRecord record) async {
    await repository.saveRecord(record);
    await repository.clearActiveDraft();
    _activeDraft = null;
    _history = await repository.listRecords();
    notifyListeners();
  }

  Future<void> renameRecord(String id, String newTitle) async {
    final int idx = _history.indexWhere((r) => r.id == id);
    if (idx < 0) return;
    final EvaluationRecord updated = _history[idx].copyWith(
      title: newTitle.trim(),
    );
    await repository.saveRecord(updated);
    _history = await repository.listRecords();
    notifyListeners();
  }

  Future<void> deleteRecord(String id) async {
    await repository.deleteRecord(id);
    await _saveStudy(_study.withoutEvaluations(id));
    _history = await repository.listRecords();
    notifyListeners();
  }

  Future<void> clearAllHistory() async {
    await repository.clearAllHistoryAndDrafts();
    _history = const <EvaluationRecord>[];
    _study = _study.withoutEvaluations();
    _activeDraft = null;
    notifyListeners();
  }
}
