import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:paged_vertical_calendar/utils/date_utils.dart';
import 'package:screwdriver/screwdriver.dart';

import '../resources/keys.dart';
import '../utils/extensions.dart';
import '../utils/utils.dart';

part 'target_store.g.dart';

// ignore: library_private_types_in_public_api
class TargetStore = _TargetStore with _$TargetStore;

abstract class _TargetStore with Store {
  late final Box box = getTargetBox();
  late final Box secretsBox = getSecretsBox();

  _TargetStore() {
    init();
  }

  @observable
  bool hasCustomDaysSelection = true;

  @observable
  String? error;

  @observable
  int month = 0;

  @observable
  int year = 0;

  @observable
  List<int> selectedDays = [];

  @observable
  List<int> selectedWeekDays = [];

  @observable
  double? workingHours;

  @observable
  double? maxMonthlyWorkingHours;

  @computed
  bool get hasAllData =>
      (selectedDays.isNotEmpty || selectedWeekDays.isNotEmpty) &&
      workingHours != null;

  @computed
  double get requiredTarget =>
      maxMonthlyWorkingHours ?? (effectiveDays.length * (workingHours ?? 0));

  @computed
  Duration get requiredTargetDuration {
    final hours =
        maxMonthlyWorkingHours ?? (effectiveDays.length * (workingHours ?? 0));
    return Duration(seconds: (hours * 3600).round());
  }

  @computed
  int get currentDay {
    return effectiveDays.indexWhere((date) => date.day >= DateTime.now().day) +
        1;
  }

  @computed
  int get daysRemaining => (effectiveDays.length) - currentDay + 1;

  @computed
  int get daysRemainingAfterToday => (effectiveDays.length) - currentDay;

  @computed
  List<DateTime> get effectiveDays {
    final thisMonth = DateTime(DateTime.now().year, month);
    if (hasCustomDaysSelection) {
      return selectedDays
          .map((e) => DateTime(thisMonth.year, thisMonth.month, e))
          .toList();
    }
    return getMonthDaysFromWeekDays(
            DateTime(thisMonth.year, thisMonth.month), selectedWeekDays)
        .map((e) => DateTime(thisMonth.year, thisMonth.month, e))
        .toList();
  }

  @computed
  bool get isTodayWorkingDay => effectiveDays.containsDay(today.day);

  late final TextEditingController workingHoursController =
      TextEditingController();
  late final TextEditingController maxMonthlyWorkingHoursController =
      TextEditingController();

  @action
  void init() {
    month = box.get(HiveKeys.month, defaultValue: DateTime.now().month);
    year = box.get(HiveKeys.year, defaultValue: DateTime.now().year);
    selectedDays =
        List<int>.from(box.get(HiveKeys.workingDays, defaultValue: <int>[]));
    selectedWeekDays = box.get(HiveKeys.weekDays, defaultValue: <int>[
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
    ]);
    workingHours = box.get(HiveKeys.workingHours, defaultValue: 8.0);
    maxMonthlyWorkingHours = box.get(HiveKeys.maxMonthlyWorkingHours);
    hasCustomDaysSelection =
        box.get(HiveKeys.hasCustomDaysSelection, defaultValue: false);

    if (workingHours != null) {
      workingHoursController.text = workingHours!.isWhole
          ? workingHours!.toStringAsFixed(0)
          : workingHours!.toStringAsFixed(1);
    }

    if (maxMonthlyWorkingHours != null) {
      maxMonthlyWorkingHoursController.text = maxMonthlyWorkingHours!.isWhole
          ? maxMonthlyWorkingHours!.toStringAsFixed(0)
          : maxMonthlyWorkingHours!.toStringAsFixed(1);
    }

    updateIfMonthChanged();
  }

  @action
  void refresh() => init();

  @action
  void updateIfMonthChanged() {
    if (month == today.month) return;
    // Update local data.
    month = today.month;
    year = today.year;
    selectedDays = <int>[];
    hasCustomDaysSelection = false;

    // Update stored data.
    box.put(HiveKeys.month, today.month);
    box.put(HiveKeys.year, today.year);
    box.put(HiveKeys.hasCustomDaysSelection, false);
    box.put(HiveKeys.workingDays, <int>[]);
  }

  @action
  Future<bool> save() async {
    if (workingHours! <= 0) {
      error = 'Working hours must be greater than zero.';
      return false;
    }
    if (workingHours! > 24) {
      error = 'Working hours must be less than 24.';
      return false;
    }
    if (maxMonthlyWorkingHours == null &&
        maxMonthlyWorkingHoursController.text.trim().isNotEmpty) {
      error = 'Invalid max monthly working hours.';
      return false;
    }
    if (maxMonthlyWorkingHours != null) {
      if (maxMonthlyWorkingHours! > DateTime.now().daysInMonth * 24) {
        error =
            'There are only ${DateTime.now().daysInMonth * 24} hours in this month!';
        return false;
      }
    }
    log('saving...');

    error = null;
    try {
      await box.put(HiveKeys.year, year);
      await box.put(HiveKeys.month, month);
      await box.put(HiveKeys.workingDays, selectedDays);
      await box.put(HiveKeys.weekDays, selectedWeekDays);
      await box.put(HiveKeys.workingHours, workingHours);
      await box.put(HiveKeys.maxMonthlyWorkingHours, maxMonthlyWorkingHours);
      await box.put(HiveKeys.hasCustomDaysSelection, hasCustomDaysSelection);
      return true;
    } catch (err, stacktrace) {
      log(err.toString());
      log(stacktrace.toString());
      error = err.toString();
      return false;
    }
  }

  @action
  void onShowCalendar(bool show) {
    if (selectedDays.isEmpty && show) {
      selectedDays =
          getMonthDaysFromWeekDays(DateTime(year, month), selectedWeekDays);
    }
    hasCustomDaysSelection = show;
  }

  void dispose() {
    workingHoursController.dispose();
    maxMonthlyWorkingHoursController.dispose();
  }
}
