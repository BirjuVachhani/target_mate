import 'dart:convert';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:toggl_target/resources/keys.dart';
import 'package:toggl_target/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../ui/back_button.dart';
import '../../ui/custom_dropdown.dart';
import '../../ui/dropdown_button3.dart';
import '../../ui/widgets.dart';
import 'project_selection_page.dart';

part 'workspace_selection_page.g.dart';

class WorkspaceSelectionPageWrapper extends StatelessWidget {
  final List<Map<String, dynamic>> workspaces;

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
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
                    return CustomDropdown<int>(
                      value: store.selectedWorkspaceId,
                      isExpanded: true,
                      onSelected: (value) => store.selectedWorkspaceId = value,
                      itemBuilder: (context, item) =>
                          CustomDropdownMenuItem<int>(
                        value: item,
                        child: Text(store.workspaces
                            .firstWhere((e) => e['id'] == item)['name']
                            .toString()),
                      ),
                      items: store.workspaces.map<int>((e) => e['id']).toList(),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Observer(
                  name: 'WorkspaceSelection-NextButton',
                  builder: (context) => Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              store.selectedWorkspaceId == -1 ? null : onNext,
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
    Navigator.of(context).push(FadeThroughPageRoute(
      child: ProjectSelectionPageWrapper(
        projects: store.projects,
      ),
    ));
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
    selectedWorkspaceId = workspaces.first['id'];
    apiKey = box.get(HiveKeys.apiKey);
  }

  late final Box box = getSecretsBox();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  final List<Map<String, dynamic>> workspaces;
  late final String apiKey;

  List<Map<String, dynamic>> projects = [];

  @observable
  int? selectedWorkspaceId;

  @action
  Future<bool> saveAndContinue() async {
    if (isLoading) return false;
    isLoading = true;
    error = null;
    try {
      final authKey = base64Encode('$apiKey:api_token'.codeUnits);

      // Load projects.
      final response = await http.get(
        Uri.parse(
            'https://api.track.toggl.com/api/v9/workspaces/$selectedWorkspaceId/projects'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $authKey',
        },
      );

      isLoading = false;
      if (response.statusCode != 200) {
        log(response.body);
        error = 'Invalid API key';
        return false;
      }
      final data = List.from(jsonDecode(response.body));
      projects = data.map((e) => Map<String, dynamic>.from(e)).toList();

      if (projects.isEmpty) {
        error = 'No projects found';
        return false;
      }
      log('${projects.length} projects found');

      final String name = workspaces.firstWhere(
          (element) => element['id'] == selectedWorkspaceId)['name'];
      await box.put(HiveKeys.workspaceId, selectedWorkspaceId);
      await box.put(HiveKeys.workspaceName, name);

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
