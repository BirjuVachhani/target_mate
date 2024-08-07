// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: (json['id'] as num).toInt(),
      workspaceId: (json['workspace_id'] as num).toInt(),
      name: json['name'] as String,
      isPrivate: json['is_private'] as bool,
      active: json['active'] as bool,
      at: const DateTimeConverter().fromJson(json['at'] as String),
      createdAt:
          const DateTimeConverter().fromJson(json['created_at'] as String),
      isDeleted: deletedFromJson(json['server_deleted_at']),
      color: json['color'] as String?,
      billable: json['billable'] as bool? ?? false,
      currency: json['currency'] as String?,
      recurring: json['recurring'] as bool? ?? false,
      wid: (json['wid'] as num?)?.toInt(),
      clientId: (json['client_id'] as num?)?.toInt(),
      cid: (json['cid'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'workspace_id': instance.workspaceId,
      'name': instance.name,
      'is_private': instance.isPrivate,
      'active': instance.active,
      'at': const DateTimeConverter().toJson(instance.at),
      'created_at': const DateTimeConverter().toJson(instance.createdAt),
      'server_deleted_at': instance.isDeleted,
      'color': instance.color,
      'billable': instance.billable,
      'currency': instance.currency,
      'recurring': instance.recurring,
      'wid': instance.wid,
      'client_id': instance.clientId,
      'cid': instance.cid,
    };
