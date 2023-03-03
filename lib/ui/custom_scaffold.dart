import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final Color? systemNavigationBarColor;
  final Future<bool> Function()? onWillPop;

  const CustomScaffold({
    super.key,
    required this.body,
    this.systemNavigationBarColor,
    this.onWillPop,
  });

  @override
  Widget build(BuildContext context) {
    final mode = AdaptiveTheme.of(context).mode;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            mode.isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: mode.isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            systemNavigationBarColor ?? context.theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            mode.isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: WillPopScope(
        onWillPop: onWillPop ?? () async => true,
        child: Scaffold(
          body: body,
        ),
      ),
    );
  }
}
