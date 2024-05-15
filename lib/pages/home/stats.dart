import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:screwdriver/screwdriver.dart';
import 'package:shimmer/shimmer.dart';

import '../../resources/resources.dart';
import '../../utils/extensions.dart';
import '../../utils/font_variations.dart';
import '../../utils/rect_clipper.dart';
import '../../utils/utils.dart';
import '../settings/settings_store.dart';
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

class TodayProgressStats extends StatelessObserverWidget {
  const TodayProgressStats({super.key});

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
        CustomProgressIndicator(value: store.todayPercentage),
        const SizedBox(height: 8),
        Row(
          children: [
            if (store.isWorkingExtra && store.didOvertimeToday)
              Text.rich(
                TextSpan(
                  text: 'Overtime: ',
                  children: [
                    TextSpan(
                      text: formatDailyOvertimeDuration(store),
                      style: TextStyle(
                        color: context.theme.textColor,
                        fontVariations: FontVariations.w600,
                      ),
                    )
                  ],
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: context.theme.textColor.withOpacity(0.6),
                ),
              )
            else
              const TimeToCompleteStat(),
            const Spacer(),
            if (store.isWorkingExtra && store.isTimerRunning)
              const WorkingExtraBadge(),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String formatDailyOvertimeDuration(HomeStore store) {
    final Duration duration = store.overtimeToday;
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
      return '$time ${percentage.toInt() > 0 ? '(${percentage.toFormattedStringAsFixed(0)}%)' : ''}';
    }

    return '';
  }

  String formatTodayProgressPercentage(HomeStore store) {
    final double percentage = (store.todayPercentage * 100).clamp(0, 100);
    return '${percentage.toFormattedStringAsFixed(2)}%';
  }
}

class CustomProgressIndicator extends StatefulWidget {
  final double value;

  const CustomProgressIndicator({super.key, required this.value});

  @override
  State<CustomProgressIndicator> createState() =>
      _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator> {
  late double initial = widget.value;

  @override
  Widget build(BuildContext context) {
    final store = context.read<HomeStore>();

    return ClipPath(
      clipBehavior: Clip.antiAlias,
      clipper: ShapeBorderClipper(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: SizedBox(
        height: 32,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: context.theme.textColor.withOpacity(0.15),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 12),
              child: !store.isLoading || store.isLoadingWithData
                  ? getText(context, context.theme.textColor, store)
                  : const SizedBox.shrink(),
            ),
            TweenAnimationBuilder<double>(
              duration: 1.seconds,
              curve: Curves.fastOutSlowIn,
              tween: Tween<double>(begin: initial, end: widget.value),
              builder: (context, value, child) {
                final color = ColorTween(
                  begin: Colors.redAccent,
                  end: Colors.green.shade700,
                ).transform(value.clamp(0, 1));
                return ClipRect(
                  clipper: RectClipper(start: 0, end: value),
                  child: Container(
                    color: color,
                    padding: const EdgeInsets.only(right: 12),
                    alignment: Alignment.centerRight,
                    child: child,
                  ),
                );
              },
              child: getText(context, Colors.white, store),
            ),
            if (store.isLoading && !store.isLoadingWithData)
              Shimmer.fromColors(
                baseColor: context.theme.textColor.withOpacity(0.4),
                highlightColor: context.theme.textColor.withOpacity(0.8),
                child: Container(
                  color: context.theme.textColor.withOpacity(0.3),
                  padding: const EdgeInsets.only(right: 12),
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.access_time, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Doing math!',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.theme.textColor.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget getText(BuildContext context, Color color, HomeStore store) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (store.isTodayTargetAchieved)
          SvgPicture.asset(
            Vectors.done,
            colorFilter: ColorFilter.mode(
              color,
              BlendMode.srcIn,
            ),
            width: 16,
          ),
        const SizedBox(width: 4),
        Text(
          store.todayPercentage >= 1
              ? 'Completed'
              : 'Remaining: ${formatDailyTargetDuration(store.remainingForToday)}',
          style: TextStyle(
            fontSize: 13,
            height: 1,
            color: color,
          ),
        ),
      ],
    );
  }
}

class TimeToCompleteStat extends StatelessObserverWidget {
  const TimeToCompleteStat({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<HomeStore>();

    if (store.isLoading && !store.isLoadingWithData) {
      return const SizedBox.shrink();
    }

    if (!store.isTimerRunning) {
      // show estimated time to complete.
      return Row(
        children: [
          Icon(
            Icons.access_time,
            size: 14,
            color: context.theme.textColor.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          TickingWidget(
            mode: TickingMode.minute,
            builder: (context, current, child) => Text.rich(
              TextSpan(
                text: 'Finishing Time: ',
                children: [
                  TextSpan(
                    text:
                        formatTime(DateTime.now().add(store.remainingForToday)),
                    style: TextStyle(
                      color: context.theme.textColor,
                      fontVariations: FontVariations.w600,
                    ),
                  ),
                ],
              ),
              style: TextStyle(
                fontSize: 12,
                color: context.theme.textColor.withOpacity(0.6),
              ),
            ),
          ),
        ],
      );
    }

    if (store.remainingForToday.isNegative ||
        store.remainingForToday == Duration.zero) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: context.theme.textColor.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text.rich(
          TextSpan(
            text: 'Finishing Time: ',
            children: [
              TextSpan(
                text: formatTime(DateTime.now().add(store.remainingForToday)),
                style: TextStyle(
                  color: context.theme.textColor,
                  fontVariations: FontVariations.w600,
                ),
              ),
            ],
          ),
          style: TextStyle(
            fontSize: 12,
            color: context.theme.textColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  String formatTime(DateTime dateTime) =>
      DateFormat('hh:mm a').format(dateTime);
}

class WorkingExtraBadge extends StatelessObserverWidget {
  const WorkingExtraBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<TargetStore>();
    return Tooltip(
      message: store.isTodayWorkingDay
          ? 'You finished your goal for today!'
          : 'Today is not your working day!',
      waitDuration: const Duration(milliseconds: 500),
      textAlign: TextAlign.end,
      preferBelow: true,
      verticalOffset: 14,
      triggerMode:
          defaultTargetPlatform.isMobile ? TooltipTriggerMode.tap : null,
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
    );
  }
}
