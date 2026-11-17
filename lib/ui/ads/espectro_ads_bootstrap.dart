import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Bootstrap não-bloqueante de anúncios (portado do Zeen).
///
/// Em Web, o Google AdSense é inicializado de forma assíncrona diretamente via
/// `adsbygoogle.js` no `web/index.html` (`ca-pub-1519935796466095`).
/// Em Android/iOS, o SDK `google_mobile_ads` aguarda o primeiro frame para
/// nunca travar o boot da aplicação.
class EspectroAdsBootstrap {
  EspectroAdsBootstrap._();

  static final EspectroAdsBootstrap instance = EspectroAdsBootstrap._();

  static const bool kAdsDisabled = bool.fromEnvironment('ESPECTRO_NO_ADS');

  final ValueNotifier<bool> adsAllowed = ValueNotifier<bool>(false);
  late final Future<void> _ready = _init();

  Future<void> get ready => _ready;

  bool get _isSupportedMobilePlatform =>
      !kIsWeb &&
      !kAdsDisabled &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<bool> mayLoadAds() async {
    if (!_isSupportedMobilePlatform) return false;
    // Evita inicializar o plugin nativo dentro de `flutter test`
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    if (bindingType.contains('TestWidgetsFlutterBinding') ||
        bindingType.contains('AutomatedTestWidgetsFlutterBinding')) {
      return false;
    }
    await ready;
    return adsAllowed.value;
  }

  Future<void> _init() async {
    if (!_isSupportedMobilePlatform) return;
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    if (bindingType.contains('TestWidgetsFlutterBinding') ||
        bindingType.contains('AutomatedTestWidgetsFlutterBinding')) {
      return;
    }

    await WidgetsBinding.instance.waitUntilFirstFrameRasterized;
    await Future<void>.delayed(const Duration(seconds: 2));

    try {
      await MobileAds.instance.initialize();
      adsAllowed.value = true;
    } catch (e) {
      debugPrint('EspectroAdsBootstrap init skipped: $e');
      adsAllowed.value = false;
    }
  }
}
