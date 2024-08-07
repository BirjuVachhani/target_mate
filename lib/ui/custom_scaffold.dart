import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

import '../resources/resources.dart';
import '../utils/extensions.dart';
import 'gradient_background.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final Color? systemNavigationBarColor;

  // final Future<bool> Function()? onWillPop;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final bool gradientBackground;
  final PreferredSizeWidget? appBar;
  final PopInvokedWithResultCallback? onPopInvokedWithResult;
  final bool canPop;

  const CustomScaffold({
    super.key,
    required this.body,
    this.systemNavigationBarColor,
    // this.onWillPop,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
    this.gradientBackground = false,
    this.appBar,
    this.canPop = true,
    this.onPopInvokedWithResult,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = context.theme.brightness;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness.isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            brightness.isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            systemNavigationBarColor ?? context.theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            brightness.isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: PopScope(
        canPop: canPop,
        onPopInvokedWithResult: onPopInvokedWithResult,
        child: ColoredBox(
          color: context.theme.scaffoldBackgroundColor,
          child: GradientBackground(
            child: Builder(builder: (context) {
              return Scaffold(
                backgroundColor: gradientBackground
                    ? context.theme.scaffoldBackgroundColor.withOpacity(0)
                    : backgroundColor,
                resizeToAvoidBottomInset: resizeToAvoidBottomInset,
                appBar: defaultTargetPlatform.isDesktop
                    ? PreferredSize(
                        preferredSize: Size.fromHeight(getToolbarHeight()),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (gradientBackground)
                              Align(
                                alignment: defaultTargetPlatform.isWindows
                                    ? Alignment.centerLeft
                                    : Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Image.asset(
                                    Images.logoTrimmed,
                                    fit: BoxFit.fitHeight,
                                    height: 16,
                                    color: context.theme.brightness.isDark
                                        ? context.theme.colorScheme.surface
                                        : context.theme.textColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : appBar,
                body: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: body,
                ),
              );
            }),
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
      appWindow.titleBarButtonSize;
      return appWindow.titleBarButtonSize.height + 8;
  }
}
