import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sphere_app/custom&utils/strings.dart';
import 'package:sphere_app/model/card_model.dart';
import 'package:sphere_app/ui/app_screens/app_details_screen.dart';
import 'package:sphere_app/ui/app_screens/apps_screen.dart';
import 'package:sphere_app/ui/settings_screen.dart';

import '../ad_helper.dart';
import '../custom&utils/custom_bottom_bar.dart';
import '../custom&utils/my_flutter_app_icons.dart';
import '../generated/assets.dart';

class NavigationScreen extends StatefulWidget {
  static const String id = "navigationscreen";

  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _scrollController;
  late Future<void> Function() handleOverlayCallBack;
  late void Function(bool isScrolling) handleSizeCallBack;
  BannerAd? bannerAd;
  double bottomBarHeight = 92;

  void loadAndShowBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: AdHelper.bannerAdListener,
      request: const AdRequest(),
    )..load().then((value) => setState(() {}));
  }

  @override
  void initState() {
    loadAndShowBannerAd();
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        handleSizeCallBack(true);
        handleOverlayCallBack();
      }
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        handleSizeCallBack(false);
        handleOverlayCallBack();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    bannerAd?.dispose();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
            [
          SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Image.asset(
                        Assets.imagesAvatar,
                        width: 32,
                        height: 42,
                      ),
                      Flexible(
                        child: Text(
                          "ShibSphere",
                          style: theme.textTheme.headline3,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _tabController.index == 0
                      ? Container(
                          height: 90,
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => Get.toNamed(
                                  AppDetailsScreen.id,
                                  arguments: "https://facebook.com",
                                ),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor:
                                      theme.colorScheme.onBackground,
                                  child: SvgPicture.asset(
                                    Assets.iconsFacebook,
                                    width: 18,
                                    color: theme.scaffoldBackgroundColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => Get.toNamed(
                                  AppDetailsScreen.id,
                                  arguments: "https://youtube.com/",
                                ),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor:
                                      theme.colorScheme.onBackground,
                                  child: SvgPicture.asset(
                                    Assets.iconsYoutube,
                                    width: 18,
                                    color: theme.scaffoldBackgroundColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => Get.toNamed(
                                  AppDetailsScreen.id,
                                  arguments: "https://www.pinterest.com/",
                                ),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor:
                                      theme.colorScheme.onBackground,
                                  child: SvgPicture.asset(
                                    Assets.iconsPinterest,
                                    width: 16,
                                    color: theme.scaffoldBackgroundColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        )
                      : const SizedBox(height: 90),
                ),
              ],
            ),
          ),
        ],
        body: Stack(
          fit: StackFit.expand,
          children: [
            TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: _screens(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ValueListenableBuilder<Box<AppCardModel>>(
                  valueListenable:
                      Hive.box<AppCardModel>(MyStrings.cardsBoxName)
                          .listenable(),
                  builder: (context, cardsBox, child) {
                    List<AppCardModel> cardItems = cardsBox.values.toList();
                    cardItems.sort((a, b) {
                      return -a.lastUsed.compareTo(b.lastUsed);
                    });
                    return MyBottomNavBar(
                      shadow: true,
                      bannerAd: bannerAd,
                      showNavButton: true,
                      showNavArrows: false,
                      bottomBarHeight: bottomBarHeight,
                      backgroundColor: theme.colorScheme.background,
                      onScrollOverlayCallBack: (handleOverlayCallBack) {
                        this.handleOverlayCallBack = handleOverlayCallBack;
                      },
                      onScrollSizeCallBack: (handleSizeCallBack) {
                        this.handleSizeCallBack = handleSizeCallBack;
                      },
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                      onTap: (index) {
                        _tabController.animateTo(index);
                      },
                      subItems: [
                        for (int i = 0; i < 3; i++)
                          BottomNavBarSubItem(
                            widget: SubItemWidget(cardData: cardItems[i]),
                            onTap: () {
                              return Get.toNamed(
                                cardItems[i].screenRouteNamed!,
                                arguments: cardItems[i].webUrl,
                              );
                            },
                          )
                      ],
                      items: [
                        MyBottomNavBarItem(
                          icon: MyFlutterApp.compass,
                          activeColor: Colors.blue,
                        ),
                        MyBottomNavBarItem(
                          icon: MyFlutterApp.settings,
                          activeColor: Colors.blue,
                        ),
                      ],
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _screens() {
    return [
      AppsScreen(
        onEditPressed: () {
          setState(() {
            _tabController.animateTo(1);
          });
        },
      ),
      const SettingsScreen()
    ];
  }
}

class SubItemWidget extends StatelessWidget {
  const SubItemWidget({
    Key? key,
    required this.cardData,
  }) : super(key: key);

  final AppCardModel cardData;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: cardData.gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: GestureDetector(
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: cardData.assetIcon != null
                  ? cardData.assetIcon!.endsWith("svg")
                      ? SvgPicture.asset(
                          cardData.assetIcon!,
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        )
                      : cardData.assetIcon == Assets.imagesShibburnText
                          ? const Text(
                              "SB",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Image.asset(
                              cardData.assetIcon!,
                              width: 24,
                              height: 24,
                            )
                  : cardData.fileIcon!.endsWith("svg")
                      ? SvgPicture.file(
                          File(cardData.fileIcon!),
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        )
                      : Image.file(
                          File(cardData.fileIcon!),
                          width: 24,
                          height: 24,
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
