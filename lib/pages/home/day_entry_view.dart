import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:intl/intl.dart';
import 'package:screwdriver/screwdriver.dart';

import '../../model/day_entry.dart';
import '../../utils/extensions.dart';
import '../../utils/font_variations.dart';

class PerDayTimeEntryView extends StatelessWidget {
  const PerDayTimeEntryView({
    super.key,
    required this.date,
    required this.entry,
  });

  final DateTime date;
  final DayEntry entry;

  @override
  Widget build(BuildContext context) {
    final totalDuration = entry.duration;
    return Container(
      padding: const EdgeInsets.only(top: 0, bottom: 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: context.theme.colorScheme.primary.withOpacity(0.05),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: context.theme.colorScheme.primary.withOpacity(0.05),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formatDate(date),
                    style: TextStyle(
                      fontSize: 14,
                      fontVariations: FontVariations.w600,
                      color: context.theme.textColor,
                    ),
                  ),
                ),
                Text(
                  formatTotalDuration(totalDuration),
                  style: TextStyle(
                    fontSize: 14,
                    fontVariations: FontVariations.w600,
                    color: entry.isTargetAchieved
                        ? Colors.green
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 14),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: entry.entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = entry.entries[index];
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
                                  fontVariations: FontVariations.w600,
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
                                  fontVariations: FontVariations.w500,
                                  color: item.description == null
                                      ? context.theme.textColor.withOpacity(0.4)
                                      : context.theme.textColor
                                          .withOpacity(0.7),
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
                          fontVariations: FontVariations.w300,
                          color: item.description == null
                              ? context.theme.textColor.withOpacity(0.4)
                              : context.theme.textColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                  const SizedBox(width: 14),
                  Text(
                    formatDuration(item.duration),
                    style: TextStyle(
                      fontSize: 13,
                      fontVariations: FontVariations.w300,
                      letterSpacing: 0.4,
                      color: context.theme.textColor.withOpacity(0.7),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          if (entry.isWorkingDay && (entry.target.inMinutes > 0)) ...[
            const Divider(height: 0.5, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '',
                      children: [
                        const TextSpan(
                          text: 'Goal: ',
                          style: TextStyle(
                            fontVariations: FontVariations.w500,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: formatTotalDuration(entry.target),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      fontVariations: FontVariations.w600,
                      color: context.theme.textColor.withOpacity(0.8),
                      // color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${((entry.duration.inMinutes / entry.target.inMinutes) * 100).clamp(0, 100).floor()}% Achieved',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.theme.textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // hh h mm min
  String formatTotalDuration(Duration duration) {
    if (duration.isNegative) return '';
    if (duration.inMinutes < 1) return '${duration.inSeconds} seconds';
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
