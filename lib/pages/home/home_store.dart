import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:screwdriver/screwdriver.dart';

import '../../api/toggl_api_service.dart';
import '../../model/day_entry.dart';
import '../../model/project.dart';
import '../../model/time_entry.dart';
import '../../model/toggl_client.dart';
import '../../model/user.dart';
import '../../model/workspace.dart';
import '../../resources/keys.dart';
import '../../utils/app_icon_manager.dart';
import '../../utils/extensions.dart';
import '../../utils/system_tray_manager.dart';
import '../../utils/utils.dart';
import '../target_store.dart';

part 'home_store.g.dart';

// ignore: library_private_types_in_public_api
class HomeStore = _HomeStore with _$HomeStore;

abstract class _HomeStore with Store {
  TargetStore targetStore;
  late final SystemTrayManager systemTrayManager =
      GetIt.instance.get<SystemTrayManager>();
  late final AppIconManager appIconManager =
      GetIt.instance.get<AppIconManager>();

  late final Box secretsBox = getSecretsBox();
  late final Box settingsBox = getAppSettingsBox();
  late final Box notificationsBox = getNotificationsBox();
  late final TogglApiService apiService = GetIt.instance.get<TogglApiService>();

  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  _HomeStore(this.targetStore);

  @observable
  DateTime? lastUpdated;

  @observable
  List<TimeEntry>? timeEntries;

  @observable
  bool isLoading = true;

  @observable
  String? error;

  @observable
  Duration completed = Duration.zero;

  @computed
  Duration get todayDuration => dayEntries[today]?.duration ?? Duration.zero;

  @computed
  Duration get completedTillToday => completed - todayDuration;

  @computed
  bool get isLoadingWithData => isLoading && (timeEntries?.isNotEmpty == true);

  @computed
  Duration get remaining {
    if (completed > targetStore.requiredTargetDuration) return Duration.zero;
    final diff = targetStore.requiredTargetDuration - completed;
    if (diff.inSeconds % 60 > 0) {
      // round to 1 more minute if there are seconds less than a minute.
      return Duration(minutes: diff.inSeconds ~/ 60 + 1);
    }
    return diff;
  }

  @computed
  Duration get remainingTillToday {
    if (completedTillToday >= targetStore.requiredTargetDuration) {
      return Duration.zero;
    }

    final diff = targetStore.requiredTargetDuration - completedTillToday;
    if (diff.inSeconds % 60 > 0) {
      // round to 1 more minute if there are seconds less than a minute.
      return Duration(minutes: diff.inSeconds ~/ 60 + 1);
    }
    return diff;
  }

  @computed
  bool get isWorkingExtra {
    if (isLoading && !isLoadingWithData) {
      return false;
    }
    if (!targetStore.isTodayWorkingDay && todayDuration > Duration.zero) {
      return true;
    }
    if (targetStore.isTodayWorkingDay &&
        todayDuration > dailyAverageTargetTillToday) {
      return true;
    }
    return false;
  }

  @observable
  Map<DateTime, DayEntry> dayEntries = {};

  @computed
  Duration get dailyAverageTarget {
    if (targetStore.daysRemainingAfterToday == 0) return remaining;

    return Duration(
        minutes:
            (remaining.inMinutes / targetStore.daysRemainingAfterToday).ceil());
  }

  @computed
  Duration get dailyAverageTargetTillToday {
    if (targetStore.daysRemaining == 0) return remainingTillToday;
    if (remainingTillToday <= Duration.zero) return Duration.zero;

    return Duration(
        minutes:
            (remainingTillToday.inMinutes / targetStore.daysRemaining).ceil());
  }

  @computed
  double get todayPercentage {
    if (dailyAverageTargetTillToday <= Duration.zero) return 0;

    return (todayDuration.inMinutes / dailyAverageTargetTillToday.inMinutes)
        .roundToPrecision(4);
  }

  @computed
  bool get isTodayTargetAchieved => todayPercentage >= 1;

  @computed
  bool get didOvertimeToday => todayDuration > dailyAverageTargetTillToday;

  @computed
  Duration get overtimeToday => todayDuration - dailyAverageTargetTillToday;

  @computed
  Duration get remainingForToday {
    final diff = dailyAverageTargetTillToday - todayDuration;
    if (diff.isNegative) return Duration.zero;

    if (diff.inSeconds % 60 > 0) {
      // round to 1 more minute if there are seconds less than a minute.
      return Duration(minutes: diff.inMinutes + 1);
    }
    return diff;
  }

  @computed
  Duration get effectiveAverageTarget {
    return todayPercentage > 1
        ? dailyAverageTarget
        : dailyAverageTargetTillToday;
  }

  @computed
  bool get isMonthlyTargetAchieved =>
      completed >= targetStore.requiredTargetDuration;

  @computed
  bool get isTimerRunning => timeEntries?.any((e) => e.isRunning) == true;

  @computed
  Duration get overtime => completed - targetStore.requiredTargetDuration;

  late String authKey;
  User? user;

  @action
  Future<void> init(BuildContext context) async {
    authKey = secretsBox.get(HiveKeys.authKey);

    log('Loading user data...');
    user = getUserFromStorage()!;

    // ignore: use_build_context_synchronously
    await systemTrayManager.init(context, refreshCallback: refreshData);
    await refreshData();
  }

  void updateSystemTrayText() {
    if (!defaultTargetPlatform.isDesktop) return;

    String text;
    final percentage = (todayPercentage * 100).floor();
    final completed = percentage >= 100;
    if (completed) {
      text = 'Completed';
    } else {
      text = '$percentage%';
    }

    systemTrayManager.setTitle(text);

    if (completed) {
      systemTrayManager.setCompletedAppIcon();
    } else {
      systemTrayManager.setDefaultAppIcon();
    }
  }

  void updateAppIcon() {
    log('Updating app icon to ${isTimerRunning ? 'active' : 'inactive'}...');
    appIconManager.setAppIcon(inactive: !isTimerRunning);
  }

  Future<List<TimeEntry>?> fetchData() async {
    log('Fetching data...');
    try {
      final DateFormat format = DateFormat('yyyy-MM-dd');
      final String startDate =
          format.format(DateTime(targetStore.year, targetStore.month, 1));
      // endDate is exclusive, so we need use 1st of next month.
      final String endDate =
          format.format(DateTime(targetStore.year, targetStore.month + 1, 1));

      log('Fetching data from $startDate until $endDate...');

      final response = await apiService.getTimeEntries(startDate, endDate);

      if (!response.isSuccessful) {
        log('Error', error: response.body);
        return null;
      }

      final List<TimeEntry> timeEntries = response.body ?? [];

      return timeEntries;
    } catch (error, stackTrace) {
      log('Error', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  @action
  Future<void> refreshData() async {
    isLoading = true;
    systemTrayManager.setRefreshOption(enabled: false, label: 'Syncing...');
    try {
      // await Future.delayed(3.seconds);
      final List<TimeEntry>? data = await fetchData();
      if (data == null) {
        error = 'Error fetching data';
        isLoading = false;
        return;
      }
      final previousMonthly = isMonthlyTargetAchieved;
      final previousToday = isTodayTargetAchieved;
      processTimeEntries(data);
      timeEntries = data;
      isLoading = false;
      lastUpdated = DateTime.now();
      updateSystemTrayText();
      updateAppIcon();

      showTargetNotificationsIfRequired(
        previousToday: previousToday,
        previousMonthly: previousMonthly,
        debugTest: false,
      );
    } on SocketException catch (error, stackTrace) {
      log('Error', error: error, stackTrace: stackTrace);
      this.error = 'No internet connection!';
      isLoading = false;
    } catch (error, stackTrace) {
      log('Error', error: error, stackTrace: stackTrace);
      this.error =
          'Unable to load time entries at the moment! Please try again!';
      isLoading = false;
    } finally {
      systemTrayManager.setRefreshOption(enabled: true);
    }
  }

  void showTargetNotificationsIfRequired({
    required bool previousMonthly,
    required bool previousToday,
    bool debugTest = false,
  }) {
    // test notification on refresh
    if (!kReleaseMode && debugTest) {
      log('Showing test notification...');
      showNotification(
        title: 'Target Mate',
        body: 'Synced successfully!',
      );
      return;
    }

    if (!previousMonthly && isMonthlyTargetAchieved) {
      final isAlreadyShown =
          notificationsBox.get('m_$today', defaultValue: false);
      log('Monthly target achieved!');

      if (isAlreadyShown) return;

      showNotification(
        title: 'Target Mate',
        body: 'Yay! You have achieved your monthly target!',
      );

      notificationsBox.put('m_$today', true);
    } else if (!previousToday && isTodayTargetAchieved) {
      final isAlreadyShown =
          notificationsBox.get('$today', defaultValue: false);
      log("Today's target achieved!");

      if (isAlreadyShown) return;

      showNotification(
        title: 'Target Mate',
        body: "Yay! You have achieved today's target!",
      );

      notificationsBox.put('$today', true);
    }
  }

  void dispose() {}

  void processTimeEntries(List<TimeEntry> entries) {
    log('Processing time entries...');

    final Project? project = getProjectFromStorage();
    final TogglClient? client = getClientFromStorage();
    final Workspace? workspace = getWorkspaceFromStorage();

    final TimeEntryType selectedTimeEntryType = TimeEntryType.values.byName(
        settingsBox.get(HiveKeys.entryType,
            defaultValue: TimeEntryType.all.name));

    List<TimeEntry> filtered = [...entries];
    if (workspace != null && workspace.id != -1) {
      // filter by workspace.
      filtered = filtered
          .where((entry) =>
              entry.workspaceId == workspace.id || entry.wid == workspace.id)
          .toList();
    }
    if (client != null && client.id != -1) {
      // filter by client.
      filtered =
          filtered.where((entry) => entry.clientName == client.name).toList();
    }
    if (project != null && project.id != -1) {
      // filter by client.
      filtered =
          filtered.where((entry) => entry.projectId == project.id).toList();
    }

    // List<TimeEntry> filtered = entries.where((item) {
    //   // when a specific project is selected.
    //   if (item.projectId == project?.id && item.workspaceId == workspace.id) {
    //     return true;
    //   }
    //   if (workspace != null && item.workspaceId != workspace.id) {
    //     log('Skipping entry [${item.id}]: ${item.description} because workspaceId does not match!');
    //     return false;
    //   }
    //   if (project != null && item.projectId != project.id) {
    //     log('Skipping entry [${item.id}]: ${item.description} because projectId does not match!');
    //     return false;
    //   }
    //   return true;
    // }).toList();

    filtered = filtered.where((entry) {
      if (selectedTimeEntryType.isAll) return true;
      if (entry.type == selectedTimeEntryType) return true;
      log('Skipping entry [${entry.id}]: ${entry.description} because entry type does not match!');
      return false;
    }).toList();

    // Group entries by day and convert to DayEntry.
    final Map<DateTime, DayEntry> groupedEntries = {};
    Duration completedDuration = Duration.zero;
    for (final item in filtered) {
      final day = item.start.dateOnly;

      final DayEntry dayEntry = groupedEntries[day] ??
          DayEntry(
            date: day,
            target:
                Duration(seconds: (targetStore.workingHours! * 3600).round()),
            isWorkingDay: targetStore.effectiveDays.contains(day),
          );

      dayEntry.addEntry(item);
      groupedEntries[day] = dayEntry;
      completedDuration += item.duration;
    }
    final Duration monthlyTarget = targetStore.requiredTargetDuration;

    completed = completedDuration;
    dayEntries = calculateDailyTarget(
      groupedEntries: groupedEntries,
      effectiveDays: targetStore.effectiveDays,
      monthlyTarget: monthlyTarget,
      // log: true,
    );

    log('-------------------------------------------------------------------');
    log('completed: $completed');
    log('completedTillToday: $completedTillToday');
    log('requiredTargetDuration: ${targetStore.requiredTargetDuration}');
    log('remaining: $remaining');
    log('remainingTillToday: $remainingTillToday');
    log('currentDay: ${targetStore.currentDay}');
    log('daysRemaining: ${targetStore.daysRemaining}');
    log('daysRemainingAfterToday: ${targetStore.daysRemainingAfterToday}');
    log('effectiveDays: ${targetStore.effectiveDays.length}');
    log('dailyAverageTarget: $dailyAverageTarget');
    log('dailyAverageTargetTillToday: $dailyAverageTargetTillToday');
    log('today: $todayDuration');
    log('todayPercentage: $todayPercentage');
    log('effectiveAverageTarget: $effectiveAverageTarget');
    log('remainingForToday: $remainingForToday');
    log('isMonthlyTargetAchieved: $isMonthlyTargetAchieved');
    log('-------------------------------------------------------------------');
  }

  void showNotification({
    String title = '',
    String? body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'target_mate_channel',
        'General',
        channelDescription: 'A general notification channel.',
        importance: Importance.max,
        priority: Priority.high,
        // ticker: 'ticker',
      );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        macOS: DarwinNotificationDetails(
          badgeNumber: 1,
          subtitle: 'subtitle',
          interruptionLevel: InterruptionLevel.active,
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      log('Showing notification: $title - $body');
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (error, stackTrace) {
      log('Notification Error', error: error, stackTrace: stackTrace);
    }
  }

  Future<(Version, JsonMap)?> getLatestRelease() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.github.com/repos/BirjuVachhani/target_mate/releases/latest'),
      );

      if (response.statusCode != 200) {
        throw response.body;
      }

      final data = jsonDecode(response.body) as JsonMap;
      return (Version.parse(data['tag_name'].toString()), data);
    } catch (error, stackTrace) {
      log(error.toString());
      log(stackTrace.toString());
      return null;
    }
  }
}
