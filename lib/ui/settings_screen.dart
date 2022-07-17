import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sphere_app/custom&utils/new_app_dialogue.dart';
import 'package:sphere_app/custom&utils/strings.dart';
import 'package:sphere_app/generated/assets.dart';
import 'package:sphere_app/ui/app_screens/app_details_screen.dart';

import '../ad_helper.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  static String id = "settingsscreen";

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin<SettingsScreen> {
  final InAppReview inAppReview = InAppReview.instance;
  late final ValueNotifier<bool> switchController;
  final textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  RewardedAd? rewardedAd;
  int rewardedAdLoadingAttempts = 0;

  Future<void> loadRewardedAd() async {
    if (kDebugMode) {
      print('loading rewarded ad $rewardedAdLoadingAttempts');
    }
    await RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('rewarded ad loaded');
          }
          rewardedAd = ad;
          rewardedAdLoadingAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('rewarded ad loading failed: $error ');
          }
          rewardedAd = null;
          if (rewardedAdLoadingAttempts < maxAdLoadingAttempts) {
            rewardedAdLoadingAttempts++;
            loadRewardedAd();
          }
        },
      ),
    );
  }

  void showRewardedAd() {
    final adsBox = Hive.box<int>(MyStrings.adsBoxName);
    final adsShownCount = adsBox.get(MyStrings.rewardedAdCount);
    if (rewardedAd != null && DateTime.now().hour > (3 * adsShownCount!)) {
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) async {
          if (kDebugMode) {
            print('rewarded ad shown count $adsShownCount');
          }
          await adsBox.put(MyStrings.rewardedAdCount, adsShownCount + 1);
        },
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          if (kDebugMode) {
            print('rewarded ad is dismissed');
          }
          ad.dispose();
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          if (kDebugMode) {
            print('Error showing rewarded ad: ${error.message}');
          }
          ad.dispose();
          loadRewardedAd();
        },
      );
      rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          if (kDebugMode) {
            print('reward earned: ${reward.type}');
          }
        },
      );
    }
  }

  @override
  void initState() {
    loadRewardedAd();
    switchController = ValueNotifier<bool>(
        AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark);
    switchController.addListener(() {
      AdaptiveTheme.of(context).setThemeMode(
        switchController.value
            ? AdaptiveThemeMode.dark
            : AdaptiveThemeMode.light,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    switchController.dispose();
    textController.dispose();
    rewardedAd?.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final divider = Divider(
      color: theme.colorScheme.onBackground,
      height: 1,
    );
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                divider,
                const SizedBox(height: 10),
                Row(
                  children: [
                    Form(
                      key: _formKey,
                      child: Expanded(
                        child: TextFormField(
                          controller: textController,
                          validator: (value) =>
                              value == null || value.length < 3
                                  ? "Too short"
                                  : null,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            border: InputBorder.none,
                            hintText: "Enter name here",
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        showRewardedAd();
                        if (_formKey.currentState!.validate()) {
                          final Box<String> userBox =
                              Hive.box<String>(MyStrings.userBoxName);
                          final List<String> list =
                              textController.text.split(" ");
                          String firstName = "";
                          String lastName = "";
                          for (int i = 0; i < list.length; i++) {
                            if (i == 0) {
                              firstName = list[i];
                            } else if (i == 1) {
                              lastName = list[i];
                            } else {
                              lastName = lastName + " " + list[i];
                            }
                          }
                          await userBox.put("first_name", firstName);
                          await userBox.put("last_name", lastName);
                          Fluttertoast.showToast(
                            msg: "Name Successfully Updated",
                            backgroundColor: Theme.of(context).primaryColor,
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_SHORT,
                          );
                          textController.clear();
                        }
                      },
                      icon: const Icon(FontAwesomeIcons.paperPlane),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                divider,
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      AppDetailsScreen.id,
                      arguments: "https://royaltyholdingcompany.com/contact-us",
                    );
                  },
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        "Help & Support",
                        style: theme.textTheme.bodyText1?.copyWith(
                          fontFamily: "InterRegular",
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                divider,
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      AppDetailsScreen.id,
                      arguments: "https://royaltyholdingcompany.com/contact-us",
                    );
                  },
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        "Email Us",
                        style: theme.textTheme.bodyText1?.copyWith(
                          fontFamily: "InterRegular",
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                divider,
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await Get.toNamed(
                      AppDetailsScreen.id,
                      arguments:
                          "https://apps.apple.com/us/developer/travis-johnson/id1502039508",
                    );
                  },
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        "More Apps",
                        style: theme.textTheme.bodyText1?.copyWith(
                          fontFamily: "InterRegular",
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                divider,
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    Get.toNamed(
                      AppDetailsScreen.id,
                      arguments:
                          "https://apps.apple.com/ca/app/shibsphere-media-management/id1114883398",
                    );
                  },
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        "Review this app",
                        style: theme.textTheme.bodyText1?.copyWith(
                          fontFamily: "InterRegular",
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                divider,
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    Text(
                      "App Version 2.0.0",
                      style: theme.textTheme.bodyText1?.copyWith(
                        fontFamily: "InterRegular",
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                divider,
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    Text(
                      "Dark Mode",
                      style: theme.textTheme.bodyText1?.copyWith(
                        fontFamily: "InterRegular",
                        fontSize: 12,
                      ),
                    ),
                    const Expanded(child: SizedBox.shrink()),
                    AdvancedSwitch(
                      height: 25,
                      width: 50,
                      activeColor: theme.colorScheme.onBackground,
                      inactiveColor: theme.colorScheme.onBackground,
                      controller: switchController,
                      inactiveChild: Image.asset(
                        Assets.imagesMoon,
                        width: 14,
                        height: 14,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      activeChild: SvgPicture.asset(
                        Assets.iconsSun,
                        width: 14,
                        height: 14,
                        color: theme.scaffoldBackgroundColor,
                      ),
                      thumb: ValueListenableBuilder(
                        valueListenable: switchController,
                        builder: (_, value, __) {
                          return Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                divider,
                Row(
                  children: [
                    const SizedBox(width: 20),
                    Text(
                      "Add website",
                      style: theme.textTheme.bodyText1?.copyWith(
                        fontFamily: "InterRegular",
                        fontSize: 12,
                      ),
                    ),
                    const Expanded(child: SizedBox.shrink()),
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return const NewAppDialogue();
                            });
                      },
                      icon: Image.asset(
                        Assets.imagesAddCircle,
                        height: 32,
                        width: 32,
                        color: theme.iconTheme.color,
                      ),
                    ),
                  ],
                ),
                divider,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class AdWidget extends StatelessWidget {
//   const AdWidget({
//     Key? key,
//     required this.theme,
//   }) : super(key: key);
//
//   final ThemeData theme;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ListTile(
//           contentPadding: EdgeInsets.zero,
//           leading: CircleAvatar(
//             radius: 32,
//             child: Image.asset(
//               Assets.imagesProfile,
//               fit: BoxFit.cover,
//             ),
//           ),
//           title: Text(
//             "Brand Name",
//             style: theme.textTheme.headline6,
//           ),
//           subtitle: Text(
//             "Sponsored",
//             style: theme.textTheme.bodyText2,
//           ),
//           trailing: IconButton(
//               onPressed: () {}, icon: const Icon(Icons.more_horiz_rounded)),
//         ),
//         const SizedBox(height: 5),
//         const MyExpandableText(
//           text:
//               "A process developed over years of experience to perfect the way we use the Facebook Business Manager tool for businesses",
//         ),
//         const SizedBox(height: 5),
//         Padding(
//           padding: const EdgeInsets.all(4.0),
//           child: Material(
//             color: theme.colorScheme.background,
//             borderRadius: BorderRadius.circular(4),
//             child: Column(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(4),
//                     topRight: Radius.circular(4),
//                   ),
//                   child: Image.asset(
//                     Assets.imagesPostPic,
//                     fit: BoxFit.cover,
//                     height: 300,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 100,
//                   child: Center(
//                     child: ListTile(
//                       title: Text(
//                         "Step 1",
//                         style: theme.textTheme.headline6,
//                       ),
//                       subtitle: Text(
//                         "Audit Ad Account and Competitors",
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style:
//                             theme.textTheme.bodyText2?.copyWith(fontSize: 13),
//                       ),
//                       trailing: OutlinedButton(
//                         onPressed: () {},
//                         child: Text(
//                           "Sell Now",
//                           style: theme.textTheme.bodyText1?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: theme.textTheme.bodyText1?.color,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           primary: theme.colorScheme.background,
//                           onPrimary: theme.colorScheme.onBackground,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
