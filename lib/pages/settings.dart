import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:toggl_target/model/workspace.dart';
import 'package:toggl_target/pages/home_store.dart';
import 'package:toggl_target/resources/theme.dart';
import 'package:toggl_target/ui/custom_switch.dart';
import 'package:toggl_target/ui/gesture_detector_with_cursor.dart';
import 'package:toggl_target/ui/widgets.dart';
import 'package:toggl_target/utils/extensions.dart';

import '../model/project.dart';
import '../model/user.dart';
import '../resources/colors.dart';
import '../ui/back_button.dart';
import '../ui/custom_dropdown.dart';
import '../ui/custom_safe_area.dart';
import '../ui/custom_scaffold.dart';
import '../ui/dropdown_button3.dart';
import '../utils/system_tray_manager.dart';
import '../utils/utils.dart';
import 'settings_store.dart';

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

  List<Color>? customThemeColors;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    customThemeColors ??= context.theme.useMaterial3
        ? themeColors.map((e) => e.toPrimaryMaterial3()).toList()
        : themeColors;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: CustomSafeArea(
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            primary: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Center(
              child: SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CustomBackButton(usePrimaryColor: false),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: SetupTitle('App Settings'),
                    ),
                    const AppearanceSettings(),
                    const SizedBox(height: 16),
                    const SyncSettings(),
                    const SizedBox(height: 16),
                    const ProjectSettings(),
                    const SizedBox(height: 16),
                    const AccountSettings(),
                    const SizedBox(height: 40),
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
                          final buildNumber = data.buildNumber.isNotEmpty
                              ? '(${data.buildNumber})'
                              : '';
                          final suffix =
                              data.packageName.endsWith('dev') || !kReleaseMode
                                  ? '-dev'
                                  : '';
                          return Text(
                            'v${data.version}$buildNumber$suffix',
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppearanceSettings extends StatelessObserverWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<SettingsStore>();
    return SettingsSection(
      title: 'Appearance',
      children: [
        const Text('Theme'),
        const SizedBox(height: 8),
        ColorsView(
          current: store.themeColor,
          colors: themeColors,
          getPrimaryColor: (color) =>
              store.useMaterial3 ? color.toPrimaryMaterial3() : color,
          onSelected: (color) {
            store.setThemeColor(color);
            AdaptiveTheme.of(context).setTheme(
              light: getLightTheme(color, useMaterial3: store.useMaterial3),
              dark: getDarkTheme(color, useMaterial3: store.useMaterial3),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Use faded colors'),
                  const SizedBox(height: 4),
                  Text(
                    'Use Material 3 like desaturated version of the colors.',
                    style: subtitleTextStyle.copyWith(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            CustomSwitch(
              labelStyle: const TextStyle(
                fontSize: 14,
              ),
              value: store.useMaterial3,
              onChanged: (value) {
                store.onToggleUseMaterial3(value);
                AdaptiveTheme.of(context).setTheme(
                  light: getLightTheme(store.themeColor,
                      useMaterial3: store.useMaterial3),
                  dark: getDarkTheme(store.themeColor,
                      useMaterial3: store.useMaterial3),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class SyncSettings extends StatelessObserverWidget {
  const SyncSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<SettingsStore>();
    late final SystemTrayManager systemTrayManager =
        GetIt.instance.get<SystemTrayManager>();
    return SettingsSection(
      title: 'Sync & Info',
      children: [
        const Text('Refresh frequency'),
        FractionallySizedBox(
          widthFactor: 0.9,
          child: Text(
            'How often should the app sync with Toggl?',
            style: subtitleTextStyle.copyWith(
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 12),
        CustomDropdown<Duration>(
          value: store.refreshFrequency,
          isExpanded: true,
          onSelected: (value) {
            store.setRefreshFrequency(value);
            systemTrayManager.setSyncInterval(value);
          },
          selectedItemBuilder: (context, item) => Text(
            formatDuration(store.refreshFrequency),
            style: const TextStyle(fontSize: 14),
          ),
          itemBuilder: (context, item) => CustomDropdownMenuItem<Duration>(
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
                            color: store.refreshFrequency == item
                                ? context.theme.colorScheme.onPrimary
                                : Colors.white.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          items: intervals,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Show remaining'),
                  const SizedBox(height: 4),
                  Text(
                    'Show remaining total hours and working days instead of completed.',
                    style: subtitleTextStyle.copyWith(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            CustomSwitch(
              labelStyle: const TextStyle(
                fontSize: 14,
              ),
              value: store.showRemaining,
              onChanged: (value) {
                store.onToggleShowRemaining(value);
              },
            ),
          ],
        ),
      ],
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

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  late final User user;

  @override
  void initState() {
    super.initState();
    user = getUserFromStorage()!;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<SettingsStore>();
    return Observer(
      builder: (context) => SettingsSection(
        title: 'Account',
        children: [
          // const Text('Log out of your Toggl account?'),
          Text(user.fullName),
          // const SizedBox(height: 4),
          Text(
            user.email,
            // 'Logging out will remove all your data from this device.',
            style: subtitleTextStyle,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: logout,
            style: TextButton.styleFrom(
              foregroundColor: store.useMaterial3
                  ? context.theme.colorScheme.onTertiary
                  : context.theme.colorScheme.onPrimary,
              backgroundColor: store.useMaterial3
                  ? context.theme.colorScheme.tertiary
                  : context.theme.colorScheme.primary,
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class ProjectSettings extends StatelessObserverWidget {
  const ProjectSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<SettingsStore>();
    final homeStore = context.read<HomeStore>();
    return Stack(
      children: [
        SettingsSection(
          title: 'Workspace & Project',
          children: [
            const Text('Workspace'),
            const SizedBox(height: 8),
            CustomDropdown<Workspace>(
              value: store.selectedWorkspace,
              isExpanded: true,
              onSelected: (value) async {
                if (value.id == store.selectedWorkspace!.id) return;
                await store.onWorkspaceSelected(value);
                homeStore.refreshData();
              },
              itemBuilder: (context, item) => CustomDropdownMenuItem<Workspace>(
                value: item,
                child: Text(item.name),
              ),
              items: store.workspaces,
            ),
            const SizedBox(height: 16),
            const Text('Project'),
            const SizedBox(height: 8),
            CustomDropdown<Project>(
              value: store.selectedProject,
              isExpanded: true,
              onSelected: (value) async {
                if (value.id == store.selectedProject?.id) return;
                await store.onProjectSelected(value);
                homeStore.refreshData();
              },
              itemBuilder: (context, item) {
                return CustomDropdownMenuItem<Project>(
                  value: item,
                  child: Text(
                    item.name.isNotEmpty ? item.name : 'Untitled',
                    style: TextStyle(
                      color: item.name.isEmpty
                          ? context.theme.colorScheme.onSurface.withOpacity(0.5)
                          : null,
                      fontStyle: item.name.isNotEmpty ? null : FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                );
              },
              items: [
                emptyProject,
                ...store.filteredProjects,
              ],
            ),
          ],
        ),
        Positioned(
          top: 34,
          right: 16,
          child: Tooltip(
            message: 'Refresh',
            waitDuration: const Duration(milliseconds: 700),
            preferBelow: false,
            child: IconButton(
              splashRadius: 12,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              onPressed: store.loadWorkspacesAndProjects,
              icon: Observer(builder: (context) {
                const icon = Icon(Icons.sync);
                if (store.isLoadingProjects) {
                  return icon
                      .animate(onPlay: (controller) => controller.repeat())
                      .rotate(duration: 2.seconds);
                }

                return icon;
              }),
              iconSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsets? padding;

  const SettingsSection({
    super.key,
    this.title,
    this.padding,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title!.toUpperCase(),
              style: context.theme.textTheme.titleMedium!.copyWith(
                color: context.theme.colorScheme.primary,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
        const SizedBox(height: 6),
        Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

final List<Color> themeColors = [
  AppColors.primaryColor,
  Colors.blue,
  Colors.red,
  Colors.orange,
  Colors.teal,
  Colors.deepPurpleAccent,
  Colors.grey,
];

class ColorsView extends StatelessWidget {
  final Color current;
  final ValueChanged<Color> onSelected;
  final List<Color>? colors;
  final Color Function(Color color) getPrimaryColor;

  const ColorsView({
    super.key,
    required this.current,
    required this.onSelected,
    required this.getPrimaryColor,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final color in colors ?? themeColors)
          ColorButton(
            color: getPrimaryColor(color),
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
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              color,
              color.darken(90),
            ],
            stops: const [0.48, 0.48],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: selected ? Colors.white : color,
            width: selected ? 1.5 : 1.5,
          ),
        ),
        child: selected
            ? const ImageIcon(
                AssetImage('assets/icon_done.png'),
                size: 20,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
