import 'package:flutter/widgets.dart';

import 'espectro_analytics_stub.dart'
    if (dart.library.js_interop) 'espectro_analytics_web.dart';

/// Telemetria agregada de navegação e uso no Google Analytics 4 (`G-XP4L3LL18B`).
/// Nunca envia respostas individuais, opiniões políticas ou dados pessoais.
abstract final class EspectroAnalytics {
  static void trackPageView({required String title, required String path}) {
    trackWebPageView(title: title, path: path);
  }

  static void trackEvent(String name, [Map<String, Object?> params = const {}]) {
    trackWebEvent(name, params);
  }
}

class EspectroAnalyticsObserver extends NavigatorObserver {
  void _record(Route<dynamic>? route) {
    if (route is! PageRoute<dynamic>) return;
    final rawName = route.settings.name;
    final path = (rawName == null || rawName.isEmpty) ? '/' : rawName;
    final title = path == '/'
        ? 'Espectro — Início'
        : 'Espectro · ${path.replaceFirst('/', '')}';
    EspectroAnalytics.trackPageView(title: title, path: path);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _record(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _record(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _record(newRoute);
  }
}
