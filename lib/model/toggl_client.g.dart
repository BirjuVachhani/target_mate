// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toggl_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TogglClient _$TogglClientFromJson(Map<String, dynamic> json) => TogglClient(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      wid: (json['wid'] as num).toInt(),
      archived: json['archived'] as bool,
      createdAt: const DateTimeConverter().fromJson(json['at'] as String),
      creatorId: (json['creator_id'] as num).toInt(),
    );

Map<String, dynamic> _$TogglClientToJson(TogglClient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'wid': instance.wid,
      'archived': instance.archived,
      'at': const DateTimeConverter().toJson(instance.createdAt),
      'creator_id': instance.creatorId,
    };
