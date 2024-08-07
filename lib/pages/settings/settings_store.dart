import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:screwdriver/screwdriver.dart';

import '../../api/toggl_api_service.dart';
import '../../model/project.dart';
import '../../model/time_entry.dart';
import '../../model/toggl_client.dart';
import '../../model/workspace.dart';
import '../../resources/keys.dart';
import '../../utils/utils.dart';

part 'settings_store.g.dart';

// ignore: library_private_types_in_public_api
class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore with Store {
  late final Box box = getAppSettingsBox();
  late final Box secretsBox = getSecretsBox();
  late final TogglApiService apiService = GetIt.instance.get<TogglApiService>();

  _SettingsStore() {
    init();
  }

  @observable
  Color themeColor = Colors.transparent;

  @observable
  bool useMaterial3 = false;

  @observable
  bool showRemaining = false;

  @observable
  Duration refreshFrequency = 5.minutes;

  @observable
  bool isLoadingProjects = false;

  StreamSubscription? subscription;

  @observable
  Workspace? selectedWorkspace;

  @observable
  Project? selectedProject;

  @observable
  TogglClient? selectedClient;

  @observable
  TimeEntryType selectedTimeEntryType = TimeEntryType.all;

  @observable
  List<Workspace> workspaces = [];

  @observable
  List<Project> filteredProjects = [];

  List<Project> projects = [];

  @observable
  List<TogglClient> filteredClients = [];

  List<TogglClient> clients = [];

  @observable
  String? error;

  @action
  void init() {
    subscription = getAppSettingsBox()
        .watch(key: HiveKeys.refreshFrequency)
        .listen((event) {
      refresh();
    });

    themeColor = Color(box.get(HiveKeys.primaryColor));
    refreshFrequency =
        Duration(minutes: box.get(HiveKeys.refreshFrequency, defaultValue: 5));

    selectedWorkspace = getWorkspaceFromStorage()!;
    selectedProject = getProjectFromStorage() ?? emptyProject;

    final entryTypeValue =
        box.get(HiveKeys.entryType, defaultValue: TimeEntryType.all.name);
    selectedTimeEntryType = TimeEntryType.values.byName(entryTypeValue);

    useMaterial3 = box.get(HiveKeys.useMaterial3, defaultValue: true);
    showRemaining = box.get(HiveKeys.showRemaining, defaultValue: false);

    loadFilters();
  }

  void refresh() {
    themeColor = Color(box.get(HiveKeys.primaryColor));
    refreshFrequency =
        Duration(minutes: box.get(HiveKeys.refreshFrequency, defaultValue: 5));
  }

  @action
  void onToggleUseMaterial3(bool value) {
    useMaterial3 = value;
    box.put(HiveKeys.useMaterial3, value);
  }

  @action
  void onToggleShowRemaining(bool value) {
    showRemaining = value;
    box.put(HiveKeys.showRemaining, value);
  }

  @action
  void setThemeColor(Color color) {
    themeColor = color;
    box.put(HiveKeys.primaryColor, color.value);
  }

  @action
  void setRefreshFrequency(Duration duration) {
    refreshFrequency = duration;
    box.put(HiveKeys.refreshFrequency, duration.inMinutes);
  }

  @action
  Future<void> loadFilters() async {
    try {
      isLoadingProjects = true;
      error = null;

      log('Loading workspaces and projects');

      final workspacesResponse = await apiService.getAllWorkspaces();
      if (!workspacesResponse.isSuccessful) {
        throw workspacesResponse.error ?? workspacesResponse.bodyString;
      }
      workspaces = workspacesResponse.body!;

      final projectsResponse = await apiService.getAllProjects();
      if (!projectsResponse.isSuccessful) {
        throw projectsResponse.error ?? projectsResponse.bodyString;
      }

      projects = projectsResponse.body!;
      filteredProjects = projects
          .where((project) => project.workspaceId == selectedWorkspace!.id)
          .toList();

      final clientsResponse = await apiService.getAllClients();
      if (!clientsResponse.isSuccessful) {
        throw clientsResponse.error ?? clientsResponse.bodyString;
      }

      clients = clientsResponse.body!;
      filteredClients = clients
          .where((client) => client.wid == selectedWorkspace!.id)
          .toList();

      isLoadingProjects = false;
      log('Workspaces, clients, and projects loaded successfully!');
    } catch (err, stacktrace) {
      log('Failed to load workspaces, clients, and projects');
      log(err.toString());
      log(stacktrace.toString());
      error = err.toString();
      isLoadingProjects = false;
    }
  }

  @action
  Future<void> onWorkspaceSelected(Workspace workspace) async {
    selectedWorkspace = workspace;
    // Filter projects by selected workspace.
    filteredProjects = projects
        .where((project) => project.workspaceId == workspace.id)
        .toList();
    // Set selected project to All
    selectedProject = emptyProject;

    // Filter clients by selected workspace.
    filteredClients =
        clients.where((client) => client.wid == workspace.id).toList();

    // Set selected client to All
    selectedClient = emptyClient;
    await secretsBox.put(HiveKeys.workspace, json.encode(workspace.toJson()));
    await secretsBox.delete(HiveKeys.client);
    await secretsBox.delete(HiveKeys.project);
  }

  @action
  Future<void> onClientSelected(TogglClient client) async {
    selectedClient = client;
    if (client == emptyClient) {
      // load all projects in selected workspace.
      filteredProjects = projects
          .where((project) => project.workspaceId == selectedWorkspace!.id)
          .toList();
    } else {
      // load projects filtered by selected client.
      filteredProjects = projects
          .where((project) =>
              project.clientId == client.id || project.cid == client.id)
          .toList();
    }

    // Set selected project to All
    selectedProject = emptyProject;
    await secretsBox.put(HiveKeys.client, json.encode(client.toJson()));
    await secretsBox.delete(HiveKeys.project);
  }

  @action
  Future<void> onProjectSelected(Project project) async {
    selectedProject = project;
    if (project.id == emptyProject.id) {
      await secretsBox.delete(HiveKeys.project);
    } else {
      await secretsBox.put(HiveKeys.project, json.encode(project.toJson()));
    }
  }

  @action
  Future<void> onTimeEntryTypeSelected(TimeEntryType type) async {
    selectedTimeEntryType = type;
    await box.put(HiveKeys.entryType, type.name);
  }

  void dispose() {
    subscription?.cancel();
  }
}
