import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/core/network/intervals/data/map.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart' as thirdPartyLatLng;

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

  int _selectedIndex = 0;

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
        .then((loadedActivity) => setState(() {
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

    Widget? body = null;

    if (activity != null) {
      switch (_selectedIndex) {
        case 0:
          body = ShowActivityDetails(activity!);
          break;
        case 1:
          body = ShowActivityMap(activity!);
          break;
        case 2:
          body = ShowActivityHeartRate(activity!);
          break;
        case 3:
          body = ShowActivityPower(activity!);
          break;
        default:
          body = Text('N/A');
          break;
      }
    }

    return Scaffold(
        bottomNavigationBar: activity == null
            ? null
            : BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.details),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map),
                    label: 'Map',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.monitor_heart),
                    label: 'Heartrate',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.electric_bolt),
                    label: 'Power',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.amber[800],
                unselectedItemColor: Colors.blue,
                onTap: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
        appBar: AppBar(title: Text(appBarName), actions: <Widget>[
          // IconButton(
          //   icon: const Icon(
          //     Icons.refresh,
          //     color: Colors.black,
          //   ),
          //   onPressed: () {
          //
          //     // do something
          //   },
          // ),
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
                )
              ];
            },
          )
        ]),
        body: body);
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
          Text(activity.icuIntensity!.toString())
        ]),
        Row(children: [Text('Source: '), Text(activity.source!)]),
        Row(children: [
          Text('Compliance: '),
          Text(activity.compliance!.toString())
        ]),
        Row(children: [
          Text('Max speed: '),
          Text(activity.maxSpeed!.toString())
        ]),
        Row(children: [Text('Type: '), Text(activity.type!)]),
        Row(children: [
          Text('Recording Time: '),
          Text(activity.icuRecordingTime!.toString())
        ]),
        Row(children: [
          Text('Elapsed Time: '),
          Text(activity.elapsedTime!.toString())
        ]),
        Row(children: [
          Text('Distance: '),
          Text(activity.distance!.toString())
        ]),
        Row(children: [
          Text('Moving Time: '),
          Text(activity.movingTime!.toString())
        ]),
        Row(children: [
          Text('Total elevation gain: '),
          Text(activity.totalElevationGain!.toString())
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

  void loadMapData() {
    Provider.of<AuthenticatedUserModel>(context, listen: false)
        .getIntervalsClient()!
        .getMapData(widget.activity.id)
        .then((newMapData) => setState(() {
              mapData = newMapData;
            }));
    // TODO Error handling
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
                mapData!.topLeftBound.lat, mapData!.topLeftBound.lng),
            thirdPartyLatLng.LatLng(
                mapData!.bottomRightBound.lat, mapData!.bottomRightBound.lng),
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
                        .map((coordinate) => thirdPartyLatLng.LatLng(
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

class ShowActivityHeartRate extends StatelessWidget {
  final Activity activity;

  ShowActivityHeartRate(this.activity, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
            child: Text(activity.name ?? 'N/A',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20))),
        Text('heart'),
      ],
    );
  }
}

class ShowActivityPower extends StatelessWidget {
  final Activity activity;

  ShowActivityPower(this.activity, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
            child: Text(activity.name ?? 'N/A',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20))),
        Text('Power'),
      ],
    );
  }
}
