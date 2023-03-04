import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/utils.dart';

part 'user.g.dart';

@JsonSerializable()
class User with EquatableMixin {
  final int id;
  final String email;
  @JsonKey(name: 'fullname')
  final String fullName;
  @JsonKey(name: 'image_url')
  final String avatarUrl;
  final String timezone;
  @JsonKey(name: 'default_workspace_id')
  final int? defaultWorkspaceId;
  @JsonKey(name: 'beginning_of_week')
  final int beginningOfWeek;
  @JsonKey(name: 'country_id')
  final int countryId;
  @JsonKey(name: 'oauth_providers')
  final List<String> oauthProviders;
  @JsonKey(name: 'has_password')
  final bool hasPassword;
  @JsonKey(name: 'openid_enabled')
  final bool openidEnabled;
  @JsonKey(name: 'openid_email')
  final String openidEmail;
  @JsonKey(
      name: 'updated_at', fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime updatedAt;
  @JsonKey(
      name: 'created_at', fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(name: 'at', fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime at;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    required this.timezone,
    this.defaultWorkspaceId,
    required this.beginningOfWeek,
    required this.countryId,
    this.oauthProviders = const [],
    this.hasPassword = false,
    this.openidEnabled = false,
    this.openidEmail = '',
    required this.updatedAt,
    required this.createdAt,
    required this.at,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatarUrl,
        timezone,
        defaultWorkspaceId,
        beginningOfWeek,
        countryId,
        oauthProviders,
        hasPassword,
        openidEnabled,
        openidEmail,
        updatedAt,
        createdAt,
        at,
      ];
}
