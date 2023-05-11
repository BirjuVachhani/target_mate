import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../ui/custom_scaffold.dart';
import '../../utils/extensions.dart';
import '../../utils/font_variations.dart';
import '../../utils/utils.dart';
import '../settings_store.dart';
import '../target_store.dart';
import 'bottom_bar.dart';
import 'day_entry_view.dart';
import 'home_store.dart';
import 'stats.dart';
import 'update_dialog.dart';

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
      checkForUpdates(debugTest: false);
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
      gradientBackground: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const StatsHeader(),
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
                              .withOpacity(0.5),
                          duration: const Duration(milliseconds: 2000),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hold on, loading your entries...',
                          style: TextStyle(
                            color: context.theme.textColor.withOpacity(0.5),
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
                    padding: const EdgeInsets.fromLTRB(
                        kSidePadding, 8, kSidePadding, 16),
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
    );
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}

  void onDidReceiveNotificationResponse(NotificationResponse details) {}

  Future<void> checkForUpdates({bool debugTest = false}) async {
    final debugTestMode = debugTest && !kReleaseMode;

    /// Only check for updates on desktop platforms.
    if (!debugTestMode && !defaultTargetPlatform.isDesktop) return;

    // final Version? latestVersion = await store.getLatestRelease();
    final Version? latestVersion = await store.getLatestRelease();

    if (latestVersion == null) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = Version.parse(packageInfo.version);

    if (latestVersion > currentVersion || debugTestMode) {
      showUpdateAvailableUI(latestVersion);
    }
  }

  void showUpdateAvailableUI(Version latestVersion) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => UpdateDialog(
        latestVersion: latestVersion,
        onUpdate: () {
          launchUrlString(
              'https://github.com/birjuvachhani/target_mate/releases/$latestVersion');
        },
      ),
      barrierDismissible: true,
    );
  }
}

class StatsHeader extends StatelessWidget {
  const StatsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: kSidePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          HomeAppBar(),
          SizedBox(height: 16),
          MonthlyStats(),
          SizedBox(height: 16),
          DailyStats(),
          SizedBox(height: 16),
          TodayProgressStats(),
        ],
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeStore store = context.read<HomeStore>();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            CircleAvatar(
              backgroundColor: context.theme.colorScheme.primary.shade(1),
              radius: 18,
              foregroundImage: store.user != null
                  ? NetworkImage(store.user!.avatarUrl)
                  : null,
              child: Icon(
                Icons.person_rounded,
                color: context.theme.colorScheme.primary,
              ),
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
                        color: context.theme.textColor.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      store.user?.fullName ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontVariations: FontVariations.bold,
                        color: context.theme.textColor,
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
                      onPressed: store.isLoading ? null : store.refreshData,
                      style: TextButton.styleFrom(
                        foregroundColor: context.theme.textColor,
                        backgroundColor:
                            context.theme.textColor.withOpacity(0.1),
                      ),
                      child: store.isLoading
                          ? SizedBox.square(
                              dimension: 20,
                              child: Center(
                                child: SizedBox.square(
                                  dimension: 14,
                                  child: CircularProgressIndicator(
                                    color: context.theme.textColor,
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
                      foregroundColor: context.theme.textColor,
                      backgroundColor: context.theme.textColor.withOpacity(0.1),
                    ),
                    icon: store.isLoading
                        ? SizedBox.square(
                            dimension: 20,
                            child: Center(
                              child: SizedBox.square(
                                dimension: 14,
                                child: CircularProgressIndicator(
                                  color: context.theme.textColor,
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
                    foregroundColor: context.theme.textColor,
                    backgroundColor: context.theme.textColor.withOpacity(0.1),
                  ),
                  onPressed: () => openSettings(context),
                  child: const Icon(Icons.settings, size: 20),
                  // label: const Text('Logout'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
