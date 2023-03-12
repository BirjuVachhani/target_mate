import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';

const double kMacOSTopPadding = 32;

class CustomSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;

  const CustomSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (context.theme.platform) {
      case TargetPlatform.android:
        return SafeArea(
          top: top,
          bottom: bottom,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: child,
          ),
        );
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return SafeArea(top: top, bottom: bottom, child: child);
    }
  }
}
