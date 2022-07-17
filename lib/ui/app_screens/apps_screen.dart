import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sphere_app/main.dart';
import 'package:sphere_app/model/card_model.dart';
import 'package:sphere_app/services/firebase_service.dart';
import 'package:sphere_app/ui/search_screen.dart';

import '../../ad_helper.dart';
import '../../custom&utils/app_card.dart';
import '../../custom&utils/new_app_dialogue.dart';
import '../../custom&utils/strings.dart';
import '../../generated/assets.dart';

class AppsScreen extends StatefulWidget {
  static String id = "appsscreen";
  final void Function()? onEditPressed;

  const AppsScreen({
    Key? key,
    this.onEditPressed,
  }) : super(key: key);

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen>
    with AutomaticKeepAliveClientMixin<AppsScreen> {
  int interstitialAdLoadingAttempts = 0;
  InterstitialAd? interstitialAd;

  late final Future<String?> imageFuture;

  void loadInterstitialAd() {
    if (kDebugMode) {
      print('Interstitial Ad loading $interstitialAdLoadingAttempts');
    }
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (kDebugMode) {
            print('Interstitial Ad Loaded');
          }
          interstitialAd = ad;
          interstitialAdLoadingAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('InterstitialAd failed to load: $error');
          }
          interstitialAd = null;
          if (interstitialAdLoadingAttempts < maxAdLoadingAttempts) {
            interstitialAdLoadingAttempts++;
            loadInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    final adsBox = Hive.box<int>(MyStrings.adsBoxName);
    final adsShownCount = adsBox.get(MyStrings.interstitialAdCount);
    if (interstitialAd != null && DateTime.now().hour > (3 * adsShownCount!)) {
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) async {
          await adsBox.put(MyStrings.interstitialAdCount, adsShownCount + 1);
          if (kDebugMode) {
            print('interstitial ad shown count $adsShownCount');
          }
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          if (kDebugMode) {
            print('Error showing Interstitial ad: ${error.message}');
          }
          ad.dispose();
          loadInterstitialAd();
        },
      );
      interstitialAd!.show();
    }
  }

  @override
  void initState() {
    imageFuture = FirebaseService().getRandomQuoteImageUrl();
    loadInterstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(SearchScreen.id),
                  child: TextField(
                    decoration: InputDecoration(
                      enabled: false,
                      filled: true,
                      hintText: "Search...",
                      fillColor: theme.colorScheme.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => Get.toNamed(SearchScreen.id),
                        child: Icon(
                          Icons.search,
                          color: theme.iconTheme.color,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Welcome back",
                  style: theme.textTheme.bodyText2,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      ValueListenableBuilder<Box<String>>(
                        valueListenable: Hive.box<String>(MyStrings.userBoxName)
                            .listenable(),
                        builder: (context, value, child) => RichText(
                          text: TextSpan(
                            text:
                                "${value.get(MyStrings.firstName) ?? "Error"} ",
                            style: theme.textTheme.headline4
                                ?.copyWith(color: Colors.blue),
                            children: [
                              TextSpan(
                                text: value.get(MyStrings.lastName) ?? "error",
                                style: theme.textTheme.bodyText1
                                    ?.copyWith(fontSize: 30),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: const Alignment(-0.95, 0.9),
                          child: GestureDetector(
                            onTap: () {
                              if (widget.onEditPressed != null) {
                                widget.onEditPressed!();
                              }
                            },
                            child: Text(
                              "(Edit)",
                              style: theme.textTheme.bodyText2?.copyWith(
                                color: const Color(0xff9F9F9F),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  "Quote of the day...",
                  style: theme.textTheme.headline6,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 160,
                  width: double.maxFinite,
                  child: FutureBuilder<String?>(
                      future: imageFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                "Error: ${snapshot.error.toString()}",
                                style: theme.textTheme.caption,
                              ),
                            );
                          }
                          if (!snapshot.hasData) {
                            return Center(
                              child: Text(
                                "No data received",
                                style: theme.textTheme.caption,
                              ),
                            );
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data!,
                              width: double.maxFinite,
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) {
                                return const Icon(Icons.error);
                              },
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              "Loading Quote...",
                              style: theme.textTheme.caption,
                            ),
                          );
                        }
                      }),
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<Box<AppCardModel>>(
                  valueListenable:
                      Hive.box<AppCardModel>(MyStrings.cardsBoxName)
                          .listenable(),
                  builder: (context, box, child) {
                    return GridView.builder(
                      itemCount: box.length + 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        if (index == box.length) {
                          return GestureDetector(
                            onTap: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const NewAppDialogue();
                                  });
                            },
                            child: Container(
                              height: 350,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xff000000).withOpacity(0.35),
                                      const Color(0xffffffff)
                                    ]),
                              ),
                              child: Image.asset(
                                Assets.imagesAddCircle,
                                height: 63,
                                width: 63,
                                color: theme.iconTheme.color,
                              ),
                            ),
                          );
                        }
                        final cardData = box.getAt(index);
                        return AppCard(
                          cardData: cardData ??
                              AppCardModel(
                                title: "Data Retrieval Failed",
                                assetIcon: Assets.iconsCompass,
                                timeUsedMinutes: 0,
                                webUrl: null,
                                screenRouteNamed: null,
                                backgroundImage: null,
                                isDeleteAble: true,
                              ),
                          onTap: (AppCardModel cardData) {
                            showInterstitialAd();
                            gotoAppDetailsScreen(cardData);
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> gotoAppDetailsScreen(AppCardModel cardData) async {
    if (cardData.screenRouteNamed != null) {
      final int timeSpentInSeconds = await Get.toNamed(
        cardData.screenRouteNamed!,
        arguments: cardData.webUrl!,
      );
      cardData.timeUsedMinutes =
          cardData.timeUsedMinutes + (timeSpentInSeconds ~/ 60);
      cardData.lastUsed = DateTime.now();
      await cardData.save();
    }
  }
}
