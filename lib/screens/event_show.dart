import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/events.dart' as intervals;
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:provider/provider.dart';

class EventShowPage extends StatefulWidget {
  final int eventId;

  const EventShowPage({super.key, required this.eventId});

  @override
  State<EventShowPage> createState() => _EventShowPageState();
}

class _EventShowPageState extends State<EventShowPage> {
  intervals.Events? _event;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadEventData();
    });
  }

  Future<void> loadEventData() async {
    // Load the event data
    intervals.Events? event =
        await Provider.of<AuthenticatedUserModel>(context, listen: false)
            .getIntervalsClient()!
            .getEventById(eventId: widget.eventId);

    if (event == null) {
      return;
    }

    setState(() {
      _event = event;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title:
                Text(_event == null ? 'Loading...' : _event!.name ?? 'Event')),
        body: _event == null
            ? CircularProgressIndicator()
            : Center(
                child: ListView(
                  children: [
                    ListTile(
                        title: Text('Description'),
                        subtitle: Text(_event!.description ?? 'N/A')),
                    ListTile(
                        title: Text('Date'),
                        subtitle: Text(
                            '${_event!.startDate?.toString() ?? 'N/A'} - ${_event!.endDate?.toString() ?? 'N/A'}')),
                    ListTile(
                        title: Text('Type'),
                        subtitle: Text(_event!.category?.toString() ?? 'N/A')),
                    ListTile(
                        title: Text('Training Load'),
                        subtitle:
                            Text(_event!.icuTrainingLoad?.toString() ?? 'N/A')),
                    ListTile(
                        title: Text('Type'),
                        subtitle: Text(_event!.type?.toString() ?? 'N/A')),
                    ListTile(
                        title: Text('Category'),
                        subtitle: Text(_event!.category?.toString() ?? 'N/A')),
                    ListTile(
                        title: Text('Indoor'),
                        subtitle: Text(_event!.indoor?.toString() ?? 'N/A')),
                    ListTile(
                        title: Text('Color'),
                        subtitle: Text(_event!.color ?? 'N/A')),
                    ListTile(
                        title: Text('Moving Time'),
                        subtitle: _event?.movingTime == null
                            ? Text('N/A')
                            : Text(Duration(seconds: _event!.movingTime!)
                                .pretty(upperTersity: DurationTersity.hour))),

                    // TODO "not_on_fitness_chart": false,
                    // TODO "show_as_note": false,
                    // TODO "show_on_ctl_line": false,

                    ListTile(
                        title: Text('Energy'),
                        subtitle: Text(
                            '${_event!.joules} Joules, with ${_event!.joulesAboveFtp} Joules above FTP')),

                    ListTile(
                        title: Text('Shared Event'),
                        subtitle:
                            Text(_event!.sharedEventId?.toString() ?? 'N/A')),
                    ListTile(
                        title: Text('Distance'),
                        subtitle: Text(_event!.distance?.toString() ?? 'N/A')),
                    ListTile(
                        title: Text('ICU Intensity'),
                        subtitle:
                            Text(_event!.icuIntensity?.toString() ?? 'N/A')),
                    ListTile(
                        title: Text('Workout doc targets'),
                        subtitle: Column(
                          children: [
                            Text(
                                'Distance: ${_event!.workoutDoc?.distance?.toString() ?? 'N/A'}'),
                            Text(
                                'Duration: ${_event!.workoutDoc?.duration?.toString() ?? 'N/A'}'),
                            Text(
                                'Avg Watts: ${_event!.workoutDoc?.averageWatts?.toString() ?? 'N/A'}'),
                            Text(
                                'Normalised Power: ${_event!.workoutDoc?.normalizedPower?.toString() ?? 'N/A'}'),
                            Text(
                                'Polarization Index: ${_event!.workoutDoc?.polarizationIndex?.toString() ?? 'N/A'}'),
                            Text(
                                'Variability Index: ${_event!.workoutDoc?.variabilityIndex?.toString() ?? 'N/A'}'),
                            Text(
                                'Description: ${_event!.workoutDoc?.description?.toString() ?? 'N/A'}'),
                          ],
                        )),
                    ListTile(
                        title: Text('Workout doc zones'),
                        subtitle: Column(
                            children: _event!.workoutDoc?.zoneTimes
                                    .map((e) => Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Zone ${e.zone}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                      'Zone ${e.zone}: ${e.name}'),
                                                  Text(
                                                      'Time: ${Duration(seconds: e.secs ?? 0).pretty(upperTersity: DurationTersity.hour)}'),
                                                  Text(
                                                      'Zones: ${e.minWatts}W - ${e.maxWatts}W'),
                                                  Text('Max: ${e.max}'),
                                                  Text('ID: ${e.id}'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ))
                                    .toList() ??
                                [])),
                    ListTile(
                        title: Text('Activity Graph'),
                        subtitle:
                            WorkoutDocShow(workoutDoc: _event!.workoutDoc))
                  ],
                ),
              ));
  }
}

class WorkoutDocShow extends StatelessWidget {
  final intervals.WorkoutDoc? workoutDoc;

  const WorkoutDocShow({super.key, required this.workoutDoc});

  @override
  Widget build(BuildContext context) {
    if (workoutDoc == null) {
      return Text('No workout doc');
    }

    return WorkoutDocImage(
      totalSeconds: workoutDoc?.duration ?? 0,
      steps: workoutDoc?.steps ?? [],
    );
  }
}

class WorkoutDocImage extends StatelessWidget {
  final List<intervals.StepEntry> steps;

  final int totalSeconds;

  const WorkoutDocImage({
    super.key,
    required this.steps,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth == double.infinity
            ? 400
            : constraints.maxWidth;
        double maxHeight = constraints.maxHeight == double.infinity
            ? 400
            : constraints.maxHeight;

        List<WorkoutImageEntry> data =
            createData(steps, maxWidth, maxHeight);

        List<Widget> children = [];

        data.forEach((imageEntry) {
          children.add(WorkoutDocImageRod(
            color: imageEntry.color,
            width: imageEntry.width,
            height: imageEntry.height,
          ));
        });

        return SizedBox(
            width: maxWidth,
            height: maxHeight,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: children));
      },
    );
  }

  List<WorkoutImageEntry> createData(
      List<intervals.StepEntry> stepData, double maxWidth, double maxHeight) {
    int totalTime = 0;
    intervals.Power? maxPower;
    for (var step in stepData) {
      if (step.duration != null) {
        totalTime += step.duration!;
      }
      if ((step.power?.value ?? 0) > (maxPower?.value ?? 0)) {
        maxPower = step.power;
      }
    }

    double horizontalPixelsPerSecond = maxWidth / totalTime;
    double verticalPixelsPerPowerUnit = maxHeight / maxPower!.value!;

    List<WorkoutImageEntry> data = [];

    for (final intervals.StepEntry step in stepData) {
      if (step.stepRepeat != null) {
        for (int i = 0; i < step.stepRepeat!.reps; i++) {
          for (final intervals.Step s in step.stepRepeat!.steps) {
            data.add(_convertToWorkoutImageEntry(
                s, horizontalPixelsPerSecond, verticalPixelsPerPowerUnit));
          }
        }
      } else {
        data.add(_convertToWorkoutImageEntry(
            step.step!, horizontalPixelsPerSecond, verticalPixelsPerPowerUnit));
      }
    }

    return data;
  }

  WorkoutImageEntry _convertToWorkoutImageEntry(intervals.Step step,
      double horizontalPixelsPerSecond, double verticalPixelsPerPowerUnit) {
    print(verticalPixelsPerPowerUnit);
    print(step.power?.value);
    return WorkoutImageEntry(
      color: step.warmup ? Colors.red : Colors.blue,
      width: (step.duration?.toDouble() ?? 0) * horizontalPixelsPerSecond,
      height: (step.power?.value?.toDouble() ?? 0) * verticalPixelsPerPowerUnit,
    );
  }

  convertZoneToColour(int zone, int numZones) {
    if (numZones == 7) {
      switch (zone) {
        case 1:
          return const Color.fromRGBO(0, 158, 128, 1);
        case 2:
          return const Color.fromRGBO(0, 158, 0, 1);
        case 3:
          return const Color.fromRGBO(255, 203, 14, 1);
        case 4:
          return const Color.fromRGBO(255, 127, 14, 1);
        case 5:
          return const Color.fromRGBO(221, 4, 71, 1);
        case 6:
          return const Color.fromRGBO(102, 51, 204, 1);
        case 7:
          return const Color.fromRGBO(80, 72, 97, 1);
      }
    }
    return Colors.blue;
  }
}

class WorkoutImageEntry {
  final Color color;

  final double width;

  final double height;

  WorkoutImageEntry({
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  String toString() {
    return 'WorkoutImageEntry{width: $width, height: $height}';
  }
}

class WorkoutDocImageRod extends StatelessWidget {
  final Color color;

  final double width;

  final double height;

  WorkoutDocImageRod(
      {super.key,
      required this.width,
      required this.height,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: color,
        child: SizedBox(
          width: width,
          height: height,
        ));
  }
}
