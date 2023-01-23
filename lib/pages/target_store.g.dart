// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TargetStore on _TargetStore, Store {
  Computed<bool>? _$hasAllDataComputed;

  @override
  bool get hasAllData =>
      (_$hasAllDataComputed ??= Computed<bool>(() => super.hasAllData,
              name: '_TargetStore.hasAllData'))
          .value;
  Computed<double>? _$requiredTargetComputed;

  @override
  double get requiredTarget =>
      (_$requiredTargetComputed ??= Computed<double>(() => super.requiredTarget,
              name: '_TargetStore.requiredTarget'))
          .value;
  Computed<Duration>? _$requiredTargetDurationComputed;

  @override
  Duration get requiredTargetDuration => (_$requiredTargetDurationComputed ??=
          Computed<Duration>(() => super.requiredTargetDuration,
              name: '_TargetStore.requiredTargetDuration'))
      .value;
  Computed<int>? _$currentDayComputed;

  @override
  int get currentDay =>
      (_$currentDayComputed ??= Computed<int>(() => super.currentDay,
              name: '_TargetStore.currentDay'))
          .value;
  Computed<int>? _$daysRemainingComputed;

  @override
  int get daysRemaining =>
      (_$daysRemainingComputed ??= Computed<int>(() => super.daysRemaining,
              name: '_TargetStore.daysRemaining'))
          .value;
  Computed<List<DateTime>>? _$effectiveDaysComputed;

  @override
  List<DateTime> get effectiveDays => (_$effectiveDaysComputed ??=
          Computed<List<DateTime>>(() => super.effectiveDays,
              name: '_TargetStore.effectiveDays'))
      .value;

  late final _$hasCustomDaysSelectionAtom =
      Atom(name: '_TargetStore.hasCustomDaysSelection', context: context);

  @override
  bool get hasCustomDaysSelection {
    _$hasCustomDaysSelectionAtom.reportRead();
    return super.hasCustomDaysSelection;
  }

  @override
  set hasCustomDaysSelection(bool value) {
    _$hasCustomDaysSelectionAtom
        .reportWrite(value, super.hasCustomDaysSelection, () {
      super.hasCustomDaysSelection = value;
    });
  }

  late final _$errorAtom = Atom(name: '_TargetStore.error', context: context);

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$monthAtom = Atom(name: '_TargetStore.month', context: context);

  @override
  int get month {
    _$monthAtom.reportRead();
    return super.month;
  }

  @override
  set month(int value) {
    _$monthAtom.reportWrite(value, super.month, () {
      super.month = value;
    });
  }

  late final _$yearAtom = Atom(name: '_TargetStore.year', context: context);

  @override
  int get year {
    _$yearAtom.reportRead();
    return super.year;
  }

  @override
  set year(int value) {
    _$yearAtom.reportWrite(value, super.year, () {
      super.year = value;
    });
  }

  late final _$selectedDaysAtom =
      Atom(name: '_TargetStore.selectedDays', context: context);

  @override
  List<int> get selectedDays {
    _$selectedDaysAtom.reportRead();
    return super.selectedDays;
  }

  @override
  set selectedDays(List<int> value) {
    _$selectedDaysAtom.reportWrite(value, super.selectedDays, () {
      super.selectedDays = value;
    });
  }

  late final _$selectedWeekDaysAtom =
      Atom(name: '_TargetStore.selectedWeekDays', context: context);

  @override
  List<int> get selectedWeekDays {
    _$selectedWeekDaysAtom.reportRead();
    return super.selectedWeekDays;
  }

  @override
  set selectedWeekDays(List<int> value) {
    _$selectedWeekDaysAtom.reportWrite(value, super.selectedWeekDays, () {
      super.selectedWeekDays = value;
    });
  }

  late final _$workingHoursAtom =
      Atom(name: '_TargetStore.workingHours', context: context);

  @override
  double? get workingHours {
    _$workingHoursAtom.reportRead();
    return super.workingHours;
  }

  @override
  set workingHours(double? value) {
    _$workingHoursAtom.reportWrite(value, super.workingHours, () {
      super.workingHours = value;
    });
  }

  late final _$maxMonthlyWorkingHoursAtom =
      Atom(name: '_TargetStore.maxMonthlyWorkingHours', context: context);

  @override
  double? get maxMonthlyWorkingHours {
    _$maxMonthlyWorkingHoursAtom.reportRead();
    return super.maxMonthlyWorkingHours;
  }

  @override
  set maxMonthlyWorkingHours(double? value) {
    _$maxMonthlyWorkingHoursAtom
        .reportWrite(value, super.maxMonthlyWorkingHours, () {
      super.maxMonthlyWorkingHours = value;
    });
  }

  late final _$saveAsyncAction =
      AsyncAction('_TargetStore.save', context: context);

  @override
  Future<bool> save() {
    return _$saveAsyncAction.run(() => super.save());
  }

  late final _$_TargetStoreActionController =
      ActionController(name: '_TargetStore', context: context);

  @override
  void init() {
    final _$actionInfo =
        _$_TargetStoreActionController.startAction(name: '_TargetStore.init');
    try {
      return super.init();
    } finally {
      _$_TargetStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onShowCalendar(bool show) {
    final _$actionInfo = _$_TargetStoreActionController.startAction(
        name: '_TargetStore.onShowCalendar');
    try {
      return super.onShowCalendar(show);
    } finally {
      _$_TargetStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
hasCustomDaysSelection: ${hasCustomDaysSelection},
error: ${error},
month: ${month},
year: ${year},
selectedDays: ${selectedDays},
selectedWeekDays: ${selectedWeekDays},
workingHours: ${workingHours},
maxMonthlyWorkingHours: ${maxMonthlyWorkingHours},
hasAllData: ${hasAllData},
requiredTarget: ${requiredTarget},
requiredTargetDuration: ${requiredTargetDuration},
currentDay: ${currentDay},
daysRemaining: ${daysRemaining},
effectiveDays: ${effectiveDays}
    ''';
  }
}
