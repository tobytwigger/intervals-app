import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/events.dart' as intervals;
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/locale/units.dart';
import 'package:intervals/ui/colours.dart';
import 'package:intervals/ui/components/charts/skyline.dart';
import 'package:intervals/ui/components/stat_display.dart';
import 'package:intervals/ui/icons/icon.dart';
import 'package:provider/provider.dart';

class EventShowPage extends StatefulWidget {
  final int eventId;

  const EventShowPage({super.key, required this.eventId});

  @override
  State<EventShowPage> createState() => _EventShowPageState();
}

class _EventShowPageState extends State<EventShowPage> {
  intervals.Events? _event;

  late PageController _pageViewController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageViewController = PageController();

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
            title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(IconRepository.fromSport(_event?.type)),
            ),
            Text(_event == null ? 'Loading...' : _event!.name ?? 'Event'),
          ],
        )),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              print('Jumping to page $index');
              _pageViewController.jumpToPage(index);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.text_fields),
                label: 'Description',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Workout',
              ),
            ]),
        body: _event == null
            ? CircularProgressIndicator()
            : RefreshIndicator(
                onRefresh: () async {
                  await loadEventData();
                },
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              VerticalStatsWidgetEntry(
                                label: 'Distance',
                                value: _event!.distance?.toString() ?? 'N/A',
                              ),
                              VerticalStatsWidgetEntry(
                                label: 'Duration',
                                value: _event!.movingTime?.display() ?? 'N/A',
                              ),
                              VerticalStatsWidgetEntry(
                                  label: 'Load',
                                  value: _event!.icuTrainingLoad?.toString() ??
                                      'N/A'),
                              VerticalStatsWidgetEntry(
                                  label: 'Intensity',
                                  value:
                                      _event!.icuIntensity?.ceil().toString() ??
                                          'N/A'),
                            ]),
                      ),
                      Expanded(
                        child: PageView.builder(
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            itemCount: 2,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return DescriptionPage(event: _event!);
                              } else if (index == 1) {
                                return WorkoutDocPage(event: _event!);
                              }
                              return Text('Unknown page');
                            }),
                      )
                    ])));
  }
}

class DescriptionPage extends StatelessWidget {
  final intervals.Events event;

  DescriptionPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
            child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HorizontalStatsWidgetEntry(
                    label: 'Avg Watts',
                    value:
                        '${event!.workoutDoc?.averageWatts?.toString() ?? 'N/A'}',
                  ),
                  HorizontalStatsWidgetEntry(
                      label: 'Normalised Power',
                      value:
                          '${event!.workoutDoc?.normalizedPower?.toString() ?? 'N/A'}'),
                  HorizontalStatsWidgetEntry(
                      label: 'Polarization Index',
                      value:
                          '${event!.workoutDoc?.polarizationIndex?.toString() ?? 'N/A'}'),
                  HorizontalStatsWidgetEntry(
                      label: 'Variability Index',
                      value:
                          '${event!.workoutDoc?.variabilityIndex?.toStringAsFixed(2) ?? 'N/A'}'),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(
                  children: event!.workoutDoc?.zoneTimes
                          .map((zoneTime) => Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ZoneBar(
                                    zone: zoneTime.id,
                                    duration:
                                        Time.fromSeconds(zoneTime.secs ?? 0),
                                    colour: HexColor.fromHex(
                                        zoneTime.color ?? '#000000'),
                                    percentage: zoneTime.secs! /
                                        event!.movingTime!.duration.inSeconds
                                            .toDouble(),
                                  ),
                                ],
                              ))
                          .toList() ??
                      []),
            ),
          ],
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(event.description ?? 'No description')),
      ],
    )));
  }
}

class WorkoutDocPage extends StatelessWidget {
  final intervals.Events event;

  WorkoutDocPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    if (event.workoutDoc == null) {
      return Text('No workout doc');
    }

    return SizedBox(
      height: 400,
      child: WorkoutDocImage(
        totalSeconds: event.workoutDoc?.duration ?? 0,
        steps: event.workoutDoc?.steps ?? [],
      ),
    );
  }
}

class ZoneBar extends StatelessWidget {
  final String zone;
  final Time duration;
  final Color colour;
  final double percentage;

  ZoneBar(
      {super.key,
      required this.zone,
      required this.duration,
      required this.colour,
      required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 1.0,
      ),
      child: Row(
        children: [
          Text(zone),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: SizedBox(
              width: 100,
              child: Row(
                children: [
                  Container(
                    height: 20,
                    width: 100 * percentage,
                    color: colour,
                  ),
                  Container(
                    height: 20,
                    width: 100 * (1 - percentage),
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ),
          // Container(
          //   height: 20,
          //   width: 100,
          //   color: watts > maxWatts ? Colors.red : Colors.green,
          //   child: Text('$watts'),
          // ),
          Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(duration.display())),
        ],
      ),
    );
  }
}
