import 'package:hive/hive.dart';
import 'package:paged_vertical_calendar/utils/date_utils.dart';

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
