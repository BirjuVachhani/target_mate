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

  final colorScheme = useMaterial3 ? m3colorScheme : m2colorScheme;

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
      fillColor: colorScheme.onSurface.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      hintStyle: TextStyle(
        fontSize: 15,
        color: colorScheme.onSurface.withOpacity(0.5),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.5,
        ),
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
  // final Color backgroundColor = const Color(0xFFFAFAFA);

  final m3colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor, brightness: Brightness.light);

  final m2colorScheme = ColorScheme.fromSwatch(
    primarySwatch: primaryColor.toMaterialColor(),
    brightness: Brightness.light,
  );

  final colorScheme = useMaterial3 ? m3colorScheme : m2colorScheme;

  final textColor = colorScheme.primary.darken(70);

  final Color backgroundColor = useMaterial3
      ? m3colorScheme.background
      : m2colorScheme.primary.shade(1).shade(1).shade(1).shade(10);
  return ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    colorScheme: useMaterial3 ? m3colorScheme : m2colorScheme,
    // useMaterial3: true,
    // colorSchemeSeed: primaryColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: colorScheme.background,
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
    textTheme: TextTheme(
      bodySmall: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodyLarge: TextStyle(color: textColor),
      displaySmall: TextStyle(color: textColor),
      displayMedium: TextStyle(color: textColor),
      displayLarge: TextStyle(color: textColor),
      titleSmall: TextStyle(color: textColor),
      titleMedium: TextStyle(color: textColor),
      titleLarge: TextStyle(color: textColor),
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
      fillColor: colorScheme.onSurface.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      hintStyle: TextStyle(
        fontSize: 15,
        color: colorScheme.onSurface.withOpacity(0.5),
        // color: Colors.white24,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.5,
        ),
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
        letterSpacing: 0.2,
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
