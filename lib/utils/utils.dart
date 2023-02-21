import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/utils/date_utils.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:toggl_target/resources/colors.dart';
import 'package:toggl_target/resources/theme.dart';

import '../main.dart';
import '../model/day_entry.dart';
import '../pages/setup/auth_page.dart';
import '../resources/keys.dart';

Box getSecretsBox() => Hive.box(HiveBoxes.secrets);

Box getAppSettingsBox() => Hive.box(HiveBoxes.settings);

Box getTargetBox() => Hive.box(HiveBoxes.target);

Box getNotificationsBox() => Hive.box(HiveBoxes.notifications);

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
  final adaptiveTheme = AdaptiveTheme.of(navigator.context);
  adaptiveTheme.reset();
  adaptiveTheme.setTheme(
      light: getTheme(AppColors.primaryColor),
      dark: getTheme(AppColors.primaryColor));

  // Delete saved data.
  await Hive.deleteBoxFromDisk(HiveBoxes.secrets);
  await Hive.deleteBoxFromDisk(HiveBoxes.settings);
  await Hive.deleteBoxFromDisk(HiveBoxes.target);
  await Hive.deleteBoxFromDisk(HiveBoxes.notifications);

  // Delete data from secure storage. (Encryption key)
  await GetIt.instance.get<EncryptedSharedPreferences>().clear();

  if (navigate) {
    // Navigate to auth page.
    navigator.pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const AuthPageWrapper()),
      (route) => false,
    );
  }

  // Reset GetIt registry. (stores, etc.)
  await GetIt.instance.reset(dispose: true);

  // Reinitialize data. Encryption key, Hive, GetIt, etc.
  await initializeData();
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

String formatDailyTargetDuration(Duration duration) {
  int hours = duration.inHours;
  int minutes = duration.inMinutes % 60;

  return '${hours > 0 ? '$hours h ' : ''}${minutes > 0 ? minutes.toString().padLeft(hours > 0 ? 2 : 1, '0') : '1'} min';
}
