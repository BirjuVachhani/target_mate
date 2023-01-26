import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:toggl_target/pages/settings.dart';
import 'package:toggl_target/pages/setup/target_setup_page.dart';
import 'package:toggl_target/pages/target_store.dart';
import 'package:toggl_target/utils/extensions.dart';

import '../model/time_entry.dart';
import '../resources/colors.dart';
import '../ui/custom_safe_area.dart';
import '../ui/gradient_background.dart';
import 'home_store.dart';

class HomePageWrapper extends StatelessWidget {
  const HomePageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => SettingsStore(),
          dispose: (_, SettingsStore store) => store.dispose(),
        ),
        Provider(
          create: (_) => HomeStore(),
          dispose: (_, HomeStore store) => store.dispose(),
        ),
      ],
      child: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeStore store = context.read<HomeStore>();
  late final TargetStore targetStore = GetIt.instance.get<TargetStore>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HomeHeader(onEdit: onEdit),
              Expanded(
                child: Observer(builder: (context) {
                  if (store.isLoading && !store.isLoadingWithData) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SpinKitPouringHourGlassRefined(
                            size: 64,
                            color: context.theme.colorScheme.primary
                                .withOpacity(0.25),
                            duration: const Duration(milliseconds: 2000),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Hold on, loading your entries...',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (store.timeEntries == null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: context.theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          FractionallySizedBox(
                            widthFactor: 0.8,
                            child: Text(
                              store.error ??
                                  'Unable to load entries.\nPlease check your internet connection!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.theme.colorScheme.error,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: store.refreshData,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (store.timeEntries!.isEmpty) {
                    return const Center(
                      child: Text('No entries found'),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ListView.separated(
                      itemCount: store.groupedEntries.length,
                      primary: false,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return PerDayTimeEntryView(
                          date: store.groupedEntries.keys.elementAt(index),
                          entries: store.groupedEntries.values.elementAt(index),
                          dailyTarget: Duration(
                              seconds: (store.targetStore.workingHours! * 3600)
                                  .round()),
                        );
                      },
                    ),
                  );
                }),
              ),
              const BottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onEdit() async {
    final bool? modified = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(
        builder: (context) => const TargetSetupPage(),
      ),
    );
    if (modified == true) {
      store.refreshData();
    }
  }
}

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
    final store = context.read<HomeStore>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primary.darken(85),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
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
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                )
              ],
              if (store.lastUpdated != null && !store.isLoadingWithData)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.sync,
                    color: Colors.white.withOpacity(0.7),
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
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              Icon(
                Icons.schedule_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Every ${formatFrequency(settingsStore.refreshFrequency)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withOpacity(0.7),
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

class PerDayTimeEntryView extends StatelessWidget {
  const PerDayTimeEntryView({
    super.key,
    required this.date,
    required this.entries,
    required this.dailyTarget,
  });

  final DateTime date;
  final List<TimeEntry> entries;
  final Duration dailyTarget;

  @override
  Widget build(BuildContext context) {
    final totalDuration = entries.total;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: context.theme.colorScheme.primary.withOpacity(0.05),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDate(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatTotalDuration(totalDuration),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: totalDuration >= dailyTarget
                        ? Colors.greenAccent.shade700
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 14),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = entries[index];
              return Row(
                children: [
                  if (item.isRunning)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: context.theme.colorScheme.primary
                                .withOpacity(0.2),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Running'.toUpperCase(),
                                style: TextStyle(
                                  color: context.theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description?.isNotEmpty == true
                                    ? item.description!
                                    : 'No Description',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: entries[index].description == null
                                      ? Colors.white.withOpacity(0.4)
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (!item.isRunning)
                    Expanded(
                      child: Text(
                        item.description?.isNotEmpty == true
                            ? item.description!
                            : 'No Description',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: entries[index].description == null
                              ? Colors.white.withOpacity(0.4)
                              : Colors.white70,
                        ),
                      ),
                    ),
                  const SizedBox(width: 14),
                  Text(
                    formatDuration(item.duration),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.4,
                      color: Colors.white70,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // hh h mm min
  String formatTotalDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '$hours h ${minutes.toString().padLeft(2, '0')} min';
  }

  // hh:mm:ss
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime date) {
    if (date.isToday) return 'Today';
    if (date.isYesterday) return 'Yesterday';
    return DateFormat('EEE, dd MMM').format(date);
  }
}

class HomeHeader extends StatelessWidget {
  final VoidCallback onEdit;

  const HomeHeader({super.key, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final HomeStore store = context.read<HomeStore>();
    final TargetStore targetStore = GetIt.instance.get<TargetStore>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (context.theme.platform.isDesktop)
            SizedBox(
              height: kMacOSTopPadding,
              child: Center(
                child: Image.asset(
                  'assets/logo_trimmed.png',
                  fit: BoxFit.fitHeight,
                  height: 16,
                  color: context.theme.colorScheme.background,
                ),
              ),
            ),
          // SizedBox(
          //     height: kMacOSTopPadding,
          //     child: Center(
          //       child: Text(
          //         'Toggl Target',
          //         style: TextStyle(
          //           fontSize: 13,
          //           fontWeight: FontWeight.w500,
          //           color: context.theme.colorScheme.onPrimary.withOpacity(0.8),
          //         ),
          //       ),
          //     ),
          //   ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.backgroundColorDarker,
                    radius: 18,
                    backgroundImage: NetworkImage(store.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Builder(builder: (context) {
                      if (constraints.maxWidth <= 305) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            store.fullName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Text(
                          //   DateFormat('EEEE, dd').format(DateTime.now()),
                          //   style: TextStyle(
                          //     fontSize: 13,
                          //     color: Colors.white.withOpacity(0.5),
                          //   ),
                          // ),
                          // Text(
                          //   store.email,
                          //   style: TextStyle(
                          //     fontSize: 13,
                          //     color: Colors.white.withOpacity(0.5),
                          //   ),
                          // ),
                        ],
                      );
                    }),
                  ),
                  if (constraints.maxWidth <= 190)
                    SizedBox(
                      width: 38,
                      child: Observer(
                        builder: (context) {
                          return TextButton(
                            onPressed:
                                store.isLoading ? null : store.refreshData,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withOpacity(0.1),
                            ),
                            child: store.isLoading
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: Center(
                                      child: SizedBox.square(
                                        dimension: 14,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 20),
                          );
                        },
                      ),
                    )
                  else
                    Observer(
                      builder: (context) {
                        return TextButton.icon(
                          onPressed: store.isLoading ? null : store.refreshData,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                          icon: store.isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: Center(
                                    child: SizedBox.square(
                                      dimension: 14,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text('Refresh'),
                        );
                      },
                    ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 38,
                    child: Tooltip(
                      message: 'Settings',
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                        onPressed: () {
                          openSettings(context);
                        },
                        child: const Icon(Icons.settings, size: 20),
                        // label: const Text('Logout'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Observer(
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy')
                              .format(DateTime.now())
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              if (store.isLoading)
                                const WidgetSpan(
                                  child: SizedBox(
                                    width: 48,
                                    height: 24,
                                    child: Center(
                                      child: SpinKitThreeBounce(
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                TextSpan(
                                  text: formatCompletedDuration(
                                      store, targetStore),
                                ),
                              TextSpan(
                                text: formatTotalDuration(store, targetStore),
                              ),
                              const TextSpan(
                                text: ' hours',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                ),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Observer(
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Daily average to achieve goal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              if (store.isLoading)
                                const WidgetSpan(
                                  child: SizedBox(
                                    width: 48,
                                    height: 24,
                                    child: Center(
                                      child: SpinKitThreeBounce(
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                TextSpan(
                                  text: formatDailyTargetDuration(
                                      store.effectiveAverageTarget),
                                ),
                              const TextSpan(
                                text: ' / day',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 20,
                                ),
                              ),
                              const TextSpan(
                                text: ' ',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Observer(
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Working days',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          text:
                              '${targetStore.currentDay}/${targetStore.effectiveDays.length}',
                          children: const [
                            TextSpan(
                              text: ' days',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Observer(
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Today's Progress",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                            if (!store.isLoading || store.isLoadingWithData)
                              Text(
                                formatTodayProgressPercentage(store),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            const SizedBox(width: 2),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Observer(
                          builder: (context) {
                            return SizedBox(
                              height: 24,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: store.todayPercentage,
                                        minHeight: 24,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.15),
                                        valueColor: AlwaysStoppedAnimation(
                                          ColorTween(
                                            begin: Colors.red,
                                            end: Colors.green,
                                          ).transform(store.todayPercentage),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!store.isLoading ||
                                      store.isLoadingWithData)
                                    Positioned(
                                      top: 4,
                                      bottom: 0,
                                      right: 8,
                                      child: Builder(builder: (context) {
                                        return Text(
                                          store.todayPercentage >= 1
                                              ? 'Completed'
                                              : 'Remaining: ${formatDailyTargetDuration(store.remainingForToday)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            letterSpacing: 0.2,
                                          ),
                                        );
                                      }),
                                    )
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String formatCompletedDuration(HomeStore store, TargetStore targetStore) {
    // final double completed = store.completed.inSeconds / 3600;
    // String completedString = completed.isWhole
    //     ? completed.toStringAsFixed(0)
    //     : completed.toStringAsFixed(2);

    return '${store.completed.inHours > 0 ? '${store.completed.inHours}h ' : ''}${store.completed.inMinutes.remainder(60)}m ';
  }

  String formatTotalDuration(HomeStore store, TargetStore targetStore) {
    final double total = targetStore.requiredTargetDuration.inSeconds / 3600;
    String totalString =
        total.isWhole ? total.toStringAsFixed(0) : total.toStringAsFixed(2);

    return '/ $totalString';
  }

  String formatDailyTargetDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;

    return '${hours > 0 ? '$hours h ' : ''}${minutes > 0 ? minutes.toString().padLeft(hours > 0 ? 2 : 1, '0') : '1'} min';
  }

  void openSettings(BuildContext context) {
    final settingsStore = context.read<SettingsStore>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Provider.value(
          value: settingsStore,
          child: const SettingsPage(),
        ),
      ),
    );
  }

  String formatTodayProgressPercentage(HomeStore store) {
    final double percentage = (store.todayPercentage * 100).clamp(0, 100);
    return '${percentage.toFormattedStringAsFixed(2)}%';
  }
}
