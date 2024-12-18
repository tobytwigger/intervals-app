import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/core/network/intervals/data/events.dart';
import 'package:intervals/core/network/intervals/intervals.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/screens/activities_index.dart';
import 'package:intervals/services/icons.dart';
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
        view: CalendarView.schedule,
        monthCellBuilder:
            (BuildContext buildContext, MonthCellDetails details) {
          return MonthlyCell(details: details);
        },
        // appointmentBuilder:
        //     (BuildContext buildContext, CalendarAppointmentDetails details) {
        //   return Text('Appointment');
        // },
        appointmentBuilder:
            (BuildContext buildContext, CalendarAppointmentDetails details) {
          //
          //
          //         Widget recordsWidget = (details.appointments.length) > 0
          //             ? ListView.builder(
          //           scrollDirection: Axis.vertical,
          //           shrinkWrap: true,
          //           prototypeItem: ListTile(
          //             title: details.appointments!.first
          //                 .createSchedulePreviewWidget(context),
          //           ),
          //           itemCount: details.appointments?.length ?? 0,
          //           itemBuilder: (BuildContext context, int index) {
          //             assert(details.appointments![index] is EventEntry);
          //
          //             ;
          //           },
          //         )
          //             : Text('No records found');
          //
          //         return Container(
          //           width: double.infinity,
          //           height: double.infinity / 2,
          //           child: Column(children: [
          //             Center(
          //               child: Text(
          //                 DateFormat('EEE, MMM d yyyy').format(details.date!),
          //                 style: TextStyle(
          //                   fontSize: 24,
          //                   fontWeight: FontWeight.bold,
          //                 ),
          //               ),
          //             ),
          //             recordsWidget,
          //           ]),
          //         );
          //       });
          // }

          List<Widget> children = [];

          for (var appointment in details.appointments) {
            assert(appointment is EventEntry);
            children.add(
                appointment.createSchedulePreviewWidget(buildContext) ??
                    Text(appointment.subject));
          }

          return Column(
            children: children,
          );
        },
        monthViewSettings: const MonthViewSettings(
          showTrailingAndLeadingDates: true,
          showAgenda: false,
          appointmentDisplayMode: MonthAppointmentDisplayMode.none,
        ),
        scheduleViewSettings: const ScheduleViewSettings(
          appointmentItemHeight: 100,
        ),
        scheduleViewMonthHeaderBuilder:
            (BuildContext context, ScheduleViewMonthHeaderDetails details) {
          return Text(DateFormat('MMM yyyy').format(details.date));
        },
        allowViewNavigation: true,
        allowedViews: <CalendarView>[CalendarView.month, CalendarView.schedule],
        dataSource: EventDataSource(
            intervals:
                Provider.of<AuthenticatedUserModel>(context, listen: false)
                    .getIntervalsClient()!),
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
      assert(appointment is EventEntry);
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
  * Data in the calendar
 */

class EventDataSource extends CalendarDataSource<EventEntry> {
  Intervals intervals;

  EventDataSource({required this.intervals}) {
    appointments = <EventEntry>[];
    loadData(DateTime.now().subtract(const Duration(days: 31)), DateTime.now());
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
        entries.add(PlannedWorkoutEntry(
          activity: activity,
          event: events.firstWhere((e) => e.id == activity.pairedEventId)!,
        ));
        // Add to the used event IDs
        eventIdsLinkedToActivities.add(activity.pairedEventId!);
      } else {
        entries.add(UnplannedWorkoutEntry(
          activity: activity,
        ));
      }
    }

    // Add any remaining events
    for (var event in events) {
      if (!eventIdsLinkedToActivities.contains(event.id)) {
        switch (event.category) {
          case EventCategory.workout:
            entries.add(WorkoutPlanEntry(
              event: event,
            ));
            break;
          case EventCategory.note:
            entries.add(CalendarNoteEntry(
              event: event,
            ));
            break;
          default:
            entries.add(UnknownEntry(
              event: event,
            ));
            break;
        }
      }
    }

    return entries;
  }

  Future<void> loadData(DateTime startDate, DateTime endDate) async {
    List<EventEntry> newAppointments =
        await getCalendarData(startDate, endDate);

    List<EventEntry> uniqueAppointments = <EventEntry>[];

    for (final EventEntry appointment in newAppointments) {
      if ((appointments as List<EventEntry>)
          .where((EventEntry a) => a.getUniqueId == appointment.getUniqueId)
          .isNotEmpty) {
        // If the current appointments list contains the appointment, skip it
        continue;
      }

      uniqueAppointments.add(appointment);
    }

    appointments = uniqueAppointments;

    notifyListeners(CalendarDataSourceAction.reset, uniqueAppointments);
  }

  @override
  Future<void> handleLoadMore(DateTime startDate, DateTime endDate) async {
    List<EventEntry> newAppointments =
        await getCalendarData(startDate, endDate);

    List<EventEntry> uniqueAppointments = <EventEntry>[];

    for (final EventEntry appointment in newAppointments) {
      if ((appointments as List<EventEntry>)
          .where((EventEntry a) => a.getUniqueId == appointment.getUniqueId)
          .isNotEmpty) {
        // If the current appointments list contains the appointment, skip it
        continue;
      }

      uniqueAppointments.add(appointment);
    }

    appointments = uniqueAppointments;

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

  String get id;

  get getUniqueId {
    return '${this.runtimeType.toString()}:${id}';
  }

  Widget? createMonthPreviewWidget(BuildContext context);

  Widget? createSchedulePreviewWidget(BuildContext context);
}

class PlannedWorkoutEntry extends EventEntry {
  final Activity activity;

  final Events event;

  PlannedWorkoutEntry({
    required this.activity,
    required this.event,
  });

  int? get trainingLoad => activity.icuTrainingLoad ?? event.icuTrainingLoad;

  Color get color => Colors.blue;

  Duration get duration => _runForActivityOrEvent(
      (a) => Duration(seconds: a.movingTime ?? 0),
      (e) => Duration(seconds: e.timeTarget ?? 0));

  @override
  Widget? createMonthPreviewWidget(BuildContext context) {
    // If it's an activity, show the TSS and the sport icon in green
    // If there's an event and no activity, show the TSS and the sport icon in blue.

    // Add a sport icon if there's an activity or event
    return CalendarAppointmentIndicator(
      trainingLoad: trainingLoad,
      type: activity?.type ?? event?.type,
      color: color,
    );
  }

  @override
  Widget? createSchedulePreviewWidget(BuildContext context) {
    return PlannedAndCompletedWorkoutCard(
      activity: activity,
      event: event,
    );
  }

  @override
  DateTime get startTime => _runForActivityOrEvent(
      (a) => a.startDateLocal!.add(Duration(milliseconds: a.elapsedTime ?? 10)),
      (e) => e.endDate ?? e.startDate!.add(Duration(hours: 1)));

  @override
  // TODO: implement endTime
  DateTime get endTime => _runForActivityOrEvent((a) => a.startDateLocal!,
      (e) => e.endDate ?? e.startDate!.add(Duration(hours: 1)));

  @override
  // TODO: implement subject
  String get subject =>
      _runForActivityOrEvent((a) => a.name ?? 'N/A', (e) => e.name ?? 'N/A');

  T _runForActivityOrEvent<T>(
    T Function(Activity) forActivity,
    T Function(Events) forEvent,
  ) {
    if (activity != null) {
      return forActivity(activity!);
    } else if (event != null) {
      return forEvent(event!);
    } else {
      throw Exception('No activity or event');
    }
  }

  @override
  String get id => activity.id.toString();
}

class UnplannedWorkoutEntry extends EventEntry {
  final Activity activity;

  UnplannedWorkoutEntry({required this.activity});

  String get id => activity.id.toString();

  @override
  Widget? createMonthPreviewWidget(BuildContext context) {
    return CalendarAppointmentIndicator(
      trainingLoad: activity.icuTrainingLoad,
      type: activity.type,
    );
  }

  @override
  Widget? createSchedulePreviewWidget(BuildContext context) {
    return ActivityCard(activity: activity);
  }

  @override
  DateTime get startTime => activity.startDateLocal!;

  @override
  DateTime get endTime => activity.startDateLocal!;

  @override
  String get subject => activity.name ?? 'N/A';
}

class WorkoutPlanEntry extends EventEntry {
  final Events event;

  WorkoutPlanEntry({required this.event});

  @override
  Widget? createMonthPreviewWidget(BuildContext context) {
    return CalendarAppointmentIndicator(
      trainingLoad: event.icuTrainingLoad,
      type: event.type,
    );
  }

  @override
  Widget? createSchedulePreviewWidget(BuildContext context) {
    return EventCard(event: event);
  }

  @override
  DateTime get startTime => event.startDate!;

  @override
  DateTime get endTime =>
      event.endDate ?? event.startDate!.add(Duration(hours: 1));

  @override
  String get subject => event.name ?? 'N/A';

  @override
  String get id => event.id.toString();
}

class CalendarNoteEntry extends EventEntry {
  final Events event;

  CalendarNoteEntry({required this.event});

  String get id => event.id.toString();

  @override
  Widget? createMonthPreviewWidget(BuildContext context) {
    return CalendarAppointmentIndicator(
      trainingLoad: null, // TODO Show all icons properly
      type: event.type,
    );
  }

  @override
  Widget? createSchedulePreviewWidget(BuildContext context) {
    // TODO Name, colour. Put along top of day

    return ScheduleActivityCard(
        header: Text('Note'),
        body: Text(event.name ?? 'N/A'),
        subtitle: 'Note');
  }

  @override
  DateTime get startTime => event.startDate!;

  @override
  DateTime get endTime =>
      event.endDate ?? event.startDate!.add(Duration(hours: 1));

  @override
  String get subject => event.name ?? 'N/A';
}

class UnknownEntry extends EventEntry {
  final Events event;

  String get id => event.id.toString();

  UnknownEntry({required this.event});

  @override
  Widget? createMonthPreviewWidget(BuildContext context) {
    return CalendarAppointmentIndicator(
      trainingLoad: null, // TODO Show all icons properly
      type: event.type,
    );
  }

  @override
  Widget? createSchedulePreviewWidget(BuildContext context) {
    return ScheduleActivityCard(
        header: Text('Other'),
        body: Text(subject),
        subtitle: 'Unknown event: ${event.category?.name ?? 'N/A'}');
  }

  @override
  DateTime get startTime => event.startDate!;

  @override
  DateTime get endTime =>
      event.endDate ?? event.startDate!.add(Duration(hours: 1));

  @override
  String get subject => event.name ?? 'N/A';
}

// class WorkoutEntry extends EventEntry {
//   final Activity? activity;
//
//   WorkoutEntry({
//     this.activity,
//   });
//
//   @override
//   Widget? createMonthPreviewWidget(BuildContext context) {
//     // If it's an activity, show the TSS and the sport icon in green
//     // If there's an event and no activity, show the TSS and the sport icon in blue.
//
//     // Add a sport icon if there's an activity or event
//     Widget iconWidget = Icon(AppIcons.fromActivityType(activity?.type ?? event?.type));
//     // TODO Add the 'traisition' notes as all day tasks
//     return Container(
//       child: trainingLoad == null
//           ? iconWidget
//           : Container(
//         padding: const EdgeInsets.all(2),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: color,
//           // TODO edit size depending on load,
//         ),
//         child: Wrap(
//           direction: Axis.vertical,
//           children: [
//             Center(child: Text(trainingLoad.toString())),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget? createSchedulePreviewWidget(BuildContext context) {
//     return PlannedWorkoutEntryScheduleActivityCard(child: this);
//   }
//
//   @override
//   DateTime get startTime =>
//       _runForActivityOrEvent(
//               (a) =>
//               a.startDateLocal!.add(
//                   Duration(milliseconds: a.elapsedTime ?? 10)),
//               (e) => e.endDate ?? e.startDate!.add(Duration(hours: 1)));
//
//   @override
//   // TODO: implement endTime
//   DateTime get endTime =>
//       _runForActivityOrEvent((a) => a.startDateLocal!,
//               (e) => e.endDate ?? e.startDate!.add(Duration(hours: 1)));
//
//   @override
//   // TODO: implement subject
//   String get subject =>
//       _runForActivityOrEvent((a) => a.name ?? 'N/A', (e) => e.name ?? 'N/A');
//
//   T _runForActivityOrEvent<T>(T Function(Activity) forActivity,
//       T Function(Events) forEvent,) {
//     if (activity != null) {
//       return forActivity(activity!);
//     } else if (event != null) {
//       return forEvent(event!);
//     } else {
//       throw Exception('No activity or event');
//     }
//   }
// }
//
//
// class PlannedWorkoutEntryScheduleActivityCard extends StatelessWidget {
//   final PlannedWorkoutEntry child;
//
//   PlannedWorkoutEntryScheduleActivityCard(
//       {super.key, required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     String? type = child.activity?.type ?? child.event?.type;
//     IconData icon = type == null
//         ? Icons.question_mark
//         : AppIcons.fromActivityType(type);
//
//     Widget iconWidget = Icon(icon);
//
//     return Container(
//       child: GestureDetector(
//         onTap: () {
//           GoRouter.of(context).push('/event/${child.event?.id}');
//         },
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                   border: Border.fromBorderSide(
//                     BorderSide(
//                       width: 1.0
//                     )
//                   )
//               ),
//               child: Padding(
//                   padding: EdgeInsets.all(4.0),
//                   child: PlannedWorkoutEntryScheduleActivityCardSkylineImage(child: child)
//               ),
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 Container(
//                   color: child.color,
//                   child: Row(
//                       children: [
//                         iconWidget,
//                         Text(child.duration.pretty(
//                             tersity: DurationTersity.minute,
//                             abbreviated: true
//                         )),
//                       ]
//                   ),
//                 ),
//                 Text(
//                   child.subject,
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   child.event?.category?.name ?? 'N/A',
//                 ),
//
//               ],
//             ),
//             ...child.trainingLoad == null
//                 ? [Padding(padding: EdgeInsets.all(16))]
//                 : [
//               Container(
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   border: Border.fromBorderSide(
//                     BorderSide(color: child.color, width: 4.0),
//                   ),
//                   shape: BoxShape.circle,
//                   color: Colors.white,
//                 ),
//                 child: Center(child: Text(child.trainingLoad.toString())),
//               )
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//

/*
 * UI for the calendar entries
 */

class ActivityCard extends StatelessWidget {
  final Activity activity;

  ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {

    return ScheduleActivityCard(
        icon: AppIcons.fromActivityType(activity.type),
        header: Text('Event'),
        onTap: () {
          GoRouter.of(context).push('/activity/${activity.id}');
        },
        body: Column(
          children: [
            // Text(activity.name ?? 'N/A'),
            if(activity.skylineChartBytes != null)
              ...[Text(activity.name ?? 'N/A'), SkylineImage(skylineData: activity.skylineChartData!)]
          ],
        ),
        subtitle: 'Unplanned activity');
  }
}

class PlannedAndCompletedWorkoutCard extends StatelessWidget {
  final Activity activity;

  final Events event;

  PlannedAndCompletedWorkoutCard(
      {super.key, required this.activity, required this.event});

  @override
  Widget build(BuildContext context) {
    return ScheduleActivityCard(
        icon: AppIcons.fromActivityType(activity.type),
        header: Text(activity.name ?? 'N/A'),
        onTap: () {
          GoRouter.of(context).push('/activity/${activity.id}');
        },
        body: Row(
          children: [
            Text(event.name ?? 'N/A'),
            if (activity.skylineChartBytes != null)
              ...[SkylineImage(skylineData: activity.skylineChartData!)]
          ],
        ),
        subtitle: 'Scheduled activity');
  }
}

class EventCard extends StatelessWidget {
  final Events event;

  EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ScheduleActivityCard(
        header: Text('Event'),
        icon: AppIcons.fromActivityType(event.type),
        onTap: () {
          GoRouter.of(context).push('/event/${event.id}');
        },
        body: Text(event.name ?? 'N/A'),
        subtitle: 'Planned (not completed) activity');
  }
}

class CalendarAppointmentIndicator extends StatelessWidget {
  final String? type;

  final Color color;

  final int? trainingLoad;

  CalendarAppointmentIndicator({
    super.key,
    required this.type,
    required this.trainingLoad,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(AppIcons.fromActivityType(type));
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
}

class ScheduleActivityCard extends StatelessWidget {
  final String? subtitle;

  final GestureTapCallback? onTap;

  final Widget header;

  final Widget body;

  final IconData icon;

  ScheduleActivityCard({
    super.key,
    this.icon = Icons.question_mark,
    this.subtitle,
    this.onTap,
    required this.header,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      // height: 50,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Colors.lightBlue,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [GestureDetector(
          onTap: onTap,
          child: SingleChildScrollView(
              child: BasicActivityCardLayout(
            header: header,
            body: body,
            icon: Icon(icon),
          )),
        )],
      ),
    );
  }
}

class BasicActivityCardLayout extends StatelessWidget {
  final Widget header;

  final Widget body;

  final Widget? icon;

  final Widget? trailing;

  BasicActivityCardLayout(
      {super.key,
      required this.header,
      required this.body,
      this.icon,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) icon!,
        Column(
          children: [
            header,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: body,
            )
          ],
        ),
        if (trailing != null) trailing!
      ],
    );
  }
}

class PlannedWorkoutEntryScheduleActivityCardSkylineImage
    extends StatelessWidget {
  final PlannedWorkoutEntry child;

  PlannedWorkoutEntryScheduleActivityCardSkylineImage(
      {super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    var chartData = child.activity?.skylineChartData;
    if (chartData != null) {
      return SkylineImage(skylineData: chartData);
    }
    return Text('');
  }
}
