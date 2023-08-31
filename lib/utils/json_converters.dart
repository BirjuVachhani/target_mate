import 'package:json_annotation/json_annotation.dart';

class DurationConverter extends JsonConverter<Duration, int> {
  const DurationConverter();

  @override
  Duration fromJson(int json) {
    if (json >= 0) return Duration(seconds: json);
    return DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(json * -1000));
  }

  @override
  int toJson(Duration object) => object.inSeconds;
}

class DateTimeConverter extends JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json).toLocal();

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

class NullableDateTimeConverter extends JsonConverter<DateTime, String?> {
  const NullableDateTimeConverter();

  @override
  DateTime fromJson(String? json) =>
      json == null ? DateTime.now() : DateTime.parse(json).toLocal();

  @override
  String? toJson(DateTime? object) => object?.toIso8601String();
}
