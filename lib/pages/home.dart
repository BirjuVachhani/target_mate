import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:toggl_target/model/day_entry.dart';
import 'package:toggl_target/pages/setup/target_setup_page.dart';
import 'package:toggl_target/pages/target_store.dart';
import 'package:toggl_target/utils/extensions.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../resources/colors.dart';
import '../ui/animated_horizontal_progress_bar.dart';
import '../ui/custom_safe_area.dart';
import '../ui/custom_scaffold.dart';
import '../ui/gradient_background.dart';
import '../utils/utils.dart';
import 'home_store.dart';
import 'settings_store.dart';

class HomePageWrapper extends StatelessWidget {
  const HomePageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => TargetStore(),
          dispose: (context, store) => store.dispose(),
        ),
        Provider(
          create: (context) => SettingsStore(),
          dispose: (context, store) => store.dispose(),
        ),
        ProxyProvider<TargetStore, HomeStore>(
          create: (context) =>
              HomeStore(Provider.of<TargetStore>(context, listen: false)),
          update: (context, targetStore, previous) {
            return previous ?? HomeStore(targetStore);
          },
        ),
      ],
      child: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeStore store = context.read<HomeStore>();
  late final TargetStore targetStore = context.read<TargetStore>();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      requestNotificationPermission();
      checkForUpdates();
    });
    store.init(context);
  }

  void requestNotificationPermission() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_launcher_foreground');
      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      );

      const LinuxInitializationSettings initializationSettingsLinux =
          LinuxInitializationSettings(defaultActionName: 'Open notification');

      final InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: initializationSettingsDarwin,
              macOS: initializationSettingsDarwin,
              linux: initializationSettingsLinux);
      await store.flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

      if (defaultTargetPlatform.isIOS) {
        await store.flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      } else if (defaultTargetPlatform.isMacOS) {
        await store.flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              sound: true,
            );
      } else if (defaultTargetPlatform.isAndroid) {
        await store.flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestPermission();
      }
    } catch (error, stackTrace) {
      log('Error initializing notifications');
      log(error.toString());
      log(stackTrace.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      systemNavigationBarColor: context.theme.colorScheme.primary.darken(85),
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HomeHeader(onEdit: onEdit),
              Expanded(
                child: Observer(builder: (context) {
                  if (store.isLoading && !store.isLoadingWithData) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SpinKitPouringHourGlassRefined(
                            size: 64,
                            color: context.theme.colorScheme.primary
                                .withOpacity(0.25),
                            duration: const Duration(milliseconds: 2000),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Hold on, loading your entries...',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (store.timeEntries == null && store.error != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: context.theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          FractionallySizedBox(
                            widthFactor: 0.8,
                            child: Text(
                              store.error ??
                                  'Unable to load entries.\nPlease check your internet connection!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.theme.colorScheme.error,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: store.refreshData,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (store.timeEntries == null || store.timeEntries!.isEmpty) {
                    return const Center(
                      child: Text('No entries found'),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ListView.separated(
                      itemCount: store.dayEntries.length,
                      primary: false,
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return PerDayTimeEntryView(
                          date: store.dayEntries.keys.elementAt(index),
                          entry: store.dayEntries.values.elementAt(index),
                        );
                      },
                    ),
                  );
                }),
              ),
              const BottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onEdit() async {
    final bool? modified = await Navigator.of(context).push<bool?>(
      CupertinoPageRoute(
        builder: (context) => Provider.value(
          value: targetStore,
          child: const TargetSetupPage(),
        ),
      ),
    );
    if (modified == true) {
      targetStore.refresh();
      store.refreshData();
    }
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}

  void onDidReceiveNotificationResponse(NotificationResponse details) {}

  Future<void> checkForUpdates() async {
    final Version? latestVersion = await store.getLatestRelease();

    if (latestVersion == null) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = Version.parse(packageInfo.version);

    // enable this for testing update UI.
    // final currentVersion = Version(0, 0, 1);

    if (latestVersion > currentVersion) {
      showUpdateAvailableUI(latestVersion);
    }
  }

  void showUpdateAvailableUI(Version latestVersion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('A new version is available!'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 34),
        showCloseIcon: true,
        duration: const Duration(days: 1),
        action: SnackBarAction(
          label: 'Download',
          onPressed: () {
            launchUrlString(
                'https://github.com/birjuvachhani/toggl_target/releases/$latestVersion');
          },
        ),
      ),
    );
  }
}

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  late final store = context.read<HomeStore>();
  late final settingsStore = context.read<SettingsStore>();

  late DateTime _initialTime;
  late DateTime _now;
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      startTicker();
    });
  }

  void onTick(Duration elapsed) {
    final newTime = _initialTime.add(elapsed);
    if (_now.second != newTime.second) {
      onTimerCallback();
      if (_now.minute != newTime.minute) {
        log('Time changed: $_now');
      }
      _now = newTime;
      setState(() {});
    }
  }

  /// Start the timer for auto background refresh.
  void startTicker() {
    _ticker = createTicker(onTick);
    _initialTime = _now = DateTime.now();
    _ticker?.start();
  }

  void onTimerCallback() {
    final lastUpdated = store.lastUpdated;
    if (lastUpdated == null) return;
    // Enable this to see timer logs
    // final Duration nextRefreshTime = lastUpdated
    //     .add(settingsStore.refreshFrequency)
    //     .difference(DateTime.now());
    // log('Next data refresh in ${nextRefreshTime.inMinutes}:${nextRefreshTime.inSeconds % 60}');
    if (lastUpdated
        .add(settingsStore.refreshFrequency)
        .isBefore(DateTime.now())) {
      log('Refreshing data from timer...');
      store.refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primary.darken(85),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Observer(builder: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (store.isLoading) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(
                      color: context.theme.colorScheme.primary,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Syncing...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                )
              ],
              if (store.lastUpdated != null && !store.isLoadingWithData)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.sync,
                    color: Colors.white.withOpacity(0.7),
                    size: 14,
                  ),
                ),
              if (store.lastUpdated != null && !store.isLoadingWithData)
                Expanded(
                  child: Text(
                    formatLastUpdated(
                        DateTime.now().difference(store.lastUpdated!)),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              Icon(
                Icons.schedule_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Every ${formatFrequency(settingsStore.refreshFrequency)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String formatFrequency(Duration item) {
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

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  String formatLastUpdated(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 1) {
      if (duration.inSeconds < 10) return 'Just now';
      if (duration.inSeconds < 30) return 'Few seconds ago';
      return 'Less than a minute ago';
    }
    if (minutes < 60) {
      return '$minutes minute${minutes != 1 ? 's' : ''} ago';
    }
    final hours = minutes ~/ 60;
    if (hours < 24) {
      return '$hours hours ago';
    }
    final days = hours ~/ 24;
    return '$days days ago';
  }
}

class PerDayTimeEntryView extends StatelessWidget {
  const PerDayTimeEntryView({
    super.key,
    required this.date,
    required this.entry,
  });

  final DateTime date;
  final DayEntry entry;

  @override
  Widget build(BuildContext context) {
    final totalDuration = entry.duration;
    return Container(
      padding: const EdgeInsets.only(top: 0, bottom: 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: context.theme.colorScheme.primary.withOpacity(0.05),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: context.theme.colorScheme.primary.withOpacity(0.05),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formatDate(date),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  formatTotalDuration(totalDuration),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: entry.isTargetAchieved
                        ? Colors.green
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 14),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: entry.entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = entry.entries[index];
              return Row(
                children: [
                  if (item.isRunning)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: context.theme.colorScheme.primary
                                .withOpacity(0.2),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Running'.toUpperCase(),
                                style: TextStyle(
                                  color: context.theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description?.isNotEmpty == true
                                    ? item.description!
                                    : 'No Description',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: item.description == null
                                      ? Colors.white.withOpacity(0.4)
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (!item.isRunning)
                    Expanded(
                      child: Text(
                        item.description?.isNotEmpty == true
                            ? item.description!
                            : 'No Description',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: item.description == null
                              ? Colors.white.withOpacity(0.4)
                              : Colors.white70,
                        ),
                      ),
                    ),
                  const SizedBox(width: 14),
                  Text(
                    formatDuration(item.duration),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.4,
                      color: Colors.white70,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          if (entry.isWorkingDay) ...[
            const Divider(height: 0.5, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '',
                      children: [
                        const TextSpan(
                          text: 'Goal: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: formatTotalDuration(entry.target),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                      // color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${((entry.duration.inMinutes / entry.target.inMinutes) * 100).clamp(0, 100).floor()}% Achieved',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // hh h mm min
  String formatTotalDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '$hours h ${minutes.toString().padLeft(2, '0')} min';
  }

  // hh:mm:ss
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime date) {
    if (date.isToday) return 'Today';
    if (date.isYesterday) return 'Yesterday';
    return DateFormat('EEE, dd MMM').format(date);
  }
}

class HomeHeader extends StatelessWidget {
  final VoidCallback onEdit;

  const HomeHeader({super.key, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final HomeStore store = context.read<HomeStore>();
    final TargetStore targetStore = context.read<TargetStore>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (context.theme.platform.isDesktop)
            SizedBox(
              height: kMacOSTopPadding,
              child: Center(
                child: Image.asset(
                  'assets/logo_trimmed.png',
                  fit: BoxFit.fitHeight,
                  height: 16,
                  color: context.theme.colorScheme.background,
                ),
              ),
            ),
          // SizedBox(
          //     height: kMacOSTopPadding,
          //     child: Center(
          //       child: Text(
          //         'Toggl Target',
          //         style: TextStyle(
          //           fontSize: 13,
          //           fontWeight: FontWeight.w500,
          //           color: context.theme.colorScheme.onPrimary.withOpacity(0.8),
          //         ),
          //       ),
          //     ),
          //   ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.backgroundColorDarker,
                    radius: 18,
                    backgroundImage: store.user != null
                        ? NetworkImage(store.user!.avatarUrl)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(builder: (context) {
                      if (constraints.maxWidth <= 305) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            store.user?.fullName ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Text(
                          //   DateFormat('EEEE, dd').format(DateTime.now()),
                          //   style: TextStyle(
                          //     fontSize: 13,
                          //     color: Colors.white.withOpacity(0.5),
                          //   ),
                          // ),
                          // Text(
                          //   store.email,
                          //   style: TextStyle(
                          //     fontSize: 13,
                          //     color: Colors.white.withOpacity(0.5),
                          //   ),
                          // ),
                        ],
                      );
                    }),
                  ),
                  if (constraints.maxWidth <= 190)
                    SizedBox(
                      width: 38,
                      child: Observer(
                        builder: (context) {
                          return TextButton(
                            onPressed:
                                store.isLoading ? null : store.refreshData,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withOpacity(0.1),
                            ),
                            child: store.isLoading
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: Center(
                                      child: SizedBox.square(
                                        dimension: 14,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 20),
                          );
                        },
                      ),
                    )
                  else
                    Observer(
                      builder: (context) {
                        return FilledButton.icon(
                          onPressed: store.isLoading ? null : store.refreshData,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                          icon: store.isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: Center(
                                    child: SizedBox.square(
                                      dimension: 14,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text('Refresh'),
                        );
                      },
                    ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 38,
                    child: Tooltip(
                      message: 'Settings',
                      waitDuration: 700.milliseconds,
                      child: FilledButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                        onPressed: () {
                          openSettings(context);
                        },
                        child: const Icon(Icons.settings, size: 20),
                        // label: const Text('Logout'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Observer(
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy')
                              .format(DateTime.now())
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              if (store.isLoading)
                                const WidgetSpan(
                                  child: SizedBox(
                                    width: 48,
                                    height: 24,
                                    child: Center(
                                      child: SpinKitThreeBounce(
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                TextSpan(
                                  text: formatCompletedDuration(
                                      store, targetStore),
                                ),
                              TextSpan(
                                text: formatTotalDuration(store, targetStore),
                              ),
                              const TextSpan(
                                text: ' hours',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              FilledButton.icon(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                ),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Observer(
                  builder: (context) {
                    if (store.isMonthlyTargetAchieved) {
                      return const SizedBox(
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Goal achieved! ✌🏻🎉',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Daily average to achieve goal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              if (store.isLoading)
                                const WidgetSpan(
                                  child: SizedBox(
                                    width: 48,
                                    height: 24,
                                    child: Center(
                                      child: SpinKitThreeBounce(
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                TextSpan(
                                  text: formatDailyTargetDuration(
                                      store.effectiveAverageTarget),
                                ),
                              const TextSpan(
                                text: ' / day',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 20,
                                ),
                              ),
                              const TextSpan(
                                text: ' ',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Observer(
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Working days',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          text:
                              '${targetStore.currentDay}/${targetStore.effectiveDays.length}',
                          children: const [
                            TextSpan(
                              text: ' days',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          const TodayProgressIndicator(),
        ],
      ),
    );
  }

  String formatCompletedDuration(HomeStore store, TargetStore targetStore) {
    return '${store.completed.inHours > 0 ? '${store.completed.inHours} h ' : ''}${store.completed.inMinutes.remainder(60)}m ';
  }

  String formatTotalDuration(HomeStore store, TargetStore targetStore) {
    final double total = targetStore.requiredTargetDuration.inSeconds / 3600;
    String totalString =
        total.isWhole ? total.toStringAsFixed(0) : total.toStringAsFixed(2);

    return '/ $totalString';
  }
}

class TodayProgressIndicator extends StatelessObserverWidget {
  const TodayProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeStore store = context.read<HomeStore>();
    final TargetStore targetStore = context.read<TargetStore>();

    if (store.isMonthlyTargetAchieved) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Today's Progress",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    color: Colors.white60,
                  ),
                ),
              ),
              if (!store.isLoading || store.isLoadingWithData)
                Text(
                  formatTodayProgressPercentage(store),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              const SizedBox(width: 2),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 24,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedHorizontalProgressBar(
                      value: store.todayPercentage,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      duration: 1.seconds,
                      curve: Curves.fastOutSlowIn,
                      valueColor: AlwaysStoppedAnimation(
                        ColorTween(
                          begin: Colors.redAccent,
                          end: Colors.green.shade700,
                        ).transform(
                          store.todayPercentage.clamp(0, 1),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!store.isLoading || store.isLoadingWithData)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 8,
                    child: Builder(
                      builder: (context) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const ImageIcon(
                              AssetImage('assets/icon_done.png'),
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              store.todayPercentage >= 1
                                  ? 'Completed'
                                  : 'Remaining: ${formatDailyTargetDuration(store.remainingForToday)}',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
              ],
            ),
          ),
          Observer(
            builder: (context) {
              if (store.isLoading && !store.isLoadingWithData) {
                return const SizedBox.shrink();
              }
              if (targetStore.isTodayWorkingDay) {
                return const SizedBox(height: 8);
              }

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Tooltip(
                    message: 'Today is not your working day!',
                    waitDuration: const Duration(milliseconds: 500),
                    textAlign: TextAlign.end,
                    preferBelow: true,
                    verticalOffset: 14,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Working extra!',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 0.2,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.error_outline_rounded,
                          size: 16,
                          color: context.theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String formatTodayProgressPercentage(HomeStore store) {
    final double percentage = (store.todayPercentage * 100).clamp(0, 100);
    return '${percentage.toFormattedStringAsFixed(2)}%';
  }
}
