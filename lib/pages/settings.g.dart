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
refreshFrequency: ${refreshFrequency}
    ''';
  }
}
