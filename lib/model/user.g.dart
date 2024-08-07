// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      fullName: json['fullname'] as String,
      avatarUrl: json['image_url'] as String,
      timezone: json['timezone'] as String,
      defaultWorkspaceId: (json['default_workspace_id'] as num?)?.toInt(),
      beginningOfWeek: (json['beginning_of_week'] as num?)?.toInt() ?? 1,
      countryId: (json['country_id'] as num?)?.toInt() ?? -1,
      oauthProviders: (json['oauth_providers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hasPassword: json['has_password'] as bool? ?? false,
      openidEnabled: json['openid_enabled'] as bool? ?? false,
      openidEmail: json['openid_email'] as String? ?? '',
      updatedAt:
          const DateTimeConverter().fromJson(json['updated_at'] as String),
      createdAt:
          const DateTimeConverter().fromJson(json['created_at'] as String),
      at: const DateTimeConverter().fromJson(json['at'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullname': instance.fullName,
      'image_url': instance.avatarUrl,
      'timezone': instance.timezone,
      'default_workspace_id': instance.defaultWorkspaceId,
      'beginning_of_week': instance.beginningOfWeek,
      'country_id': instance.countryId,
      'oauth_providers': instance.oauthProviders,
      'has_password': instance.hasPassword,
      'openid_enabled': instance.openidEnabled,
      'openid_email': instance.openidEmail,
      'updated_at': const DateTimeConverter().toJson(instance.updatedAt),
      'created_at': const DateTimeConverter().toJson(instance.createdAt),
      'at': const DateTimeConverter().toJson(instance.at),
    };
