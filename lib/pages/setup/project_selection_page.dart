import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:toggl_target/pages/setup/target_setup_page.dart';
import 'package:toggl_target/resources/keys.dart';
import 'package:toggl_target/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../ui/back_button.dart';
import '../../ui/custom_dropdown.dart';
import '../../ui/dropdown_button3.dart';
import '../../ui/widgets.dart';

part 'project_selection_page.g.dart';

class ProjectSelectionPageWrapper extends StatelessWidget {
  final List<Map<String, dynamic>> projects;

  const ProjectSelectionPageWrapper({
    super.key,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => ProjectSelectionStore(projects),
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
                const FieldLabel('Select Project'),
                Observer(
                  name: 'ProjectSelection-dropdown',
                  builder: (context) {
                    return CustomDropdown<int>(
                      value: store.selectedProjectId,
                      isExpanded: true,
                      onSelected: (value) => store.selectedProjectId = value,
                      itemBuilder: (context, item) {
                        final name = item == -1
                            ? 'All'
                            : store.projects
                                .firstWhere((e) => e['id'] == item)['name']
                                .toString();
                        return CustomDropdownMenuItem<int>(
                          value: item,
                          child: Text(
                            name.isNotEmpty ? name : 'Untitled',
                            style: TextStyle(
                              color: name.isEmpty
                                  ? context.theme.colorScheme.onSurface
                                      .withOpacity(0.5)
                                  : null,
                              fontStyle:
                                  name.isNotEmpty ? null : FontStyle.italic,
                            ),
                          ),
                        );
                      },
                      items: store.projects.map<int>((e) => e['id']).toList()
                        ..insert(0, -1),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Observer(
                  name: 'ProjectSelection-NextButton',
                  builder: (context) => Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              store.selectedProjectId == null ? null : onNext,
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
      FadeThroughPageRoute(child: const TargetSetupPageWrapper()),
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
  _ProjectSelectionStore(this.projects) {
    apiKey = box.get(HiveKeys.apiKey);
  }

  late final Box box = getSecretsBox();

  @observable
  bool isLoading = false;

  @observable
  String? error;

  final List<Map<String, dynamic>> projects;
  late final String apiKey;

  @observable
  int? selectedProjectId = -1;

  @action
  Future<bool> saveAndContinue() async {
    if (isLoading) return false;
    isLoading = true;
    error = null;
    try {
      final String name = selectedProjectId == -1
          ? 'All'
          : projects.firstWhere(
              (element) => element['id'] == selectedProjectId)['name'];
      if (selectedProjectId == -1) {
        await box.delete(HiveKeys.projectId);
      } else {
        await box.put(HiveKeys.projectId, selectedProjectId);
      }
      await box.put(HiveKeys.projectName, name);
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
