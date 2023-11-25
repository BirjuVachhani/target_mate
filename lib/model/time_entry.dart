import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:screwdriver/screwdriver.dart';

import '../utils/json_converters.dart';
import '../utils/utils.dart';

part 'time_entry.g.dart';

/// The type of time entry. Stored as name in the database.
enum TimeEntryType {
  /// All time entries.
  all,

  /// Only billable time entries.
  billable,

  /// Only non-billable time entries.
  nonBillable;

  bool get isBillable => this == billable;

  bool get isNonBillable => this == nonBillable;

  bool get isAll => this == all;

  factory TimeEntryType.fromBool(bool billable) => switch (billable) {
        true => TimeEntryType.billable,
        false => TimeEntryType.nonBillable,
      };

  String get prettify => switch (this) {
        billable => 'Billable Hours Only',
        nonBillable => 'Non-billable Hours Only',
        all => 'Everything',
      };
}

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
  @DateTimeConverter()
  final DateTime start;
  @NullableDateTimeConverter()
  final DateTime stop;
  @DurationConverter()
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

  TimeEntryType get type => TimeEntryType.fromBool(billable);

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

  /// CopyWith
  TimeEntry copyWith({
    int? id,
    int? workspaceId,
    int? projectId,
    int? taskId,
    String? description,
    DateTime? start,
    DateTime? stop,
    Duration? duration,
    int? userId,
    int? uid,
    int? wid,
    int? pid,
    bool? billable,
    bool? isDeleted,
    bool? isRunning,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      description: description ?? this.description,
      start: start ?? this.start,
      stop: stop ?? this.stop,
      duration: duration ?? this.duration,
      userId: userId ?? this.userId,
      uid: uid ?? this.uid,
      wid: wid ?? this.wid,
      pid: pid ?? this.pid,
      billable: billable ?? this.billable,
      isDeleted: isDeleted ?? this.isDeleted,
      isRunning: isRunning ?? this.isRunning,
    );
  }

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
