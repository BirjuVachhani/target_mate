// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workspace _$WorkspaceFromJson(Map<String, dynamic> json) => Workspace(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      name: json['name'] as String,
      defaultCurrency: json['default_currency'] as String,
      projectsBillableByDefault: json['projects_billable_by_default'] as bool,
      logoUrl: json['logo_url'] as String?,
    );

Map<String, dynamic> _$WorkspaceToJson(Workspace instance) => <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'name': instance.name,
      'default_currency': instance.defaultCurrency,
      'projects_billable_by_default': instance.projectsBillableByDefault,
      'logo_url': instance.logoUrl,
    };
