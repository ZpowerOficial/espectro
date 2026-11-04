import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/domain/models/political_models.dart';
import 'package:politico/ui/view_models/app_view_model.dart';
import 'package:politico/ui/view_models/quiz_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppData data;
  late Directory tempDir;
  late LocalStorageService storage;
  late EvaluationRepository repository;

  setUpAll(() async {
    data = await AppData.load();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('espectro_repo_test_');
    storage = LocalStorageService(overrideDirectory: tempDir);
    repository = EvaluationRepository(storage: storage);
  });

  tearDown(() async {
    await storage.flush();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('persiste, lista, renomeia e exclui EvaluationRecord atomicamente com round-trip íntegro', () async {
    final AppViewModel appVm = AppViewModel(data: data, repository: repository);
    await appVm.initialize();
    expect(appVm.history, isEmpty);

    final QuizViewModel quizVm = QuizViewModel.startNew(
      data: data,
      repository: repository,
      suite: TestSuite.espectroIntegrated,
      depth: TestDepth.quick,
      seed: 101,
    );
    for (var i = 0; i < quizVm.totalCount; i++) {
      quizVm.jumpTo(i);
      if (i % 7 == 0) {
        quizVm.skipCurrent();
      } else {
        quizVm.selectAnswer(
          i.isEven ? LikertAnswer.agree : LikertAnswer.disagree,
        );
      }
    }

    final EvaluationRecord record = quizVm.buildCompletedRecord(
      now: DateTime.utc(2026, 11, 2, 18, 30),
    );
    await appVm.recordCompletedEvaluation(record);

    expect(appVm.history.length, 1);
    expect(appVm.activeDraft, isNull);

    // Recarrega em nova instância para garantir leitura do disco.
    final AppViewModel reloaded = AppViewModel(
      data: data,
      repository: repository,
    );
    await reloaded.initialize();
    expect(reloaded.history.length, 1);

    final EvaluationRecord loaded = reloaded.history.single;
    expect(loaded.id, record.id);
    expect(loaded.suite, TestSuite.espectroIntegrated);
    expect(loaded.depth, TestDepth.quick);
    expect(loaded.axes.length, 12);
    expect(loaded.triads.length, 6);
    expect(loaded.quality.totalSkipped, record.quality.totalSkipped);
    expect(loaded.rawAnswers.length, quizVm.totalCount);

    for (var i = 0; i < 12; i++) {
      expect(loaded.axes[i].score, closeTo(record.axes[i].score, 1e-12));
    }
    for (var i = 0; i < 6; i++) {
      expect(
        loaded.triads[i].engagement,
        closeTo(record.triads[i].engagement, 1e-12),
      );
    }

    // Renomear e excluir.
    await reloaded.renameRecord(loaded.id, 'Avaliação de Novembro');
    expect(reloaded.history.single.title, 'Avaliação de Novembro');

    await reloaded.deleteRecord(loaded.id);
    expect(reloaded.history, isEmpty);
  });

  test(
    'persiste preferências de tema (claro/escuro/sistema) e rascunho retomável',
    () async {
      final AppViewModel appVm = AppViewModel(
        data: data,
        repository: repository,
      );
      await appVm.initialize();
      expect(appVm.themeMode, ThemeMode.system);
      expect(appVm.autoAdvance, isTrue);

      await appVm.setThemeMode(ThemeMode.dark);
      await appVm.setAutoAdvance(false);

      final ActiveQuizDraft draft = ActiveQuizDraft(
        suite: TestSuite.triads,
        depth: TestDepth.quick,
        seed: 77,
        questionUids: data.questionByUid.keys.take(10).toList(),
        answers: const <int?>[
          2,
          -1,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
        ],
        skippedSet: <String>{data.questionByUid.keys.elementAt(2)},
        currentIndex: 3,
        updatedAt: DateTime.utc(2026, 11, 2),
      );
      await repository.saveActiveDraft(draft);

      final AppViewModel restarted = AppViewModel(
        data: data,
        repository: repository,
      );
      await restarted.initialize();
      expect(restarted.themeMode, ThemeMode.dark);
      expect(restarted.autoAdvance, isFalse);
      expect(restarted.activeDraft, isNotNull);
      expect(restarted.activeDraft!.answeredOrSkippedCount, 3);

      final QuizViewModel resumed = QuizViewModel.fromDraft(
        data: data,
        repository: repository,
        draft: restarted.activeDraft!,
      );
      expect(resumed.currentIndex, 3);
      expect(resumed.answeredCount, 2);
      expect(resumed.skippedCount, 1);

      await restarted.clearAllHistory();
      expect(restarted.activeDraft, isNull);
      // Preferências de tema devem ser preservadas após limpar o histórico.
      expect(restarted.themeMode, ThemeMode.dark);
    },
  );

  test('tolera arquivos JSON corrompidos sem quebrar inicialização', () async {
    final Directory recordsDir = Directory('${tempDir.path}/records');
    await recordsDir.create(recursive: true);
    await File('${recordsDir.path}/corrompido.json')
        .writeAsString('{json_invalido:::');
    await File('${tempDir.path}/preferences.json').writeAsString('não-é-json');
    await File('${tempDir.path}/active_draft.json')
        .writeAsString('{"schemaVersion":1}');

    final AppViewModel appVm = AppViewModel(data: data, repository: repository);
    await appVm.initialize();

    expect(appVm.initialized, isTrue);
    expect(appVm.history, isEmpty);
    expect(appVm.activeDraft, isNull);
    expect(appVm.themeMode, ThemeMode.system);
  });

  test(
    'biblioteca persiste entre instâncias, limita recentes e comparação',
    () async {
      final AppViewModel vm = AppViewModel(data: data, repository: repository);
      await vm.initialize();
      await vm.toggleStudyFavorite('current:liberalismo_classico');
      for (var i = 0; i < 15; i++) {
        await vm.visitStudySubject('book:livro_$i');
      }
      await vm.visitStudySubject('book:livro_10');
      for (var i = 0; i < 4; i++) {
        await vm.toggleStudyComparison('current:corrente_$i');
      }
      final AppViewModel restored = AppViewModel(
        data: data,
        repository: EvaluationRepository(
          storage: LocalStorageService(overrideDirectory: tempDir),
        ),
      );
      await restored.initialize();
      expect(restored.studyFavorites, <String>{'current:liberalismo_classico'});
      expect(restored.studyRecent.length, 12);
      expect(restored.studyRecent.first, 'book:livro_10');
      expect(restored.studyRecent.toSet().length, 12);
      expect(restored.studyComparison, <String>[
        'current:corrente_0',
        'current:corrente_1',
        'current:corrente_2',
      ]);
      expect(
        () => restored.studyFavorites.add('current:other'),
        throwsUnsupportedError,
      );
      await restored.toggleStudyComparison('current:corrente_1');
      await restored.toggleStudyComparison('country:brasil');
      expect(restored.studyComparison.last, 'country:brasil');
      await restored.clearStudyComparison();
      expect((await repository.loadStudyState()).comparison, isEmpty);
    },
  );

  test(
    'limpar histórico preserva estudo e remove referências pessoais',
    () async {
      final AppViewModel vm = AppViewModel(data: data, repository: repository);
      await vm.initialize();
      await vm.toggleStudyFavorite('current:liberalismo');
      await vm.toggleStudyFavorite('evaluation:privado');
      await vm.visitStudySubject('evaluation:privado');
      await vm.visitStudySubject('book:obra');
      await vm.toggleStudyComparison('evaluation:privado');
      await vm.toggleStudyComparison('country:brasil');
      await vm.clearAllHistory();
      final StudyLibraryState stored = await repository.loadStudyState();
      expect(stored.favorites, <String>{'current:liberalismo'});
      expect(stored.recent, <String>['book:obra']);
      expect(stored.comparison, <String>['country:brasil']);
      expect(vm.studyFavorites, stored.favorites);
    },
  );

  test(
    'biblioteca rejeita versão desconhecida e filtra chaves malformadas',
    () async {
      await storage.writeJsonAtomic('study_library.json', <String, Object?>{
        'schemaVersion': 1,
        'favorites': <Object?>[
          'current:ok',
          null,
          '../private',
          3,
          'current:ok',
        ],
        'recent': 'invalid',
        'comparison': List<String>.generate(20, (i) => 'book:$i'),
      });
      final StudyLibraryState state = await repository.loadStudyState();
      expect(state.favorites, <String>{'current:ok'});
      expect(state.recent, isEmpty);
      expect(state.comparison.length, 3);
      await storage.writeJsonAtomic('study_library.json', <String, Object?>{
        'schemaVersion': 999,
        'favorites': <String>['current:unknown'],
      });
      expect((await repository.loadStudyState()).favorites, isEmpty);
    },
  );

  test(
    'falha ao salvar estudo fica explícita e pode ser tentada novamente',
    () async {
      final _FailingStudyStorage failing = _FailingStudyStorage();
      final AppViewModel vm = AppViewModel(
        data: data,
        repository: EvaluationRepository(storage: failing),
      );
      await vm.initialize();
      await vm.toggleStudyFavorite('book:obra');
      expect(vm.studyFavorites, <String>{'book:obra'});
      expect(vm.studyStorageError, contains('Não foi possível salvar'));
      failing.failStudyWrites = false;
      await vm.visitStudySubject('book:obra');
      expect(vm.studyStorageError, isNull);
      final StudyLibraryState saved = await EvaluationRepository(
        storage: failing,
      ).loadStudyState();
      expect(saved.favorites, <String>{'book:obra'});
    },
  );
}

class _FailingStudyStorage extends LocalStorageService {
  _FailingStudyStorage() : super.inMemory();
  bool failStudyWrites = true;

  @override
  Future<void> writeJsonAtomic(
    String relativePath,
    Map<String, Object?> payload,
  ) {
    if (relativePath == 'study_library.json' && failStudyWrites) {
      return Future<void>.error(StateError('storage full'));
    }
    return super.writeJsonAtomic(relativePath, payload);
  }
}
