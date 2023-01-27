import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:system_tray/system_tray.dart';
import 'package:toggl_target/pages/home_store.dart';
import 'package:toggl_target/pages/settings.dart';
import 'package:toggl_target/utils/extensions.dart';

import 'utils.dart';

class SystemTrayManager {
  late SystemTray? _systemTray;
  late AppWindow? _appWindow;
  late Menu? _menu;

  SystemTray get systemTray => _systemTray!;

  AppWindow get appWindow => _appWindow!;

  Menu get menu => _menu!;

  bool get isInitialized => _systemTray != null && _appWindow != null;

  late final SettingsStore settingsStore = GetIt.instance.get<SettingsStore>();
  late final HomeStore homeStore = GetIt.instance.get<HomeStore>();

  bool get isNotSupported => kIsWeb || !defaultTargetPlatform.isDesktop;

  late final Map<Duration, MenuItemCheckbox> intervalItems = {
    for (final interval in intervals)
      interval: MenuItemCheckbox(
        label: interval.inMinutes == 1
            ? 'Every minute'
            : interval.inMinutes == 60
                ? 'Every hour'
                : 'Every ${interval.inMinutes} minutes',
        checked: settingsStore.refreshFrequency == interval,
        onClicked: (item) => _onIntervalItemSelected(interval),
      ),
  };

  Future<void> init() async {
    if (isNotSupported) return;

    _systemTray = SystemTray();
    _appWindow = AppWindow();
    _menu = Menu();

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
      if (homeStore.fullName.isNotEmpty)
        MenuItemLabel(
          label: homeStore.fullName,
          name: 'fullName',
          enabled: false,
        ),
      if (homeStore.email.isNotEmpty)
        MenuItemLabel(
          label: homeStore.email,
          name: 'email',
          enabled: false,
        ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Sync',
        name: 'sync',
        onClicked: (menuItem) => homeStore.refreshData(),
      ),
      SubMenu(label: 'Sync Interval', children: intervalItems.values.toList())
        ..name = 'syncInterval',
      MenuSeparator(),
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
  }

  void _onIntervalItemSelected(Duration duration) {
    if (isNotSupported) return;
    settingsStore.setRefreshFrequency(duration);
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
    await systemTray.destroy();
    _systemTray = null;
    _appWindow = null;
    _menu = null;
  }
}
