import 'package:screwdriver/screwdriver.dart';

/// A utility class that helps you calculate stuff.
class Calculator {
  Calculator._();

  /// Version of [calculateDaysRemaining] that takes [int]s as day instead of
  /// [DateTime]s. See [calculateDaysRemaining] for more details.
  static int calculateDaysRemainingFor(
    int targetDate,
    List<int> effectiveDays, {
    bool includeTargetDate = true,
    bool sorted = false,
  }) =>
      calculateDaysRemaining(
        DateTime.now().copyWith(day: targetDate),
        effectiveDays.map((day) => DateTime.now().copyWith(day: day)).toList(),
        includeTargetDate: includeTargetDate,
        sorted: sorted,
      );

  /// Gives you remaining days based on [effectiveDays].
  /// [effectiveDays] is a list of days that are marked as working days.
  /// Duplicate days are removed before calculating the remaining days.
  /// [effectiveDays] is sorted before calculating the remaining days if
  /// [sorted] is false.
  ///
  /// [targetDate] is the date that you want to calculate the remaining days
  /// after it.
  ///
  /// [includeTargetDate] is a flag that indicates whether to include the target
  /// date in the final count or not. [targetDate] is not included if it's not
  /// in [effectiveDays].
  ///
  /// Note: Although [effectiveDays] is a list of [DateTime]s, only the day
  /// component is used to calculate the remaining days. Same goes for
  /// [targetDate], only the day component is used.
  static int calculateDaysRemaining(
    DateTime targetDate,
    Iterable<DateTime> effectiveDays, {
    bool includeTargetDate = true,
    bool sorted = false,
  }) {
    // Sort effective days if not sorted when sorted is false.
    if (!sorted) {
      effectiveDays = effectiveDays.sortedBy<num>((item) => item.day);
    }

    // Remove duplicate days.
    List<DateTime> sortedEffectiveDays = effectiveDays.toSet().toList();

    // If there are no effective days, then there are no remaining days.
    if (effectiveDays.isEmpty) return 0;

    // Get index of target date in effective days to see if it should be
    // considered as effective day or not.
    final currentIndex =
        sortedEffectiveDays.indexWhere((date) => date.day == targetDate.day);
    if (currentIndex != -1) {
      // target date is in effective day. So we return the remaining days
      // after it optionally including the target date itself if
      // [includeTargetDate] is true.
      return (sortedEffectiveDays.length) -
          currentIndex -
          (includeTargetDate ? 0 : 1);
    }

    // target date is not an effective day. So we count all the effective days
    // that are after the target date.
    final remaining = effectiveDays.fold(
        0,
        (previousValue, date) =>
            date.day > targetDate.day ? previousValue + 1 : previousValue);
    return remaining;
  }
}
