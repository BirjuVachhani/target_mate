// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeEntry _$TimeEntryFromJson(Map<String, dynamic> json) => TimeEntry(
      id: json['id'] as int,
      workspaceId: json['workspace_id'] as int,
      projectId: json['project_id'] as int?,
      taskId: json['task_id'] as int?,
      description: json['description'] as String?,
      start: dateTimeFromJson(json['start'] as String),
      stop: stopDateTimeFromJson(json['stop'] as String?),
      duration: durationFromJson(json['duration'] as int),
      userId: json['user_id'] as int,
      uid: json['uid'] as int,
      wid: json['wid'] as int?,
      pid: json['pid'] as int?,
      billable: json['billable'] as bool,
      isDeleted: deletedFromJson(json['server_deleted_at'] as String?),
      isRunning: json['isRunning'] as bool? ?? false,
    );

Map<String, dynamic> _$TimeEntryToJson(TimeEntry instance) => <String, dynamic>{
      'id': instance.id,
      'workspace_id': instance.workspaceId,
      'project_id': instance.projectId,
      'task_id': instance.taskId,
      'description': instance.description,
      'start': dateTimeToJson(instance.start),
      'stop': dateTimeToJson(instance.stop),
      'duration': durationToJson(instance.duration),
      'user_id': instance.userId,
      'uid': instance.uid,
      'wid': instance.wid,
      'pid': instance.pid,
      'billable': instance.billable,
      'server_deleted_at': instance.isDeleted,
      'isRunning': instance.isRunning,
    };
