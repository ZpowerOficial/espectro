import 'dart:js_interop';
import 'dart:math' as math;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

import 'espectro_ad_state.dart';

@JS('document.createElement')
external _DomElement _createElement(String tagName);

@JS('document.querySelector')
external _DomElement? _querySelector(String selector);

@JS('window.navigator.onLine')
external bool get _navigatorOnLine;

@JS('window.setTimeout')
external int _setTimeout(JSFunction callback, int delayMs);

@JS('window.clearTimeout')
external void _clearTimeout(int timerId);

extension type _AdsByGoogleQueue._(JSObject _) implements JSObject {
  external int push(JSObject item);
}

@JS('window.adsbygoogle')
external _AdsByGoogleQueue? get _adsByGoogle;

@JS('window.adsbygoogle')
external set _adsByGoogle(_AdsByGoogleQueue? value);

@JS('MutationObserver')
extension type _MutationObserver._(JSObject _) implements JSObject {
  external factory _MutationObserver(JSFunction callback);
  external void observe(_DomElement target, JSAny options);
  external void disconnect();
}

extension type _DomRect(JSObject _) implements JSObject {
  external double get height;
}

extension type _DomElement(JSObject _) implements JSObject {
  external _DomStyle get style;
  external int get offsetWidth;
  external int get offsetHeight;
  external String? getAttribute(String name);
  external void setAttribute(String name, String value);
  external void appendChild(_DomElement child);
  external _DomElement? querySelector(String selector);
  external _DomRect getBoundingClientRect();
}

extension type _DomStyle(JSObject _) implements JSObject {
  external set display(String value);
  external set width(String value);
  external set minWidth(String value);
  external set height(String value);
  external set background(String value);
  external set border(String value);
  external set margin(String value);
  external set padding(String value);
  external set overflow(String value);
  external set textAlign(String value);
}

final Set<String> _registeredViewTypes = <String>{};

Widget buildWebAdSenseSlot({
  required String publisherId,
  required String slotId,
  required String instanceKey,
  required WebAdStatusCallback onStatusChanged,
}) => _WebAdSenseSlot(
  publisherId: publisherId,
  slotId: slotId,
  instanceKey: instanceKey,
  onStatusChanged: onStatusChanged,
);

class _WebAdSenseSlot extends StatefulWidget {
  const _WebAdSenseSlot({
    required this.publisherId,
    required this.slotId,
    required this.instanceKey,
    required this.onStatusChanged,
  });

  final String publisherId;
  final String slotId;
  final String instanceKey;
  final WebAdStatusCallback onStatusChanged;

  @override
  State<_WebAdSenseSlot> createState() => _WebAdSenseSlotState();
}

class _WebAdSenseSlotState extends State<_WebAdSenseSlot> {
  late final String _cleanSlot = widget.slotId.contains('/')
      ? widget.slotId.split('/').last
      : widget.slotId;
  late final String _viewType = 'espectro-adsense-$_cleanSlot-${widget.instanceKey}';

  _MutationObserver? _observer;
  int? _pushTimer;
  int? _timeoutTimer;
  bool _disposed = false;
  EspectroAdSlotStatus? _lastStatus;
  double _lastHeight = -1;

  @override
  void initState() {
    super.initState();
    if (_registeredViewTypes.add(_viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final wrapper = _createElement('div');
        wrapper.style.width = '100%';
        wrapper.style.minWidth = '280px';
        wrapper.style.height = 'auto';
        wrapper.style.background = 'transparent';
        wrapper.style.border = '0';
        wrapper.style.margin = '0';
        wrapper.style.padding = '0';
        wrapper.style.overflow = 'visible';
        wrapper.style.textAlign = 'center';

        final ins = _createElement('ins');
        ins.setAttribute('class', 'adsbygoogle');
        ins.style.display = 'block';
        ins.style.width = '100%';
        ins.style.height = 'auto';
        ins.style.background = 'transparent';
        ins.setAttribute('data-ad-client', widget.publisherId);
        ins.setAttribute('data-ad-slot', _cleanSlot);
        ins.setAttribute('data-ad-format', 'auto');
        ins.setAttribute('data-full-width-responsive', 'true');
        wrapper.appendChild(ins);

        void syncDomState() {
          if (_disposed) return;
          final rawStatus = ins.getAttribute('data-ad-status');
          final parsed = parseWebAdStatus(rawStatus);
          final iframeRectH =
              ins.querySelector('iframe')?.getBoundingClientRect().height ?? 0.0;
          final insRectH = ins.getBoundingClientRect().height;
          final domH = math.max(
            ins.offsetHeight.toDouble(),
            math.max(iframeRectH, insRectH),
          );

          if (parsed == EspectroAdSlotStatus.unfilled) {
            ins.style.display = 'none';
            wrapper.style.display = 'none';
            _cancelTimeout();
            _emit(EspectroAdSlotStatus.unfilled, 0.0);
            return;
          }

          if (parsed == EspectroAdSlotStatus.unfillOptimized) {
            // Nunca aplicar display: none em unfill-optimized para respeitar a
            // otimização oficial do Google AdSense.
            wrapper.style.display = 'block';
            ins.style.display = 'block';
            _cancelTimeout();
            final double normalizedH = domH >= 20.0 ? domH.clamp(50.0, 320.0) : 0.0;
            _emit(EspectroAdSlotStatus.unfillOptimized, normalizedH);
            return;
          }

          if (parsed == EspectroAdSlotStatus.filled) {
            wrapper.style.display = 'block';
            ins.style.display = 'block';
            _cancelTimeout();
            final double normalizedH = domH >= 20.0 ? domH.clamp(50.0, 320.0) : 100.0;
            _emit(EspectroAdSlotStatus.filled, normalizedH);
          }
        }

        _observer?.disconnect();
        _observer = _MutationObserver(
          ((JSAny records, _MutationObserver observer) => syncDomState()).toJS,
        );
        _observer!.observe(
          ins,
          <String, Object?>{
            'attributes': true,
            'attributeFilter': <String>[
              'data-ad-status',
              'data-adsbygoogle-status',
              'style',
            ],
            'childList': true,
            'subtree': true,
          }.jsify()!,
        );

        void tryPush([int attempt = 0]) {
          if (_disposed) return;
          if (parseWebAdStatus(ins.getAttribute('data-ad-status')) !=
              EspectroAdSlotStatus.loading) {
            syncDomState();
            return;
          }
          if (!_navigatorOnLine) {
            _emit(EspectroAdSlotStatus.unavailable, 0.0);
            return;
          }
          if (attempt == 0 &&
              _querySelector('script[src*="adsbygoogle.js"]') == null &&
              _adsByGoogle == null) {
            _emit(EspectroAdSlotStatus.unavailable, 0.0);
            return;
          }
          try {
            if (wrapper.offsetWidth <= 0 && attempt < 8) {
              _pushTimer = _setTimeout((() => tryPush(attempt + 1)).toJS, 250);
              return;
            }
            if (wrapper.offsetWidth <= 0) {
              _emit(EspectroAdSlotStatus.unavailable, 0.0);
              return;
            }
            final _AdsByGoogleQueue queue =
                _adsByGoogle ?? _AdsByGoogleQueue._(JSArray<JSObject>());
            _adsByGoogle = queue;
            queue.push(JSObject());
            syncDomState();

            _timeoutTimer = _setTimeout((() {
              if (_disposed) return;
              final statusNow = parseWebAdStatus(ins.getAttribute('data-ad-status'));
              if (statusNow == EspectroAdSlotStatus.loading) {
                ins.style.display = 'none';
                wrapper.style.display = 'none';
                _emit(EspectroAdSlotStatus.unavailable, 0.0);
              } else {
                syncDomState();
              }
            }).toJS, 5000);
          } on Object {
            _emit(EspectroAdSlotStatus.unavailable, 0.0);
          }
        }

        _pushTimer = _setTimeout((() => tryPush(0)).toJS, 160);
        return wrapper;
      });
    }
  }

  void _emit(EspectroAdSlotStatus status, double height) {
    if (_disposed) return;
    if (_lastStatus == status && (_lastHeight - height).abs() < 0.5) return;
    _lastStatus = status;
    _lastHeight = height;
    widget.onStatusChanged(status, height);
  }

  void _cancelTimeout() {
    final timer = _timeoutTimer;
    if (timer != null) {
      _clearTimeout(timer);
      _timeoutTimer = null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    final pushTimer = _pushTimer;
    if (pushTimer != null) {
      _clearTimeout(pushTimer);
      _pushTimer = null;
    }
    _cancelTimeout();
    _observer?.disconnect();
    _observer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
