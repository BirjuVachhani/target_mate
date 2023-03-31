import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../resources/resources.dart';
import 'extensions.dart';

class AppIconManager {
  late final MethodChannel? _channel;

  Uint8List? _defaultIcon;
  Uint8List? _inactiveIcon;

  AppIconManager() {
    init();
  }

  Future<void> init() async {
    /// Don't initialize on mobile platforms
    if (defaultTargetPlatform.isMobile) return;

    // Initialize platform channels
    _channel = const MethodChannel('target-mate');

    // Get default icon
    _defaultIcon = await getDefaultIcon();
    _inactiveIcon = await getInactiveIcon();
    log('AppIconManager initialized');
  }

  Future<void> setAppIcon({required bool inactive}) async {
    try {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.iOS:
          log('Unsupported platform for setAppIcon: ${defaultTargetPlatform.toString()}');
          return;
        case TargetPlatform.linux:
          // Unsupported
          break;
        case TargetPlatform.macOS:
          return _setIconForMacOS(inactive: inactive);
        case TargetPlatform.windows:
          // Unsupported
          break;
      }
    } catch (error, stacktrace) {
      log('Error while setting app icon:');
      log(error.toString());
      log(stacktrace.toString());
    }
  }

  // Future<void> _setIconForIos({required bool inactive}) async {
  // if (!await FlutterDynamicIcon.supportsAlternateIcons) {
  //   log('Error while setting iOS app icon: alternate icons are not supported');
  //   return;
  // }
  // await FlutterDynamicIcon.setAlternateIconName(
  //   inactive ? 'inactive' : 'default',
  //   showAlert: false,
  // );
  // }

  Future<void> _setIconForMacOS({required bool inactive}) async {
    final bytes = inactive ? _inactiveIcon : _defaultIcon;
    if (bytes == null) {
      log('Error while setting MacOS app icon: bytes are null');
      return;
    }
    log('Setting MacOS app icon to ${inactive ? 'inactive' : 'default'}');
    await _channel?.invokeMethod('setAppIcon', bytes);
  }

  Future<Uint8List?> getInactiveIcon() async {
    try {
      // Read image from AssetBundle.
      final byteData = await rootBundle.load(getInactiveIconAssetPath());
      return byteData.buffer.asUint8List();

      // TargetMateAppIcon appIcon =
      //     TargetMateAppIcon.platform(color: AppColors.inactiveAppIconColor);

      // return await appIcon.toImage(
      //   size: const Size.square(1024),
      //   delay: const Duration(milliseconds: 100),
      // );
    } catch (error, stacktrace) {
      log('Error while getting inactive app icon:');
      log(error.toString());
      log(stacktrace.toString());
      return null;
    }
  }

  Future<Uint8List?> getDefaultIcon() async {
    try {
      // Read image from AssetBundle.
      final byteData = await rootBundle.load(getDefaultIconAssetPath());
      return byteData.buffer.asUint8List();

      // TargetMateAppIcon appIcon = TargetMateAppIcon.platform();
      // return await appIcon.toImage(
      //   size: const Size.square(1024),
      //   delay: const Duration(milliseconds: 100),
      // );
    } catch (error, stacktrace) {
      log('Error while getting default app icon:');
      log(error.toString());
      log(stacktrace.toString());
      return null;
    }
  }

  String getDefaultIconAssetPath() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.iOS:
        return AppIcons.ios;
      case TargetPlatform.macOS:
        return AppIcons.macos;
      case TargetPlatform.windows:
        return AppIcons.windows;
    }
  }

  String getInactiveIconAssetPath() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.iOS:
        return AppIcons.iosInactive;
      case TargetPlatform.macOS:
        return AppIcons.macosInactive;
      case TargetPlatform.windows:
        return AppIcons.windowsInactive;
    }
  }
}
