import 'package:flutter/material.dart';

import 'app_colors.dart';

class ThemeColor {
  static ThemeData lightThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: ColorPalette.backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: ColorPalette.primaryColor,
      onPrimary: ColorPalette.whiteColor,
      secondary: ColorPalette.primaryDark,
      surface: ColorPalette.surfaceColor,
      onSurface: ColorPalette.blackColor,
      error: ColorPalette.dangerColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorPalette.primaryColor,
      foregroundColor: ColorPalette.whiteColor,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ColorPalette.whiteColor,
      ),
      iconTheme: IconThemeData(color: ColorPalette.whiteColor),
    ),
    cardTheme: CardThemeData(
      color: ColorPalette.surfaceColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: ColorPalette.borderColor),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorPalette.whiteColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorPalette.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorPalette.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorPalette.primaryColor, width: 1.8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.primaryColor,
        foregroundColor: ColorPalette.whiteColor,
        minimumSize: const Size(48, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorPalette.primaryColor,
        minimumSize: const Size(48, 50),
        side: const BorderSide(color: ColorPalette.primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ColorPalette.blackColor),
      bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: ColorPalette.blackColor),
      bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ColorPalette.textMuted),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ColorPalette.blackColor),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ColorPalette.blackColor),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ColorPalette.blackColor),
    ),
  );
}
