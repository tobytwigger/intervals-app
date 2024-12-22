import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/core/network/intervals/data/events.dart';
import 'package:intervals/core/network/intervals/intervals.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/ui/components/summary-cards/workout_or_plan.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Events> events = [];
  List<Activity> activities = [];

  DateTime oldest = DateTime.now().subtract(const Duration(days: 31));

  DateTime newest = DateTime.now();

  late CalendarController _calendarController;

  late CustomCalendarDataSource _dataSource;

  @override
  void initState() {
    _calendarController = CalendarController();
    _dataSource = CustomCalendarDataSource(
        intervals: Provider.of<AuthenticatedUserModel>(context, listen: false)
            .getIntervalsClient()!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      drawer: NavDrawer(),
      body: SfCalendar(
        controller: _calendarController,
        loadMoreWidgetBuilder:
            (BuildContext context, LoadMoreCallback loadMoreAppointments) {
          return FutureBuilder<void>(
            future: loadMoreAppointments(),
            builder: (context, snapShot) {
              if (snapShot.hasError) {
                // TODO Proper error handling
                return Container(
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text('Error loading data: ' +
                        snapShot.error.toString() +
                        '\n' +
                        snapShot.stackTrace.toString()));
              }
              return Container(
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.blue)));
            },
          );
        },

        showDatePickerButton: true,
        showNavigationArrow: true,
        showTodayButton: true,
        view: CalendarView.schedule,
        // monthCellBuilder:
        //     (BuildContext buildContext, MonthCellDetails details) {
        //   return MonthlyCell(details: details);
        // },
        onTap: (CalendarTapDetails details) {
          if(details.date != null) {
            GoRouter.of(context).go('/today?date=${DateFormat('yyyy-MM-dd').format(details.date!)}');
          }
        },
        appointmentBuilder:
            (BuildContext buildContext, CalendarAppointmentDetails details) {
          List<Widget> children = [];

          for (var appointment in (details.appointments)) {
            if (appointment is! CalendarEntry) {
              continue;
            }

            if (appointment.workoutOrPlan != null) {
              return WorkoutOrPlanSummaryCard(
                  workoutOrPlan: appointment.workoutOrPlan!, tight: true);
            }

            throw Exception('EventTile: event is neither activity nor event');
          }

          return Column(
            children: children,
          );
        },
        monthViewSettings: const MonthViewSettings(
          //   showTrailingAndLeadingDates: true,
          //   showAgenda: false,

          // appointmentDisplayMode: MonthAppointmentDisplayMode.none,
        ),
        scheduleViewSettings: const ScheduleViewSettings(
          appointmentItemHeight: 150,
        ),
        // scheduleViewMonthHeaderBuilder:
        //     (BuildContext context, ScheduleViewMonthHeaderDetails details) {
        //   return Text(DateFormat('MMM yyyy').format(details.date));
        // },
        allowViewNavigation: false,
        allowedViews: <CalendarView>[CalendarView.schedule, CalendarView.month],
        dataSource: _dataSource,
      ),
    );
  }
}

/*
 * Layout for the calendars themselves
 */

class MonthlyCell extends StatelessWidget {
  final MonthCellDetails details;

  MonthlyCell({super.key, required this.details});

  bool get isToday =>
      details.date.year == DateTime.now().year &&
      details.date.month == DateTime.now().month &&
      details.date.day == DateTime.now().day;

  @override
  Widget build(BuildContext context) {
    final Color defaultColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black54
        : Colors.white;

    final List<Widget> entries = [];
    for (var appointment in ((details.appointments ?? []))) {
      // assert appointment is EventEntry;
      Widget? appt = appointment.createMonthPreviewWidget(context);
      if (appt != null) {
        entries.add(appt);
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: defaultColor, width: 0.5),
        // color: isToday ? Colors.lightBlue.withOpacity(0.2) : null,
      ),
      child: Column(
        children: [
          MonthlyCellDateEntry(date: details.date, isToday: isToday),
          Wrap(children: entries)
        ],
      ),
    );
  }
}

class MonthlyCellDateEntry extends StatelessWidget {
  final DateTime date;

  final bool isToday;

  MonthlyCellDateEntry({super.key, required this.date, required this.isToday});

  @override
  Widget build(BuildContext context) {
    // bool isToday = date.year == DateTime.now().year &&
    //     date.month == DateTime.now().month &&
    //     date.day == DateTime.now().day;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday ? Colors.lightBlue.withOpacity(0.3) : null,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: isToday ? Colors.blue : null,
          ),
        ),
      ),
    );
  }
}

/*
New data in the calendar
 */

class CalendarEntry implements Comparable<CalendarEntry> {
  final WorkoutOrPlan? workoutOrPlan;

  CalendarEntry({required this.workoutOrPlan});

  bool isEqual(CalendarEntry other) {
    return workoutOrPlan?.activity?.id == other.workoutOrPlan?.activity?.id;
  }

  DateTime get from {
    return workoutOrPlan?.activity?.startDateLocal ??
        workoutOrPlan?.event?.startDate ??
        DateTime.now();
  }

  DateTime get to {
    return from.add(Duration(hours: 1));
  }

  bool get isAllDay {
    return true;
  }

  String get eventName {
    return workoutOrPlan?.activity?.name ?? workoutOrPlan?.event?.name ?? 'N/A';
  }

  String get startTimeZone {
    return 'GMT Standard Time';
  }

  String get endTimeZone {
    return 'GMT Standard Time';
  }

  Color get background {
    return Colors.grey;
  }

  @override
  int compareTo(CalendarEntry other) {
    // That is, it returns a negative integer if `this` is ordered before [other],
    // a positive integer if `this` is ordered after [other],
    // and zero if `this` and [other] are ordered together.

    if (workoutOrPlan == null) {
      return -1;
    }
    return 0;
  }
}

class CustomCalendarDataSource extends CalendarDataSource {
  Intervals intervals;

  CustomCalendarDataSource({required this.intervals}) {
    appointments = <CalendarEntry>[];
    loadData(DateTime.now().subtract(const Duration(days: 31)), DateTime.now());
  }

  Future<List<CalendarEntry>> _getCalendarData(
      DateTime startDate, DateTime endDate) async {
    final events = await intervals.getEventsWithActivities(
      oldest: startDate,
      newest: endDate,
    );

    final List<CalendarEntry> entries = <CalendarEntry>[];

    for (var event in events) {
      entries.add(CalendarEntry(workoutOrPlan: event));
    }

    return entries;
  }

  Future<void> loadData(DateTime startDate, DateTime endDate) async {
    print(startDate);
    print(endDate);
    List<CalendarEntry> newAppointments =
        await _getCalendarData(startDate, endDate);

    // Filter through every new appointment. For each, check if it's present in the appointments array
    List<CalendarEntry> uniqueAppointments =
        newAppointments.where((CalendarEntry possiblyUniqueEntry) {
      return (appointments as List<CalendarEntry>)
          .where((CalendarEntry existingEntry) =>
              existingEntry.isEqual(possiblyUniqueEntry))
          .isEmpty;
    }).toList();

    appointments!.addAll(uniqueAppointments);

    notifyListeners(CalendarDataSourceAction.add, uniqueAppointments);
  }

  @override
  Future<void> handleLoadMore(DateTime startDate, DateTime endDate) async {
    print('handleLoadMore');
    await loadData(startDate, endDate);
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  String getStartTimeZone(int index) {
    return appointments![index].startTimeZone;
  }

  @override
  String getEndTimeZone(int index) {
    return appointments![index].endTimeZone;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }
}
