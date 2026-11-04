@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/evaluation_repository.dart';
import 'package:politico/data/local_storage_service.dart';

@JS('globalThis.localStorage')
external _TestBrowserStorage get _storage;

extension type _TestBrowserStorage(JSObject _) implements JSObject {
  external String? getItem(String key);
  external void setItem(String key, String value);
  external void removeItem(String key);
}

void main() {
  test(
    'web persiste JSON entre instâncias e preserva chaves de outra aplicação',
    () async {
      final LocalStorageService first = LocalStorageService();
      await first.wipeAll();
      _storage.setItem('other-app-test', 'preserve');
      addTearDown(() async {
        await first.wipeAll();
        _storage.removeItem('other-app-test');
      });
      await first.writeJsonAtomic('records/browser.json', <String, Object?>{
        'id': 'browser',
        'nested': <String, Object?>{'answer': 42},
      });
      final LocalStorageService restarted = LocalStorageService();
      expect(
        (await restarted.readJsonOrNull('records/browser.json'))?['id'],
        'browser',
      );
      expect((await restarted.listJsonDirectory('records')).length, 1);
      _storage.setItem('espectro/v2/records/broken.json', '{invalid');
      expect((await restarted.listJsonDirectory('records')).length, 1);
      await restarted.wipeAll();
      expect(await first.readJsonOrNull('records/browser.json'), isNull);
      expect(_storage.getItem('other-app-test'), 'preserve');
    },
  );

  test(
    'web enfileira gravar/apagar e restaura favoritos do repositório',
    () async {
      final LocalStorageService storage = LocalStorageService();
      await storage.wipeAll();
      addTearDown(storage.wipeAll);
      final Future<void> write = storage.writeJsonAtomic(
        'queue.json',
        <String, Object?>{'a': 1},
      );
      final Future<void> delete = storage.deleteFileIfExists('queue.json');
      await Future.wait(<Future<void>>[write, delete]);
      expect(await storage.readJsonOrNull('queue.json'), isNull);
      final EvaluationRepository repo = EvaluationRepository(storage: storage);
      await repo.saveStudyState(
        StudyLibraryState(favorites: <String>['current:teste']),
      );
      final EvaluationRepository restored = EvaluationRepository(
        storage: LocalStorageService(),
      );
      expect((await restored.loadStudyState()).favorites, <String>{
        'current:teste',
      });
    },
  );
}
