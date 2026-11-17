import 'dart:js_interop';

@JS('window.__espectroTrackPageView')
external JSFunction? get _trackPageViewFn;

@JS('window.__espectroTrackEvent')
external JSFunction? get _trackEventFn;

void trackWebPageView({required String title, required String path}) {
  try {
    _trackPageViewFn?.callAsFunction(null, title.toJS, path.toJS);
  } on Object {
    // Analytics bloqueado por extensão do usuário: falha silenciosa.
  }
}

void trackWebEvent(String name, Map<String, Object?> params) {
  try {
    _trackEventFn?.callAsFunction(null, name.toJS, params.jsify());
  } on Object {
    // Falha silenciosa sem afetar a navegação.
  }
}
