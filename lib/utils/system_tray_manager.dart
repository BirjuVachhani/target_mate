import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:system_tray/system_tray.dart';
import 'package:toggl_target/resources/keys.dart';
import 'package:toggl_target/utils/extensions.dart';

import '../model/user.dart';
import 'utils.dart';

class SystemTrayManager {
  SystemTray? _systemTray;
  AppWindow? _appWindow;
  Menu? _menu;

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

      final User? user = getUserFromStorage();

      String path = defaultTargetPlatform.isWindows
          ? 'assets/icon_system_tray.ico'
          : 'assets/icon_system_tray.png';

      // We first init the systray menu
      await systemTray.initSystemTray(
        title: 'Toggl Target',
        toolTip: 'Toggl Target',
        iconPath: path,
      );

      // create context menu
      await menu.buildFrom([
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
      ]);

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

  void _onIntervalItemSelected(Duration duration) {
    if (isNotSupported) return;
    getAppSettingsBox().put(HiveKeys.refreshFrequency, duration.inMinutes);
    setSyncInterval(duration);
  }

  Future<void> setSyncInterval(Duration duration) async {
    if (isNotSupported) return;
    for (final entry in intervalItems.entries) {
      await entry.value.setCheck(entry.key == duration);
    }
  }

  Future<void> setTitle(String text) async {
    if (isNotSupported) return;
    await systemTray.setTitle(text);
  }

  Future<void> setIcon(String path) async {
    if (isNotSupported) return;
    await systemTray.setImage(path);
  }

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
