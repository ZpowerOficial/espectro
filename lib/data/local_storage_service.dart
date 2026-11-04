// Persistência nativa em arquivos e web em localStorage, com a mesma API JSON.
export 'local_storage_native.dart'
    if (dart.library.js_interop) 'local_storage_web.dart';
