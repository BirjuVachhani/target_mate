import 'package:equatable/equatable.dart';
import 'package:toggl_target/model/time_entry.dart';

class DayEntry with EquatableMixin {
  final DateTime date;
  Duration duration;
  final bool isWorkingDay;
  Duration target;
  List<TimeEntry> entries;

  bool get isTargetAchieved => duration >= target;

  DayEntry({
    required this.date,
    this.duration = Duration.zero,
    required this.isWorkingDay,
    this.target = Duration.zero,
    List<TimeEntry>? entries,
  }) : entries = entries ?? [];

  @override
  List<Object?> get props => [date, duration, isWorkingDay, target, entries];

  void addEntry(TimeEntry entry) {
    entries.add(entry);
    duration += entry.duration;
  }
}
