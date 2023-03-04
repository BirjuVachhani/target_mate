import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:toggl_target/api/toggl_api_service.dart';
import 'package:toggl_target/resources/keys.dart';
import 'package:toggl_target/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../model/project.dart';
import '../../model/workspace.dart';
import '../../ui/back_button.dart';
import '../../ui/custom_dropdown.dart';
import '../../ui/custom_scaffold.dart';
import '../../ui/dropdown_button3.dart';
import '../../ui/widgets.dart';
import 'project_selection_page.dart';

part 'workspace_selection_page.g.dart';

class WorkspaceSelectionPageWrapper extends StatelessWidget {
  final List<Workspace> workspaces;

  const WorkspaceSelectionPageWrapper({
    super.key,
    required this.workspaces,
  });

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => WorkspaceSelectionStore(workspaces),
      // dispose: (context, store) => store.dispose(),
      child: const WorkspaceSelectionPage(),
    );
  }
}

class WorkspaceSelectionPage extends StatefulWidget {
  const WorkspaceSelectionPage({super.key});

  @override
  State<WorkspaceSelectionPage> createState() => _WorkspaceSelectionPageState();
}

class _WorkspaceSelectionPageState extends State<WorkspaceSelectionPage> {
  late final WorkspaceSelectionStore store =
      context.read<WorkspaceSelectionStore>();

  late final TapGestureRecognizer recognizer = TapGestureRecognizer()
    ..onTap = () => launchUrlString('https://track.toggl.com/profile');

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 350,
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
                      onSelected: (value) => store.selectedWorkspace = value,
                      itemBuilder: (context, item) =>
                          CustomDropdownMenuItem<Workspace>(
                        value: item,
                        child: Text(item.name),
                      ),
                      items: store.workspaces,
                    );
                  },
                ),
                const SizedBox(height: 32),
                Observer(
                  name: 'WorkspaceSelection-NextButton',
                  builder: (context) => Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed:
                              store.selectedWorkspace == null ? null : onNext,
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
                  name: 'WorkspaceSelection-Error',
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
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => ProjectSelectionPageWrapper(
          projects: store.projects,
        ),
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
class WorkspaceSelectionStore = _WorkspaceSelectionStore
    with _$WorkspaceSelectionStore;

abstract class _WorkspaceSelectionStore with Store {
  _WorkspaceSelectionStore(this.workspaces) {
    selectedWorkspace = workspaces.firstOrNull;
    authKey = box.get(HiveKeys.authKey);
  }

  late final Box box = getSecretsBox();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  final List<Workspace> workspaces;

  late final String authKey;

  List<Project> projects = [];

  late final TogglApiService apiService = GetIt.instance.get<TogglApiService>();

  @observable
  Workspace? selectedWorkspace;

  @action
  Future<bool> saveAndContinue() async {
    if (isLoading) return false;
    isLoading = true;
    error = null;
    try {
      // Load projects.
      final response =
          await apiService.getWorkspaceProjects(selectedWorkspace!.id);

      isLoading = false;
      if (!response.isSuccessful) {
        error = 'Invalid API key';
        return false;
      }
      projects = response.body ?? [];

      if (projects.isEmpty) {
        error = 'No projects found';
        return false;
      }
      log('${projects.length} projects found');

      await box.put(
          HiveKeys.workspace, json.encode(selectedWorkspace!.toJson()));

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
