import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/core/network/intervals/data/events.dart';
import 'package:intervals/core/network/intervals/intervals.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/services/icons.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';
import 'package:intl/intl.dart';
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
        // showWeekNumber: true,
        // weekNumberStyle: const WeekNumberStyle(
        //   backgroundColor: Colors.blue,
        //   textStyle: TextStyle(color: Colors.white),
        // ),
        onTap: (CalendarTapDetails details) {
          if (details.date != null) {
            showModalBottomSheet(
                enableDrag: true,
                showDragHandle: true,
                useSafeArea: true,
                context: context,
                constraints: BoxConstraints(
                  maxWidth: double.infinity,
                ),
                builder: (BuildContext context) {
                  Widget recordsWidget = (details.appointments?.length ?? 0) > 0
                      ? ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    prototypeItem: ListTile(
                      title: details.appointments!.first
                          .createSchedulePreviewWidget(context),
                    ),
                    itemCount: details.appointments?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      assert(details.appointments![index] is EventEntry);

                      return ListTile(
                          title: details.appointments![index]
                              .createSchedulePreviewWidget(context) ??
                              Text(details.appointments![index].subject));
                    },
                  )
                      : Text('No records found');

                  return Container(
                    width: double.infinity,
                    height: double.infinity / 2,
                    child: Column(children: [
                      Center(
                        child: Text(
                          DateFormat('EEE, MMM d yyyy').format(details.date!),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      recordsWidget,
                    ]),
                  );
                });
          }
        },
        monthCellBuilder:
            (BuildContext buildContext, MonthCellDetails details) {
          return MonthlyCell(details: details);
        },
        // appointmentBuilder:
        //     (BuildContext buildContext, CalendarAppointmentDetails details) {
        //   return Text('Appointment');
        // },
        monthViewSettings: const MonthViewSettings(
          showTrailingAndLeadingDates: true,
          showAgenda: false,
          appointmentDisplayMode: MonthAppointmentDisplayMode.none,
        ),
        allowedViews: <CalendarView>[
          CalendarView.day,
          CalendarView.week,
          CalendarView.workWeek,
          CalendarView.month,
          CalendarView.schedule
        ],
        dataSource: EventDataSource(
            intervals:
            Provider.of<AuthenticatedUserModel>(context, listen: false)
                .getIntervalsClient()!),
      ),
    );
  }
}

class MonthlyCell extends StatelessWidget {
  final MonthCellDetails details;

  MonthlyCell({super.key, required this.details});

  bool get isToday =>
      details.date.year == DateTime
          .now()
          .year &&
          details.date.month == DateTime
              .now()
              .month &&
          details.date.day == DateTime
              .now()
              .day;

  @override
  Widget build(BuildContext context) {
    final Color defaultColor = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.black54
        : Colors.white;

    final List<Widget> entries = [];
    for (var appointment in ((details.appointments ?? []))) {
      // assert appointment is EventEntry;
      assert(appointment is EventEntry);
      // TODO Add support for weekly view too...
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

class EventDataSource extends CalendarDataSource {
  Intervals intervals;

  EventDataSource({required this.intervals}) {
    appointments = <EventEntry>[];
  }

  Future<List<EventEntry>> getCalendarData(DateTime startDate,
      DateTime endDate) async {
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

    // We need to merge any activities with the events that have the associated plan.

    List<int> eventIdIndex = [];
    List<int> eventIdsLinkedToActivities = [];
    final List<EventEntry> entries = <EventEntry>[];

    // Populate the eventIdIndex
    for (var event in events) {
      eventIdIndex.add(event.id);

      // if(event.pairedActivityId == null) {
      //   entries.add(EventEventEntry(event));
      // }
    }

    // Go through each activity
    for (var activity in activities) {
      // If the activity has a paired event, and this event is in the eventIdIndex (i.e. has been loaded from the API)
      if (activity.pairedEventId != null &&
          eventIdIndex.contains(activity.pairedEventId)) {
        // Add the activity to the eventIdsLinkedToActivities
        entries.add(WorkoutEventEntry(
          activity: activity,
          event: events.firstWhere((e) => e.id == activity.pairedEventId),
        ));
        // Add to the used event IDs
        eventIdsLinkedToActivities.add(activity.pairedEventId!);
      } else {
        entries.add(WorkoutEventEntry(
          activity: activity,
          event: null,
        ));
      }
    }

    // Add any remaining events
    for (var event in events) {
      if (!eventIdsLinkedToActivities.contains(event.id)) {
        entries.add(WorkoutEventEntry(
          event: event,
          activity: null,
        ));
      }
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
        // TODO Fix this. Currently never matching ones
        continue;
      }

      uniqueAppointments.add(appointment);
    }

    appointments = uniqueAppointments;

    notifyListeners(CalendarDataSourceAction.reset, uniqueAppointments);
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

  Widget? createMonthPreviewWidget(BuildContext context);

  Widget? createSchedulePreviewWidget(BuildContext context);
}

class WorkoutEventEntry extends EventEntry {
  final Activity? activity;

  final Events? event;

  WorkoutEventEntry({
    this.activity,
    this.event,
  });

  int? get trainingLoad => activity?.icuTrainingLoad ?? event?.icuTrainingLoad;

  Color get color =>
      activity == null
          ? (event?.isInPast == true
              ? Colors.red // Event has passed with no activity
              : Colors.blue // Event is planned for the future
          )
          : Colors.green;

  @override
  Widget? createMonthPreviewWidget(BuildContext context) {
    // If it's an activity, show the TSS and the sport icon in green
    // If there's an event and no activity, show the TSS and the sport icon in blue.

    // Add a sport icon if there's an activity or event
    Widget iconWidget = Icon(AppIcons.fromActivityType(activity?.type ?? event?.type));
    // TODO Add the 'traisition' notes as all day tasks
    return Container(
      child: trainingLoad == null
          ? iconWidget
          : Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          // TODO edit size depending on load,
        ),
        child: Wrap(
          direction: Axis.vertical,
          children: [
            Center(child: Text(trainingLoad.toString())),
          ],
        ),
      ),
    );
  }

  @override
  Widget? createSchedulePreviewWidget(BuildContext context) {
    String? type = activity?.type ?? event?.type;
    IconData icon = type == null
      ? Icons.question_mark
      : AppIcons.fromActivityType(type);

    Widget iconWidget = Icon(icon);

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(padding: EdgeInsets.all(4.0), child: iconWidget),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                subject,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Start: ' + startTime.toString()),
              Text('End: ' + endTime.toString()),
            ],
          ),
          ...trainingLoad == null
              ? [Padding(padding: EdgeInsets.all(16))]
              : [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(color: color, width: 4.0),
                ),
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(child: Text(trainingLoad.toString())),
            )
          ],
        ],
      ),
    );
  }

  @override
  DateTime get startTime =>
      _runForActivityOrEvent(
              (a) =>
              a.startDateLocal!.add(
                  Duration(milliseconds: a.elapsedTime ?? 10)),
              (e) => e.endDate ?? e.startDate!.add(Duration(hours: 1)));

  @override
  // TODO: implement endTime
  DateTime get endTime =>
      _runForActivityOrEvent((a) => a.startDateLocal!,
              (e) => e.endDate ?? e.startDate!.add(Duration(hours: 1)));

  @override
  // TODO: implement subject
  String get subject =>
      _runForActivityOrEvent((a) => a.name ?? 'N/A', (e) => e.name ?? 'N/A');

  T _runForActivityOrEvent<T>(T Function(Activity) forActivity,
      T Function(Events) forEvent,) {
    if (activity != null) {
      return forActivity(activity!);
    } else if (event != null) {
      return forEvent(event!);
    } else {
      throw Exception('No activity or event');
    }
  }
}

class ScheduleAppointmentContainer extends StatelessWidget {
  final Widget child;

  final Color? backgroundColor;

  ScheduleAppointmentContainer(
      {super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: backgroundColor ?? Colors.red),
      child: Padding(padding: EdgeInsets.all(2), child: child),
    );
  }
}
