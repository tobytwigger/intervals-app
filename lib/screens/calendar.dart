import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/core/network/intervals/data/events.dart';
import 'package:intervals/core/network/intervals/intervals.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Events> events = [];
  List<Activity> activities = [];

  DateTime oldest = DateTime.now().subtract(const Duration(days: 31));

  DateTime newest = DateTime.now();

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   loadCalendarData();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      drawer: NavDrawer(),
      body: SfCalendar(
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
        view: CalendarView.month,
        monthCellBuilder:
            (BuildContext buildContext, MonthCellDetails details) {
          final Color backgroundColor = Colors.green;
          final Color defaultColor =
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.black54
                  : Colors.white;
          final List<Widget> entries = [];
          for (var appointment in ((details.appointments ?? []))) {
            // assert appointment is EventEntry;
            assert(appointment is EventEntry);
            // TODO Add support for weekly view too...
            entries.add(
              appointment.createMonthPreviewWidget(context)
            );
          }

          return Container(
            decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(color: defaultColor, width: 0.5)),
            child: Column(
              children: [
                Text(
                  details.date.day.toString(),
                  style: TextStyle(color: Colors.black),
                ),
                ...entries
              ],
            ),
          );
        },
        monthViewSettings: const MonthViewSettings(
          showAgenda: true,
          appointmentDisplayMode: MonthAppointmentDisplayMode.none,
        ),
        dataSource: EventDataSource(
            intervals:
                Provider.of<AuthenticatedUserModel>(context, listen: false)
                    .getIntervalsClient()!),
      ),
    );
  }
}

class EventDataSource extends CalendarDataSource {
  Intervals intervals;

  EventDataSource({required this.intervals}) {
    appointments = <EventEntry>[];
  }

  Future<List<EventEntry>> getCalendarData(
      DateTime startDate, DateTime endDate) async {
    final events = await intervals.getEvents(
      oldest: startDate,
      newest: endDate,
    );

    final activities = await intervals.loadActivitiesInDuration(
      oldest: startDate,
      newest: endDate,
    );

    // TODO Merge into one future to wait for both at the same time
    // final (events, activities) = await (eventsFuture, activitiesFuture).wait;

    final List<EventEntry> entries = <EventEntry>[];

    for (var event in events) {
      entries.add(EventEventEntry(event));
    }

    for (var activity in activities) {
      entries.add(ActivityEventEntry(activity));
    }

    return entries;
  }

  @override
  Future<void> handleLoadMore(DateTime startDate, DateTime endDate) async {
    List<EventEntry> newAppointments =
        await getCalendarData(startDate, endDate);

    List<EventEntry> uniqueAppointments = <EventEntry>[];

    for (final EventEntry appointment in newAppointments) {
      if (appointments!.contains(appointment)) {
        continue;
      }

      uniqueAppointments.add(appointment);
    }

    appointments!.addAll(uniqueAppointments);

    notifyListeners(CalendarDataSourceAction.add, uniqueAppointments);
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  bool isAllDay(int index) {
    return true;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  String getStartTimeZone(int index) {
    // TODO Implement timezone
    return 'GMT Standard Time';
  }

  @override
  String getEndTimeZone(int index) {
    // TODO Implement timezone
    return 'GMT Standard Time';
  }

  @override
  Color getColor(int index) {
    return Colors.red;
  }
}

abstract class EventEntry {
  DateTime get startTime;

  DateTime get endTime;

  String get subject;

  Widget createMonthPreviewWidget(BuildContext context);
}

class EventEventEntry extends EventEntry {
  Events event;

  EventEventEntry(this.event);

  @override
  DateTime get endTime {
    return event.endDate ?? event.startDate!.add(Duration(hours: 1));
  }

  @override
  String get subject {
    return event.name ?? 'N/A';
  }

  @override
  DateTime get startTime {
    return event.startDate!;
  }

  @override
  Widget createMonthPreviewWidget(BuildContext context) {
    return Text(event.name ?? 'N/A');
  }
}

class ActivityEventEntry extends EventEntry {
  Activity activity;

  ActivityEventEntry(this.activity);

  @override
  DateTime get startTime {
    return activity.startDateLocal!;
  }

  @override
  DateTime get endTime {
    return activity.startDateLocal!
        .add(Duration(milliseconds: activity.elapsedTime ?? 10));
  }

  @override
  String get subject {
    return activity.name ?? 'N/A';
  }

  @override
  Widget createMonthPreviewWidget(BuildContext context) {
    return Text(activity.name ?? 'N/A');
  }
}
