import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:toggl_target/utils/utils.dart';

part 'project.g.dart';

@JsonSerializable()
class Project with EquatableMixin {
  final int id;
  @JsonKey(name: 'workspace_id')
  final int workspaceId;
  final String name;
  @JsonKey(name: 'is_private')
  final bool isPrivate;
  final bool active;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime at;
  @JsonKey(
      name: 'created_at', fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(name: 'server_deleted_at', fromJson: deletedFromJson)
  final bool isDeleted;
  final String? color;
  final bool billable;
  final String? currency;
  final bool recurring;
  final int? wid;

  Project({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.isPrivate,
    required this.active,
    required this.at,
    required this.createdAt,
    required this.isDeleted,
    this.color,
    this.billable = false,
    required this.currency,
    this.recurring = false,
    this.wid,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  @override
  List<Object?> get props => [
        id,
        workspaceId,
        name,
        isPrivate,
        active,
        at,
        createdAt,
        isDeleted,
        color,
        billable,
        currency,
        recurring,
        wid,
      ];
}
