// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeEntry _$TimeEntryFromJson(Map<String, dynamic> json) => TimeEntry(
      id: (json['id'] as num).toInt(),
      workspaceId: (json['workspace_id'] as num).toInt(),
      projectId: (json['project_id'] as num?)?.toInt(),
      taskId: (json['task_id'] as num?)?.toInt(),
      description: json['description'] as String?,
      start: const DateTimeConverter().fromJson(json['start'] as String),
      stop: const NullableDateTimeConverter().fromJson(json['stop'] as String?),
      duration:
          const DurationConverter().fromJson((json['duration'] as num).toInt()),
      userId: (json['user_id'] as num).toInt(),
      uid: (json['uid'] as num).toInt(),
      wid: (json['wid'] as num?)?.toInt(),
      pid: (json['pid'] as num?)?.toInt(),
      billable: json['billable'] as bool,
      isDeleted: deletedFromJson(json['server_deleted_at']),
      isRunning: json['isRunning'] as bool? ?? false,
      clientName: json['client_name'] as String?,
    );

Map<String, dynamic> _$TimeEntryToJson(TimeEntry instance) => <String, dynamic>{
      'id': instance.id,
      'workspace_id': instance.workspaceId,
      'project_id': instance.projectId,
      'task_id': instance.taskId,
      'description': instance.description,
      'start': const DateTimeConverter().toJson(instance.start),
      'stop': const NullableDateTimeConverter().toJson(instance.stop),
      'duration': const DurationConverter().toJson(instance.duration),
      'user_id': instance.userId,
      'uid': instance.uid,
      'wid': instance.wid,
      'pid': instance.pid,
      'billable': instance.billable,
      'server_deleted_at': instance.isDeleted,
      'isRunning': instance.isRunning,
      'client_name': instance.clientName,
    };
