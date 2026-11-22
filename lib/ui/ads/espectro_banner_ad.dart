import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../theme.dart';
import 'espectro_ad_state.dart';
import 'espectro_ad_units.dart';
import 'espectro_ads_bootstrap.dart';
import 'espectro_web_ad_slot_stub.dart'
    if (dart.library.js_interop) 'espectro_web_ad_slot_web.dart';

/// Bloco inline de publicidade posicionado entre seções editoriais naturais.
///
/// Regras de conformidade e experiência:
/// - Nunca é montado no fluxo de perguntas do questionário nem colado à barra
///   inferior de navegação.
/// - Slots `unfilled` ou `unavailable` recolhem integralmente a `0 px`
///   (`SizedBox.shrink`), sem caixas vazias nem rotulagem enganosa própria.
/// - Slots Web `unfill-optimized` preservam o comportamento oficial do AdSense
///   (nunca recebem `display: none` forçado).
class EspectroInlineAdSlot extends StatefulWidget {
  const EspectroInlineAdSlot({
    required this.placementId,
    this.adUnitId,
    this.webSlotId,
    this.verticalMargin = 24.0,
    this.maxWidth = 728.0,
    this.testStatusOverride,
    this.testObservedHeight,
    super.key,
  });

  final String placementId;
  final String? adUnitId;
  final String? webSlotId;
  final double verticalMargin;
  final double maxWidth;

  /// Usado exclusivamente em testes de widget para verificar os estados
  /// `filled`, `unfilled`, `unfillOptimized` e `unavailable`.
  final EspectroAdSlotStatus? testStatusOverride;
  final double? testObservedHeight;

  @override
  State<EspectroInlineAdSlot> createState() => _EspectroInlineAdSlotState();
}

class _EspectroInlineAdSlotState extends State<EspectroInlineAdSlot> {
  static int _webInstanceCounter = 0;

  late final String _webInstanceKey =
      '${widget.placementId}_${++_webInstanceCounter}';

  BannerAd? _bannerAd;
  bool _loadingNative = false;
  late EspectroAdSlotStatus _status =
      widget.testStatusOverride ?? EspectroAdSlotStatus.loading;
  late double _observedHeight = widget.testObservedHeight ?? 0.0;

  bool get _isTestBinding {
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    return bindingType.contains('TestWidgetsFlutterBinding') ||
        bindingType.contains('AutomatedTestWidgetsFlutterBinding');
  }

  @override
  void initState() {
    super.initState();
    if (widget.testStatusOverride != null) return;
    if (!kIsWeb && !_isTestBinding && !EspectroAdsBootstrap.kAdsDisabled) {
      _loadNativeBanner(widget.adUnitId ?? EspectroAdUnits.atlasBannerId);
    }
  }

  @override
  void didUpdateWidget(covariant EspectroInlineAdSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.testStatusOverride != oldWidget.testStatusOverride ||
        widget.testObservedHeight != oldWidget.testObservedHeight) {
      if (widget.testStatusOverride != null) {
        _status = widget.testStatusOverride!;
        _observedHeight = widget.testObservedHeight ?? 0.0;
      }
    }
  }

  void _onWebStatusChanged(EspectroAdSlotStatus nextStatus, double height) {
    if (!mounted) return;
    if (_status == nextStatus && (_observedHeight - height).abs() < 0.5) return;
    setState(() {
      _status = nextStatus;
      _observedHeight = height;
    });
  }

  Future<void> _loadNativeBanner(String unitId) async {
    if (kIsWeb || _isTestBinding || EspectroAdsBootstrap.kAdsDisabled) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      if (mounted) {
        setState(() {
          _status = EspectroAdSlotStatus.unavailable;
          _observedHeight = 0.0;
        });
      }
      return;
    }
    if (_loadingNative) return;
    _loadingNative = true;
    final allowed = await EspectroAdsBootstrap.instance.mayLoadAds();
    _loadingNative = false;
    if (!mounted) return;
    if (!allowed) {
      setState(() {
        _status = EspectroAdSlotStatus.unavailable;
        _observedHeight = 0.0;
      });
      return;
    }

    try {
      _bannerAd?.dispose();
      _bannerAd = BannerAd(
        adUnitId: unitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            if (ad != _bannerAd || !mounted) {
              ad.dispose();
              return;
            }
            setState(() {
              _status = EspectroAdSlotStatus.filled;
              _observedHeight = _bannerAd!.size.height.toDouble();
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            _bannerAd = null;
            if (mounted) {
              setState(() {
                _status = EspectroAdSlotStatus.unfilled;
                _observedHeight = 0.0;
              });
            }
          },
        ),
      )..load();
    } catch (e) {
      debugPrint('EspectroInlineAdSlot init failed: $e');
      if (mounted) {
        setState(() {
          _status = EspectroAdSlotStatus.unavailable;
          _observedHeight = 0.0;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (EspectroAdsBootstrap.kAdsDisabled) {
      return const SizedBox.shrink();
    }
    if (_isTestBinding && widget.testStatusOverride == null) {
      return const SizedBox.shrink();
    }

    if (_status == EspectroAdSlotStatus.unfilled ||
        _status == EspectroAdSlotStatus.unavailable) {
      return const SizedBox.shrink();
    }

    final EspectroPalette p = context.palette;
    final bool hasTestOverride = widget.testStatusOverride != null;
    final bool hasDisplayableHeight = _observedHeight >= 20.0;
    final bool showVisibleFrame = switch (_status) {
      EspectroAdSlotStatus.filled => hasDisplayableHeight || !kIsWeb,
      EspectroAdSlotStatus.unfillOptimized => hasDisplayableHeight,
      _ => false,
    };

    if (!kIsWeb && !hasTestOverride) {
      if (_status != EspectroAdSlotStatus.filled || _bannerAd == null) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.symmetric(vertical: widget.verticalMargin),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Publicidade',
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: p.muted,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Container(
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
            ],
          ),
        ),
      );
    }

    if (hasTestOverride && !showVisibleFrame) {
      return const SizedBox.shrink();
    }

    final Widget slotChild = hasTestOverride
        ? Container(
            key: ValueKey<String>('ad-test-surface-${widget.placementId}'),
            decoration: BoxDecoration(
              color: p.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.line),
            ),
          )
        : buildWebAdSenseSlot(
            publisherId: EspectroAdUnits.publisherId,
            slotId: widget.webSlotId ?? EspectroAdUnits.webAdSenseSlotId,
            instanceKey: _webInstanceKey,
            onStatusChanged: _onWebStatusChanged,
          );

    final double renderedHeight = showVisibleFrame
        ? (_observedHeight >= 20.0 ? _observedHeight : 50.0)
        : 1.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: showVisibleFrame ? widget.verticalMargin : 0.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (showVisibleFrame) ...<Widget>[
                Text(
                  'Publicidade',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: p.muted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              SizedBox(
                width: double.infinity,
                height: renderedHeight,
                child: slotChild,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
