// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeStore on _HomeStore, Store {
  Computed<Duration>? _$todayDurationComputed;

  @override
  Duration get todayDuration =>
      (_$todayDurationComputed ??= Computed<Duration>(() => super.todayDuration,
              name: '_HomeStore.todayDuration'))
          .value;
  Computed<Duration>? _$completedTillTodayComputed;

  @override
  Duration get completedTillToday => (_$completedTillTodayComputed ??=
          Computed<Duration>(() => super.completedTillToday,
              name: '_HomeStore.completedTillToday'))
      .value;
  Computed<bool>? _$isLoadingWithDataComputed;

  @override
  bool get isLoadingWithData => (_$isLoadingWithDataComputed ??= Computed<bool>(
          () => super.isLoadingWithData,
          name: '_HomeStore.isLoadingWithData'))
      .value;
  Computed<Duration>? _$remainingComputed;

  @override
  Duration get remaining =>
      (_$remainingComputed ??= Computed<Duration>(() => super.remaining,
              name: '_HomeStore.remaining'))
          .value;
  Computed<Duration>? _$remainingTillTodayComputed;

  @override
  Duration get remainingTillToday => (_$remainingTillTodayComputed ??=
          Computed<Duration>(() => super.remainingTillToday,
              name: '_HomeStore.remainingTillToday'))
      .value;
  Computed<bool>? _$isWorkingExtraComputed;

  @override
  bool get isWorkingExtra =>
      (_$isWorkingExtraComputed ??= Computed<bool>(() => super.isWorkingExtra,
              name: '_HomeStore.isWorkingExtra'))
          .value;
  Computed<Duration>? _$dailyAverageTargetComputed;

  @override
  Duration get dailyAverageTarget => (_$dailyAverageTargetComputed ??=
          Computed<Duration>(() => super.dailyAverageTarget,
              name: '_HomeStore.dailyAverageTarget'))
      .value;
  Computed<Duration>? _$dailyAverageTargetTillTodayComputed;

  @override
  Duration get dailyAverageTargetTillToday =>
      (_$dailyAverageTargetTillTodayComputed ??= Computed<Duration>(
              () => super.dailyAverageTargetTillToday,
              name: '_HomeStore.dailyAverageTargetTillToday'))
          .value;
  Computed<double>? _$todayPercentageComputed;

  @override
  double get todayPercentage => (_$todayPercentageComputed ??= Computed<double>(
          () => super.todayPercentage,
          name: '_HomeStore.todayPercentage'))
      .value;
  Computed<bool>? _$isTodayTargetAchievedComputed;

  @override
  bool get isTodayTargetAchieved => (_$isTodayTargetAchievedComputed ??=
          Computed<bool>(() => super.isTodayTargetAchieved,
              name: '_HomeStore.isTodayTargetAchieved'))
      .value;
  Computed<Duration>? _$remainingForTodayComputed;

  @override
  Duration get remainingForToday => (_$remainingForTodayComputed ??=
          Computed<Duration>(() => super.remainingForToday,
              name: '_HomeStore.remainingForToday'))
      .value;
  Computed<Duration>? _$effectiveAverageTargetComputed;

  @override
  Duration get effectiveAverageTarget => (_$effectiveAverageTargetComputed ??=
          Computed<Duration>(() => super.effectiveAverageTarget,
              name: '_HomeStore.effectiveAverageTarget'))
      .value;
  Computed<bool>? _$isMonthlyTargetAchievedComputed;

  @override
  bool get isMonthlyTargetAchieved => (_$isMonthlyTargetAchievedComputed ??=
          Computed<bool>(() => super.isMonthlyTargetAchieved,
              name: '_HomeStore.isMonthlyTargetAchieved'))
      .value;
  Computed<bool>? _$isTimerRunningComputed;

  @override
  bool get isTimerRunning =>
      (_$isTimerRunningComputed ??= Computed<bool>(() => super.isTimerRunning,
              name: '_HomeStore.isTimerRunning'))
          .value;

  late final _$lastUpdatedAtom =
      Atom(name: '_HomeStore.lastUpdated', context: context);

  @override
  DateTime? get lastUpdated {
    _$lastUpdatedAtom.reportRead();
    return super.lastUpdated;
  }

  @override
  set lastUpdated(DateTime? value) {
    _$lastUpdatedAtom.reportWrite(value, super.lastUpdated, () {
      super.lastUpdated = value;
    });
  }

  late final _$timeEntriesAtom =
      Atom(name: '_HomeStore.timeEntries', context: context);

  @override
  List<TimeEntry>? get timeEntries {
    _$timeEntriesAtom.reportRead();
    return super.timeEntries;
  }

  @override
  set timeEntries(List<TimeEntry>? value) {
    _$timeEntriesAtom.reportWrite(value, super.timeEntries, () {
      super.timeEntries = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_HomeStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorAtom = Atom(name: '_HomeStore.error', context: context);

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

  late final _$completedAtom =
      Atom(name: '_HomeStore.completed', context: context);

  @override
  Duration get completed {
    _$completedAtom.reportRead();
    return super.completed;
  }

  @override
  set completed(Duration value) {
    _$completedAtom.reportWrite(value, super.completed, () {
      super.completed = value;
    });
  }

  late final _$dayEntriesAtom =
      Atom(name: '_HomeStore.dayEntries', context: context);

  @override
  Map<DateTime, DayEntry> get dayEntries {
    _$dayEntriesAtom.reportRead();
    return super.dayEntries;
  }

  @override
  set dayEntries(Map<DateTime, DayEntry> value) {
    _$dayEntriesAtom.reportWrite(value, super.dayEntries, () {
      super.dayEntries = value;
    });
  }

  late final _$initAsyncAction =
      AsyncAction('_HomeStore.init', context: context);

  @override
  Future<void> init(BuildContext context) {
    return _$initAsyncAction.run(() => super.init(context));
  }

  late final _$refreshDataAsyncAction =
      AsyncAction('_HomeStore.refreshData', context: context);

  @override
  Future<void> refreshData() {
    return _$refreshDataAsyncAction.run(() => super.refreshData());
  }

  @override
  String toString() {
    return '''
lastUpdated: ${lastUpdated},
timeEntries: ${timeEntries},
isLoading: ${isLoading},
error: ${error},
completed: ${completed},
dayEntries: ${dayEntries},
todayDuration: ${todayDuration},
completedTillToday: ${completedTillToday},
isLoadingWithData: ${isLoadingWithData},
remaining: ${remaining},
remainingTillToday: ${remainingTillToday},
isWorkingExtra: ${isWorkingExtra},
dailyAverageTarget: ${dailyAverageTarget},
dailyAverageTargetTillToday: ${dailyAverageTargetTillToday},
todayPercentage: ${todayPercentage},
isTodayTargetAchieved: ${isTodayTargetAchieved},
remainingForToday: ${remainingForToday},
effectiveAverageTarget: ${effectiveAverageTarget},
isMonthlyTargetAchieved: ${isMonthlyTargetAchieved},
isTimerRunning: ${isTimerRunning}
    ''';
  }
}
