import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config.dart';

/// Where a banner may appear. Only "after the fun" screens: never the quiz
/// itself, and never inside the scorecard image people share.
enum AdPlacement { result, history }

abstract class AdsService {
  /// Resolves consent (GDPR form where required) and then starts the ad SDK.
  /// Safe to call more than once; never throws.
  Future<void> init();

  /// True once ads may be requested. Banners appear when this flips.
  ValueListenable<bool> get ready;

  /// True when the user must be offered a way to change their consent
  /// (EEA/UK). The About screen shows a "Privacy & ad choices" entry then.
  Future<bool> privacyOptionsRequired();

  Future<void> showPrivacyOptions();

  /// A self-sizing banner for [placement], or an empty box when there is
  /// nothing to show (not ready, no fill, no ad unit configured).
  Widget banner(AdPlacement placement);
}

/// Shows nothing — used in tests and as the safe fallback.
class NoopAdsService implements AdsService {
  final ValueNotifier<bool> _ready = ValueNotifier(false);

  @override
  Future<void> init() async {}

  @override
  ValueListenable<bool> get ready => _ready;

  @override
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}

  @override
  Widget banner(AdPlacement placement) => const SizedBox.shrink();
}

/// Google AdMob, with Google's User Messaging Platform for consent.
///
/// Ad content is capped at "T" (teen) because the app is rated 13+.
class AdMobAdsService implements AdsService {
  final ValueNotifier<bool> _ready = ValueNotifier(false);
  Future<void>? _init;

  @override
  ValueListenable<bool> get ready => _ready;

  @override
  Future<void> init() => _init ??= _start();

  Future<void> _start() async {
    try {
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          updated.complete();
        },
        // Offline or misconfigured: fall back to whatever consent the user
        // gave last time (canRequestAds below decides).
        (_) => updated.complete(),
      );
      await updated.future;

      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(maxAdContentRating: MaxAdContentRating.t),
      );
      await MobileAds.instance.initialize();
      _ready.value = true;
    } catch (e) {
      // Ads are a nice-to-have; the app must work without them.
      debugPrint('Ads disabled: $e');
    }
  }

  @override
  Future<bool> privacyOptionsRequired() async {
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> showPrivacyOptions() =>
      ConsentForm.showPrivacyOptionsForm((_) {});

  @override
  Widget banner(AdPlacement placement) {
    final unitId = bannerAdUnitId(placement);
    if (unitId.isEmpty) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: _ready,
      builder: (context, ready, _) => ready
          ? _AdaptiveBanner(key: ValueKey(placement), unitId: unitId)
          : const SizedBox.shrink(),
    );
  }
}

/// Google's sample banner unit — serves "Test Ad" creatives, never revenue.
const String _testBannerUnitId = 'ca-app-pub-3940256099942544/9214589741';

/// Debug builds always use Google's test unit (clicking real ads in testing
/// gets AdMob accounts suspended). Release builds use the real unit, or
/// nothing at all if it hasn't been configured.
String bannerAdUnitId(AdPlacement placement, {bool release = kReleaseMode}) {
  if (!release) return _testBannerUnitId;
  return switch (placement) {
    AdPlacement.result => admobBannerResultUnitId,
    AdPlacement.history => admobBannerHistoryUnitId,
  };
}

/// Anchored adaptive banner sized to the screen width. Takes no space until
/// an ad has actually loaded, and disappears again on no-fill.
class _AdaptiveBanner extends StatefulWidget {
  const _AdaptiveBanner({super.key, required this.unitId});

  final String unitId;

  @override
  State<_AdaptiveBanner> createState() => _AdaptiveBannerState();
}

class _AdaptiveBannerState extends State<_AdaptiveBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    _load(MediaQuery.sizeOf(context).width.truncate());
  }

  Future<void> _load(int width) async {
    final size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) return;
    final ad = BannerAd(
      adUnitId: widget.unitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
