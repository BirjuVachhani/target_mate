import 'dart:convert';
import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:toggl_target/model/time_entry.dart';
import 'package:toggl_target/pages/target_store.dart';
import 'package:toggl_target/utils/utils.dart';

import '../resources/keys.dart';

part 'home_store.g.dart';

// ignore: library_private_types_in_public_api
class HomeStore = _HomeStore with _$HomeStore;

abstract class _HomeStore with Store {
  late final TargetStore targetStore = GetIt.instance.get<TargetStore>();

  late final Box secretsBox = getSecretsBox();
  late final Box settingsBox = getAppSettingsBox();

  _HomeStore() {
    init();
  }

  @observable
  DateTime? lastUpdated;

  @observable
  List<TimeEntry>? timeEntries;

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  Duration completed = Duration.zero;

  @computed
  bool get isLoadingWithData => isLoading && (timeEntries?.isNotEmpty == true);

  @computed
  Duration get remaining => (targetStore.requiredTargetDuration) - completed;

  @observable
  Map<DateTime, List<TimeEntry>> groupedEntries = {};

  @computed
  Duration get dailyTargetForRemaining =>
      Duration(seconds: remaining.inSeconds ~/ targetStore.daysRemaining);

  late String apiKey;
  late String fullName;
  late String email;
  late String timezone;
  late String avatarUrl;

  Future<void> init() async {
    apiKey = secretsBox.get(HiveKeys.apiKey);
    fullName = secretsBox.get(HiveKeys.fullName);
    email = secretsBox.get(HiveKeys.email);
    timezone = secretsBox.get(HiveKeys.timezone);
    avatarUrl = secretsBox.get(HiveKeys.avatarUrl) ?? '';
    refreshData();
  }

  Future<List<TimeEntry>?> fetchData() async {
    log('Fetching data...');
    try {
      final DateFormat format = DateFormat('yyyy-MM-dd');
      final String startDate =
          format.format(DateTime(targetStore.year, targetStore.month, 1));
      final String endDate =
          format.format(DateTime(targetStore.year, targetStore.month + 1, 0));
      final uri = Uri.parse(
          'https://api.track.toggl.com/api/v9/me/time_entries?start_date=$startDate&end_date=$endDate');
      log('Fetching data from $startDate to $endDate...');
      log('URL: $uri');
      final apiKey = secretsBox.get(HiveKeys.apiKey);
      final authKey = base64Encode('$apiKey:api_token'.codeUnits);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $authKey',
        },
      );

      if (response.statusCode != 200) {
        log('Error', error: response.body);
        return null;
      }

      final List<JsonMap> data = List<JsonMap>.from(jsonDecode(response.body));

      final List<TimeEntry> timeEntries = data.map(TimeEntry.fromJson).toList();

      return timeEntries;
    } catch (error, stackTrace) {
      log('Error', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  @action
  Future<void> refreshData() async {
    isLoading = true;
    try {
      final List<TimeEntry>? data = await fetchData();
      if (data == null) {
        error = 'Error fetching data';
        isLoading = false;
        return;
      }
      processTimeEntries(data);
      timeEntries = data;
      isLoading = false;
    } catch (error, stackTrace) {
      log('Error', error: error, stackTrace: stackTrace);
      this.error = error.toString();
      isLoading = false;
    }
  }

  void dispose() {}

  void processTimeEntries(List<TimeEntry> entries) {
    log('Processing time entries...');

    final int? projectId = secretsBox.get(HiveKeys.projectId);
    final int? workspaceId = secretsBox.get(HiveKeys.workspaceId);

    List<TimeEntry> filtered = entries.where((item) {
      if (item.projectId == projectId && item.workspaceId == workspaceId) {
        return true;
      }
      if (workspaceId != null && item.workspaceId != workspaceId) {
        log('Skipping entry [${item.id}]: ${item.description} because workspaceId does not match!');
        return false;
      }
      if (projectId != null && item.projectId != projectId) {
        log('Skipping entry [${item.id}]: ${item.description} because projectId does not match!');
        return false;
      }
      return true;
    }).toList();

    // group entries
    groupedEntries = filtered.groupBy((entry) =>
        DateTime(entry.start.year, entry.start.month, entry.start.day));

    final List<Duration> durationPerDay = groupedEntries.entries.map((entry) {
      final List<TimeEntry> entries = entry.value;
      final Duration duration = entries.fold<Duration>(Duration.zero,
          (previousValue, element) => previousValue + element.duration);
      return duration;
    }).toList();

    completed = durationPerDay.fold<Duration>(
        Duration.zero, (previousValue, element) => previousValue + element);

    lastUpdated = DateTime.now();

    log('Total duration: ${completed.inHours}:${completed.inMinutes.remainder(60)}');
    log('Required target: ${targetStore.requiredTargetDuration.inHours}:${targetStore.requiredTargetDuration.inMinutes.remainder(60)}');
    log('remaining: ${remaining.inHours}:${remaining.inMinutes.remainder(60)}');
  }
}
