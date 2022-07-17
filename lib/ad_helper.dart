import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  ///test ids
  static String get bannerAdUnitId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/6300978111"
      : "ca-app-pub-3940256099942544/2934735716";

  static String get interstitialAdUnitId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/1033173712"
      : "ca-app-pub-3940256099942544/4411468910";

  static String get rewardedAdUnitId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/5224354917"
      : "ca-app-pub-3940256099942544/1712485313";

  static String get appOpenAdUnitId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/3419835294"
      : "ca-app-pub-3940256099942544/5662855259";

//  ¬¬Android App test:
//  ca-app-pub-3940256099942544~3347511713
//
//   IOS App test:
//   ca-app-pub-3940256099942544~1458002511

  static BannerAdListener get bannerAdListener => BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (kDebugMode) {
            print('banner ad loaded.');
          }
        },
        onAdOpened: (Ad ad) {
          if (kDebugMode) {
            print('banner ad opened.');
          }
        },
        onAdClosed: (Ad ad) {
          if (kDebugMode) {
            print('banner ad closed.');
          }
        },
        onAdImpression: (Ad ad) {
          if (kDebugMode) {
            print('banner ad impression.');
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (kDebugMode) {
            print('banner ad failed to load: $error');
          }
          ad.dispose();
        },
      );
}
