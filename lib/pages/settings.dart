import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:toggl_target/resources/keys.dart';
import 'package:toggl_target/resources/theme.dart';
import 'package:toggl_target/ui/gesture_detector_with_cursor.dart';
import 'package:toggl_target/ui/widgets.dart';

import '../resources/colors.dart';
import '../ui/back_button.dart';
import '../ui/custom_dropdown.dart';
import '../ui/custom_safe_area.dart';
import '../ui/dropdown_button3.dart';
import '../utils/system_tray_manager.dart';
import '../utils/utils.dart';

part 'settings.g.dart';

// ignore: library_private_types_in_public_api
class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
  late final Box box = getAppSettingsBox();

  _SettingsStore() {
    init();
  }

  @observable
  Color themeColor = Colors.transparent;

  @observable
  Duration refreshFrequency = 5.minutes;

  StreamSubscription? subscription;

  void init() {
    subscription = getAppSettingsBox()
        .watch(key: HiveKeys.refreshFrequency)
        .listen((event) {
      refresh();
    });

    themeColor = Color(box.get(HiveKeys.primaryColor));
    refreshFrequency =
        Duration(minutes: box.get(HiveKeys.refreshFrequency, defaultValue: 5));
  }

  void refresh() {
    themeColor = Color(box.get(HiveKeys.primaryColor));
    refreshFrequency =
        Duration(minutes: box.get(HiveKeys.refreshFrequency, defaultValue: 5));
  }

  @action
  void setThemeColor(Color color) {
    themeColor = color;
    box.put(HiveKeys.primaryColor, color.value);
  }

  @action
  void setRefreshFrequency(Duration duration) {
    refreshFrequency = duration;
    box.put(HiveKeys.refreshFrequency, duration.inMinutes);
  }

  void dispose() {
    subscription?.cancel();
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsStore store = context.read<SettingsStore>();
  late final SystemTrayManager systemTrayManager =
      GetIt.instance.get<SystemTrayManager>();

  late final Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomSafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: 350,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CustomBackButton(usePrimaryColor: false),
                        const SizedBox(height: 16),
                        const SetupTitle('Select theme color'),
                        const SizedBox(height: 8),
                        Observer(
                          builder: (context) {
                            return ColorsView(
                              current: store.themeColor,
                              onSelected: (color) {
                                store.setThemeColor(color);
                                AdaptiveTheme.of(context).setTheme(
                                    light: getTheme(color),
                                    dark: getTheme(color));
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const FieldLabel('Refresh frequency'),
                        Observer(
                          builder: (context) {
                            return CustomDropdown<Duration>(
                              value: store.refreshFrequency,
                              isExpanded: true,
                              onSelected: (value) {
                                store.setRefreshFrequency(value);
                                systemTrayManager.setSyncInterval(value);
                              },
                              selectedItemBuilder: (context, item) => Text(
                                formatDuration(store.refreshFrequency),
                              ),
                              itemBuilder: (context, item) =>
                                  CustomDropdownMenuItem<Duration>(
                                value: item,
                                child: item.inMinutes != 5
                                    ? Text(
                                        formatDuration(item),
                                      )
                                    : Text.rich(
                                        TextSpan(
                                          text: formatDuration(item),
                                          children: [
                                            TextSpan(
                                              text: ' (Recommended)',
                                              style: TextStyle(
                                                color:
                                                    store.refreshFrequency ==
                                                            item
                                                        ? context
                                                            .theme
                                                            .colorScheme
                                                            .onPrimary
                                                        : Colors.white
                                                            .withOpacity(0.5),
                                                fontStyle: FontStyle.italic,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              items: intervals,
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: TextButton.icon(
                            onPressed: logout,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              backgroundColor: Colors.red.withOpacity(0.1),
                            ),
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text('Logout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/logo_trimmed.png',
                width: 100,
                color: context.theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: FutureBuilder<PackageInfo>(
                future: packageInfo,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final data = snapshot.data;
                  if (data == null) return const SizedBox.shrink();
                  return Text(
                    'v${data.version}(${data.buildNumber})${data.packageName.endsWith('dev') || !kReleaseMode ? '-dev' : ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration item) {
    final minutes = item.inMinutes;
    if (minutes == 1) {
      return '1 minute';
    } else if (minutes < 60) {
      return '$minutes minutes';
    } else {
      final hours = minutes ~/ 60;
      return '$hours hour${hours == 1 ? '' : 's'}';
    }
  }
}

const List<Color> themeColors = [
  AppColors.primaryColor,
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.purple,
  Colors.orange,
  Colors.pink,
  Colors.teal,
  Colors.cyan,
  Colors.lime,
  Colors.yellow,
  Colors.indigo,
  Colors.brown,
  Colors.grey,
];

class ColorsView extends StatelessWidget {
  final Color current;
  final ValueChanged<Color> onSelected;

  const ColorsView({
    super.key,
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 12,
      spacing: 12,
      children: [
        for (final color in themeColors)
          ColorButton(
            color: color,
            selected: color.value == current.value,
            onPressed: () => onSelected(color),
          ),
      ],
    );
  }
}

class ColorButton extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  const ColorButton({
    super.key,
    required this.color,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetectorWithCursor(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: selected
            ? const Icon(
                Icons.done_rounded,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
