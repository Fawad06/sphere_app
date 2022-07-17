import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sphere_app/generated/assets.dart';
import 'package:sphere_app/ui/app_screens/app_details_screen.dart';

part 'card_model.g.dart';

@HiveType(typeId: 0)
class AppCardModel extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String? assetIcon;
  @HiveField(2)
  final String? fileIcon;
  @HiveField(3)
  int timeUsedMinutes;
  @HiveField(4)
  final List<Color> gradientColors;
  @HiveField(5)
  final String? backgroundImage;
  @HiveField(6)
  final String? screenRouteNamed;
  @HiveField(7)
  final String? webUrl;
  @HiveField(8)
  final bool isDeleteAble;
  @HiveField(9)
  DateTime lastUsed;

  AppCardModel({
    required this.title,
    this.assetIcon,
    this.fileIcon,
    required this.timeUsedMinutes,
    this.backgroundImage,
    this.webUrl,
    required this.isDeleteAble,
    this.gradientColors = const [Color(0xFF40C4FF), Color(0xffffffff)],
    required this.screenRouteNamed,
  })  : lastUsed = DateTime(DateTime.now().year),
        assert(screenRouteNamed != null ? webUrl != null : true),
        assert(fileIcon != null || assetIcon != null);
}

final cardsData = [
  AppCardModel(
    title: "ShibSuperstore",
    assetIcon: Assets.imagesAvatar,
    timeUsedMinutes: 0,
    backgroundImage: Assets.imagesShibBackground,
    gradientColors: const [
      Color(0xff000000),
      Color(0xff000000),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://shibsuperstore.com",
    isDeleteAble: false,
  ),
  AppCardModel(
    assetIcon: Assets.imagesShibburnText,
    timeUsedMinutes: 0,
    gradientColors: const [
      Color(0xffFF6B00),
      Color(0xff000000),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    title: "shibburn",
    webUrl: "https://shibburn.com",
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "FaceBook",
    assetIcon: Assets.iconsFacebook,
    timeUsedMinutes: 0,
    gradientColors: const [
      Color(0xff507DD2),
      Color(0xff3764B9),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://facebook.com",
    backgroundImage: null,
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "Instagram",
    assetIcon: Assets.iconsInstagram,
    timeUsedMinutes: 0,
    gradientColors: const [
      Color(0xffEA4C88),
      Color(0xffEA4C4C),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://instagram.com",
    backgroundImage: null,
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "Twitter",
    assetIcon: Assets.iconsTwitter,
    timeUsedMinutes: 0,
    gradientColors: const [
      Color(0xff55ACEE),
      Color(0xff5577EE),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://twitter.com/",
    backgroundImage: null,
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "Games",
    assetIcon: Assets.iconsController,
    timeUsedMinutes: 0,
    gradientColors: const [
      Color(0xffFF9900),
      Color(0xffFF4D00),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://addictinggames.com",
    backgroundImage: null,
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "Google",
    assetIcon: Assets.iconsGoogle,
    timeUsedMinutes: 0,
    gradientColors: const [
      Colors.red,
      Colors.blue,
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://google.com",
    backgroundImage: null,
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "Youtube",
    assetIcon: Assets.iconsYoutube,
    timeUsedMinutes: 0,
    gradientColors: const [
      Colors.purpleAccent,
      Colors.orange,
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://youtube.com",
    backgroundImage: null,
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "TikTok",
    assetIcon: Assets.iconsTicktock,
    timeUsedMinutes: 0,
    gradientColors: const [
      Color(0xff08FFF9),
      Color(0xff0C48A3),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://www.tiktok.com/?is_copy_url=1&is_from_webapp=1",
    backgroundImage: null,
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "Reddit",
    assetIcon: Assets.iconsReddit,
    timeUsedMinutes: 0,
    gradientColors: const [
      Color(0xfffd6f3e),
      Color(0xffDC3400),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://www.reddit.com/",
    backgroundImage: null,
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "Pinterest",
    assetIcon: Assets.iconsPinterest,
    timeUsedMinutes: 0,
    gradientColors: const [
      Color(0xffFF1A48),
      Color(0xffC2001B),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://www.pinterest.com/",
    backgroundImage: null,
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "Netflix",
    assetIcon: Assets.iconsNetflix,
    timeUsedMinutes: 0,
    gradientColors: const [
      Color(0xf3f54f42),
      Color(0xffD32F2F),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://www.netflix.com/",
    backgroundImage: null,
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "Spotify",
    assetIcon: Assets.iconsSpotify,
    timeUsedMinutes: 0,
    gradientColors: const [
      Color(0xff18e759),
      Color(0xff0A9A37),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://www.spotify.com/",
    backgroundImage: null,
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "Drive",
    assetIcon: Assets.iconsDrive,
    timeUsedMinutes: 0,
    gradientColors: const [
      Color(0xffFFDA2D),
      Color(0xff59C36A),
      Color(0xff4086F4),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://drive.google.com/",
    backgroundImage: null,
    isDeleteAble: true,
  ),
  AppCardModel(
    title: "Amazon",
    assetIcon: Assets.iconsAmazone,
    timeUsedMinutes: 0,
    gradientColors: const [
      Color(0xffFF9900),
      Color(0xffFF4D00),
    ],
    screenRouteNamed: AppDetailsScreen.id,
    webUrl: "https://www.amazon.com/",
    backgroundImage: null,
    isDeleteAble: true,
  ),
];
