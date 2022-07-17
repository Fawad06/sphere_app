import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:sphere_app/services/firebase_service.dart';

import '../ad_helper.dart';
import '../custom&utils/strings.dart';
import '../generated/assets.dart';
import '../main.dart';
import '../model/card_model.dart';
import 'navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppOpenAd? appOpenAd;
  int appOpenAdLoadingAttempts = 0;

  Future<void> _loadAppOpenAd() async {
    if (kDebugMode) {
      print('appOpenAd loading $appOpenAdLoadingAttempts');
    }
    await AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('appOpenAd is loaded');
          }
          appOpenAd = ad;
          appOpenAdLoadingAttempts = 0;
          appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('appOpenAd is shown');
              }
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('appOpenAd is dismissed');
              }
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('appOpenAd failed to show: $error');
              }
              appOpenAd = null;
              if (appOpenAdLoadingAttempts < maxAdLoadingAttempts) {
                appOpenAdLoadingAttempts++;
                _loadAppOpenAd();
              }
            },
          );
          appOpenAd!.show();
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('appOpenAd failed to load: $error');
          }
          appOpenAd = null;
          if (appOpenAdLoadingAttempts <= maxAdLoadingAttempts) {
            appOpenAdLoadingAttempts++;
            _loadAppOpenAd();
          }
        },
      ),
      orientation: AppOpenAd.orientationPortrait,
    );
  }

  Future<void> initializeAppCards() async {
    await Hive.openBox<bool>(MyStrings.appBoxName);
    await Hive.openBox<AppCardModel>(MyStrings.cardsBoxName);
    await Hive.openBox<String>(MyStrings.userBoxName);
    await Hive.openBox<int>(MyStrings.adsBoxName);
    final Box<int> adsBox = Hive.box<int>(MyStrings.adsBoxName);
    final Box<bool> appBox = Hive.box<bool>(MyStrings.appBoxName);
    final Box<String> userBox = Hive.box<String>(MyStrings.userBoxName);
    final Box<AppCardModel> cardsBox =
        Hive.box<AppCardModel>(MyStrings.cardsBoxName);
    final initialLaunch = appBox.get(MyStrings.initialLaunch);
    final int? oldDate = adsBox.get(MyStrings.todaysDate);
    if (oldDate == null || oldDate < DateTime.now().day) {
      await Future.wait([
        adsBox.put(MyStrings.todaysDate, DateTime.now().day),
        adsBox.put(MyStrings.interstitialAdCount, 0),
        adsBox.put(MyStrings.rewardedAdCount, 0),
      ]);
    }
    if (initialLaunch == null) {
      await Future.wait([
        appBox.put(MyStrings.initialLaunch, false),
        userBox.put(MyStrings.firstName, "John"),
        userBox.put(MyStrings.lastName, " Doe"),
        ...List.generate(
          cardsData.length,
          (index) => cardsBox.add(
            cardsData[index],
          ),
        ),
      ]);
    }
  }

  @override
  void dispose() {
    appOpenAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: Future.wait([
            _loadAppOpenAd(),
            initializeAppCards(),
            FirebaseService().authenticate(),
            Future.delayed(const Duration(milliseconds: 250))
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                Get.offAll(
                  () => const NavigationScreen(),
                  transition: Transition.fade,
                );
              });
            }
            return SizedBox.expand(
              child: Image.asset(
                Assets.imagesSplashScreenDark,
                width: double.maxFinite,
                height: double.maxFinite,
                fit: BoxFit.fill,
              ),
            );
          }),
    );
  }
}
