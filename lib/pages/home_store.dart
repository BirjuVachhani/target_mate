import 'dart:convert';
import 'dart:developer';

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
import 'package:toggl_target/model/day_entry.dart';
import 'package:toggl_target/model/time_entry.dart';
import 'package:toggl_target/pages/target_store.dart';
import 'package:toggl_target/utils/extensions.dart';
import 'package:toggl_target/utils/system_tray_manager.dart';
import 'package:toggl_target/utils/utils.dart';

import '../resources/keys.dart';

part 'home_store.g.dart';

// ignore: library_private_types_in_public_api
class HomeStore = _HomeStore with _$HomeStore;

abstract class _HomeStore with Store {
  TargetStore targetStore;
  late final SystemTrayManager systemTrayManager =
      GetIt.instance.get<SystemTrayManager>();

  late final Box secretsBox = getSecretsBox();
  late final Box settingsBox = getAppSettingsBox();
  late final Box notificationsBox = getNotificationsBox();

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

  late String authKey;
  late String fullName;
  late String email;
  late String timezone;
  late String avatarUrl;

  Future<void> init(BuildContext context) async {
    authKey = secretsBox.get(HiveKeys.authKey);
    fullName = secretsBox.get(HiveKeys.fullName);
    email = secretsBox.get(HiveKeys.email);
    timezone = secretsBox.get(HiveKeys.timezone);
    avatarUrl = secretsBox.get(HiveKeys.avatarUrl) ?? '';

    await systemTrayManager.init(context, refreshCallback: refreshData);
    await refreshData();
  }

  void updateSystemTrayText() {
    String text;
    final percentage = (todayPercentage * 100).floor();
    final completed = percentage >= 100;
    if (completed) {
      text = 'Completed';
    } else {
      text = '$percentage%';
    }

    systemTrayManager.setTitle(text);

    if (completed && defaultTargetPlatform.isMacOS) {
      systemTrayManager.setIcon('assets/icon_done.png');
    }
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
      final uri = Uri.parse(
          'https://api.track.toggl.com/api/v9/me/time_entries?start_date=$startDate&end_date=$endDate');
      log('Fetching data from $startDate until $endDate...');
      log('URL: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $authKey',
        },
      );

      if (response.statusCode != 200) {
        log('Error', error: response.body);
        return null;
      }

      final List<JsonMap> data = List<JsonMap>.from(jsonDecode(response.body));

      final List<TimeEntry> timeEntries = data.map(TimeEntry.fromJson).toList();

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

      showTargetNotificationsIfRequired(
          previousToday: previousToday, previousMonthly: previousMonthly);
    } catch (error, stackTrace) {
      log('Error', error: error, stackTrace: stackTrace);
      this.error = error.toString();
      isLoading = false;
    } finally {
      systemTrayManager.setRefreshOption(enabled: true);
    }
  }

  void showTargetNotificationsIfRequired({
    required bool previousMonthly,
    required bool previousToday,
  }) {
    // test notification on refresh
    // showNotification(
    //   title: 'Toggl Track',
    //   body: 'Synced successfully!',
    // );

    if (!previousMonthly && isMonthlyTargetAchieved) {
      final isAlreadyShown =
          notificationsBox.get('m_$today', defaultValue: false);
      log('Monthly target achieved!');

      if (isAlreadyShown) return;

      showNotification(
        title: 'Toggl Track',
        body: 'Yay! You have achieved your monthly target!',
      );

      notificationsBox.put('m_$today', true);
    } else if (!previousToday && isTodayTargetAchieved) {
      final isAlreadyShown =
          notificationsBox.get('$today', defaultValue: false);
      log("Today's target achieved!");

      if (isAlreadyShown) return;

      showNotification(
        title: 'Toggl Track',
        body: "Yay! You have achieved today's target!",
      );

      notificationsBox.put('$today', true);
    }
  }

  void dispose() {}

  void processTimeEntries(List<TimeEntry> entries) {
    log('Processing time entries...');

    final int? projectId = secretsBox.get(HiveKeys.projectId);
    final int? workspaceId = secretsBox.get(HiveKeys.workspaceId);

    List<TimeEntry> filtered = entries.where((item) {
      if (item.projectId == projectId && item.workspaceId == workspaceId) {
        return true;
      }
      if (workspaceId != null && item.workspaceId != workspaceId) {
        log('Skipping entry [${item.id}]: ${item.description} because workspaceId does not match!');
        return false;
      }
      if (projectId != null && item.projectId != projectId) {
        log('Skipping entry [${item.id}]: ${item.description} because projectId does not match!');
        return false;
      }
      return true;
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
        'toggl_target_channel',
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

  Future<Version?> getLatestRelease() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.github.com/repos/BirjuVachhani/toggl_target/releases/latest'),
      );

      if (response.statusCode != 200) {
        throw response.body;
      }

      final data = jsonDecode(response.body);
      return Version.parse(data['tag_name'].toString());
    } catch (error, stackTrace) {
      log(error.toString());
      log(stackTrace.toString());
      return null;
    }
  }
}
