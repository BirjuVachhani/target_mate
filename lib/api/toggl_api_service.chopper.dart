// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toggl_api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$TogglApiService extends TogglApiService {
  _$TogglApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = TogglApiService;

  @override
  Future<Response<User>> getProfile() {
    final Uri $url = Uri.parse('/api/v9/me');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<User, User>($request);
  }

  @override
  Future<Response<List<TimeEntry>>> getTimeEntries(
    String startDate,
    String endDate,
  ) {
    final Uri $url = Uri.parse('/api/v9/me/time_entries?meta=true');
    final Map<String, dynamic> $params = <String, dynamic>{
      'start_date': startDate,
      'end_date': endDate,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<TimeEntry>, TimeEntry>($request);
  }

  @override
  Future<Response<List<Workspace>>> getAllWorkspaces() {
    final Uri $url = Uri.parse('/api/v9/workspaces');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<Workspace>, Workspace>($request);
  }

  @override
  Future<Response<List<TogglClient>>> getAllClients() {
    final Uri $url = Uri.parse('/api/v9/me/clients');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<TogglClient>, TogglClient>($request);
  }

  @override
  Future<Response<List<Project>>> getAllProjects() {
    final Uri $url = Uri.parse('/api/v9/me/projects');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<Project>, Project>($request);
  }

  @override
  Future<Response<List<Project>>> getWorkspaceProjects(int workspaceId) {
    final Uri $url = Uri.parse('/api/v9/workspaces/${workspaceId}/projects');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<Project>, Project>($request);
  }

  @override
  Future<Response<Project>> getProject(
    int id,
    int workspaceId,
  ) {
    final Uri $url =
        Uri.parse('/api/v9/workspaces/${workspaceId}/projects/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Project, Project>($request);
  }

  @override
  Future<Response<Workspace>> getWorkspace(int id) {
    final Uri $url = Uri.parse('/api/v9/workspaces/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Workspace, Workspace>($request);
  }
}
