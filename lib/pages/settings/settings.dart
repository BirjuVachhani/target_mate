import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../model/project.dart';
import '../../model/time_entry.dart';
import '../../model/toggl_client.dart';
import '../../model/user.dart';
import '../../model/workspace.dart';
import '../../resources/colors.dart';
import '../../resources/resources.dart';
import '../../resources/theme.dart';
import '../../resources/urls.dart';
import '../../ui/back_button.dart';
import '../../ui/custom_dropdown.dart';
import '../../ui/custom_safe_area.dart';
import '../../ui/custom_scaffold.dart';
import '../../ui/custom_switch.dart';
import '../../ui/dropdown_button3.dart';
import '../../ui/gesture_detector_with_cursor.dart';
import '../../ui/network_markdown_page.dart';
import '../../ui/svg_icon.dart';
import '../../ui/widgets.dart';
import '../../utils/extensions.dart';
import '../../utils/font_variations.dart';
import '../../utils/system_tray_manager.dart';
import '../../utils/utils.dart';
import '../home/home_store.dart';
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
            padding:
                const EdgeInsets.fromLTRB(kSidePadding, 8, kSidePadding, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CustomBackButton(usePrimaryColor: false),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: SetupTitle('App Settings'),
                    ),
                    const AppearanceSettings(),
                    const SizedBox(height: 24),
                    const SyncSettings(),
                    const SizedBox(height: 24),
                    const ProjectSettings(),
                    const SizedBox(height: 24),
                    const MoreInfoSection(),
                    const SizedBox(height: 24),
                    const AccountSettings(),
                    const SizedBox(height: 40),
                    Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        Images.logoTrimmed,
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
                            style: TextStyle(
                              color: context.theme.textColor.withOpacity(0.6),
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
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingItemTitle('Theme'),
                  Text(
                    'Customize your theme',
                    style: subtitleTextStyle(context),
                  ),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                final manager = AdaptiveTheme.of(context);
                return ToggleButtons(
                  borderRadius: BorderRadius.circular(6),
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 40),
                  onPressed: (index) {
                    final mode = AdaptiveThemeMode.values[index];
                    manager.setThemeMode(mode);
                  },
                  isSelected: [
                    manager.mode == AdaptiveThemeMode.light,
                    manager.mode == AdaptiveThemeMode.dark,
                    manager.mode == AdaptiveThemeMode.system,
                  ],
                  children: const [
                    Tooltip(
                      message: 'Light Mode',
                      waitDuration: Duration(milliseconds: 500),
                      child: Center(child: Icon(Icons.sunny, size: 18)),
                    ),
                    Tooltip(
                      message: 'Dark Mode',
                      waitDuration: Duration(milliseconds: 500),
                      child: Center(child: Icon(Icons.nightlight, size: 18)),
                    ),
                    Tooltip(
                      message: 'Same as System',
                      waitDuration: Duration(milliseconds: 500),
                      child: Center(
                          child:
                              Icon(Icons.brightness_auto_outlined, size: 18)),
                    )
                  ],
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SettingItemTitle('Colors'),
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
                  const SettingItemTitle('Use faded colors'),
                  const SizedBox(height: 4),
                  Text(
                    'Use Material 3 like desaturated version of the colors.',
                    style: subtitleTextStyle(context),
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
        const SettingItemTitle('Refresh frequency'),
        FractionallySizedBox(
          widthFactor: 0.9,
          child: Text(
            'How often should the app sync with Toggl?',
            style: subtitleTextStyle(context),
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
                  const SettingItemTitle('Show remaining'),
                  const SizedBox(height: 4),
                  Text(
                    'Show remaining total hours and working days instead of completed.',
                    style: subtitleTextStyle(context),
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
          SettingItemTitle(user.fullName),
          // const SizedBox(height: 4),
          Text(
            user.email,
            // 'Logging out will remove all your data from this device.',
            style: subtitleTextStyle(context),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: logout,
            style: TextButton.styleFrom(
              foregroundColor: store.useMaterial3
                  ? context.theme.colorScheme.onError
                  : Colors.white,
              backgroundColor: store.useMaterial3
                  ? context.theme.colorScheme.error
                  : context.theme.colorScheme.error,
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
          title: 'Filters',
          children: [
            const SettingItemTitle('Workspace'),
            Text(
              'Select a workspace to track time for its projects.',
              style: subtitleTextStyle(context),
            ),
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
            const SettingItemTitle('Client'),
            Text(
              'Select a client to track time for its projects.',
              style: subtitleTextStyle(context),
            ),
            const SizedBox(height: 8),
            CustomDropdown<TogglClient>(
              value: store.selectedClient,
              isExpanded: true,
              onSelected: (value) async {
                if (value.id == store.selectedClient?.id) return;
                await store.onClientSelected(value);
                homeStore.refreshData();
              },
              itemBuilder: (context, item) {
                return CustomDropdownMenuItem<TogglClient>(
                  value: item,
                  child: Text(
                    item.name.isNotEmpty ? item.name : 'Untitled',
                    style: TextStyle(
                      color: item.name.isEmpty
                          ? context.theme.textColor.withOpacity(0.5)
                          : null,
                      fontStyle: item.name.isNotEmpty ? null : FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                );
              },
              items: [emptyClient, ...store.filteredClients],
            ),
            const SizedBox(height: 16),
            const SettingItemTitle('Project'),
            Text(
              'Select a project to track your time for.',
              style: subtitleTextStyle(context),
            ),
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
                          ? context.theme.textColor.withOpacity(0.5)
                          : null,
                      fontStyle: item.name.isNotEmpty ? null : FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                );
              },
              items: [emptyProject, ...store.filteredProjects],
            ),
            const SizedBox(height: 16),
            const SettingItemTitle('What to track?'),
            Text(
              'Select what type of time entries you want to track.',
              style: subtitleTextStyle(context),
            ),
            const SizedBox(height: 8),
            CustomDropdown<TimeEntryType>(
              value: store.selectedTimeEntryType,
              isExpanded: true,
              items: TimeEntryType.values,
              onSelected: (value) async {
                await store.onTimeEntryTypeSelected(value);
                homeStore.refreshData();
              },
              itemBuilder: (context, item) {
                return CustomDropdownMenuItem<TimeEntryType>(
                  value: item,
                  child: Text(
                    item.prettify,
                    style: TextStyle(
                      color: item.name.isEmpty
                          ? context.theme.textColor.withOpacity(0.5)
                          : null,
                      fontStyle: item.name.isNotEmpty ? null : FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        Positioned(
          top: 30,
          right: 10,
          child: Tooltip(
            message: 'Refresh',
            waitDuration: const Duration(milliseconds: 700),
            preferBelow: false,
            child: IconButton(
              splashRadius: 12,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              onPressed: store.loadFilters,
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

class MoreInfoSection extends StatelessObserverWidget {
  const MoreInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Extra',
      padding: EdgeInsets.zero,
      children: [
        SettingsTile(
          label: "What's new",
          subtitle: 'See what has changed in the latest version.',
          leading: const Icon(Icons.auto_awesome),
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(48),
              topRight: Radius.circular(48),
            ),
          ),
          onTap: () async {
            final packageInfo = await PackageInfo.fromPlatform();
            navigator.push(
              CupertinoPageRoute(
                builder: (_) => NetworkMarkdownPage(
                  title: "What's new ✨",
                  url: Urls.changelogMarkdown
                      .replaceAll('{version}', packageInfo.version),
                ),
              ),
            );
          },
          trailing: const Icon(Icons.arrow_forward_ios_rounded),
        ),
        if (defaultTargetPlatform
            case TargetPlatform.android ||
                TargetPlatform.iOS ||
                TargetPlatform.macOS)
          SettingsTile(
            label: 'Rate the app',
            leading: const Icon(Icons.star_border),
            subtitle:
                'If you like the app, rate us tell others what you think about the app.',
            onTap: () {
              final url = switch (defaultTargetPlatform) {
                TargetPlatform.android => Urls.playStore,
                TargetPlatform.iOS => Urls.iosAppStore,
                TargetPlatform.macOS => Urls.macOSAppStore,
                _ => '',
              };
              if (url.isNotEmpty) launchUrlString(url);
            },
            trailing: const Icon(Icons.open_in_new),
          ),
        SettingsTile(
          label: 'Report an issue',
          leading: const Icon(Icons.bug_report_outlined),
          subtitle:
              'Found a bug? Report it on Github and we will fix it as soon as possible.',
          onTap: () => launchUrlString(Urls.reportIssue),
          trailing: const Icon(Icons.open_in_new),
        ),
        // Apple rejects apps that have donation links.
        // SettingsTile(
        //   label: 'Donate',
        //   subtitle:
        //       'If you like the app, consider donating whatever you can to support it.',
        //   leading: const Icon(Icons.paid_outlined),
        //   onTap: () => launchUrlString(Urls.githubSponsor),
        //   trailing: const Icon(Icons.open_in_new),
        // ),
        SettingsTile(
          label: 'View on Github',
          subtitle: 'Star the repo on Github if you like the app.',
          leading: const SvgIcon.asset(Vectors.github, size: 24),
          onTap: () => launchUrlString(Urls.github),
          trailing: const Icon(Icons.open_in_new),
        ),
        SettingsTile(
          label: 'Privacy Policy',
          leading: const Icon(Icons.article_outlined),
          onTap: () {
            navigator.push(
              CupertinoPageRoute(
                builder: (_) =>
                    const NetworkMarkdownPage(url: Urls.privacyPolicyMarkdown),
              ),
            );
          },
          trailing: const Icon(Icons.arrow_forward_ios_rounded),
        ),
        SettingsTile(
          label: 'License',
          leading: const Icon(Icons.article_outlined),
          onTap: () {
            navigator.push(
              CupertinoPageRoute(
                builder: (_) => const NetworkMarkdownPage(
                  title: 'License',
                  url: Urls.licenseMarkdown,
                ),
              ),
            );
          },
          trailing: const Icon(Icons.arrow_forward_ios_rounded),
        ),
        SettingsTile(
          label: 'Third party licenses',
          leading: const Icon(Icons.article_outlined),
          onTap: () async {
            final packageInfo = await PackageInfo.fromPlatform();
            navigator.push(
              CupertinoPageRoute(
                builder: (_) =>
                    ThirdPartyLicensesPage(packageInfo: packageInfo),
              ),
            );
          },
          trailing: const Icon(Icons.arrow_forward_ios_rounded),
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(48),
              bottomRight: Radius.circular(48),
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final String? subtitle;
  final ShapeBorder? shape;

  const SettingsTile({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.subtitle,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: shape,
      overlayColor: WidgetStateProperty.all(
          context.theme.colorScheme.primary.withOpacity(0.1)),
      child: Padding(
        padding: padding ?? const EdgeInsets.fromLTRB(12, 12, 16, 12),
        child: Row(
          children: [
            if (leading != null) ...[
              SizedBox.square(
                dimension: 24,
                child: IconTheme(
                  data: IconTheme.of(context).copyWith(
                    size: 20,
                    color: context.theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  child: Center(child: leading),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontVariations: FontVariations.medium,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        fontVariations: FontVariations.normal,
                        color: context.theme.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              IconTheme(
                data: IconTheme.of(context).copyWith(
                  size: 16,
                  color: context.theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                child: trailing!,
              ),
            ],
          ],
        ),
      ),
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
                  fontSize: 12,
                  letterSpacing: 1,
                  fontVariations: FontVariations.semiBold),
            ),
          ),
        const SizedBox(height: 8),
        Container(
          padding: padding ?? const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            ),
            color: context.theme.colorScheme.primary.withOpacity(0.05),
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
  AppColors.togglColor,
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              color,
              context.theme.brightness.isLight
                  ? color.shade(5)
                  : color.darken(95),
            ],
            stops: const [0.48, 0.48],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: selected ? context.theme.textColor : color,
            width: selected ? 1.5 : 1.5,
          ),
        ),
        child: selected
            ? ImageIcon(
                const AssetImage(SystemTrayIcons.iconDone),
                size: 20,
                color: context.theme.textColor,
              )
            : null,
      ),
    );
  }
}

class SettingItemTitle extends StatelessWidget {
  final String label;
  final TextStyle? style;

  const SettingItemTitle(
    this.label, {
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: style ??
          context.theme.textTheme.titleMedium!.copyWith(
            fontSize: 14,
            fontVariations: FontVariations.semiBold,
          ),
    );
  }
}

class ThirdPartyLicensesPage extends StatelessWidget {
  final PackageInfo packageInfo;

  const ThirdPartyLicensesPage({super.key, required this.packageInfo});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: CustomSafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(
                size: 20,
              ),
              centerTitle: false,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontVariations: FontVariations.semiBold,
              ),
            ),
            scaffoldBackgroundColor: context.theme.scaffoldBackgroundColor,
            cardColor: context.theme.scaffoldBackgroundColor,
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  surface: context.theme.scaffoldBackgroundColor,
                  surfaceTint: context.theme.scaffoldBackgroundColor,
                ),
          ),
          child: LicensePage(
            applicationName: packageInfo.appName,
            applicationVersion: packageInfo.version,
          ),
        ),
      ),
    );
  }
}
