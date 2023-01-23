// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeStore on _HomeStore, Store {
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
  Computed<Duration>? _$dailyTargetForRemainingComputed;

  @override
  Duration get dailyTargetForRemaining => (_$dailyTargetForRemainingComputed ??=
          Computed<Duration>(() => super.dailyTargetForRemaining,
              name: '_HomeStore.dailyTargetForRemaining'))
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

  late final _$groupedEntriesAtom =
      Atom(name: '_HomeStore.groupedEntries', context: context);

  @override
  Map<DateTime, List<TimeEntry>> get groupedEntries {
    _$groupedEntriesAtom.reportRead();
    return super.groupedEntries;
  }

  @override
  set groupedEntries(Map<DateTime, List<TimeEntry>> value) {
    _$groupedEntriesAtom.reportWrite(value, super.groupedEntries, () {
      super.groupedEntries = value;
    });
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
groupedEntries: ${groupedEntries},
isLoadingWithData: ${isLoadingWithData},
remaining: ${remaining},
dailyTargetForRemaining: ${dailyTargetForRemaining}
    ''';
  }
}
