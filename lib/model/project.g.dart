// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: json['id'] as int,
      workspaceId: json['workspace_id'] as int,
      name: json['name'] as String,
      isPrivate: json['is_private'] as bool,
      active: json['active'] as bool,
      at: dateTimeFromJson(json['at'] as String),
      createdAt: dateTimeFromJson(json['created_at'] as String),
      isDeleted: deletedFromJson(json['server_deleted_at']),
      color: json['color'] as String?,
      billable: json['billable'] as bool? ?? false,
      currency: json['currency'] as String?,
      recurring: json['recurring'] as bool? ?? false,
      wid: json['wid'] as int?,
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'workspace_id': instance.workspaceId,
      'name': instance.name,
      'is_private': instance.isPrivate,
      'active': instance.active,
      'at': dateTimeToJson(instance.at),
      'created_at': dateTimeToJson(instance.createdAt),
      'server_deleted_at': instance.isDeleted,
      'color': instance.color,
      'billable': instance.billable,
      'currency': instance.currency,
      'recurring': instance.recurring,
      'wid': instance.wid,
    };
