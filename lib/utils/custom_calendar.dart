import 'package:awesome_calendar/awesome_calendar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class CustomAwesomeCalendar extends StatefulWidget {
  const CustomAwesomeCalendar({
    super.key,
    this.startDate,
    this.endDate,
    this.dayTileBuilder,
    this.selectedSingleDate,
    this.selectedDates,
    this.selectionMode = SelectionMode.single,
    this.onTap,
    this.onPageSelected,
    this.weekdayLabels,
    this.heightDelegate,
    this.usePageView = true,
  });

  /// The height delegate to use for the calendar
  final double Function(int weekNumber)? heightDelegate;

  /// Whether to use a PageView.
  final bool usePageView;

  /// First date of the calendar
  final DateTime? startDate;

  /// Last date of the calendar
  final DateTime? endDate;

  /// The selection mode: [single, multi, range]
  final SelectionMode selectionMode;

  /// The builder to create a day widget
  final DayTileBuilder? dayTileBuilder;

  /// The weekdays widget to show above the calendar
  final Widget? weekdayLabels;

  /// The function when the user clicks on a day
  final void Function(DateTime datetime)? onTap;

  /// Function triggered when the current page of the calendar changes
  final void Function(DateTime pageStartDate, DateTime pageEndDate)?
      onPageSelected;

  /// The selected date in case of single selection mode
  final DateTime? selectedSingleDate;

  /// The list of selected dates in case of multi or range selection mode
  final List<DateTime>? selectedDates;

  /// Function to get the state of awesome_calendar
  static CustomAwesomeCalendarState? of(BuildContext context) =>
      context.findAncestorStateOfType<CustomAwesomeCalendarState>();

  @override
  CustomAwesomeCalendarState createState() => CustomAwesomeCalendarState();
}

class CustomAwesomeCalendarState extends State<CustomAwesomeCalendar> {
  late DateTime? selectedSingleDate = widget.selectedSingleDate;
  late List<DateTime>? selectedDates = widget.selectedDates;
  late DateTime startDate;
  late DateTime endDate;
  late DayTileBuilder dayTileBuilder;
  late Widget weekdayLabels;
  late int pagesCount;
  double dayTileHeight = 40.0;
  double dayLabelHeight = 20.0;
  late double widgetHeight;
  late PageController controller;

  @override
  void initState() {
    super.initState();
    startDate = widget.startDate ?? CalendarHelper.getFirstDayOfCurrentMonth();
    startDate = CalendarHelper.toMidnight(startDate);
    endDate = widget.endDate ?? CalendarHelper.getLastDayOfCurrentMonth();
    endDate = CalendarHelper.toMidnight(endDate);
    if (startDate.isAfter(endDate)) {
      throw ArgumentError(
          'CustomAwesomeCalendar: startDate is after the endDate');
    }
    dayTileBuilder = widget.dayTileBuilder ?? DefaultDayTileBuilder();
    weekdayLabels = widget.weekdayLabels ?? DefaultWeekdayLabels();
    selectedSingleDate = widget.selectedSingleDate ?? startDate;
    selectedDates ??= <DateTime>[];
    pagesCount =
        CalendarHelper.calculateMonthsDifference(startDate, endDate) + 1;
    final int maxWeeksNumber =
        CalendarHelper.calculateMaxWeeksNumberMonthly(startDate, endDate);
    if (widget.heightDelegate != null) {
      widgetHeight = widget.heightDelegate!(maxWeeksNumber);
    } else {
      widgetHeight = dayLabelHeight + maxWeeksNumber * dayTileHeight;
    }
  }

  @override
  void didUpdateWidget(covariant CustomAwesomeCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.heightDelegate != widget.heightDelegate) {
      final int maxWeeksNumber =
          CalendarHelper.calculateMaxWeeksNumberMonthly(startDate, endDate);
      if (widget.heightDelegate != null) {
        widgetHeight = widget.heightDelegate!(maxWeeksNumber);
      } else {
        widgetHeight = dayLabelHeight + maxWeeksNumber * dayTileHeight;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    controller = PageController(
      initialPage:
          selectedSingleDate != null ? _getPageForDate(selectedSingleDate!) : 0,
    );

    if (!widget.usePageView) {
      final DateRange pageDateRange = _calculatePageDateRange(0);

      return AwesomeCalendarPage(
        pageStartDate: pageDateRange.startDate,
        pageEndDate: pageDateRange.endDate,
        weekdayLabels: weekdayLabels,
        dayTileBuilder: dayTileBuilder,
        onTap: widget.onTap,
      );
    }
    return SizedBox(
      height: widgetHeight,
      child: PageView.builder(
        itemBuilder: (BuildContext context, int position) {
          final DateRange pageDateRange = _calculatePageDateRange(position);
          return AwesomeCalendarPage(
            pageStartDate: pageDateRange.startDate,
            pageEndDate: pageDateRange.endDate,
            weekdayLabels: weekdayLabels,
            dayTileBuilder: dayTileBuilder,
            onTap: widget.onTap,
          );
        },
        itemCount: pagesCount,
        controller: controller,
        onPageChanged: (int page) {
          if (widget.onPageSelected != null) {
            final DateRange pageDateRange = _calculatePageDateRange(page);
            widget.onPageSelected!(
              pageDateRange.startDate,
              pageDateRange.endDate,
            );
          }
        },
      ),
    );
  }

  /// Set the selected date of the calendar
  void setSelectedDate(DateTime date) {
    setState(() {
      switch (widget.selectionMode) {
        case SelectionMode.single:
          selectedSingleDate = date;
          break;
        case SelectionMode.multi:
          _setMultiSelectedDate(date);
          break;
        case SelectionMode.range:
          _setRangeSelectedDate(date);
          break;
      }
    });
  }

  /// Set the current date of the calendar: will go to the correct page
  void setCurrentDate(DateTime date) {
    setState(() {
      final int page = _getPageForDate(date);
      controller.jumpToPage(page);
    });
  }

  /// If a given date is selected in the calendar
  bool isDateSelected(DateTime date) {
    if (widget.selectionMode == SelectionMode.single) {
      return CalendarHelper.isSameDay(selectedSingleDate!, date);
    } else {
      final DateTime? matchedSelectedDate = selectedDates!
          .firstWhereOrNull((DateTime d) => CalendarHelper.isSameDay(d, date));
      return matchedSelectedDate != null;
    }
  }

  /// Get the page number in the calendar for a given date
  int _getPageForDate(DateTime date) {
    return (date.year * 12 + date.month) -
        (startDate.year * 12 + startDate.month);
  }

  /// Get the first and last date of a page
  DateRange _calculatePageDateRange(int pagePosition) {
    late DateTime pageStartDate;
    late DateTime pageEndDate;

    if (pagePosition == 0) {
      pageStartDate = startDate;
      if (pagesCount <= 1) {
        pageEndDate = endDate;
      } else {
        final DateTime lastDayOfMonth =
            CalendarHelper.getLastDayOfMonth(startDate);
        pageEndDate = lastDayOfMonth;
      }
    } else if (pagePosition == pagesCount - 1) {
      pageStartDate = CalendarHelper.getFirstDayOfMonth(endDate);
      pageEndDate = endDate;
    } else {
      final DateTime firstDateOfCurrentMonth =
          CalendarHelper.addMonths(startDate, pagePosition)!;
      pageStartDate = firstDateOfCurrentMonth;
      pageEndDate = CalendarHelper.getLastDayOfMonth(firstDateOfCurrentMonth);
    }

    return DateRange(pageStartDate, pageEndDate);
  }

  /// Select the dates for range selection mode
  void _setRangeSelectedDate(DateTime date) {
    switch (selectedDates!.length) {
      case 0:
        selectedDates!.add(date);
        break;
      case 1:
        DateTime firstDate;
        DateTime lastDate;
        selectedDates!.add(date);
        if (selectedDates![0].isBefore(date)) {
          firstDate = selectedDates![0];
          lastDate = date;
        } else {
          firstDate = date;
          lastDate = selectedDates![0];
        }
        for (int i = 1; i < lastDate.difference(firstDate).inDays; i++) {
          selectedDates!.add(firstDate.add(Duration(days: i)));
        }
        break;
      default:
        selectedDates!.clear();
        selectedDates!.add(date);
        break;
    }
  }

  /// Toggle a date in multi selection mode
  void _setMultiSelectedDate(DateTime date) {
    if (selectedDates!.contains(date)) {
      selectedDates!.remove(date);
    } else {
      selectedDates!.add(date);
    }
  }
}

class DateRange {
  DateRange(this.startDate, this.endDate);

  DateTime startDate;
  DateTime endDate;
}
