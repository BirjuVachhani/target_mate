import 'dart:convert';
import 'dart:developer';

import 'package:get_it/get_it.dart';

import '../../api/toggl_api_service.dart';
import '../../model/project.dart';
import '../../model/user.dart';
import '../../model/workspace.dart';
import '../../resources/keys.dart';
import '../utils.dart';
import 'migration.dart';

const int kDatabaseVersion = 2;

const Map<int, Migration> migrationRegistry = {
  2: MigrationV2(),
  1: EmptyMigration(1),
};

// What changed:
// 1. Using a User model for user data instead of raw values.
// 2. Using a Workspace model for workspace data instead of raw values.
// 3. Using a Project model for project data instead of raw values.
class MigrationV2 extends Migration {
  const MigrationV2();

  @override
  final int version = 2;

  @override
  Future<void> upgrade() async {
    final apiService = GetIt.instance.get<TogglApiService>();
    final secretsBox = getSecretsBox();

    if (secretsBox.get(HiveKeys.onboarded, defaultValue: false) == false) {
      log('Skipping migration for version $version because user is not onboarded yet.');
      return;
    }

    // 1. Using a User model for user data instead of raw values.
    final userResponse = await apiService.getProfile();
    if (userResponse.isSuccessful) {
      final User user = userResponse.body!;
      await secretsBox.put(HiveKeys.user, jsonEncode(user.toJson()));
    } else {
      throw userResponse.error ?? userResponse.bodyString;
    }

    // 2. Using a Workspace model for workspace data instead of raw values.
    final int? workspaceId = await secretsBox.get('workspace_id');
    if (workspaceId != null) {
      final workspaceResponse = await apiService.getWorkspace(workspaceId);
      if (workspaceResponse.isSuccessful) {
        final Workspace workspace = workspaceResponse.body!;
        await secretsBox.put(
            HiveKeys.workspace, jsonEncode(workspace.toJson()));
      } else {
        throw workspaceResponse.error ?? workspaceResponse.bodyString;
      }
    }

    // 3. Using a Project model for project data instead of raw values.
    final int? projectId = await secretsBox.get('project_id');
    if (projectId != null && workspaceId != null) {
      final projectResponse =
          await apiService.getProject(projectId, workspaceId);
      if (projectResponse.isSuccessful) {
        final Project project = projectResponse.body!;
        await secretsBox.put(HiveKeys.project, jsonEncode(project.toJson()));
      } else {
        throw projectResponse.error ?? projectResponse.bodyString;
      }
    }

    // 4. Clear old data
    await secretsBox.delete('fullname');
    await secretsBox.delete('email');
    await secretsBox.delete('timezone');

    await secretsBox.delete('workspace_id');
    await secretsBox.delete('workspace_name');

    await secretsBox.delete('project_id');
    await secretsBox.delete('project_name');
  }

  @override
  Future<void> downgrade() async {
    final secretsBox = getSecretsBox();
    if (secretsBox.get(HiveKeys.onboarded, defaultValue: false) == false) {
      log('Skipping migration for version $version because user is not onboarded yet.');
      return;
    }

    // 1. Using a User model for user data instead of raw values.
    final user = User.fromJson(json.decode(secretsBox.get(HiveKeys.user)));
    await secretsBox.put('fullname', user.fullName);
    await secretsBox.put('email', user.email);
    await secretsBox.put('timezone', user.timezone);

    // 2. Using a Workspace model for workspace data instead of raw values.
    final workspace = secretsBox.containsKey(HiveKeys.workspace)
        ? Workspace.fromJson(json.decode(secretsBox.get(HiveKeys.workspace)))
        : null;
    if (workspace != null) {
      await secretsBox.put('workspace_id', workspace.id);
      await secretsBox.put('workspace_name', workspace.name);
    }

    // 3. Using a Project model for project data instead of raw values.
    final Project? project = secretsBox.containsKey(HiveKeys.project)
        ? Project.fromJson(json.decode(secretsBox.get(HiveKeys.project)))
        : null;
    if (project != null) {
      await secretsBox.put('project_id', project.id);
      await secretsBox.put('project_name', project.name);
    }

    // 4. Clear new data
    await secretsBox.delete(HiveKeys.user);
    await secretsBox.delete(HiveKeys.workspace);
    await secretsBox.delete(HiveKeys.project);
  }
}
