import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/json_converters.dart';
import '../utils/utils.dart';

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
  @DateTimeConverter()
  final DateTime at;
  @JsonKey(name: 'created_at')
  @DateTimeConverter()
  final DateTime createdAt;
  @JsonKey(name: 'server_deleted_at', fromJson: deletedFromJson)
  final bool isDeleted;
  final String? color;
  final bool billable;
  final String? currency;
  final bool recurring;
  final int? wid;
  @JsonKey(name: 'client_id')
  final int? clientId;
  final int? cid;

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
    this.clientId,
    this.cid,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  @override
  List<Object?> get props => [id];
}
