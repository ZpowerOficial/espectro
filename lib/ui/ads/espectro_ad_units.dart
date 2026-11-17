import 'package:flutter/foundation.dart';

/// Identificadores Google AdMob / AdSense compartilhados com a conta Zeen (`pub-1519935796466095`).
class EspectroAdUnits {
  EspectroAdUnits._();

  static const String publisherId = 'ca-pub-1519935796466095';
  static const String webAdSenseSlotId = '8975287447';
  static const String appId = 'ca-app-pub-1519935796466095~1117614814';

  static const String feedNativeProduction =
      'ca-app-pub-1519935796466095/9537574045';
  static const String atlasBannerProduction =
      'ca-app-pub-1519935796466095/2941832373';
  static const String detailBannerProduction =
      'ca-app-pub-1519935796466095/5376424025';

  // IDs de teste oficiais do Google AdMob para debug local
  static const String androidBannerTest =
      'ca-app-pub-3940256099942544/9214589741';
  static const String iosBannerTest = 'ca-app-pub-3940256099942544/2435281174';

  static String get atlasBannerId {
    if (kDebugMode && !kIsWeb) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? iosBannerTest
          : androidBannerTest;
    }
    return atlasBannerProduction;
  }

  static String get detailBannerId {
    if (kDebugMode && !kIsWeb) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? iosBannerTest
          : androidBannerTest;
    }
    return detailBannerProduction;
  }
}
