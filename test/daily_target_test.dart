import 'package:flutter_test/flutter_test.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:toggl_target/model/day_entry.dart';
import 'package:toggl_target/utils/utils.dart';

void main() {
  final List<DateTime> effectiveDays =
      List.generate(20, (index) => DateTime(2023, 1, index + 1));

  final day1 = DateTime(2023, 1, 1);
  final day2 = DateTime(2023, 1, 2);
  final day3 = DateTime(2023, 1, 3);

  test('Daily target calculation test 1', () {
    final Map<DateTime, DayEntry> groupedEntries = {
      day3: DayEntry(date: day3, duration: 6.hours, isWorkingDay: true),
      day2: DayEntry(date: day2, duration: 6.hours, isWorkingDay: true),
      day1: DayEntry(date: day1, duration: 6.hours, isWorkingDay: true),
    };

    final Map<DateTime, DayEntry> result = calculateDailyTarget(
      effectiveDays: effectiveDays,
      groupedEntries: groupedEntries,
      monthlyTarget: 120.hours,
      // log: true,
    );

    final entry1 = result[day1]!;
    expect(entry1.target, 6.hours);
    expect(entry1.isTargetAchieved, true);

    final entry2 = result[day2]!;
    expect(entry2.target, 6.hours);
    expect(entry2.isTargetAchieved, true);

    final entry3 = result[day3]!;
    expect(entry3.target, 6.hours);
    expect(entry3.isTargetAchieved, true);
  });

  test('Daily target calculation test 2', () {
    final Map<DateTime, DayEntry> groupedEntries = {
      day3: DayEntry(date: day3, duration: 6.hours, isWorkingDay: true),
      day2: DayEntry(date: day2, duration: 8.hours, isWorkingDay: true),
      day1: DayEntry(date: day1, duration: 4.hours, isWorkingDay: true),
    };

    final Map<DateTime, DayEntry> result = calculateDailyTarget(
      effectiveDays: effectiveDays,
      groupedEntries: groupedEntries,
      monthlyTarget: 120.hours,
      // log: true,
    );

    final entry1 = result[day1]!;
    expect(entry1.target, 6.hours);
    expect(entry1.isTargetAchieved, false);

    final entry2 = result[day2]!;
    expect(entry2.target > 6.hours, isTrue);
    expect(entry2.isTargetAchieved, true);

    final entry3 = result[day3]!;
    expect(entry3.target, 6.hours);
    expect(entry3.isTargetAchieved, true);
  });

  test('Daily target calculation test 3', () {
    final Map<DateTime, DayEntry> groupedEntries = {
      day3: DayEntry(date: day3, duration: 6.hours, isWorkingDay: true),
      day2: DayEntry(date: day2, duration: 8.hours, isWorkingDay: true),
      day1: DayEntry(date: day1, duration: 0.hours, isWorkingDay: true),
    };

    final Map<DateTime, DayEntry> result = calculateDailyTarget(
      effectiveDays: effectiveDays,
      groupedEntries: groupedEntries,
      monthlyTarget: 120.hours,
      // log: true,
    );

    final entry1 = result[day1]!;
    expect(entry1.target, 6.hours);
    expect(entry1.isTargetAchieved, false);

    final entry2 = result[day2]!;
    expect(entry2.target > 6.hours, isTrue);
    expect(entry2.isTargetAchieved, true);

    final entry3 = result[day3]!;
    expect(entry3.target > 6.hours, isTrue);
    expect(entry3.isTargetAchieved, false);
  });
}
