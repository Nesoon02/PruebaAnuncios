import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/user_session.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-8384147664965505/1804451469'
      : 'ca-app-pub-3940256099942544/2934735716';

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAd() async {
    if (_isLoading || _isLoaded) return;

    _isLoading = true;
    try {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      final double screenWidth = size.width;

      final AnchoredAdaptiveBannerAdSize? adSize =
      await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          screenWidth.truncate());

      if (!mounted || adSize == null) {
        _isLoading = false;
        return;
      }

      _bannerAd = BannerAd(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        size: adSize,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) setState(() { _isLoaded = true; _isLoading = false; });
          },
          onAdFailedToLoad: (ad, err) {
            _isLoading = false;
            ad.dispose();
          },
        ),
      );
      await _bannerAd!.load();
    } catch (e) {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💎 ESTA ES LA ÚNICA VERDAD (Provider)
    final bool isPremiumGlobal = Provider.of<UserSession>(context).isPremium;

    // 🚫 SI ES PREMIUM: Matamos el anuncio y no mostramos nada
    if (isPremiumGlobal) {
      if (_bannerAd != null) {
        _bannerAd!.dispose();
        _bannerAd = null;
        _isLoaded = false;
      }
      return const SizedBox.shrink();
    }

    // 📢 SI NO ES PREMIUM: Cargamos y mostramos
    if (!_isLoaded && !_isLoading) {
      _loadAd();
    }

    if (_bannerAd != null && _isLoaded) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    return const SizedBox.shrink();
  }
}