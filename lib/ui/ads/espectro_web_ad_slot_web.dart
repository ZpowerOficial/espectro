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

@JS('window.innerHeight')
external int get _windowInnerHeight;

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

@JS('IntersectionObserver')
extension type _IntersectionObserver._(JSObject _) implements JSObject {
  external factory _IntersectionObserver(
    JSFunction callback, [
    JSAny? options,
  ]);
  external void observe(_DomElement target);
  external void disconnect();
}

extension type _IntersectionEntry._(JSObject _) implements JSObject {
  external bool get isIntersecting;
}

extension type _DomRect._(JSObject _) implements JSObject {
  external double get top;
  external double get bottom;
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
  _IntersectionObserver? _intersectionObserver;
  int? _pushTimer;
  int? _timeoutTimer;
  int? _resyncTimer1;
  int? _resyncTimer2;
  bool _disposed = false;
  bool _pushed = false;
  bool _nearViewport = false;
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

        late void Function() syncDomState;

        void scheduleFollowUpResync() {
          _resyncTimer1 ??= _setTimeout((() {
            _resyncTimer1 = null;
            syncDomState();
          }).toJS, 350);
          _resyncTimer2 ??= _setTimeout((() {
            _resyncTimer2 = null;
            syncDomState();
          }).toJS, 1100);
        }

        syncDomState = () {
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
            _cancelResyncTimers();
            _emit(EspectroAdSlotStatus.unfilled, 0.0);
            return;
          }

          if (parsed == EspectroAdSlotStatus.unfillOptimized) {
            // Nunca aplicar display: none em unfill-optimized para respeitar a
            // otimização oficial do Google AdSense.
            wrapper.style.display = 'block';
            ins.style.display = 'block';
            _cancelTimeout();
            final double normalizedH =
                domH >= 20.0 ? domH.clamp(50.0, 320.0) : 0.0;
            _emit(EspectroAdSlotStatus.unfillOptimized, normalizedH);
            scheduleFollowUpResync();
            return;
          }

          if (parsed == EspectroAdSlotStatus.filled) {
            wrapper.style.display = 'block';
            ins.style.display = 'block';
            _cancelTimeout();
            final double normalizedH =
                domH >= 20.0 ? domH.clamp(50.0, 320.0) : 100.0;
            _emit(EspectroAdSlotStatus.filled, normalizedH);
            scheduleFollowUpResync();
          }
        };

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
              'height',
            ],
            'childList': true,
            'subtree': true,
          }.jsify()!,
        );

        bool isWrapperNearViewport() {
          if (wrapper.offsetWidth <= 0) return false;
          final rect = wrapper.getBoundingClientRect();
          return rect.bottom >= -250.0 &&
              rect.top <= (_windowInnerHeight + 250.0);
        }

        void tryPush([int attempt = 0]) {
          if (_disposed || _pushed) return;
          if (parseWebAdStatus(ins.getAttribute('data-ad-status')) !=
              EspectroAdSlotStatus.loading) {
            syncDomState();
            return;
          }
          if (!_nearViewport) {
            if (isWrapperNearViewport()) {
              _nearViewport = true;
              _intersectionObserver?.disconnect();
              _intersectionObserver = null;
            } else {
              // Slots fora da viewport pré-montados pelo cacheExtent do ListView
              // aguardam o scroll via IntersectionObserver sem erro prematuro.
              return;
            }
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
            if (wrapper.offsetWidth < 200 && attempt < 12) {
              _pushTimer = _setTimeout((() => tryPush(attempt + 1)).toJS, 250);
              return;
            }
            if (wrapper.offsetWidth < 200) {
              _emit(EspectroAdSlotStatus.unavailable, 0.0);
              return;
            }
            _pushed = true;
            final _AdsByGoogleQueue queue =
                _adsByGoogle ?? _AdsByGoogleQueue._(JSArray<JSObject>());
            _adsByGoogle = queue;
            queue.push(JSObject());
            syncDomState();

            _timeoutTimer = _setTimeout((() {
              if (_disposed) return;
              final statusNow = parseWebAdStatus(
                ins.getAttribute('data-ad-status'),
              );
              final bool agDone =
                  ins.getAttribute('data-adsbygoogle-status') == 'done';
              if (statusNow != EspectroAdSlotStatus.loading) {
                syncDomState();
              } else if (!agDone) {
                ins.style.display = 'none';
                wrapper.style.display = 'none';
                _emit(EspectroAdSlotStatus.unavailable, 0.0);
              }
            }).toJS, 15000);
          } on Object {
            _emit(EspectroAdSlotStatus.unavailable, 0.0);
          }
        }

        void probeViewport([int waitLayoutAttempt = 0]) {
          if (_disposed || _pushed) return;
          if (_nearViewport || isWrapperNearViewport()) {
            _nearViewport = true;
            _intersectionObserver?.disconnect();
            _intersectionObserver = null;
            tryPush(0);
            return;
          }
          if (wrapper.offsetWidth <= 0 && waitLayoutAttempt < 8) {
            _pushTimer = _setTimeout(
              (() => probeViewport(waitLayoutAttempt + 1)).toJS,
              250,
            );
          }
        }

        _intersectionObserver?.disconnect();
        try {
          _intersectionObserver = _IntersectionObserver(
            ((
              JSArray<_IntersectionEntry> entries,
              _IntersectionObserver obs,
            ) {
              if (_disposed || _pushed) return;
              if (entries.toDart.any((e) => e.isIntersecting)) {
                _nearViewport = true;
                obs.disconnect();
                _intersectionObserver = null;
                tryPush(0);
              }
            }).toJS,
            <String, Object?>{
              'rootMargin': '250px 0px',
              'threshold': 0.0,
            }.jsify(),
          );
          _intersectionObserver!.observe(wrapper);
        } on Object {
          _nearViewport = true;
        }

        _pushTimer = _setTimeout((() => probeViewport(0)).toJS, 160);
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

  void _cancelResyncTimers() {
    final t1 = _resyncTimer1;
    if (t1 != null) {
      _clearTimeout(t1);
      _resyncTimer1 = null;
    }
    final t2 = _resyncTimer2;
    if (t2 != null) {
      _clearTimeout(t2);
      _resyncTimer2 = null;
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
    _cancelResyncTimers();
    _observer?.disconnect();
    _observer = null;
    _intersectionObserver?.disconnect();
    _intersectionObserver = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _viewType);
}
