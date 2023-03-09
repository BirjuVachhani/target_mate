import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:toggl_target/ui/gradient_background.dart';
import 'package:toggl_target/utils/extensions.dart';

import 'window_border.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final Color? systemNavigationBarColor;
  final Future<bool> Function()? onWillPop;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final bool gradientBackground;

  const CustomScaffold({
    super.key,
    required this.body,
    this.systemNavigationBarColor,
    this.onWillPop,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
    this.gradientBackground = false,
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
        child: GradientBackground(
          child: Scaffold(
            backgroundColor: gradientBackground ? Colors.transparent : backgroundColor,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            appBar: gradientBackground && defaultTargetPlatform.isDesktop
                ? PreferredSize(
                    preferredSize: Size.fromHeight(getToolbarHeight()),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Align(
                          alignment: defaultTargetPlatform.isWindows
                              ? Alignment.centerLeft
                              : Alignment.center,
                          child: Image.asset(
                            'assets/logo_trimmed.png',
                            fit: BoxFit.fitHeight,
                            height: 16,
                            color: context.theme.colorScheme.background,
                          ),
                        ),
                        MoveWindow(),
                      ],
                    ),
                  )
                : null,
            body: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    behavior: HitTestBehavior.opaque,
                    child: body,
                  ),
                ),
                if (defaultTargetPlatform.isDesktop)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: getToolbarHeight(),
                    child: MoveWindow(),
                  ),
                if (defaultTargetPlatform.isWindows)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: ColoredBox(
                      color: Colors.yellow.withOpacity(0.3),
                      child: const WindowButtons(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

double getToolbarHeight() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return 34;
    case TargetPlatform.linux:
      return 0;
    case TargetPlatform.windows:
      return appWindow.titleBarButtonSize.height + 16;
  }
}
