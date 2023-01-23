import 'package:flutter/cupertino.dart';
import 'package:screwdriver/screwdriver.dart';

import '../model/time_entry.dart';

extension TargetPlatformExt on TargetPlatform {
  bool get isDesktop =>
      this == TargetPlatform.macOS ||
      this == TargetPlatform.linux ||
      this == TargetPlatform.windows;

  bool get isMobile =>
      this == TargetPlatform.android || this == TargetPlatform.iOS;

  bool get isMacOS => this == TargetPlatform.macOS;

  bool get isLinux => this == TargetPlatform.linux;

  bool get isWindows => this == TargetPlatform.windows;

  bool get isAndroid => this == TargetPlatform.android;

  bool get isIOS => this == TargetPlatform.iOS;
}

extension TimeEntryListExt on List<TimeEntry> {
  Duration get total => fold<Duration>(
        Duration.zero,
        (previousValue, element) => previousValue + element.duration,
      );
}

extension ColorExt on Color {
  Color darken([double percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(
        alpha, (red * f).round(), (green * f).round(), (blue * f).round());
  }
}

extension DoubleExt on double {
  String toFormattedStringAsFixed(int fractionDigits) {
    final double value = roundToPrecision(fractionDigits);
    if (value.isWhole) return value.toStringAsFixed(0);
    return value.toStringAsFixed(fractionDigits);
  }
}
