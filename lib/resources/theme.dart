import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

import '../utils/extensions.dart';

ThemeData getDarkTheme(Color primaryColor, {bool useMaterial3 = false}) {
  final Color backgroundColor = primaryColor.darken(95);

  final m3colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor, brightness: Brightness.dark);

  final m2colorScheme = ColorScheme.fromSwatch(
    primarySwatch: primaryColor.toMaterialColor(),
    brightness: Brightness.dark,
  ).copyWith(background: backgroundColor);

  return ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    colorScheme: useMaterial3 ? m3colorScheme : m2colorScheme,
    // useMaterial3: true,
    // colorSchemeSeed: primaryColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'SF Pro',
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
    scrollbarTheme: ScrollbarThemeData(
      interactive: true,
      crossAxisMargin: 4,
      thickness: MaterialStateProperty.all(4),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: (useMaterial3
            ? m3colorScheme.primary
            : m2colorScheme.primary.darken(65)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      textStyle: TextStyle(
        fontSize: 12,
        color:
            (useMaterial3 ? m3colorScheme.onPrimary : m2colorScheme.onPrimary),
      ),
    ),
    dividerTheme: DividerThemeData(
      thickness: 1,
      color: useMaterial3
          ? m3colorScheme.onSurface.withOpacity(0.2)
          : m2colorScheme.onSurface.withOpacity(0.1),
    ),
  );
}

ThemeData getLightTheme(Color primaryColor, {bool useMaterial3 = false}) {
  // TODO: imeplement a light theme
  return getDarkTheme(primaryColor, useMaterial3: useMaterial3);
}
