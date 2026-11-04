import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:politico/data/app_data.dart';
import 'package:politico/data/local_storage_service.dart';
import 'package:politico/main.dart';
import 'package:politico/ui/view_models/app_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppData data;
  setUpAll(() async {
    data = await AppData.load();
  });

  test(
    'armazenamento indisponível mantém catálogo acessível com aviso permanente',
    () async {
      final _DeniedStorage denied = _DeniedStorage();
      final AppViewModel vm = await initializeAppViewModel(
        data: data,
        storage: denied,
      );
      addTearDown(vm.dispose);
      expect(vm.initialized, isTrue);
      expect(identical(vm.data, data), isTrue);
      expect(vm.data.catalog.currents, isNotEmpty);
      expect(vm.storageNotice, contains('Modo temporário'));
      expect(vm.storageNotice, contains('não persistem'));
      await vm.toggleStudyFavorite('current:liberalismo');
      await vm.setThemeMode(ThemeMode.dark);
      expect(vm.studyFavorites, <String>{'current:liberalismo'});
      expect(vm.themeMode, ThemeMode.dark);
      expect(vm.studyStorageError, isNull);
      expect(vm.storageNotice, isNotNull);
      expect(denied.writes, 0);
      expect(denied.wipes, 0);
      // Uma nova sessão não apresenta os dados temporários como persistidos.
      final AppViewModel restarted = await initializeAppViewModel(
        data: data,
        storage: denied,
      );
      addTearDown(restarted.dispose);
      expect(restarted.studyFavorites, isEmpty);
      expect(restarted.storageNotice, isNotNull);
    },
  );

  test('sessão durável usa repositório original e não mostra aviso de contingência', () async {
    final LocalStorageService storage = LocalStorageService.inMemory();
    final AppViewModel first = await initializeAppViewModel(
      data: data,
      storage: storage,
    );
    addTearDown(first.dispose);
    await first.toggleStudyFavorite('book:obra');
    final AppViewModel restored = await initializeAppViewModel(
      data: data,
      storage: storage,
    );
    addTearDown(restored.dispose);
    expect(restored.studyFavorites, <String>{'book:obra'});
    expect(restored.storageNotice, isNull);
  });
}

class _DeniedStorage extends LocalStorageService {
  _DeniedStorage() : super.inMemory();
  int writes = 0;
  int wipes = 0;

  @override
  Future<Map<String, Object?>?> readJsonOrNull(String relativePath) =>
      Future<Map<String, Object?>?>.error(
        StateError('SecurityError: storage blocked'),
      );

  @override
  Future<void> writeJsonAtomic(
    String relativePath,
    Map<String, Object?> payload,
  ) {
    writes++;
    return Future<void>.error(StateError('SecurityError: storage blocked'));
  }

  @override
  Future<void> wipeAll() {
    wipes++;
    return Future<void>.error(StateError('SecurityError: storage blocked'));
  }
}
