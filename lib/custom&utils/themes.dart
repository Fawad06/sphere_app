import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF00BF6D);
const kSecondaryColor = Color(0xFFFE9901);
const kContentColorLightTheme = Color(0xFF222222);
const kContentColorDarkTheme = Color(0xFFF2F2F2);
const kWarningColor = Color(0xFFF3BB1C);
const kErrorColor = Color(0xFFF03738);
get kContainerShadow => [
      BoxShadow(
        color: Colors.grey.withOpacity(0.7),
        spreadRadius: 0,
        blurRadius: 4,
        offset: const Offset(0, 4),
      ),
    ];

class MyTheme {
  static ThemeMode themeMode = ThemeMode.system;

  static ThemeData get lightTheme => ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kContentColorDarkTheme,
        appBarTheme: appBarTheme,
        fontFamily: "Poppins",
        iconTheme:
            const IconThemeData(color: kContentColorLightTheme, size: 24),
        colorScheme: const ColorScheme.light(
          brightness: Brightness.light,
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          background: Colors.white,
          onBackground: Colors.black,
          error: kErrorColor,
        ),
        textTheme: TextTheme(
          bodyText1: myBodyText1(Colors.black),
          bodyText2: myBodyText2(Colors.black),
          headline3: myHeadline3(Colors.black),
          headline4: myHeadline4(Colors.black),
          headline5: myHeadline5(Colors.black),
          headline6: myHeadline6(Colors.black),
        ),
      );

  ///
  static ThemeData get darkTheme => ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kContentColorLightTheme,
        appBarTheme: appBarTheme,
        iconTheme: const IconThemeData(color: kContentColorDarkTheme),
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          background: Color(0xFF313131),
          onBackground: kContentColorDarkTheme,
          error: kErrorColor,
        ),
        textTheme: TextTheme(
          bodyText1: myBodyText1(Colors.white),
          bodyText2: myBodyText2(Colors.white),
          headline3: myHeadline3(Colors.white),
          headline4: myHeadline4(Colors.white),
          headline5: myHeadline5(Colors.white),
          headline6: myHeadline6(Colors.white),
        ),
      );

  static AppBarTheme appBarTheme = const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    color: kPrimaryColor,
  );

  static TextStyle myBodyText1(Color c) => TextStyle(
        fontWeight: FontWeight.w400,
        fontFamily: "PoppinsRegular",
        fontSize: 14,
        color: c,
      );
  static TextStyle myBodyText2(Color c) => TextStyle(
        fontWeight: FontWeight.w400,
        fontFamily: "PoppinsRegular",
        fontSize: 12,
        color: c,
      );
  static TextStyle myHeadline3(Color c) => TextStyle(
        fontWeight: FontWeight.w300,
        fontFamily: "PoppinsLight",
        fontSize: 24,
        color: c,
      );
  static TextStyle myHeadline4(Color c) => TextStyle(
        fontWeight: FontWeight.w600,
        fontFamily: "PoppinsSemiBold",
        fontSize: 30,
        color: c,
      );
  static TextStyle myHeadline5(Color c) => TextStyle(
        fontWeight: FontWeight.w600,
        fontFamily: "PoppinsSemiBold",
        fontSize: 14,
        color: c,
      );
  static TextStyle myHeadline6(Color c) => TextStyle(
        fontWeight: FontWeight.w500,
        fontFamily: "PoppinsMedium",
        fontSize: 12,
        color: c,
      );
}
