import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:provider/provider.dart';

import '../../utils/extensions.dart';
import '../settings_store.dart';
import 'home_store.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  late final store = context.read<HomeStore>();
  late final settingsStore = context.read<SettingsStore>();

  late DateTime _initialTime;
  late DateTime _now;
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      startTicker();
    });
  }

  void onTick(Duration elapsed) {
    final newTime = _initialTime.add(elapsed);
    if (_now.second != newTime.second) {
      onTimerCallback();
      if (_now.minute != newTime.minute) {
        log('Time changed: $_now');
      }
      _now = newTime;
      setState(() {});
    }
  }

  /// Start the timer for auto background refresh.
  void startTicker() {
    _ticker = createTicker(onTick);
    _initialTime = _now = DateTime.now();
    _ticker?.start();
  }

  void onTimerCallback() {
    final lastUpdated = store.lastUpdated;
    if (lastUpdated == null) return;
    // Enable this to see timer logs
    // final Duration nextRefreshTime = lastUpdated
    //     .add(settingsStore.refreshFrequency)
    //     .difference(DateTime.now());
    // log('Next data refresh in ${nextRefreshTime.inMinutes}:${nextRefreshTime.inSeconds % 60}');
    if (lastUpdated
        .add(settingsStore.refreshFrequency)
        .isBefore(DateTime.now())) {
      log('Refreshing data from timer...');
      store.refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.theme.brightness.isDark
            ? context.theme.colorScheme.primary.darken(85)
            : context.theme.colorScheme.primary.shade(1).shade(1),
        border: Border(
          top: BorderSide(
            color: context.theme.colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Observer(builder: (context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (store.isLoading) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(
                      color: context.theme.colorScheme.primary,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Syncing...',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.theme.textColor.withOpacity(0.7),
                    ),
                  ),
                )
              ],
              if (store.lastUpdated != null && !store.isLoadingWithData)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.sync,
                    color: context.theme.textColor.withOpacity(0.7),
                    size: 14,
                  ),
                ),
              if (store.lastUpdated != null && !store.isLoadingWithData)
                Expanded(
                  child: Text(
                    formatLastUpdated(
                        DateTime.now().difference(store.lastUpdated!)),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.theme.textColor.withOpacity(0.7),
                    ),
                  ),
                ),
              Icon(
                Icons.schedule_rounded,
                color: context.theme.textColor.withOpacity(0.7),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Every ${formatFrequency(settingsStore.refreshFrequency)}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.theme.textColor.withOpacity(0.7),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String formatFrequency(Duration item) {
    final minutes = item.inMinutes;
    if (minutes == 1) {
      return '1 minute';
    } else if (minutes < 60) {
      return '$minutes minutes';
    } else {
      final hours = minutes ~/ 60;
      return '$hours hour${hours == 1 ? '' : 's'}';
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  String formatLastUpdated(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 1) {
      if (duration.inSeconds < 10) return 'Just now';
      if (duration.inSeconds < 30) return 'Few seconds ago';
      return 'Less than a minute ago';
    }
    if (minutes < 60) {
      return '$minutes minute${minutes != 1 ? 's' : ''} ago';
    }
    final hours = minutes ~/ 60;
    if (hours < 24) {
      return '$hours hours ago';
    }
    final days = hours ~/ 24;
    return '$days days ago';
  }
}
