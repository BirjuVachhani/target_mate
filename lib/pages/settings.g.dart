// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsStore on _SettingsStore, Store {
  late final _$themeColorAtom =
      Atom(name: '_SettingsStore.themeColor', context: context);

  @override
  Color get themeColor {
    _$themeColorAtom.reportRead();
    return super.themeColor;
  }

  @override
  set themeColor(Color value) {
    _$themeColorAtom.reportWrite(value, super.themeColor, () {
      super.themeColor = value;
    });
  }

  late final _$useMaterial3Atom =
      Atom(name: '_SettingsStore.useMaterial3', context: context);

  @override
  bool get useMaterial3 {
    _$useMaterial3Atom.reportRead();
    return super.useMaterial3;
  }

  @override
  set useMaterial3(bool value) {
    _$useMaterial3Atom.reportWrite(value, super.useMaterial3, () {
      super.useMaterial3 = value;
    });
  }

  late final _$refreshFrequencyAtom =
      Atom(name: '_SettingsStore.refreshFrequency', context: context);

  @override
  Duration get refreshFrequency {
    _$refreshFrequencyAtom.reportRead();
    return super.refreshFrequency;
  }

  @override
  set refreshFrequency(Duration value) {
    _$refreshFrequencyAtom.reportWrite(value, super.refreshFrequency, () {
      super.refreshFrequency = value;
    });
  }

  late final _$isLoadingProjectsAtom =
      Atom(name: '_SettingsStore.isLoadingProjects', context: context);

  @override
  bool get isLoadingProjects {
    _$isLoadingProjectsAtom.reportRead();
    return super.isLoadingProjects;
  }

  @override
  set isLoadingProjects(bool value) {
    _$isLoadingProjectsAtom.reportWrite(value, super.isLoadingProjects, () {
      super.isLoadingProjects = value;
    });
  }

  late final _$fetchAllProjectsAsyncAction =
      AsyncAction('_SettingsStore.fetchAllProjects', context: context);

  @override
  Future<void> fetchAllProjects() {
    return _$fetchAllProjectsAsyncAction.run(() => super.fetchAllProjects());
  }

  late final _$_SettingsStoreActionController =
      ActionController(name: '_SettingsStore', context: context);

  @override
  void setThemeColor(Color color) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setThemeColor');
    try {
      return super.setThemeColor(color);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setRefreshFrequency(Duration duration) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.setRefreshFrequency');
    try {
      return super.setRefreshFrequency(duration);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
themeColor: ${themeColor},
useMaterial3: ${useMaterial3},
refreshFrequency: ${refreshFrequency},
isLoadingProjects: ${isLoadingProjects}
    ''';
  }
}
