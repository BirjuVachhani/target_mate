import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:system_tray/system_tray.dart';

import '../model/user.dart';
import '../resources/keys.dart';
import '../resources/resources.dart';
import 'extensions.dart';
import 'utils.dart';

class SystemTrayManager {
  SystemTray? _systemTray;
  AppWindow? _appWindow;
  Menu? _menu;

  String get defaultPlatformAppIconPath {
    return defaultTargetPlatform.isWindows
        ? SystemTrayIcons.windows
        : SystemTrayIcons.macos;
  }

  SystemTray get systemTray => _systemTray!;

  AppWindow get appWindow => _appWindow!;

  Menu get menu => _menu!;

  bool get isInitialized => _systemTray != null && _appWindow != null;

  bool get isNotSupported => kIsWeb || !defaultTargetPlatform.isDesktop;

  late BuildContext context;

  late final Map<Duration, MenuItemCheckbox> intervalItems = {
    for (final interval in intervals)
      interval: MenuItemCheckbox(
        label: interval.inMinutes == 1
            ? 'Every minute'
            : interval.inMinutes == 60
                ? 'Every hour'
                : 'Every ${interval.inMinutes} minutes',
        checked: refreshFrequency == interval,
        onClicked: (item) => _onIntervalItemSelected(interval),
      ),
  };

  late Duration refreshFrequency;

  Future<void> init(
    BuildContext context, {
    required VoidCallback refreshCallback,
  }) async {
    this.context = context;
    try {
      if (isNotSupported) return;

      refreshFrequency = Duration(
          minutes: getAppSettingsBox()
              .get(HiveKeys.refreshFrequency, defaultValue: 5));

      _systemTray = SystemTray();
      _appWindow = AppWindow();
      _menu = Menu();

      // We first init the systray menu
      await systemTray.initSystemTray(
        title: 'Target Mate',
        toolTip: 'Target Mate',
        iconPath: defaultPlatformAppIconPath,
      );

      // create context menu
      await menu.buildFrom(_buildMenu(refreshCallback: refreshCallback));

      // set context menu
      await systemTray.setContextMenu(menu);

      // handle system tray event
      systemTray.registerSystemTrayEventHandler((eventName) async {
        log('eventName: $eventName');
        if (eventName == kSystemTrayEventClick) {
          defaultTargetPlatform.isWindows
              ? await appWindow.show()
              : await systemTray.popUpContextMenu();
        } else if (eventName == kSystemTrayEventRightClick) {
          defaultTargetPlatform.isWindows
              ? await systemTray.popUpContextMenu()
              : await appWindow.show();
        }
        log('Event finished: $eventName');
      });
    } catch (error, stackTrace) {
      log(error.toString(), stackTrace: stackTrace);
    }
  }

  List<MenuItem> _buildMenu({
    required VoidCallback refreshCallback,
  }) {
    final User? user = getUserFromStorage();

    return [
      if (user?.fullName != null && user!.fullName.isNotEmpty)
        MenuItemLabel(
          label: user.fullName,
          name: 'fullName',
          enabled: false,
        ),
      if (user?.email != null && user!.email.isNotEmpty)
        MenuItemLabel(
          label: user.email,
          name: 'email',
          enabled: false,
        ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Sync',
        name: 'sync',
        onClicked: (menuItem) => refreshCallback(),
      ),
      SubMenu(label: 'Sync Interval', children: intervalItems.values.toList())
        ..name = 'syncInterval',
      MenuSeparator(),
      MenuItemLabel(
        label: 'Settings',
        name: 'settings',
        onClicked: (menuItem) {
          appWindow.show();
          openSettings(context);
        },
      ),
      MenuItemLabel(
        label: 'Show',
        name: 'show',
        onClicked: (menuItem) => appWindow.show(),
      ),
      MenuItemLabel(
        label: 'Hide',
        name: 'hide',
        onClicked: (menuItem) => appWindow.hide(),
      ),
      MenuItemLabel(
        label: 'Quit',
        name: 'quit',
        onClicked: (menuItem) => appWindow.close(),
      ),
    ];
  }

  void _onIntervalItemSelected(Duration duration) {
    if (isNotSupported) return;
    getAppSettingsBox().put(HiveKeys.refreshFrequency, duration.inMinutes);
    setSyncInterval(duration);
  }

  /// Sets the sync interval to the given [duration]. This must not be called
  /// by system tray event handlers. This should be called from app UI.
  Future<void> setSyncInterval(Duration duration) async {
    if (isNotSupported) return;
    for (final entry in intervalItems.entries) {
      await entry.value.setCheck(entry.key == duration);
    }
  }

  /// Sets the system tray title to the given [text].
  Future<void> setTitle(String text) async {
    if (isNotSupported) return;
    await systemTray.setTitle(text);
  }

  /// Sets the system tray icon to the given [path].
  Future<void> setIcon(String path) async {
    if (isNotSupported) return;
    await systemTray.setImage(path);
  }

  /// Sets the default app icon for the system tray.
  Future<void> setDefaultAppIcon() async {
    if (isNotSupported) return;
    await systemTray.setImage(defaultPlatformAppIconPath);
  }

  /// Sets the system tray icon to [SystemTrayIcons.iconDone] that indicates
  /// that today's target has been completed.
  Future<void> setCompletedAppIcon() async {
    if (isNotSupported) return;
    await systemTray.setImage(SystemTrayIcons.iconDone);
  }

  /// Sets the system tray menu's "Sync Interval" option to reflect the
  /// current sync interval.
  Future<void> setRefreshOption({
    required bool enabled,
    String label = 'Sync',
  }) async {
    if (isNotSupported) return;
    final item = menu.findItemByName<MenuItem>('sync');
    if (item == null) return;

    await item.setEnable(enabled);
    await item.setLabel(label);
  }

  Future<void> dispose() async {
    if (isNotSupported) return;
    await _systemTray?.destroy();
    _systemTray = null;
    _appWindow = null;
    _menu = null;
  }
}
