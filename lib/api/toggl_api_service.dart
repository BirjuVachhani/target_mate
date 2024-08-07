import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';

import '../model/project.dart';
import '../model/time_entry.dart';
import '../model/toggl_client.dart';
import '../model/user.dart';
import '../model/workspace.dart';
import '../resources/keys.dart';
import '../utils/utils.dart';

part 'toggl_api_service.chopper.dart';

@ChopperApi(baseUrl: '/api/v9')
abstract class TogglApiService extends ChopperService {
  static const String baseUrl = 'https://api.track.toggl.com';

  static TogglApiService create([ChopperClient? client]) {
    client = ChopperClient(
      baseUrl: Uri.parse(baseUrl),
      interceptors: [
        AuthInterceptor(),
        if (!kReleaseMode) HttpLoggingInterceptor(),
      ],
      services: [
        _$TogglApiService(),
      ],
      converter: const JsonToModelConverter(),
      errorConverter: const JsonConverter(),
    );
    return client.getService<TogglApiService>();
  }

  @Get(path: '/me')
  Future<Response<User>> getProfile();

  @Get(path: '/me/time_entries?meta=true')
  Future<Response<List<TimeEntry>>> getTimeEntries(
      @Query('start_date') String startDate, @Query('end_date') String endDate);

  @Get(path: '/workspaces')
  Future<Response<List<Workspace>>> getAllWorkspaces();

  @Get(path: '/me/clients')
  Future<Response<List<TogglClient>>> getAllClients();

  @Get(path: '/me/projects')
  Future<Response<List<Project>>> getAllProjects();

  @Get(path: '/workspaces/{workspace_id}/projects')
  Future<Response<List<Project>>> getWorkspaceProjects(
      @Path('workspace_id') int workspaceId);

  @Get(path: '/workspaces/{workspace_id}/projects/{project_id}')
  Future<Response<Project>> getProject(
      @Path('project_id') int id, @Path('workspace_id') int workspaceId);

  @Get(path: '/workspaces/{workspace_id}')
  Future<Response<Workspace>> getWorkspace(@Path('workspace_id') int id);
}

class AuthInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final String authKey = getSecretsBox().get(HiveKeys.authKey);
    final request = chain.request;
    final Response<BodyType> response = await chain.proceed(
      request.copyWith(
        headers: {
          ...request.headers,
          'Authorization': 'Basic $authKey',
        },
      ),
    );

    return response;
  }
}

class JsonToModelConverter extends JsonConverter {
  const JsonToModelConverter();

  @override
  FutureOr<Response<BodyType>> convertResponse<BodyType, InnerType>(
      Response response) async {
    final body = json.decode(response.bodyString);
    // Convert body to BodyType however you like

    BodyType bodyObject;
    if (body is List) {
      final List<InnerType> list = body.map((e) {
        if (registry[InnerType] == null) {
          throw Exception('No converter found for type $BodyType');
        }
        return registry[InnerType]!(e) as InnerType;
      }).toList();
      bodyObject = list as BodyType;
    } else {
      if (registry[BodyType] == null) {
        throw Exception('No converter found for type $BodyType');
      }
      bodyObject = registry[BodyType]!(body) as BodyType;
    }

    return response.copyWith<BodyType>(body: bodyObject);
  }
}

Map<Type, Object Function(Map<String, dynamic>)> registry = {
  User: User.fromJson,
  Workspace: Workspace.fromJson,
  Project: Project.fromJson,
  TogglClient: TogglClient.fromJson,
  TimeEntry: TimeEntry.fromJson,
  Map<String, dynamic>: (Map<String, dynamic> json) => json,
};
