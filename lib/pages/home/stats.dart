import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';

import '../../resources/resources.dart';
import '../../ui/animated_horizontal_progress_bar.dart';
import '../../utils/extensions.dart';
import '../../utils/font_variations.dart';
import '../../utils/utils.dart';
import '../settings_store.dart';
import '../setup/target_setup_page.dart';
import '../target_store.dart';
import 'home_store.dart';

/// Shows daily average and working days stats.
class MonthlyStats extends StatelessObserverWidget {
  const MonthlyStats({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeStore store = context.read<HomeStore>();
    final SettingsStore settingsStore = context.read<SettingsStore>();
    final TargetStore targetStore = context.read<TargetStore>();

    final bool showOvertime = settingsStore.showRemaining &&
        store.remaining <= Duration.zero &&
        !store.overtime.isNegative;

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()).toUpperCase(),
                style: TextStyle(
                    fontSize: 13,
                    fontVariations: FontVariations.w600,
                    color: context.theme.textColor.withOpacity(0.6)),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    if (store.isLoading)
                      WidgetSpan(
                        child: SizedBox(
                          width: 48,
                          height: 24,
                          child: Center(
                            child: SpinKitThreeBounce(
                              size: 16,
                              color: context.theme.textColor,
                            ),
                          ),
                        ),
                      )
                    else
                      TextSpan(
                        text: settingsStore.showRemaining
                            ? showOvertime
                                ? formatOvertimeDuration(store, targetStore)
                                : formatRemainingDuration(store, targetStore)
                            : formatCompletedDuration(store, targetStore),
                      ),
                    if (!showOvertime)
                      TextSpan(
                        text: formatTotalDuration(store, targetStore),
                      ),
                    if (!showOvertime)
                      TextSpan(
                        text: ' hours',
                        style: TextStyle(
                          color: context.theme.textColor.withOpacity(0.6),
                          fontSize: 16,
                          fontVariations: FontVariations.w600,
                        ),
                      ),
                    if (settingsStore.showRemaining)
                      TextSpan(
                        text: showOvertime ? ' overtime' : ' left',
                        style: TextStyle(
                          color: context.theme.textColor.withOpacity(0.6),
                          fontSize: 16,
                          fontVariations: FontVariations.w600,
                        ),
                      ),
                  ],
                  style: TextStyle(
                    fontSize: 20,
                    fontVariations: FontVariations.bold,
                    color: context.theme.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () => onEdit(context),
          style: TextButton.styleFrom(
            foregroundColor: context.theme.textColor,
            backgroundColor: context.theme.textColor.withOpacity(0.1),
            textStyle: const TextStyle(
              fontSize: 13,
              fontVariations: FontVariations.w600,
            ),
          ),
          icon: const Icon(
            Icons.edit_rounded,
            size: 16,
          ),
          label: const Text('Edit'),
        ),
      ],
    );
  }

  Future<void> onEdit(BuildContext context) async {
    final HomeStore store = context.read<HomeStore>();
    final TargetStore targetStore = context.read<TargetStore>();

    final bool? modified = await Navigator.of(context).push<bool?>(
      CupertinoPageRoute(
        builder: (context) => Provider.value(
          value: targetStore,
          child: const TargetSetupPage(),
        ),
      ),
    );
    if (modified == true) {
      targetStore.refresh();
      store.refreshData();
    }
  }

  String formatCompletedDuration(HomeStore store, TargetStore targetStore) {
    return '${store.completed.inHours > 0 ? '${store.completed.inHours}h ' : ''}${store.completed.inMinutes.remainder(60)}m ';
  }

  String formatRemainingDuration(HomeStore store, TargetStore targetStore) {
    return '${store.remaining.inHours > 0 ? '${store.remaining.inHours}h ' : ''}${store.remaining.inMinutes.remainder(60)}m ';
  }

  String formatOvertimeDuration(HomeStore store, TargetStore targetStore) {
    return '${store.overtime.inHours > 0 ? '${store.overtime.inHours}h ' : ''}${store.overtime.inMinutes.remainder(60)}m ';
  }

  String formatTotalDuration(HomeStore store, TargetStore targetStore) {
    final double total = targetStore.requiredTargetDuration.inSeconds / 3600;
    String totalString =
        total.isWhole ? total.toStringAsFixed(0) : total.toStringAsFixed(2);

    return '/ $totalString';
  }
}

/// Shows daily average and working days stats.
class DailyStats extends StatelessObserverWidget {
  const DailyStats({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeStore store = context.read<HomeStore>();
    final SettingsStore settingsStore = context.read<SettingsStore>();
    final TargetStore targetStore = context.read<TargetStore>();

    final days = settingsStore.showRemaining
        ? targetStore.daysRemainingAfterToday
        : targetStore.currentDay;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (store.isMonthlyTargetAchieved)
          Expanded(
            child: SizedBox(
              height: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Goal achieved! ✌🏻🎉',
                  style: TextStyle(
                    fontSize: 20,
                    fontVariations: FontVariations.w600,
                    color: context.theme.textColor,
                  ),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Average to maintain',
                  style: TextStyle(
                    fontSize: 14,
                    fontVariations: FontVariations.w600,
                    color: context.theme.textColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      if (store.isLoading)
                        WidgetSpan(
                          child: SizedBox(
                            width: 48,
                            height: 24,
                            child: Center(
                              child: SpinKitThreeBounce(
                                size: 16,
                                color: context.theme.textColor,
                              ),
                            ),
                          ),
                        )
                      else
                        TextSpan(
                          text: formatDailyTargetDuration(
                              store.effectiveAverageTarget),
                        ),
                      TextSpan(
                        text: ' / day',
                        style: TextStyle(
                          color: context.theme.textColor.withOpacity(0.6),
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: ' ',
                        style: TextStyle(
                          color: context.theme.textColor.withOpacity(0.6),
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontVariations: FontVariations.bold,
                  ),
                ),
              ],
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Working days',
              style: TextStyle(
                fontSize: 14,
                fontVariations: FontVariations.w600,
                color: context.theme.textColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                text: '$days/${targetStore.effectiveDays.length}',
                children: [
                  TextSpan(
                    text: ' days${settingsStore.showRemaining ? ' left' : ''}',
                    style: TextStyle(
                      color: context.theme.textColor.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
                style: const TextStyle(
                  fontSize: 24,
                  fontVariations: FontVariations.bold,
                ),
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ],
    );
  }
}

class TodayProgressIndicator extends StatelessObserverWidget {
  const TodayProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeStore store = context.read<HomeStore>();

    if (store.isMonthlyTargetAchieved) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Today's Progress",
                style: TextStyle(
                  fontSize: 14,
                  fontVariations: FontVariations.w600,
                  color: context.theme.textColor.withOpacity(0.6),
                ),
              ),
            ),
            if (!store.isLoading || store.isLoadingWithData)
              Text(
                formatTodayProgressPercentage(store),
                style: TextStyle(
                  fontSize: 16,
                  fontVariations: FontVariations.w600,
                  color: context.theme.textColor,
                ),
              ),
            const SizedBox(width: 2),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 32,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )
                  ),
                  child: AnimatedHorizontalProgressBar(
                    value: store.todayPercentage,
                    backgroundColor: context.theme.textColor.withOpacity(0.15),
                    duration: 1.seconds,
                    curve: Curves.fastOutSlowIn,
                    valueColor: AlwaysStoppedAnimation(
                      ColorTween(
                        begin: Colors.redAccent,
                        end: Colors.green.shade700,
                      ).transform(
                        store.todayPercentage.clamp(0, 1),
                      ),
                    ),
                  ),
                ),
              ),
              if (!store.isLoading || store.isLoadingWithData)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 12,
                  child: Builder(
                    builder: (context) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (store.isTodayTargetAchieved)
                            ImageIcon(
                              const AssetImage(SystemTrayIcons.iconDone),
                              color: context.theme.textColor,
                              size: 18,
                            ),
                          const SizedBox(width: 2),
                          Text(
                            store.todayPercentage >= 1
                                ? 'Completed'
                                : 'Remaining: ${formatDailyTargetDuration(store.remainingForToday)}',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1,
                              color: context.theme.textColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
            ],
          ),
        ),
        Observer(
          builder: (context) {
            if (!store.isWorkingExtra) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Text(
                    formatDailyOvertimeDuration(store),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.theme.textColor.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: 'Today is not your working day!',
                    waitDuration: const Duration(milliseconds: 500),
                    textAlign: TextAlign.end,
                    preferBelow: true,
                    verticalOffset: 14,
                    triggerMode: defaultTargetPlatform.isMobile
                        ? TooltipTriggerMode.tap
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Working extra!',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.theme.textColor.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.error_outline_rounded,
                          size: 16,
                          color: context.theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String formatDailyOvertimeDuration(HomeStore store) {
    final Duration duration =
        store.todayDuration - store.dailyAverageTargetTillToday;
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    String time = '';
    if (hours > 0) {
      time = '$hours h${minutes > 0 ? ' $minutes m' : ''}';
    } else if (minutes > 0) {
      time = '$minutes m';
    }

    if (time.isNotEmpty) {
      final percentage =
          (duration.inMinutes / store.dailyAverageTargetTillToday.inMinutes) *
              100;
      return 'Overtime: $time ${percentage.toInt() > 0 ? '(${percentage.toFormattedStringAsFixed(0)}%)' : ''}';
    }

    return '';
  }

  String formatTodayProgressPercentage(HomeStore store) {
    final double percentage = (store.todayPercentage * 100).clamp(0, 100);
    return '${percentage.toFormattedStringAsFixed(2)}%';
  }
}
