import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:go_router/go_router.dart';
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/core/network/intervals/data/map.dart';
import 'package:intervals/core/network/intervals/data/streams.dart';
import 'package:intervals/core/network/intervals/data/weather.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as thirdPartyLatLng;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/*
 *
 * Index page
 *
 */
class ActivitiesShowPage extends StatefulWidget {
  final String activityId;

  const ActivitiesShowPage({super.key, required this.activityId});

  @override
  State<StatefulWidget> createState() => _ActivitiesShowPageState();
}

class _ActivitiesShowPageState extends State<ActivitiesShowPage> {
  Activity? activity;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadActivity();
    });
  }

  void loadActivity() {
    Provider.of<AuthenticatedUserModel>(context, listen: false)
        .getIntervalsClient()!
        .loadActivity(widget.activityId)
        .then((loadedActivity) =>
        setState(() {
          activity = loadedActivity;
        }));
    // TODO Error handling
  }

  @override
  Widget build(BuildContext context) {
    var appBarName = 'Loading activity...';

    if (activity != null) {
      appBarName = activity!.name ?? activity!.id ?? 'N/A';
    }

    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
                title: Text(appBarName),
                bottom: const TabBar(
                  dividerColor: Colors.transparent,
                  tabs: <Widget>[
                    Tab(
                      text: 'Summary',
                      icon: Icon(Icons.speed),
                    ),
                    Tab(
                      text: 'Graphs',
                      icon: Icon(Icons.stacked_line_chart),
                    ),
                    Tab(
                      text: 'Intervals',
                      icon: Icon(Icons.bar_chart),
                    ),
                  ],
                ),
                actions: <Widget>[
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          onTap: () {
                            setState(() {
                              activity = null;
                            });
                            loadActivity();
                          },
                          child: ListTile(
                            leading: Icon(
                              Icons.refresh,
                            ),
                            title: Text('Refresh'),
                          ),
                        ),
                        PopupMenuItem<String>(
                          onTap: _launchInBrowser,
                          child: ListTile(
                            leading: Icon(
                              Icons.open_in_browser,
                            ),
                            title: Text('Open in browser'),
                          ),
                        ),
                        if(activity?.pairedEventId != null)
                          ...[
                            PopupMenuItem<String>(
                              onTap: () {
                                if(context.mounted) {
                                  GoRouter.of(context).push('/event/${activity!.pairedEventId!}');
                                }
                              },
                              child: ListTile(
                                leading: Icon(
                                  Icons.calendar_view_week,
                                ),
                                title: Text('Open event'),
                              ),
                            )
                          ],
                      ];
                    },
                  )
                ]),
            body: TabBarView(children: <Widget>[
              activity == null ? CircularProgressIndicator() : ActivitySummaryPage(activity!),
              activity == null ? CircularProgressIndicator() : ActivityGraphsPage(activity!),
              activity == null ? CircularProgressIndicator() : ActivityIntervalsPage(activity!)
            ])));
  }

  Future<void> _launchInBrowser() async {
    final Uri _url =
    Uri.parse('https://intervals.icu/activities/${activity!.id}');

    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}

class ActivitySummaryPage extends StatefulWidget {
  final Activity activity;

  ActivitySummaryPage(this.activity, {super.key});

  @override
  State<ActivitySummaryPage> createState() => _ActivitySummaryPageState();
}

class _ActivitySummaryPageState extends State<ActivitySummaryPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar.secondary(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'Data'),
            Tab(text: 'Map'),
            Tab(text: 'Weather'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              ShowActivityDetails(widget.activity),
              ShowActivityMap(widget.activity),
              ShowWeather(widget.activity),
            ],
          ),
        ),
      ],
    );
  }
}

class ActivityIntervalsPage extends StatefulWidget {
  final Activity activity;

  ActivityIntervalsPage(this.activity, {super.key});

  @override
  State<ActivityIntervalsPage> createState() => _ActivityIntervalsPageState();
}

class _ActivityIntervalsPageState extends State<ActivityIntervalsPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar.secondary(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'All'),
            Tab(text: 'Strava'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Center(child: Text('All')),
              ),
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Center(child: Text('Strava')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActivityGraphsPage extends StatelessWidget {
  final Activity activity;

  ActivityGraphsPage(this.activity, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text('GRAPHS');
  }
}

class ShowActivityDetails extends StatelessWidget {
  final Activity activity;

  ShowActivityDetails(this.activity, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
            child: Text(activity.name ?? 'N/A',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20))),
        Row(children: [
          Text('Load: '),
          Text(activity.icuTrainingLoad.toString())
        ]),
        Row(children: [
          Text('Started At: '),
          activity.startDateLocal == null
              ? Text('N/A')
              : Text(DateFormat('dd/MM/yyyy HH:mm')
              .format(activity.startDateLocal!))
        ]),
        Row(children: [
          Text('Avg Speed: '),
          Text(activity.averageSpeed.toString() ?? 'N/A')
        ]),
        Row(children: [
          Text('Intensity: '),
          Text(activity.icuIntensity?.toString() ?? 'N/A')
        ]),
        Row(children: [Text('Source: '), Text(activity.source ?? 'N/A')]),
        Row(children: [
          Text('Compliance: '),
          Text(activity.compliance?.toString() ?? 'N/A')
        ]),
        Row(children: [
          Text('Max speed: '),
          Text(activity.maxSpeed.toString() ?? 'N/A')
        ]),
        Row(children: [Text('Type: '), Text(activity.type ?? 'N/A')]),
        Row(children: [
          Text('Recording Time: '),
          Text(activity.icuRecordingTime.toString() ?? 'N/A')
        ]),
        Row(children: [
          Text('Elapsed Time: '),
          Text(activity.elapsedTime.toString() ?? 'N/A')
        ]),
        Row(children: [
          Text('Distance: '),
          Text(activity.distance?.display() ?? 'N/A')
        ]),
        Row(children: [
          Text('Moving Time: '),
          Text(activity.movingTime.toString() ?? 'N/A')
        ]),
        Row(children: [
          Text('Total elevation gain: '),
          Text(activity.totalElevationGain.toString() ?? 'N/A')
        ]),
      ],
    );
  }
}

class ShowActivityMap extends StatefulWidget {
  final Activity activity;

  ShowActivityMap(this.activity, {super.key});

  @override
  State<ShowActivityMap> createState() => _ShowActivityMapState();
}

class _ShowActivityMapState extends State<ShowActivityMap> {
  MapData? mapData;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadMapData();
    });
  }

  Future<void> loadMapData() async {
    var newMapData = await Provider.of<AuthenticatedUserModel>(context, listen: false)
        .getIntervalsClient()!
        .getMapData(widget.activity.id);

    if(context.mounted) { // TODO Do this everywhere in async functions!
      setState(() {
        mapData = newMapData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (mapData == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Flexible(
            child: flutterMap.FlutterMap(
              mapController: flutterMap.MapController(),
              options: flutterMap.MapOptions(
                  initialCameraFit: flutterMap.CameraFit.bounds(
                      bounds: flutterMap.LatLngBounds(
                        thirdPartyLatLng.LatLng(
                            mapData!.topLeftBound.lat,
                            mapData!.topLeftBound.lng),
                        thirdPartyLatLng.LatLng(
                            mapData!.bottomRightBound.lat,
                            mapData!.bottomRightBound.lng),
                      ))),
              children: [
                flutterMap.TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.intervals.interals',
                  // Plenty of other options available!
                ),
                flutterMap.PolylineLayer(
                  polylines: [
                    flutterMap.Polyline(
                        points: mapData!.coordinates
                            .map((coordinate) =>
                            thirdPartyLatLng.LatLng(
                                coordinate.lat, coordinate.lng))
                            .toList(),
                        color: Colors.blue,
                        strokeWidth: 4)
                  ],
                )
              ],
            )),
      ],
    );
  }
}

class ShowWeather extends StatefulWidget {
  final Activity activity;

  ShowWeather(this.activity, {super.key});

  @override
  State<ShowWeather> createState() => _ShowWeatherState();
}

class _ShowWeatherState extends State<ShowWeather> {
  Weather? _weather;

  List<StreamEntry>? _streams;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadWeather();
      _loadStreams();
    });
  }

  Future<void> _loadWeather() async {
    var weather =
    await Provider.of<AuthenticatedUserModel>(context, listen: false)
        .getIntervalsClient()!
        .getWeatherSummaryForActivity(widget.activity.id);

    setState(() {
      _weather = weather;
    });
  }

  Future<void> _loadStreams() async {
    var streams = await Provider.of<AuthenticatedUserModel>(
        context, listen: false)
        .getIntervalsClient()!
        .getStreamsForActivity(widget.activity.id, [
      DefaultStreams.wind_deg,
      DefaultStreams.wind_speed,
      DefaultStreams.apparent_wind_deg
    ]);

    setState(() {
      _streams = streams;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_weather == null) {
      return CircularProgressIndicator();
    }

    return
        ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: [
            ListTile(
                title: Text('Weather Summary'),
                subtitle: Text(_weather!.description!)),
            ListTile(
              title: Text('Temperature (recorded)'),
              subtitle: Text(
                  'Min: ${_weather!.minTemp}. Avg: ${_weather!
                      .averageTemp}. Max: ${_weather!.maxTemp}'),
            ),
            ListTile(
              title: Text('Temperature (weather)'),
              subtitle: Text(
                  'Min: ${_weather!.minWeatherTemp}. Avg: ${_weather!
                      .averageWeatherTemp}. Max: ${_weather!.maxWeatherTemp}'),
            ),
            ListTile(
              title: Text('Temperature (feels like)'),
              subtitle: Text(
                  'Min: ${_weather!.minFeelsLike}. Avg: ${_weather!
                      .averageFeelsLike}. Max: ${_weather!.maxFeelsLike}'),
            ),
            ListTile(
              title: Text('Wind Speed'),
              subtitle: Text(
                  'Min: ${_weather!.minWindSpeed}. Avg: ${_weather!
                      .averageWindSpeed}. Max: ${_weather!.maxWindSpeed}'),
            ),
            ListTile(
              title: Text('Wind Gust'),
              subtitle: Text(
                  'Min: ${_weather!.minWindGust}. Avg: ${_weather!
                      .averageWindGust}. Max: ${_weather!.maxWindGust}'),
            ),
            ListTile(
              // TODO Check this is correct with the arrow!
              title: Text('Wind Direction'),
              subtitle: Text('Direction: ${_weather!.prevailingWindDeg}'),
              trailing: RotationTransition(
                turns:
                AlwaysStoppedAnimation(-(_weather!.prevailingWindDeg!) / 360),
                child: Icon(Icons.arrow_upward),
              ),
            ),
            ListTile(
              title: Text('Wind Direction (feels like)'),
              subtitle: Text('Direction: ${_weather!.averageYaw}'),
              trailing: RotationTransition(
                turns: AlwaysStoppedAnimation(-(_weather!.averageYaw!) / 360),
                child: Icon(Icons.arrow_upward),
              ),
            ),
            ListTile(
              title: Text('Conditions'),
              subtitle: Column(children: [
                Text('Rain: ${_weather!.maxRain}mm'),
                Text('Showers: ${_weather!.maxShowers}mm'),
                Text('Snow: ${_weather!.maxSnow}mm'),
                Text('Cloud coverage: ${_weather!.averageClouds}%'),
              ]),
            ),
            _streams == null ? CircularProgressIndicator() : HeadwindMap(_streams!, apparent: true),
            _streams == null ? CircularProgressIndicator() : HeadwindMap(_streams!, apparent: false),
          ],
        );
  }
}


class HeadwindMap extends StatelessWidget {
  List<StreamEntry> streams;

  final bool apparent;

  HeadwindMap(this.streams, {super.key, this.apparent = false});

  @override
  Widget build(BuildContext context) {

    var radarEntries = getDataEntries();
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: RadarChart(
                RadarChartData(
                    radarBorderData: BorderSide(color: Colors.grey),
                    gridBorderData: BorderSide(color: Colors.black),
                    ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
                    tickBorderData: BorderSide(color: Colors.transparent),
                    getTitle: (index, angle) {
                      if(!apparent) {
                        switch(angle) {
                          case 0.0:
                            return RadarChartTitle(text: 'N');
                          case 45.0:
                            return RadarChartTitle(text: 'NE');
                          case 90.0:
                            return RadarChartTitle(text: 'E');
                          case 135.0:
                            return RadarChartTitle(text: 'SE');
                          case 180.0:
                            return RadarChartTitle(text: 'S');
                          case 225.0:
                            return RadarChartTitle(text: 'SW');
                          case 270.0:
                            return RadarChartTitle(text: 'W');
                          case 315.0:
                            return RadarChartTitle(text: 'NW');
                        }
                      }
                      return RadarChartTitle(text: '');
                    },
                    borderData: FlBorderData(show: false),
                    // radarBorderData: const BorderSide(color: Colors.transparent),
                    radarBackgroundColor: Colors.transparent,
                    tickCount: 100,

                    dataSets: [
                      RadarDataSet(
                          dataEntries: apparent ? radarEntries.speed : radarEntries.count,
                          // TODO Here, we are essentially trying to fit three components into a 2d graph.
                            // Those components are angle of the wind (radii of the graph), speed of the wind (current value of the graph), and the count of the wind (the number of times that value has been recorded).
                            // The 'count' of the wind is actually a 'time in this angle' setting.
                            // We have managed to get around this by using just the speed as an average. This won't care if I'm always going north though, I can't get 'amount of time in headwind' from this.
                            // Could maybe do sth with colours? Probably not in this lib though..
                          entryRadius: 0 // No dot at each point
                      ),
                    ]
                ),
            ),
      ),
    );
    return Text(streams.length.toString());
  }

  ({List<RadarEntry> count, List<RadarEntry> speed}) getDataEntries() {
    int angleBinGroupSize = 23; // MUST BE EVEN
    // We would like an entry for every nth [angleBinSize] degree, from 0 to 359


    Map<int, WindInformationPoint> entries = {};

    for(var streamEntry in streams) {
      int? degrees = apparent ? streamEntry.apparentWindDegrees : streamEntry.windDegrees;

      if(degrees == null) {
        continue;
      }

      WindInformationPoint entry = entries[degrees] ?? WindInformationPoint();

      double? windSpeed = streamEntry.windSpeed;

      if(windSpeed != null) {
        entry.appendSpeed(windSpeed);
      }

      entries[degrees] = entry;
    }

    List<RadarEntry> countRadarEntries = [];
    List<RadarEntry> speedRadarEntries = [];
    int numberOfSegments = (360 / angleBinGroupSize).ceil(); // Max is 360. 180 for 2.

    for(var segmentNumber = 0; segmentNumber < numberOfSegments; segmentNumber++) {
      // segment number is 0. On groups of 4, should use 358, 359, 0, 1
      // segment number of 1. On groups of 4, should use 2, 3, 4, 5
      // segment number of [numberOfSegments - 1]. On groups of 4, should use 356, 357, 358, 359

      // Segment number is 0. On groups of 3, should use 358, 359, 0
      // Segment number is 1. On groups of 3, should use 1, 2, 3
      // Segment number is 2. On groups of 3, should use 4, 5, 6

      List<double> windSpeedEntries = [];
      int countEntries = 0;
      int segmentStartsWith = (segmentNumber * angleBinGroupSize) - (angleBinGroupSize ~/ 2);
      int segmentFinishesWith = (segmentStartsWith + angleBinGroupSize) - (angleBinGroupSize ~/ 2);

      for(var degree = segmentStartsWith; degree <= segmentFinishesWith; degree++) {
        if(degree < 0) {
          degree += 360;
        }
        windSpeedEntries.addAll(entries[degree]?.windSpeeds ?? []);
        countEntries += entries[degree]?.count ?? 0;
      }

      double averageWindSpeed = windSpeedEntries.isEmpty ? 0 : (windSpeedEntries.reduce((a, b) => a + b) / windSpeedEntries.length);

      countRadarEntries.add(RadarEntry(value: countEntries.toDouble()));
      speedRadarEntries.add(RadarEntry(value: averageWindSpeed));

    }

    return (count: countRadarEntries, speed: speedRadarEntries);

  }
}

class WindInformationPoint {
  int count = 0;

  List<double> windSpeeds = [];

  void appendSpeed(double windSpeed) {
    count++;
    windSpeeds.add(windSpeed);
  }

}