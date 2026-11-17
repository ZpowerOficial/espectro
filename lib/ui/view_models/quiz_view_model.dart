import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/app_data.dart';
import '../../data/evaluation_repository.dart';
import '../../data/models.dart';
import '../../domain/engine/question_selector.dart';
import '../../domain/engine/scoring_engine.dart';
import '../../domain/models/political_models.dart';

/// ViewModel de uma sessão de questionário do Espectro, com suporte a:
/// - responder na escala Likert de 5 pontos (`-2..+2`),
/// - pular explícito (distinto de neutro!),
/// - trocar pergunta por outra equivalente da mesma dimensão,
/// - persistência automática de rascunho local a cada interação.
class QuizViewModel extends ChangeNotifier {
  QuizViewModel._({
    required this.data,
    required this.repository,
    required this.suite,
    required this.depth,
    required this.seed,
    required this._questions,
    required this._answers,
    required this._skippedUids,
    required this._currentIndex,
  }) : _random = Random(seed ^ 0x5A17) {
    _usedUids.addAll(_questions.map((q) => q.uid));
  }

  factory QuizViewModel.startNew({
    required AppData data,
    required EvaluationRepository repository,
    required TestSuite suite,
    required TestDepth depth,
    int? seed,
  }) {
    final int resolvedSeed =
        seed ?? (DateTime.now().microsecondsSinceEpoch & 0x7FFFFFFF);
    final List<UnifiedQuestion> selected = selectUnifiedQuestions(
      axesData: data.twelveAxes,
      trianglesData: data.sixTriangles,
      suite: suite,
      depth: depth,
      seed: resolvedSeed,
    );
    return QuizViewModel._(
      data: data,
      repository: repository,
      suite: suite,
      depth: depth,
      seed: resolvedSeed,
      questions: selected,
      answers: List<int?>.filled(selected.length, null),
      skippedUids: <String>{},
      currentIndex: 0,
    );
  }

  factory QuizViewModel.fromDraft({
    required AppData data,
    required EvaluationRepository repository,
    required ActiveQuizDraft draft,
  }) {
    final List<UnifiedQuestion> restored = <UnifiedQuestion>[
      for (final String uid in draft.questionUids) data.questionByUid[uid]!,
    ];
    return QuizViewModel._(
      data: data,
      repository: repository,
      suite: draft.suite,
      depth: draft.depth,
      seed: draft.seed,
      questions: restored,
      answers: List<int?>.from(draft.answers),
      skippedUids: Set<String>.from(draft.skippedSet),
      currentIndex: draft.currentIndex,
    );
  }

  final AppData data;
  final EvaluationRepository repository;
  final TestSuite suite;
  final TestDepth depth;
  final int seed;

  final List<UnifiedQuestion> _questions;
  final List<int?> _answers;
  final Set<String> _skippedUids;
  final Set<String> _usedUids = <String>{};
  final Set<String> _swappedOutUids = <String>{};
  final Random _random;

  int _currentIndex;

  List<UnifiedQuestion> get questions =>
      List<UnifiedQuestion>.unmodifiable(_questions);
  int get totalCount => _questions.length;
  int get currentIndex => _currentIndex;
  UnifiedQuestion get currentQuestion => _questions[_currentIndex];

  bool get isFirst => _currentIndex == 0;
  bool get isLast => _currentIndex == _questions.length - 1;

  LikertAnswer? get currentAnswer {
    final int? val = _answers[_currentIndex];
    return val == null ? null : LikertAnswer.fromValue(val);
  }

  bool get isCurrentSkipped =>
      _answers[_currentIndex] == null &&
      _skippedUids.contains(currentQuestion.uid);

  LikertAnswer? answerAt(int idx) {
    final int? val = _answers[idx];
    return val == null ? null : LikertAnswer.fromValue(val);
  }

  bool isSkippedAt(int idx) =>
      _answers[idx] == null && _skippedUids.contains(_questions[idx].uid);

  int get answeredCount => _answers.where((a) => a != null).length;

  int get skippedCount {
    var count = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (_answers[i] == null && _skippedUids.contains(_questions[i].uid)) {
        count++;
      }
    }
    return count;
  }

  int get untouchedCount => totalCount - answeredCount - skippedCount;

  double get progress =>
      totalCount == 0 ? 0.0 : (answeredCount + skippedCount) / totalCount;

  Axis? get currentAxis => currentQuestion.axisQuestion != null
      ? data.twelveAxes.axisById[currentQuestion.axisQuestion!.axisId]
      : null;

  SixCategory? get currentTriadCategory => currentQuestion.sixQuestion != null
      ? data.sixTriangles.categoryById[currentQuestion.sixQuestion!.category]
      : null;

  void selectAnswer(LikertAnswer answer) {
    _answers[_currentIndex] = answer.value;
    _skippedUids.remove(currentQuestion.uid);
    notifyListeners();
    _persistDraft();
  }

  void skipCurrent() {
    _answers[_currentIndex] = null;
    _skippedUids.add(currentQuestion.uid);
    if (!isLast) {
      _currentIndex++;
    }
    notifyListeners();
    _persistDraft();
  }

  void next() {
    if (!isLast) {
      _currentIndex++;
      notifyListeners();
      _persistDraft();
    }
  }

  void previous() {
    if (!isFirst) {
      _currentIndex--;
      notifyListeners();
      _persistDraft();
    }
  }

  void jumpTo(int index) {
    if (index < 0 || index >= _questions.length) return;
    _currentIndex = index;
    notifyListeners();
    _persistDraft();
  }

  /// Substitui a afirmação atual por outra ainda não apresentada da mesma dimensão
  /// e mesma direção de chaveamento (mantendo o balanceamento!).
  bool swapCurrentQuestion() {
    final UnifiedQuestion cur = currentQuestion;
    final List<UnifiedQuestion> candidates = <UnifiedQuestion>[];

    if (cur.kind == UnifiedQuestionKind.integrated) {
      final AxisQuestion aq = cur.axisQuestion!;
      for (final AxisQuestion candidate in data.twelveAxes.questionsFor(
        aq.axisId,
      )) {
        final UnifiedQuestion u = UnifiedQuestion.integrated(
          axisQuestion: candidate,
          sixQuestion: candidate.asSixQuestion,
        );
        if (candidate.agreeIsLeft == aq.agreeIsLeft &&
            !_usedUids.contains(u.uid) &&
            !_swappedOutUids.contains(u.uid)) {
          candidates.add(u);
        }
      }
    } else if (cur.kind == UnifiedQuestionKind.bipolar) {
      final AxisQuestion aq = cur.axisQuestion!;
      for (final AxisQuestion candidate in data.twelveAxes.questionsFor(
        aq.axisId,
      )) {
        final UnifiedQuestion u = UnifiedQuestion.bipolar(candidate);
        if (candidate.agreeIsLeft == aq.agreeIsLeft &&
            !_usedUids.contains(u.uid) &&
            !_swappedOutUids.contains(u.uid)) {
          candidates.add(u);
        }
      }
    } else {
      final SixQuestion sq = cur.sixQuestion!;
      for (final SixQuestion candidate in data.sixTriangles.questions) {
        if (candidate.category == sq.category &&
            candidate.subcategory == sq.subcategory &&
            candidate.multiplier == sq.multiplier) {
          final UnifiedQuestion u = UnifiedQuestion.triad(candidate);
          if (!_usedUids.contains(u.uid) && !_swappedOutUids.contains(u.uid)) {
            candidates.add(u);
          }
        }
      }
    }

    if (candidates.isEmpty) return false;
    final UnifiedQuestion replacement =
        candidates[_random.nextInt(candidates.length)];
    _swappedOutUids.add(cur.uid);
    _usedUids.remove(cur.uid);
    _skippedUids.remove(cur.uid);
    _usedUids.add(replacement.uid);
    _questions[_currentIndex] = replacement;
    _answers[_currentIndex] = null;
    notifyListeners();
    _persistDraft();
    return true;
  }

  bool get canPreview => answeredCount >= 4;

  /// Retorna os marcos/etapas sugeridos de calibração para esta bateria.
  List<int> get milestoneSteps {
    if (totalCount <= 24) return <int>[totalCount];
    if (totalCount <= 48) return <int>[24, totalCount];
    if (totalCount <= 96) return <int>[24, 48, totalCount];
    return <int>[24, 48, 96, totalCount];
  }

  int get currentMilestoneStepIndex {
    final steps = milestoneSteps;
    for (var i = 0; i < steps.length; i++) {
      if (answeredCount < steps[i]) return i;
    }
    return steps.length - 1;
  }

  String get currentStageLabel {
    final steps = milestoneSteps;
    final idx = currentMilestoneStepIndex;
    final target = steps[idx];
    if (answeredCount >= totalCount) return 'Concluído ($totalCount)';
    return 'Etapa ${idx + 1}/${steps.length} · Alvo: $target itens';
  }

  int get currentStageTarget {
    final steps = milestoneSteps;
    return steps[currentMilestoneStepIndex];
  }

  int get currentStageStart {
    final idx = currentMilestoneStepIndex;
    if (idx == 0) return 0;
    return milestoneSteps[idx - 1];
  }

  int get currentStageAnswered {
    final start = currentStageStart;
    final target = currentStageTarget;
    final inStage = answeredCount - start;
    return inStage.clamp(0, target - start);
  }

  int get currentStageTotal => (currentStageTarget - currentStageStart).clamp(1, totalCount);

  double get currentStageProgress {
    final total = currentStageTotal;
    if (total <= 0) return 1.0;
    return (currentStageAnswered / total).clamp(0.0, 1.0);
  }

  int get itemsRemainingForCurrentStage =>
      (currentStageTarget - answeredCount).clamp(0, totalCount);

  String get currentStageTitle {
    final idx = currentMilestoneStepIndex;
    switch (idx) {
      case 0:
        return 'Base Essencial';
      case 1:
        return 'Calibração Fina';
      case 2:
        return 'Alta Resolução';
      default:
        return 'Bateria Integral';
    }
  }

  String get milestoneStatusMessage {
    if (answeredCount >= 96) {
      return 'Mapeamento de alta resolução atingido! Seu perfil já possui consistência estatística sólida.';
    } else if (answeredCount >= 48) {
      return 'Resolução padrão alcançada! Todos os eixos e tríades foram refinados.';
    } else if (answeredCount >= 24) {
      return 'Calibração básica completa! Você já possui dados para gerar resultado com 12 eixos e 6 tríades.';
    } else {
      return 'Responda as 24 primeiras afirmações para calibrar todos os 12 eixos e 6 tríades.';
    }
  }

  int? firstUntouchedIndex() {
    for (var i = 0; i < _questions.length; i++) {
      if (_answers[i] == null && !_skippedUids.contains(_questions[i].uid)) {
        return i;
      }
    }
    return null;
  }

  EvaluationRecord buildCompletedRecord({
    DateTime? now,
    bool isPreliminary = false,
  }) {
    final DateTime timestamp = now ?? DateTime.now();
    final Map<String, int?> rawMap = <String, int?>{};
    for (var i = 0; i < _questions.length; i++) {
      rawMap[_questions[i].uid] = _answers[i];
    }
    final ScoredEvaluation scored = EspectroScoringEngine.evaluate(
      axesData: data.twelveAxes,
      trianglesData: data.sixTriangles,
      suite: suite,
      questions: _questions,
      rawAnswersByUid: rawMap,
    );
    final String id =
        'esp_${timestamp.millisecondsSinceEpoch}_${seed.toRadixString(16)}';
    return EvaluationRecord(
      id: id,
      createdAt: timestamp,
      suite: suite,
      depth: depth,
      seed: seed,
      engineVersion: kEspectroEngineVersion,
      bankVersion: kEspectroBankVersion,
      rawAnswers: rawMap,
      axes: scored.axes,
      triads: scored.triads,
      quality: scored.quality,
      isPreliminary: isPreliminary,
    );
  }

  EvaluationRecord buildPreliminaryRecord({DateTime? now}) =>
      buildCompletedRecord(now: now, isPreliminary: true);

  ActiveQuizDraft toDraft() => ActiveQuizDraft(
        suite: suite,
        depth: depth,
        seed: seed,
        questionUids: _questions.map((q) => q.uid).toList(),
        answers: List<int?>.from(_answers),
        skippedSet: Set<String>.from(_skippedUids),
        currentIndex: _currentIndex,
        updatedAt: DateTime.now(),
      );

  Future<void> saveDraftAsync() async {
    await repository.saveActiveDraft(toDraft());
  }

  void _persistDraft() {
    // Persiste em background sem bloquear animação de resposta.
    repository.saveActiveDraft(toDraft());
  }
}
