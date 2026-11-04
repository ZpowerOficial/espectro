import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'strict_json.dart';

/// Serviço de persistência local em arquivos JSON com escrita atômica e fila serializada.
///
/// Não depende de pacotes externos nem de rede:
/// - No Android obtém `applicationContext.filesDir` via `MethodChannel` nativo.
/// - Em Linux/Desktop usa `$XDG_DATA_HOME/espectro` ou `$HOME/.local/share/espectro`.
/// - Em testes de persistência aceita um [Directory] temporário injetado.
/// - Em testes de widget (`FakeAsync`) oferece [LocalStorageService.inMemory] com a mesma
///   codificação/decodificação JSON estrita sem bloquear descritores de arquivo do SO.
class LocalStorageService {
  LocalStorageService({this.overrideDirectory}) : _memoryStore = null;

  LocalStorageService.inMemory()
    : overrideDirectory = null,
      _memoryStore = <String, String>{};

  static const MethodChannel _channel = MethodChannel(
    'com.espectro.politico/storage',
  );

  final Directory? overrideDirectory;
  final Map<String, String>? _memoryStore;
  Directory? _resolvedRoot;
  Future<void> _queue = Future<void>.value();
  int _tmpSeq = 0;

  /// Enfileira operações de I/O em ordem FIFO para evitar corridas entre rascunhos
  /// salvos em background e exclusões/conclusões imediatas.
  Future<T> _enqueue<T>(Future<T> Function() task) {
    final Future<T> next = _queue.then((_) => task());
    _queue = next.then<void>((_) {}, onError: (_) {});
    return next;
  }

  /// Aguarda todas as operações pendentes na fila terminarem.
  Future<void> flush() => _queue;

  Future<Directory> rootDirectory() async {
    if (overrideDirectory != null) {
      if (!overrideDirectory!.existsSync()) {
        await overrideDirectory!.create(recursive: true);
      }
      return overrideDirectory!;
    }
    if (_resolvedRoot != null) return _resolvedRoot!;

    String? basePath;
    if (Platform.isAndroid) {
      try {
        basePath = await _channel.invokeMethod<String>('getFilesDir');
      } on Object {
        basePath = null;
      }
    }
    if (basePath == null || basePath.isEmpty) {
      final String? xdg = Platform.environment['XDG_DATA_HOME'];
      final String? home = Platform.environment['HOME'];
      if (xdg != null && xdg.isNotEmpty) {
        basePath = '$xdg/espectro';
      } else if (home != null && home.isNotEmpty) {
        basePath = '$home/.local/share/espectro';
      } else {
        basePath = '${Directory.systemTemp.path}/espectro_local';
      }
    }

    final Directory dir = Directory('$basePath/v2');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    _resolvedRoot = dir;
    return dir;
  }

  /// Grava um objeto JSON de forma atômica (`.tmp` exclusivo seguido de `rename`).
  Future<void> writeJsonAtomic(
    String relativePath,
    Map<String, Object?> payload,
  ) {
    final String encoded = const JsonEncoder.withIndent('  ').convert(payload);
    if (_memoryStore != null) {
      _memoryStore[relativePath] = encoded;
      return Future<void>.value();
    }
    return _enqueue<void>(() async {
      final Directory root = await rootDirectory();
      final File target = File('${root.path}/$relativePath');
      if (!target.parent.existsSync()) {
        await target.parent.create(recursive: true);
      }
      final File temp = File('${target.path}.${++_tmpSeq}.tmp');
      await temp.writeAsString(encoded, flush: true);
      await temp.rename(target.path);
    });
  }

  /// Lê um objeto JSON ou devolve `null` caso não exista ou esteja corrompido.
  Future<Map<String, Object?>?> readJsonOrNull(String relativePath) {
    if (_memoryStore != null) {
      final String? content = _memoryStore[relativePath];
      if (content == null) return Future<Map<String, Object?>?>.value(null);
      try {
        return Future<Map<String, Object?>?>.value(
          readObject(jsonDecode(content), relativePath),
        );
      } on Object {
        return Future<Map<String, Object?>?>.value(null);
      }
    }
    return _enqueue<Map<String, Object?>?>(() async {
      final Directory root = await rootDirectory();
      final File file = File('${root.path}/$relativePath');
      if (!file.existsSync()) return null;
      try {
        final String content = await file.readAsString();
        final Object? decoded = jsonDecode(content);
        return readObject(decoded, relativePath);
      } on Object {
        return null;
      }
    });
  }

  /// Lista todos os objetos JSON válidos dentro de uma subpasta.
  Future<List<Map<String, Object?>>> listJsonDirectory(String relativeDir) {
    if (_memoryStore != null) {
      final String prefix = '$relativeDir/';
      final List<Map<String, Object?>> items = <Map<String, Object?>>[];
      for (final MapEntry<String, String> entry in _memoryStore.entries) {
        if (!entry.key.startsWith(prefix) || !entry.key.endsWith('.json')) {
          continue;
        }
        try {
          items.add(readObject(jsonDecode(entry.value), entry.key));
        } on Object {
          // Ignora item corrompido.
        }
      }
      return Future<List<Map<String, Object?>>>.value(items);
    }
    return _enqueue<List<Map<String, Object?>>>(() async {
      final Directory root = await rootDirectory();
      final Directory dir = Directory('${root.path}/$relativeDir');
      if (!dir.existsSync()) return const <Map<String, Object?>>[];
      final List<Map<String, Object?>> items = <Map<String, Object?>>[];
      await for (final FileSystemEntity entity in dir.list()) {
        if (entity is! File || !entity.path.endsWith('.json')) continue;
        try {
          final String content = await entity.readAsString();
          final Object? decoded = jsonDecode(content);
          items.add(readObject(decoded, entity.path));
        } on Object {
          // Ignora arquivo individual corrompido sem derrubar o app.
        }
      }
      return items;
    });
  }

  Future<void> deleteFileIfExists(String relativePath) {
    if (_memoryStore != null) {
      _memoryStore.remove(relativePath);
      return Future<void>.value();
    }
    return _enqueue<void>(() async {
      final Directory root = await rootDirectory();
      final File file = File('${root.path}/$relativePath');
      if (file.existsSync()) {
        await file.delete();
      }
    });
  }

  Future<void> wipeAll() {
    if (_memoryStore != null) {
      _memoryStore.clear();
      return Future<void>.value();
    }
    return _enqueue<void>(() async {
      final Directory root = await rootDirectory();
      if (root.existsSync()) {
        await root.delete(recursive: true);
        await root.create(recursive: true);
      }
    });
  }
}
