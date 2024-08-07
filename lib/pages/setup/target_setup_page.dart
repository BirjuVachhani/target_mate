import 'dart:developer';

import 'package:awesome_calendar/awesome_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screwdriver/flutter_screwdriver.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'package:paged_vertical_calendar/utils/date_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../resources/keys.dart';
import '../../ui/back_button.dart';
import '../../ui/custom_calendar.dart';
import '../../ui/custom_safe_area.dart';
import '../../ui/custom_scaffold.dart';
import '../../ui/custom_switch.dart';
import '../../ui/gesture_detector_with_cursor.dart';
import '../../ui/widgets.dart';
import '../../utils/extensions.dart';
import '../../utils/font_variations.dart';
import '../../utils/utils.dart';
import '../home/home.dart';
import '../target_store.dart';

class TargetSetupPageWrapper extends StatelessWidget {
  const TargetSetupPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => TargetStore(),
      child: const TargetSetupPage(),
    );
  }
}

class TargetSetupPage extends StatefulWidget {
  const TargetSetupPage({super.key});

  @override
  State<TargetSetupPage> createState() => _TargetSetupPageState();
}

class _TargetSetupPageState extends State<TargetSetupPage> {
  late final TargetStore store = context.read<TargetStore>();

  late final TapGestureRecognizer recognizer = TapGestureRecognizer()
    ..onTap = () => launchUrlString('https://track.toggl.com/profile');

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      onPopInvokedWithResult: (didPop, result) {
        if (store.secretsBox.containsKey(HiveKeys.onboarded)) return;

        if (!store.secretsBox.containsKey(HiveKeys.onboarded)) {
          // user has not been onboarded yet. Allow returning without discarding.
          return;
        }
        log('Discarding changes');
        store.init();
      },
      body: CustomSafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: kSidePadding),
            child: Center(
              child: SizedBox(
                width: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomBackButton(
                      usePrimaryColor: false,
                    ),
                    const SizedBox(height: 16),
                    const SetupTitle('Select your working days'),
                    Text(
                      'This will be used to automatically select your working days for a month.',
                      style: TextStyle(
                        color: context.theme.textColor.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Observer(
                      builder: (context) {
                        return WeekDaysSelection(
                          selectedDays: store.selectedWeekDays,
                          onChanged: (days) =>
                              store.selectedWeekDays = [...days],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Observer(
                      builder: (context) {
                        return CustomSwitch(
                          label: 'Select custom days',
                          value: store.hasCustomDaysSelection,
                          onChanged: (value) => store.onShowCalendar(value),
                        );
                      },
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Observer(
                        builder: (context) {
                          if (store.hasCustomDaysSelection) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 8),
                                CalenderSelection(
                                  month: DateTime(
                                      DateTime.now().year, store.month),
                                  selectedDays: store.selectedDays,
                                  onChanged: (days) {
                                    store.selectedDays = [...days];
                                  },
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: FieldLabel('Working hours'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text.rich(
                              TextSpan(
                                text: 'Max hours ',
                                children: [
                                  TextSpan(
                                    text: '(Optional)',
                                    style: TextStyle(
                                      color: context.theme.textColor
                                          .withOpacity(0.25),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                color: context.theme.textColor.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: store.workingHoursController,
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                            maxLength: 5,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              store.workingHours = double.tryParse(value);
                            },
                            onFieldSubmitted: (value) {
                              store.workingHours = double.tryParse(value);
                            },
                            inputFormatters: [
                              // only allows mqx 2 digits before decimal
                              // and 2 after decimal.
                              // e.g. 13, 12.34, 1.45, 2.3
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{1,2}(\.(\d{1,2})?)?'),
                              ),
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: 'e.g. 8',
                              suffixIcon: Align(
                                alignment: Alignment.center,
                                widthFactor: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Text(
                                    'per day',
                                    style: context
                                        .theme.inputDecorationTheme.hintStyle!
                                        .copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: store.maxMonthlyWorkingHoursController,
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                            maxLength: 6,
                            onChanged: (value) {
                              store.maxMonthlyWorkingHours =
                                  double.tryParse(value);
                            },
                            onFieldSubmitted: (value) {
                              store.maxMonthlyWorkingHours =
                                  double.tryParse(value);
                            },
                            inputFormatters: [
                              // A month can have max 31 * 24 = 744 hours.
                              // only allows mqx 3 digits before decimal
                              // and 2 after decimal.
                              // e.g. 123, 12.34, 123.45, 1.23, 12.3
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{1,3}(\.(\d{1,2})?)?'),
                              ),
                            ],
                            decoration: InputDecoration(
                              hintText: 'e.g. 160',
                              counterText: '',
                              suffixIcon: Align(
                                alignment: Alignment.center,
                                widthFactor: 1,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    'hrs/month',
                                    style: context
                                        .theme.inputDecorationTheme.hintStyle!
                                        .copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Observer(
                      builder: (context) => FilledButton(
                        onPressed: !store.hasAllData ? null : onSave,
                        child: Text(
                          store.secretsBox.containsKey(HiveKeys.onboarded)
                              ? 'Save'
                              : 'Next',
                        ),
                      ),
                    ),
                    Observer(
                      builder: (context) {
                        if (store.error == null) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Error: ${store.error}',
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSave() async {
    final result = await store.save();
    if (result) onSuccess();
  }

  void onSuccess() async {
    final navigator = Navigator.of(context);
    if (getSecretsBox().containsKey(HiveKeys.onboarded)) {
      navigator.pop(true);
    } else {
      await getSecretsBox().put(HiveKeys.onboarded, true);
      navigator.pushAndRemoveUntil(
        CupertinoPageRoute(
          builder: (_) => const HomePageWrapper(),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    recognizer.dispose();
    super.dispose();
  }
}

const Map<int, String> weekdays = {
  DateTime.monday: 'Monday',
  DateTime.tuesday: 'Tuesday',
  DateTime.wednesday: 'Wednesday',
  DateTime.thursday: 'Thursday',
  DateTime.friday: 'Friday',
  DateTime.saturday: 'Saturday',
  DateTime.sunday: 'Sunday',
};

class WeekDaysSelection extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<List<int>> onChanged;

  const WeekDaysSelection({
    super.key,
    this.selectedDays = const [],
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final day in weekdays.entries)
            Builder(builder: (context) {
              final isSelected = selectedDays.contains(day.key);
              return Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: day.key != DateTime.sunday ? 12 : 0,
                  ),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      if (isSelected) {
                        onChanged([...selectedDays]..remove(day.key));
                      } else {
                        onChanged([...selectedDays, day.key]..sort());
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.theme.colorScheme.primary
                            : context.theme.textColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          day.value[0].toUpperCase(),
                          style: TextStyle(
                            color: isSelected
                                ? context.theme.colorScheme.onPrimary
                                : context.theme.textColor,
                            fontSize: 16,
                            fontVariations: FontVariations.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class CalenderSelection2 extends StatelessWidget {
  final DateTime month;
  final List<int> selectedDays;
  final ValueChanged<List<int>> onChanged;

  const CalenderSelection2({
    super.key,
    required this.selectedDays,
    required this.onChanged,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.textColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: PagedVerticalCalendar(
          minDate: DateTime(month.year, month.month, 1),
          maxDate: DateTime(month.year, month.month + 1, 0),
          invisibleMonthsThreshold: 0,
          startWeekWithSunday: false,
          physics: const NeverScrollableScrollPhysics(),
          dayBuilder: (context, date) {
            return Center(
              child: Text(
                date.day.toString(),
              ),
            );
          },
          monthBuilder: (context, month, year) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                DateFormat('MMMM yyyy').format(DateTime(year, month)),
                style: TextStyle(
                  color: context.theme.textColor,
                  fontVariations: FontVariations.w600,
                ),
              ),
            );
          },
          onMonthLoaded: (year, month) {
            // on month widget load
          },
          onDayPressed: (date) {
            if (selectedDays.contains(date.day)) {
              onChanged([...selectedDays]..remove(date.day));
            } else {
              onChanged([...selectedDays, date.day]..sort());
            }
            // on day widget pressed
          },
          onPaginationCompleted: (direction) {
            // on pagination completion
          },
        ),
      ),
    );
  }
}

class CalenderSelection extends StatelessWidget {
  final DateTime month;
  final List<int> selectedDays;
  final ValueChanged<List<int>> onChanged;

  const CalenderSelection({
    super.key,
    required this.selectedDays,
    required this.onChanged,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
          decoration: BoxDecoration(
            color: context.theme.textColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(month).toUpperCase(),
                style: TextStyle(
                  color: context.theme.textColor,
                  letterSpacing: 1.2,
                  fontVariations: FontVariations.w500,
                ),
              ),
              const SizedBox(height: 16),
              CustomAwesomeCalendar(
                key: ValueKey('$month, $selectedDays'),
                selectionMode: SelectionMode.multi,
                usePageView: false,
                startDate: DateTime(month.year, month.month, 1),
                endDate: DateTime(month.year, month.month + 1, 0),
                dayTileBuilder: CustomDayTileBuilder(),
                weekdayLabels: CustomWeekdayLabels(),
                selectedDates: [
                  for (final day in selectedDays)
                    DateTime(month.year, month.month, day),
                ],
                onTap: (date) {
                  if (selectedDays.contains(date.day)) {
                    onChanged([...selectedDays]..remove(date.day));
                  } else {
                    onChanged([...selectedDays, date.day]..sort());
                  }
                  // on day widget pressed
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Wrap(
            children: [
              GestureDetectorWithCursor(
                onTap: () {
                  final days = <int>[];
                  for (var i = 1; i <= month.daysInMonth; i++) {
                    final date = DateTime(month.year, month.month, i);
                    if (date.weekday == DateTime.saturday ||
                        date.weekday == DateTime.sunday) continue;
                    days.add(i);
                  }
                  onChanged(days);
                },
                child: Text(
                  'Select Weekdays',
                  style: TextStyle(
                    color: context.theme.colorScheme.primary,
                    fontSize: 13,
                    // fontStyle: FontStyle.italic,
                    // decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(
                height: 16,
                child: VerticalDivider(
                  width: 28,
                  color: context.theme.colorScheme.primary,
                ),
              ),
              GestureDetectorWithCursor(
                onTap: () {
                  final days = <int>[];
                  for (var i = 1; i <= month.daysInMonth; i++) {
                    days.add(i);
                  }
                  onChanged(days);
                },
                child: Text(
                  'Select All',
                  style: TextStyle(
                    color: context.theme.colorScheme.primary,
                    fontSize: 13,
                    // fontStyle: FontStyle.italic,
                    // decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(
                height: 16,
                child: VerticalDivider(
                  width: 28,
                  color: context.theme.colorScheme.primary,
                ),
              ),
              GestureDetectorWithCursor(
                onTap: () => onChanged([]),
                child: Text(
                  'Clear Selection',
                  style: TextStyle(
                    color: context.theme.colorScheme.primary,
                    fontSize: 13,
                    // fontStyle: FontStyle.italic,
                    // decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomDayTileBuilder extends DayTileBuilder {
  CustomDayTileBuilder();

  @override
  Widget build(BuildContext context, DateTime date,
      void Function(DateTime datetime)? onTap) {
    return CustomDayTile(
      date: date,
      onTap: onTap,
    );
  }
}

class CustomDayTile extends StatelessWidget {
  const CustomDayTile({
    super.key,
    required this.date,
    this.onTap,
    this.currentDayBorderColor,
    this.selectedDayColor,
    this.showToday = true,
  });

  /// The date to show
  final DateTime date;

  /// Function to call when the day is clicked
  final ValueChanged<DateTime>? onTap;

  /// Background color of the day when it is selected
  final Color? selectedDayColor;

  /// Border color of the current day (DateTime.now())
  final Color? currentDayBorderColor;

  final bool showToday;

  @override
  Widget build(BuildContext context) {
    final bool isToday = CalendarHelper.isToday(date);

    final bool daySelected =
        CustomAwesomeCalendar.of(context)!.isDateSelected(date);

    BoxDecoration? boxDecoration;
    if (daySelected) {
      boxDecoration = BoxDecoration(
        color: selectedDayColor ?? context.theme.colorScheme.primary,
        shape: BoxShape.circle,
      );
    } else if (showToday && isToday) {
      boxDecoration = BoxDecoration(
        border: Border.all(
          color: currentDayBorderColor ?? context.theme.colorScheme.primary,
          width: 1.0,
        ),
        shape: BoxShape.circle,
      );
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => handleTap(context),
        behavior: HitTestBehavior.translucent,
        child: Container(
          margin: const EdgeInsets.all(4),
          height: 34,
          decoration: boxDecoration,
          child: Center(
            child: Text(
              '${date.day}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: daySelected
                    ? context.theme.colorScheme.onPrimary
                    : date.weekday == DateTime.saturday ||
                            date.weekday == DateTime.sunday
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void handleTap(BuildContext context) {
    final DateTime day = DateTime(date.year, date.month, date.day, 12, 00);
    if (onTap != null) {
      onTap!(day);
    }

    AwesomeCalendar.of(context)?.setSelectedDate(day);
    AwesomeCalendar.of(context)?.setCurrentDate(day);
  }
}

class CustomWeekdayLabels extends StatelessWidget {
  final DateTime monday = DateTime(2020, 01, 06);
  final DateTime tuesday = DateTime(2020, 01, 07);
  final DateTime wednesday = DateTime(2020, 01, 08);
  final DateTime thursday = DateTime(2020, 01, 09);
  final DateTime friday = DateTime(2020, 01, 10);
  final DateTime saturday = DateTime(2020, 01, 11);
  final DateTime sunday = DateTime(2020, 01, 12);

  CustomWeekdayLabels({super.key});

  @override
  Widget build(BuildContext context) {
    final style =
        TextStyle(fontSize: 12, color: Theme.of(context).disabledColor);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              format(monday),
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            child: Text(
              format(tuesday),
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            child: Text(
              format(wednesday),
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            child: Text(
              format(thursday),
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            child: Text(
              format(friday),
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            child: Text(
              format(saturday),
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
          Expanded(
            child: Text(
              format(sunday),
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  String format(DateTime date) {
    return DateFormat('E').format(date)[0];
  }
}
