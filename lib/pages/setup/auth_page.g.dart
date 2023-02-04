// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_page.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStore, Store {
  late final _$isLoadingAtom =
      Atom(name: '_AuthStore.isLoading', context: context);

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

  late final _$errorAtom = Atom(name: '_AuthStore.error', context: context);

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

  late final _$apiKeyAtom = Atom(name: '_AuthStore.apiKey', context: context);

  @override
  String get apiKey {
    _$apiKeyAtom.reportRead();
    return super.apiKey;
  }

  @override
  set apiKey(String value) {
    _$apiKeyAtom.reportWrite(value, super.apiKey, () {
      super.apiKey = value;
    });
  }

  late final _$loginWithAPIKeyAtom =
      Atom(name: '_AuthStore.loginWithAPIKey', context: context);

  @override
  bool get loginWithAPIKey {
    _$loginWithAPIKeyAtom.reportRead();
    return super.loginWithAPIKey;
  }

  @override
  set loginWithAPIKey(bool value) {
    _$loginWithAPIKeyAtom.reportWrite(value, super.loginWithAPIKey, () {
      super.loginWithAPIKey = value;
    });
  }

  late final _$emailAtom = Atom(name: '_AuthStore.email', context: context);

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$passwordAtom =
      Atom(name: '_AuthStore.password', context: context);

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  late final _$saveAndContinueAsyncAction =
      AsyncAction('_AuthStore.saveAndContinue', context: context);

  @override
  Future<bool> saveAndContinue() {
    return _$saveAndContinueAsyncAction.run(() => super.saveAndContinue());
  }

  late final _$_AuthStoreActionController =
      ActionController(name: '_AuthStore', context: context);

  @override
  void setLoginWithAPIKey(bool value) {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
        name: '_AuthStore.setLoginWithAPIKey');
    try {
      return super.setLoginWithAPIKey(value);
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
apiKey: ${apiKey},
loginWithAPIKey: ${loginWithAPIKey},
email: ${email},
password: ${password}
    ''';
  }
}
