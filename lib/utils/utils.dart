import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/utils/date_utils.dart';
import 'package:screwdriver/screwdriver.dart';

import '../main.dart';
import '../model/day_entry.dart';
import '../pages/setup/auth_page.dart';
import '../resources/keys.dart';

Box getSecretsBox() => Hive.box(HiveKeys.secrets);

Box getAppSettingsBox() => Hive.box(HiveKeys.settings);

Box getTargetBox() => Hive.box(HiveKeys.target);

List<int> getMonthDaysFromWeekDays(DateTime month, List<int> weekDays) {
  final days = <int>[];
  for (var i = 1; i <= month.daysInMonth; i++) {
    final date = DateTime(month.year, month.month, i);
    if (!weekDays.contains(date.weekday)) continue;
    days.add(i);
  }
  return days;
}

List<DateTime> getMonthDaysDateTimeFromWeekDays(
    DateTime month, List<int> weekDays) {
  return getMonthDaysFromWeekDays(month, weekDays)
      .map((e) => DateTime(month.year, month.month, e))
      .toList();
}

/// Intervals for syncing data.
final List<Duration> intervals = [
  1.minutes,
  5.minutes,
  10.minutes,
  15.minutes,
  30.minutes,
  1.hours,
];

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

NavigatorState get navigator => navigatorKey.currentState!;

Future<void> logout({bool navigate = true}) async {
  // Delete saved data.
  await Hive.deleteFromDisk();

  // Delete data from secure storage. (Encryption key)
  await GetIt.instance.get<FlutterSecureStorage>().deleteAll();

  // Reset GetIt registry. (stores, etc.)
  await GetIt.instance.reset(dispose: true);

  // Reinitialize data. Encryption key, Hive, GetIt, etc.
  await initializeData();

  // Navigate to auth page.
  navigator.pushAndRemoveUntil(
      FadeScalePageRoute(child: const AuthPageWrapper()), (route) => false);
}

Map<DateTime, DayEntry> calculateDailyTarget({
  required Map<DateTime, DayEntry> groupedEntries,
  required List<DateTime> effectiveDays,
  required Duration monthlyTarget,
  bool log = false,
}) {
  Map<DateTime, DayEntry> entries = {...groupedEntries};
  debugPrint('Working days: ${effectiveDays.map((e) => e.day)}');
  // Calculate daily target for each day.
  Duration durationTillDate = Duration.zero;
  for (int index = entries.length - 1; index >= 0; index--) {
    final dayEntry = entries.values.elementAt(index);

    if (!dayEntry.isWorkingDay) {
      // If it is not a working day, then we don't care about daily target
      // for it so we set target to zero to make isTargetAchieved return true.
      dayEntry.target = Duration.zero;
      durationTillDate += dayEntry.duration;
      continue;
    }

    // Duration to be completed including today.
    final Duration remainingDuration = monthlyTarget - durationTillDate;
    final int remainingDays = effectiveDays.length -
        effectiveDays.indexWhere((date) => date.day >= dayEntry.date.day);
    final target = Duration(
        seconds: (remainingDuration.inSeconds / remainingDays).floor());
    dayEntry.target = target;

    if (log) {
      debugPrint(
          '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
      debugPrint('Day: ${DateFormat('dd-MM-yyyy').format(dayEntry.date)}');
      debugPrint('isWorkingDay: ${dayEntry.isWorkingDay}');
      debugPrint('Remaining Days: $remainingDays');
      debugPrint('Remaining Duration: $remainingDuration');
      debugPrint('Target: ${dayEntry.target}');
      debugPrint('Duration: ${dayEntry.duration}');
      debugPrint('Is target achieved: ${dayEntry.isTargetAchieved}');
      debugPrint('Duration till date: $durationTillDate');
      debugPrint(
          'Duration including date: ${durationTillDate + dayEntry.duration}');
      debugPrint(
          '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n');
    }

    durationTillDate += dayEntry.duration;
  }
  return entries;
}
