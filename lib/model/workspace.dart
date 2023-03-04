import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workspace.g.dart';

@JsonSerializable()
class Workspace with EquatableMixin {
  final int id;
  @JsonKey(name: 'organization_id')
  final int organizationId;
  final String name;
  @JsonKey(name: 'default_currency')
  final String defaultCurrency;
  @JsonKey(name: 'projects_billable_by_default')
  final bool projectsBillableByDefault;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  Workspace({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.defaultCurrency,
    required this.projectsBillableByDefault,
    this.logoUrl,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceFromJson(json);

  Map<String, dynamic> toJson() => _$WorkspaceToJson(this);

  @override
  List<Object?> get props => [
        id,
        organizationId,
        name,
        defaultCurrency,
        projectsBillableByDefault,
        logoUrl,
      ];
}
