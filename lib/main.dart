import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sphere_app/model/card_model.dart';
import 'package:sphere_app/model/color.g.dart';
import 'package:sphere_app/ui/app_screens/app_details_screen.dart';
import 'package:sphere_app/ui/app_screens/apps_screen.dart';
import 'package:sphere_app/ui/navigation_screen.dart';
import 'package:sphere_app/ui/search_screen.dart';
import 'package:sphere_app/ui/settings_screen.dart';

import 'custom&utils/themes.dart';
import 'ui/splash_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
int maxAdLoadingAttempts = 2; // 0 to 2 = 3

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive
    ..init(appDocumentDir.path)
    ..registerAdapter(AppCardModelAdapter())
    ..registerAdapter(ColorAdapter());
  await Firebase.initializeApp();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  MobileAds.instance.initialize();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({Key? key, required this.savedThemeMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      light: MyTheme.lightTheme,
      dark: MyTheme.darkTheme,
      builder: (themeLight, themeDark) {
        return GetMaterialApp(
          title: "Sphere App",
          navigatorObservers: [routeObserver],
          debugShowCheckedModeBanner: false,
          theme: themeLight,
          darkTheme: themeDark,
          routes: {
            '/': (context) => const SplashScreen(),
            NavigationScreen.id: (context) => const NavigationScreen(),
            SettingsScreen.id: (context) => const SettingsScreen(),
            AppsScreen.id: (context) => const AppsScreen(),
            SearchScreen.id: (context) => const SearchScreen(),
            AppDetailsScreen.id: (context) => const AppDetailsScreen(),
          },
        );
      },
    );
  }
}
