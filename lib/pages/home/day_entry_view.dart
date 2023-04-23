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
      decoration: ShapeDecoration(
        color: context.theme.colorScheme.primary.withOpacity(0.05),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(48),
          // side: BorderSide(
          //   color: context.theme.colorScheme.primary.withOpacity(0.1),
          //   width: 1,
          // ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: context.theme.colorScheme.primary.withOpacity(0.05),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
          Divider(
            height: 1,
            thickness: 1,
            color: context.theme.colorScheme.primary.withOpacity(0.15),
          ),
          const SizedBox(height: 14),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: entry.entries.length,
            // separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = entry.entries[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: item.isRunning ? 0 : 18,
                  right: 16,
                  top: 6,
                  bottom: 6,
                ),
                child: Row(
                  children: [
                    if (item.isRunning) ...[
                      const SizedBox(width: 2),
                      Icon(
                        Icons.play_arrow_rounded,
                        color: context.theme.colorScheme.primary,
                        size: 16,
                      ),
                    ],
                    Expanded(
                      child: Text(
                        item.description?.isNotEmpty == true
                            ? item.description!
                            : 'No Description',
                        style: TextStyle(
                          fontSize: 13,
                          color: item.isRunning
                              ? context.theme.primaryColor
                              : item.description == null
                                  ? context.theme.textColor.withOpacity(0.4)
                                  : context.theme.textColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      formatDuration(item.duration),
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 0.4,
                        color: context.theme.textColor.withOpacity(0.7),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          if (entry.isWorkingDay && (entry.target.inMinutes > 0)) ...[
            Divider(
              height: 0.5,
              thickness: 0.5,
              color: context.theme.colorScheme.primary.withOpacity(0.15),
            ),
            Container(
              color: context.theme.colorScheme.primary.withOpacity(0.02),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                            fontVariations: FontVariations.medium,
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
                      fontVariations: FontVariations.semiBold,
                      color: context.theme.textColor.withOpacity(0.8),
                      // color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${((entry.duration.inMinutes / entry.target.inMinutes) * 100).clamp(0, 100).floor()}% Achieved',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.theme.textColor.withOpacity(0.8),
                      fontVariations: FontVariations.semiBold,
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
