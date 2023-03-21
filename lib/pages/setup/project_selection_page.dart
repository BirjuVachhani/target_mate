import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../model/project.dart';
import '../../model/workspace.dart';
import '../../resources/keys.dart';
import '../../ui/back_button.dart';
import '../../ui/custom_dropdown.dart';
import '../../ui/custom_scaffold.dart';
import '../../ui/dropdown_button3.dart';
import '../../ui/widgets.dart';
import '../../utils/utils.dart';
import 'target_setup_page.dart';

part 'project_selection_page.g.dart';

class ProjectSelectionPageWrapper extends StatelessWidget {
  final List<Workspace> workspaces;
  final List<Project> projects;

  const ProjectSelectionPageWrapper({
    super.key,
    required this.workspaces,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => ProjectSelectionStore(workspaces, projects),
      // dispose: (context, store) => store.dispose(),
      child: const ProjectSelectionPage(),
    );
  }
}

class ProjectSelectionPage extends StatefulWidget {
  const ProjectSelectionPage({super.key});

  @override
  State<ProjectSelectionPage> createState() => _ProjectSelectionPageState();
}

class _ProjectSelectionPageState extends State<ProjectSelectionPage> {
  late final ProjectSelectionStore store =
      context.read<ProjectSelectionStore>();

  late final TapGestureRecognizer recognizer = TapGestureRecognizer()
    ..onTap = () => launchUrlString('https://track.toggl.com/profile');

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Observer(
                  builder: (context) => CustomBackButton(
                    disabled: store.isLoading,
                  ),
                ),
                const SizedBox(height: 24),
                const FieldLabel('Select Workspace'),
                Observer(
                  name: 'WorkspaceSelection-dropdown',
                  builder: (context) {
                    return CustomDropdown<Workspace>(
                      value: store.selectedWorkspace,
                      isExpanded: true,
                      onSelected: (value) => store.onWorkspaceSelected(value),
                      itemBuilder: (context, item) =>
                          CustomDropdownMenuItem<Workspace>(
                        value: item,
                        child: Text(item.name),
                      ),
                      items: store.workspaces,
                    );
                  },
                ),
                const SizedBox(height: 24),
                const FieldLabel('Select Project'),
                Observer(
                  name: 'ProjectSelection-dropdown',
                  builder: (context) {
                    return CustomDropdown<Project>(
                      value: store.selectedProject,
                      isExpanded: true,
                      onSelected: (value) => store.selectedProject = value,
                      itemBuilder: (context, item) {
                        return CustomDropdownMenuItem<Project>(
                          value: item,
                          child: Text(
                            item.name.isNotEmpty ? item.name : 'Untitled',
                            style: TextStyle(
                              color: item.name.isEmpty
                                  ? context.theme.colorScheme.onSurface
                                      .withOpacity(0.5)
                                  : null,
                              fontStyle: item.name.isNotEmpty
                                  ? null
                                  : FontStyle.italic,
                            ),
                          ),
                        );
                      },
                      items: [
                        emptyProject,
                        ...store.filteredProjects,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Observer(
                  name: 'ProjectSelection-NextButton',
                  builder: (context) => Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed:
                              store.selectedProject == null ? null : onNext,
                          child: store.isLoading
                              ? FittedBox(
                                  child: SpinKitThreeBounce(
                                    color: context.theme.colorScheme.onPrimary,
                                    size: 18,
                                  ),
                                )
                              : const Text('Next'),
                        ),
                      ),
                    ],
                  ),
                ),
                Observer(
                  name: 'ProjectSelection-Error',
                  builder: (context) {
                    if (store.error == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Error: ${store.error}',
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onNext() async {
    final result = await store.saveAndContinue();
    if (result == true) onSuccess();
  }

  void onSuccess() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const TargetSetupPageWrapper(),
      ),
    );
  }

  @override
  void dispose() {
    recognizer.dispose();
    super.dispose();
  }
}

// ignore: library_private_types_in_public_api
class ProjectSelectionStore = _ProjectSelectionStore
    with _$ProjectSelectionStore;

abstract class _ProjectSelectionStore with Store {
  _ProjectSelectionStore(this.workspaces, this.projects) {
    selectedWorkspace = workspaces.firstOrNull;
    authKey = box.get(HiveKeys.authKey);
    selectedProject = emptyProject;
    filteredProjects = [...projects];
  }

  late final Box box = getSecretsBox();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  final List<Workspace> workspaces;
  final List<Project> projects;
  late final String authKey;

  @observable
  List<Project> filteredProjects = [];

  @observable
  Workspace? selectedWorkspace;

  @observable
  Project? selectedProject;

  @action
  void onWorkspaceSelected(Workspace value) {
    selectedWorkspace = value;
    selectedProject = emptyProject;
    filteredProjects =
        projects.where((element) => element.workspaceId == value.id).toList();
  }

  @action
  Future<bool> saveAndContinue() async {
    if (isLoading) return false;
    isLoading = true;
    error = null;
    try {
      await box.put(
          HiveKeys.workspace, json.encode(selectedWorkspace!.toJson()));

      if (selectedProject == null || selectedProject!.id == -1) {
        await box.delete(HiveKeys.projectId);
      } else {
        await box.put(HiveKeys.project, json.encode(selectedProject!.toJson()));
      }
      isLoading = false;
      return true;
    } catch (err, stacktrace) {
      log(err.toString());
      log(stacktrace.toString());
      isLoading = false;
      error = err.toString();
      return false;
    }
  }
}
