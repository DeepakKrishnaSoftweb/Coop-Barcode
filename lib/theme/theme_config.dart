import 'package:flutter/material.dart';

import 'app_colors.dart';

class ThemeColor {
  static ThemeData lightThemeData = ThemeData(
    brightness: Brightness.light,

    /// ✅ GLOBAL FONT
    fontFamily: 'Quicksand',

    colorScheme: const ColorScheme.light(
      primary: ColorPalette.whiteColor,
      secondary: ColorPalette.whiteColor,
      surface: Color.fromRGBO(255, 250, 255, 1),
      secondaryContainer: ColorPalette.greyColor4,
      primaryContainer: ColorPalette.blackColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: ColorPalette.primaryColor,
      iconTheme: IconThemeData(color: ColorPalette.whiteColor),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ColorPalette.whiteColor,
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ColorPalette.blackColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ColorPalette.blackColor,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ColorPalette.blackColor,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  // static ThemeData darkThemeData = ThemeData(
  //   brightness: Brightness.dark,
  //   colorScheme: ColorScheme.dark(
  //     primary: Colors.grey[900]!,
  //     secondary: Colors.grey[800]!,
  //     background: ColorPalette.blackColor,
  //     secondaryContainer: Colors.grey[900]!,
  //     primaryContainer: ColorPalette.whiteColor,
  //   ),
  //   appBarTheme: const AppBarTheme(
  //     backgroundColor: ColorPalette.primaryColor,
  //     iconTheme: IconThemeData(
  //       color: ColorPalette.blackColor,
  //     ),
  //     elevation: 0,
  //     titleTextStyle: TextStyle(
  //       fontSize: 18,
  //       fontFamily: 'WinkyRough',
  //       fontWeight: FontWeight.bold,
  //       color: ColorPalette.blackColor,
  //     ),
  //   ),
  //   textTheme: const TextTheme(
  //     bodyLarge: TextStyle(
  //       color: ColorPalette.whiteColor,
  //       fontSize: 18,
  //       fontWeight: FontWeight.bold,
  //       fontFamily: 'WinkyRough',
  //       letterSpacing: 0,
  //     ),
  //     bodyMedium: TextStyle(
  //       color: ColorPalette.whiteColor,
  //       fontWeight: FontWeight.bold,
  //       fontSize: 18,
  //       fontFamily: 'WinkyRough',
  //       letterSpacing: 0,
  //     ),
  //     bodySmall: TextStyle(
  //       color: ColorPalette.whiteColor,
  //       fontSize: 14,
  //       fontWeight: FontWeight.w500,
  //       fontFamily: 'WinkyRough',
  //       letterSpacing: 0,
  //     ),
  //     labelLarge: TextStyle(
  //       color: ColorPalette.whiteColor,
  //       fontWeight: FontWeight.w500,
  //       fontSize: 18,
  //       fontFamily: 'WinkyRough',
  //       letterSpacing: 0,
  //     ),
  //     labelMedium: TextStyle(
  //       color: ColorPalette.whiteColor,
  //       fontWeight: FontWeight.w500,
  //       fontSize: 16,
  //       fontFamily: 'WinkyRough',
  //       letterSpacing: 0,
  //     ),
  //     labelSmall: TextStyle(
  //       color: ColorPalette.whiteColor,
  //       fontWeight: FontWeight.w500,
  //       fontSize: 14,
  //       fontFamily: 'WinkyRough',
  //       letterSpacing: 0,
  //     ),
  //     titleLarge: TextStyle(
  //       color: ColorPalette.whiteColor,
  //       fontSize: 24,
  //       fontWeight: FontWeight.w500,
  //       fontFamily: 'WinkyRough',
  //       letterSpacing: 0,
  //     ),
  //     titleMedium: TextStyle(
  //       color: ColorPalette.whiteColor,
  //       fontSize: 22,
  //       fontWeight: FontWeight.w500,
  //       fontFamily: 'WinkyRough',
  //       letterSpacing: 0,
  //     ),
  //     titleSmall: TextStyle(
  //       color: ColorPalette.whiteColor,
  //       fontWeight: FontWeight.bold,
  //       fontSize: 14,
  //       fontFamily: 'WinkyRough',
  //       letterSpacing: 0,
  //     ),
  //     headlineLarge: TextStyle(
  //       color: ColorPalette.whiteColor,
  //       fontSize: 24,
  //       fontWeight: FontWeight.bold,
  //       fontFamily: 'WinkyRough',
  //       letterSpacing: 0,
  //     ),
  //     headlineMedium: TextStyle(
  //       color: ColorPalette.whiteColor,
  //       fontSize: 18,
  //       fontWeight: FontWeight.bold,
  //       fontFamily: 'WinkyRough',
  //       letterSpacing: 0,
  //     ),
  //     headlineSmall: TextStyle(
  //       color: ColorPalette.blackColor,
  //       fontSize: 18,
  //       fontWeight: FontWeight.bold,
  //       fontFamily: 'WinkyRough',
  //       letterSpacing: 0,
  //     ),
  //   ),
  // );
}