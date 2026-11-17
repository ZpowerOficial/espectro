import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

@JS('document.createElement')
external _DomElement _createElement(String tagName);

@JS('window.setTimeout')
external int _setTimeout(JSFunction callback, int delayMs);

@JS('window.adsbygoogle')
external JSArray<JSObject>? get _adsByGoogle;

@JS('window.adsbygoogle')
external set _adsByGoogle(JSArray<JSObject>? value);

extension type _DomElement(JSObject _) implements JSObject {
  external _DomStyle get style;
  external int get offsetWidth;
  external void setAttribute(String name, String value);
  external void appendChild(_DomElement child);
}

extension type _DomStyle(JSObject _) implements JSObject {
  external set display(String value);
  external set width(String value);
  external set minWidth(String value);
  external set height(String value);
  external set overflow(String value);
  external set textAlign(String value);
}

final Set<String> _registeredViewTypes = <String>{};

Widget buildWebAdSenseSlot({
  required String publisherId,
  required String slotId,
  required double height,
  String? instanceKey,
}) {
  final cleanSlot = slotId.contains('/') ? slotId.split('/').last : slotId;
  final suffix = instanceKey ?? cleanSlot;
  final viewType = 'espectro-adsense-$cleanSlot-$suffix';

  if (_registeredViewTypes.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final wrapper = _createElement('div');
      wrapper.style.width = '100%';
      wrapper.style.minWidth = '300px';
      wrapper.style.height = '${height.round()}px';
      wrapper.style.overflow = 'hidden';
      wrapper.style.textAlign = 'center';

      final ins = _createElement('ins');
      ins.setAttribute('class', 'adsbygoogle');
      ins.style.display = 'block';
      ins.style.width = '100%';
      ins.style.height = '${height.round()}px';
      ins.setAttribute('data-ad-client', publisherId);
      ins.setAttribute('data-ad-slot', cleanSlot);
      ins.setAttribute('data-ad-format', 'auto');
      ins.setAttribute('data-full-width-responsive', 'true');
      wrapper.appendChild(ins);

      void tryPush([int attempt = 0]) {
        try {
          if (wrapper.offsetWidth <= 0 && attempt < 6) {
            _setTimeout((() => tryPush(attempt + 1)).toJS, 250);
            return;
          }
          final queue = _adsByGoogle ?? JSArray<JSObject>();
          _adsByGoogle = queue;
          queue.add(JSObject());
        } on Object {
          // Adblocker ou script ainda carregando: falha silenciosa sem quebrar a UI.
        }
      }

      _setTimeout((() => tryPush(0)).toJS, 200);
      return wrapper;
    });
  }

  return SizedBox(
    width: double.infinity,
    height: height,
    child: HtmlElementView(viewType: viewType),
  );
}
