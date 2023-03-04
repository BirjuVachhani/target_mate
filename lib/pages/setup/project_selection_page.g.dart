// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_selection_page.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProjectSelectionStore on _ProjectSelectionStore, Store {
  late final _$isLoadingAtom =
      Atom(name: '_ProjectSelectionStore.isLoading', context: context);

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

  late final _$errorAtom =
      Atom(name: '_ProjectSelectionStore.error', context: context);

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

  late final _$selectedProjectAtom =
      Atom(name: '_ProjectSelectionStore.selectedProject', context: context);

  @override
  Project? get selectedProject {
    _$selectedProjectAtom.reportRead();
    return super.selectedProject;
  }

  @override
  set selectedProject(Project? value) {
    _$selectedProjectAtom.reportWrite(value, super.selectedProject, () {
      super.selectedProject = value;
    });
  }

  late final _$saveAndContinueAsyncAction =
      AsyncAction('_ProjectSelectionStore.saveAndContinue', context: context);

  @override
  Future<bool> saveAndContinue() {
    return _$saveAndContinueAsyncAction.run(() => super.saveAndContinue());
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
selectedProject: ${selectedProject}
    ''';
  }
}
