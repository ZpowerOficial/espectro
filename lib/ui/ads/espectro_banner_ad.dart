import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../theme.dart';
import 'espectro_ad_units.dart';
import 'espectro_ads_bootstrap.dart';
import 'espectro_web_ad_slot_stub.dart'
    if (dart.library.js_interop) 'espectro_web_ad_slot_web.dart';

/// Barra flutuante não-intrusiva de anúncio ancorada no rodapé das telas.
class EspectroFloatingAdBar extends StatefulWidget {
  const EspectroFloatingAdBar({
    this.adUnitId,
    super.key,
  });

  final String? adUnitId;

  @override
  State<EspectroFloatingAdBar> createState() => _EspectroFloatingAdBarState();
}

class _EspectroFloatingAdBarState extends State<EspectroFloatingAdBar> {
  bool _dismissed = false;

  bool get _isTestBinding {
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    return bindingType.contains('TestWidgetsFlutterBinding') ||
        bindingType.contains('AutomatedTestWidgetsFlutterBinding');
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed || _isTestBinding || EspectroAdsBootstrap.kAdsDisabled) {
      return const SizedBox.shrink();
    }
    final p = context.palette;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final unitId = widget.adUnitId ?? EspectroAdUnits.atlasBannerId;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(color: p.line.withValues(alpha: 0.75)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Row(
            children: [
              Expanded(
                child: EspectroBannerAdWidget(
                  adUnitId: unitId,
                  padding: EdgeInsets.zero,
                  compact: true,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => setState(() => _dismissed = true),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: p.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de Banner Não-Intrusivo do Espectro (Web AdSense + Android/iOS AdMob).
class EspectroBannerAdWidget extends StatefulWidget {
  const EspectroBannerAdWidget({
    required this.adUnitId,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.compact = false,
    super.key,
  });

  final String adUnitId;
  final EdgeInsetsGeometry padding;
  final bool compact;

  @override
  State<EspectroBannerAdWidget> createState() => _EspectroBannerAdWidgetState();
}

class _EspectroBannerAdWidgetState extends State<EspectroBannerAdWidget> {
  static int _webInstanceCounter = 0;
  late final String _webInstanceKey = 'slot_${++_webInstanceCounter}';

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _loading = false;
  bool _triedFallbackTestUnit = false;

  bool get _isTestBinding {
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    return bindingType.contains('TestWidgetsFlutterBinding') ||
        bindingType.contains('AutomatedTestWidgetsFlutterBinding');
  }

  @override
  void initState() {
    super.initState();
    _loadBanner(widget.adUnitId);
  }

  Future<void> _loadBanner(String unitId) async {
    if (kIsWeb || _isTestBinding) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    if (_loading) return;
    _loading = true;
    final allowed = await EspectroAdsBootstrap.instance.mayLoadAds();
    _loading = false;
    if (!mounted || !allowed) return;

    try {
      _bannerAd?.dispose();
      _bannerAd = BannerAd(
        adUnitId: unitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (ad != _bannerAd || !mounted) {
              ad.dispose();
              return;
            }
            setState(() => _isLoaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _bannerAd = null;
            // Se o bloco de produção do Zeen retornar No Fill no package do Espectro
            // antes da vinculação no painel AdMob, faz fallback para o bloco de preenchimento oficial.
            final fallbackUnit = defaultTargetPlatform == TargetPlatform.iOS
                ? EspectroAdUnits.iosBannerTest
                : EspectroAdUnits.androidBannerTest;
            if (!_triedFallbackTestUnit && unitId != fallbackUnit) {
              _triedFallbackTestUnit = true;
              _loadBanner(fallbackUnit);
              return;
            }
            if (mounted) {
              setState(() => _isLoaded = false);
            }
          },
        ),
      )..load();
    } catch (e) {
      debugPrint('EspectroBannerAdWidget init failed: $e');
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTestBinding || EspectroAdsBootstrap.kAdsDisabled) {
      return const SizedBox.shrink();
    }

    final p = context.palette;
    final double barHeight = widget.compact ? 50 : 58;

    if (kIsWeb) {
      return Padding(
        padding: widget.padding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 728),
            child: Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: p.surfaceMuted.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.line.withValues(alpha: 0.65)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Fallback discreto visível enquanto o domínio aguarda aprovação no painel AdSense
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: p.accent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'AD',
                              style: TextStyle(
                                fontFamily: 'IBMPlexMono',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: p.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Espectro · Observatório Político Multidimensional (12 Eixos & 6 Tríades)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: p.inkSoft,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: buildWebAdSenseSlot(
                      publisherId: EspectroAdUnits.publisherId,
                      slotId: EspectroAdUnits.webAdSenseSlotId,
                      height: barHeight,
                      instanceKey: _webInstanceKey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_isLoaded && _bannerAd != null) {
      return Padding(
        padding: widget.padding,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.line),
            ),
            clipBehavior: Clip.antiAlias,
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      );
    }

    // Enquanto o AdMob inicializa (2s pós-boot) ou sem conexão, exibe barra discreta estável
    return Padding(
      padding: widget.padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 728),
          child: Container(
            height: barHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: p.surfaceMuted.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.line.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'AD',
                    style: TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: p.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Espectro · Cartografia Política & Atlas de Ideias',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: p.inkSoft,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
