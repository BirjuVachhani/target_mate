import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:screwdriver/screwdriver.dart';

import '../utils/utils.dart';

part 'time_entry.g.dart';

@JsonSerializable()
class TimeEntry with EquatableMixin {
  final int id;
  @JsonKey(name: 'workspace_id')
  final int workspaceId;
  @JsonKey(name: 'project_id')
  final int? projectId;
  @JsonKey(name: 'task_id')
  final int? taskId;
  final String? description;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime start;
  @JsonKey(fromJson: stopDateTimeFromJson, toJson: dateTimeToJson)
  final DateTime stop;
  @JsonKey(fromJson: durationFromJson, toJson: durationToJson)
  final Duration duration;
  @JsonKey(name: 'user_id')
  final int userId;
  final int uid;
  final int? wid;
  final int? pid;
  final bool billable;
  @JsonKey(name: 'server_deleted_at', fromJson: deletedFromJson)
  final bool isDeleted;
  final bool isRunning;

  TimeEntry({
    required this.id,
    required this.workspaceId,
    required this.projectId,
    required this.taskId,
    required this.description,
    required this.start,
    required this.stop,
    required this.duration,
    required this.userId,
    required this.uid,
    required this.wid,
    required this.pid,
    required this.billable,
    required this.isDeleted,
    this.isRunning = false,
  });

  @visibleForTesting
  TimeEntry.basic({
    required this.start,
    required this.duration,
    this.isDeleted = false,
  })  : id = -1,
        workspaceId = -1,
        projectId = -1,
        taskId = -1,
        description = '',
        stop = start + duration,
        userId = -1,
        uid = -1,
        wid = -1,
        pid = -1,
        billable = false,
        isRunning = false;

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    json['isRunning'] =
        json['stop'] == null || (json['stop'] is int && json['stop'] < 0);
    return _$TimeEntryFromJson(json);
  }

  JsonMap toJson() => _$TimeEntryToJson(this);

  @override
  List<Object?> get props => [
        id,
        workspaceId,
        projectId,
        description,
        start,
        stop,
        duration,
        userId,
        uid,
        wid,
        pid,
        billable,
      ];
}

DateTime stopDateTimeFromJson(String? json) {
  if (json == null) return DateTime.now();
  return DateTime.parse(json);
}

/// For running entries should be -1 * (Unix start time)
Duration durationFromJson(int value) {
  if (value >= 0) return Duration(seconds: value);
  return DateTime.now()
      .difference(DateTime.fromMillisecondsSinceEpoch(value * -1000));
}

int durationToJson(Duration duration) => duration.inSeconds;
