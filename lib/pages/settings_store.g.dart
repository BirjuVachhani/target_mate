// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_store.dart';

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

  late final _$selectedWorkspaceAtom =
      Atom(name: '_SettingsStore.selectedWorkspace', context: context);

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
      Atom(name: '_SettingsStore.selectedProject', context: context);

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

  late final _$workspacesAtom =
      Atom(name: '_SettingsStore.workspaces', context: context);

  @override
  List<Workspace> get workspaces {
    _$workspacesAtom.reportRead();
    return super.workspaces;
  }

  @override
  set workspaces(List<Workspace> value) {
    _$workspacesAtom.reportWrite(value, super.workspaces, () {
      super.workspaces = value;
    });
  }

  late final _$filteredProjectsAtom =
      Atom(name: '_SettingsStore.filteredProjects', context: context);

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

  late final _$errorAtom = Atom(name: '_SettingsStore.error', context: context);

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

  late final _$loadWorkspacesAndProjectsAsyncAction =
      AsyncAction('_SettingsStore.loadWorkspacesAndProjects', context: context);

  @override
  Future<void> loadWorkspacesAndProjects() {
    return _$loadWorkspacesAndProjectsAsyncAction
        .run(() => super.loadWorkspacesAndProjects());
  }

  late final _$onWorkspaceSelectedAsyncAction =
      AsyncAction('_SettingsStore.onWorkspaceSelected', context: context);

  @override
  Future<void> onWorkspaceSelected(Workspace workspace) {
    return _$onWorkspaceSelectedAsyncAction
        .run(() => super.onWorkspaceSelected(workspace));
  }

  late final _$onProjectSelectedAsyncAction =
      AsyncAction('_SettingsStore.onProjectSelected', context: context);

  @override
  Future<void> onProjectSelected(Project project) {
    return _$onProjectSelectedAsyncAction
        .run(() => super.onProjectSelected(project));
  }

  late final _$_SettingsStoreActionController =
      ActionController(name: '_SettingsStore', context: context);

  @override
  void init() {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.init');
    try {
      return super.init();
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void onToggleUseMaterial3(bool value) {
    final _$actionInfo = _$_SettingsStoreActionController.startAction(
        name: '_SettingsStore.onToggleUseMaterial3');
    try {
      return super.onToggleUseMaterial3(value);
    } finally {
      _$_SettingsStoreActionController.endAction(_$actionInfo);
    }
  }

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
isLoadingProjects: ${isLoadingProjects},
selectedWorkspace: ${selectedWorkspace},
selectedProject: ${selectedProject},
workspaces: ${workspaces},
filteredProjects: ${filteredProjects},
error: ${error}
    ''';
  }
}
