import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/json_converters.dart';

part 'toggl_client.g.dart';

@JsonSerializable()
class TogglClient with EquatableMixin {
  final int id;
  final String name;
  final int wid;
  final bool archived;
  @JsonKey(name: 'at')
  @DateTimeConverter()
  final DateTime createdAt;

  @JsonKey(name: 'creator_id')
  final int creatorId;

  TogglClient({
    required this.id,
    required this.name,
    required this.wid,
    required this.archived,
    required this.createdAt,
    required this.creatorId,
  });

  factory TogglClient.fromJson(Map<String, dynamic> json) {
    return _$TogglClientFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TogglClientToJson(this);

  @override
  List<Object?> get props => [id];
}
