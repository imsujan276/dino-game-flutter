import 'dart:io';

import 'package:dino_runner/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobBannerAdWidget extends StatefulWidget {
  const AdmobBannerAdWidget({Key? key}) : super(key: key);

  @override
  _AdmobBannerAdWidgetState createState() => _AdmobBannerAdWidgetState();
}

class _AdmobBannerAdWidgetState extends State<AdmobBannerAdWidget> {
  /// check if the ads is loading or not
  bool loadingAnchoredBanner = false;

  ///banner ad variable
  BannerAd? anchoredBanner;

  /// adrequest object
  static const AdRequest request = AdRequest(
    keywords: <String>[
      'game',
      'dino game',
      'casual games',
      'offline',
    ],
    nonPersonalizedAds: true,
  );

  @override
  void initState() {
    super.initState();
  }

  /// Load admob ads
  Future<void> loadAd() async {
    loadingAnchoredBanner = true;
    if (Platform.isAndroid) createAnchoredBanner(context);
  }

  /// create banner ad
  Future<void> createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: request,
      adUnitId: bannerAdAndroid,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            anchoredBanner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    );
    return banner.load();
  }

  @override
  void dispose() {
    if (anchoredBanner != null) anchoredBanner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Container();
    return Builder(builder: (BuildContext context) {
      if (!loadingAnchoredBanner) {
        loadAd();
        loadingAnchoredBanner = true;
      }
      return Container(
        child: (anchoredBanner != null)
            ? Container(
                margin: const EdgeInsets.symmetric(vertical: 1),
                color: Colors.white,
                width: anchoredBanner?.size.width.toDouble(),
                height: anchoredBanner?.size.height.toDouble(),
                child: AdWidget(ad: anchoredBanner!),
              )
            : Container(),
      );
    });
  }
}
