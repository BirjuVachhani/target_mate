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

  late final _$filteredProjectsAtom =
      Atom(name: '_ProjectSelectionStore.filteredProjects', context: context);

  @override
  List<Project> get filteredProjects {
    _$filteredProjectsAtom.reportRead();
    return super.filteredProjects;
  }

  @override
  set filteredProjects(List<Project> value) {
    _$filteredProjectsAtom.reportWrite(value, super.filteredProjects, () {
      super.filteredProjects = value;
    });
  }

  late final _$filteredClientsAtom =
      Atom(name: '_ProjectSelectionStore.filteredClients', context: context);

  @override
  List<TogglClient> get filteredClients {
    _$filteredClientsAtom.reportRead();
    return super.filteredClients;
  }

  @override
  set filteredClients(List<TogglClient> value) {
    _$filteredClientsAtom.reportWrite(value, super.filteredClients, () {
      super.filteredClients = value;
    });
  }

  late final _$selectedWorkspaceAtom =
      Atom(name: '_ProjectSelectionStore.selectedWorkspace', context: context);

  @override
  Workspace? get selectedWorkspace {
    _$selectedWorkspaceAtom.reportRead();
    return super.selectedWorkspace;
  }

  @override
  set selectedWorkspace(Workspace? value) {
    _$selectedWorkspaceAtom.reportWrite(value, super.selectedWorkspace, () {
      super.selectedWorkspace = value;
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

  late final _$selectedClientAtom =
      Atom(name: '_ProjectSelectionStore.selectedClient', context: context);

  @override
  TogglClient? get selectedClient {
    _$selectedClientAtom.reportRead();
    return super.selectedClient;
  }

  @override
  set selectedClient(TogglClient? value) {
    _$selectedClientAtom.reportWrite(value, super.selectedClient, () {
      super.selectedClient = value;
    });
  }

  late final _$selectedEntryTypeAtom =
      Atom(name: '_ProjectSelectionStore.selectedEntryType', context: context);

  @override
  TimeEntryType get selectedEntryType {
    _$selectedEntryTypeAtom.reportRead();
    return super.selectedEntryType;
  }

  @override
  set selectedEntryType(TimeEntryType value) {
    _$selectedEntryTypeAtom.reportWrite(value, super.selectedEntryType, () {
      super.selectedEntryType = value;
    });
  }

  late final _$saveAndContinueAsyncAction =
      AsyncAction('_ProjectSelectionStore.saveAndContinue', context: context);

  @override
  Future<bool> saveAndContinue() {
    return _$saveAndContinueAsyncAction.run(() => super.saveAndContinue());
  }

  late final _$_ProjectSelectionStoreActionController =
      ActionController(name: '_ProjectSelectionStore', context: context);

  @override
  void onWorkspaceSelected(Workspace value) {
    final _$actionInfo = _$_ProjectSelectionStoreActionController.startAction(
        name: '_ProjectSelectionStore.onWorkspaceSelected');
    try {
      return super.onWorkspaceSelected(value);
    } finally {
      _$_ProjectSelectionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onClientSelected(TogglClient value) {
    final _$actionInfo = _$_ProjectSelectionStoreActionController.startAction(
        name: '_ProjectSelectionStore.onClientSelected');
    try {
      return super.onClientSelected(value);
    } finally {
      _$_ProjectSelectionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
error: ${error},
filteredProjects: ${filteredProjects},
filteredClients: ${filteredClients},
selectedWorkspace: ${selectedWorkspace},
selectedProject: ${selectedProject},
selectedClient: ${selectedClient},
selectedEntryType: ${selectedEntryType}
    ''';
  }
}
