import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:toggl_target/utils/extensions.dart';

ThemeData getTheme(Color primaryColor) {
  final Color backgroundColor = primaryColor.darken(95);

  final m3colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor, brightness: Brightness.dark);

  final m2colorScheme = ColorScheme.fromSwatch(
    primarySwatch: primaryColor.toMaterialColor(),
    brightness: Brightness.dark,
  ).copyWith(background: backgroundColor);

  return ThemeData(
    primaryColor: primaryColor,
    colorScheme: m2colorScheme,
    // useMaterial3: true,
    // colorSchemeSeed: primaryColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Inter',
    snackBarTheme: SnackBarThemeData(
      backgroundColor: m3colorScheme.tertiary,
      contentTextStyle: TextStyle(
        fontSize: 15,
        color: m3colorScheme.onTertiary,
      ),
      closeIconColor: m3colorScheme.onTertiary,
      actionTextColor: m3colorScheme.onTertiary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        visualDensity: VisualDensity.standard,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        visualDensity: VisualDensity.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        elevation: 0,
        visualDensity: VisualDensity.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      hintStyle: const TextStyle(
        fontSize: 15,
        color: Colors.white24,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
  );
}
