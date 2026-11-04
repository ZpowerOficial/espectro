import 'dart:convert';
import 'dart:js_interop';

import 'strict_json.dart';

@JS('globalThis.localStorage')
external _BrowserStorage get _browserStorage;

extension type _BrowserStorage(JSObject _) implements JSObject {
  external int get length;
  external String? key(int index);
  external String? getItem(String key);
  external void setItem(String key, String value);
  external void removeItem(String key);
}

/// JSON durável por origem, sem enviar avaliações a um servidor.
/// Cada setItem substitui integralmente uma chave de forma atômica. A fila
/// preserva a ordem de salvamentos e exclusões, como na implementação nativa.
/// Falhas de permissão ou cota são reportadas, nunca disfarçadas como sucesso.
class LocalStorageService {
  LocalStorageService() : _memoryStore = null;
  LocalStorageService.inMemory() : _memoryStore = <String, String>{};

  static const String namespace = 'espectro/v2/';
  final Map<String, String>? _memoryStore;
  Future<void> _queue = Future<void>.value();

  Future<T> _enqueue<T>(T Function() task) {
    final Future<T> next = _queue.then((_) {
      try {
        return task();
      } on Object catch (error) {
        throw StateError(
          'Não foi possível acessar o armazenamento deste navegador. '
          'Verifique a permissão de dados locais e o espaço disponível. '
          'Detalhe: $error',
        );
      }
    });
    _queue = next.then<void>((_) {}, onError: (_) {});
    return next;
  }

  Future<void> flush() => _queue;

  String _key(String path) {
    if (path.isEmpty ||
        path.startsWith('/') ||
        path.split('/').contains('..')) {
      throw ArgumentError.value(path, 'path', 'Caminho local inválido');
    }
    return '$namespace$path';
  }

  String? _read(String key) =>
      _memoryStore != null ? _memoryStore[key] : _browserStorage.getItem(key);

  Map<String, Object?>? _decode(String? raw, String path) {
    if (raw == null) return null;
    try {
      return readObject(jsonDecode(raw), path);
    } on Object {
      return null;
    }
  }

  Future<void> writeJsonAtomic(
    String relativePath,
    Map<String, Object?> payload,
  ) {
    final String key = _key(relativePath);
    final String raw = jsonEncode(payload);
    return _enqueue<void>(() {
      if (_memoryStore case final Map<String, String> memory) {
        memory[key] = raw;
      } else {
        _browserStorage.setItem(key, raw);
      }
    });
  }

  Future<Map<String, Object?>?> readJsonOrNull(String relativePath) {
    final String key = _key(relativePath);
    return _enqueue(() => _decode(_read(key), relativePath));
  }

  List<String> _keys() {
    if (_memoryStore case final Map<String, String> memory) {
      return memory.keys.toList();
    }
    return <String>[
      for (var i = 0; i < _browserStorage.length; i++)
        if (_browserStorage.key(i) case final String key) key,
    ];
  }

  Future<List<Map<String, Object?>>> listJsonDirectory(String relativeDir) {
    final String prefix = '${_key(relativeDir)}/';
    return _enqueue(
      () => <Map<String, Object?>>[
        for (final String key in _keys())
          if (key.startsWith(prefix) && key.endsWith('.json'))
            if (_decode(_read(key), key) case final Map<String, Object?> value)
              value,
      ],
    );
  }

  Future<void> deleteFileIfExists(String relativePath) {
    final String key = _key(relativePath);
    return _enqueue<void>(() {
      if (_memoryStore case final Map<String, String> memory) {
        memory.remove(key);
      } else {
        _browserStorage.removeItem(key);
      }
    });
  }

  Future<void> wipeAll() => _enqueue<void>(() {
    // Não usa localStorage.clear(): outros aplicativos na origem são preservados.
    for (final String key in _keys().where((k) => k.startsWith(namespace))) {
      if (_memoryStore case final Map<String, String> memory) {
        memory.remove(key);
      } else {
        _browserStorage.removeItem(key);
      }
    }
  });
}
