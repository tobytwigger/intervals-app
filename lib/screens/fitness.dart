import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/wellness.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/ui/forms/date_range_selector.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FitnessPage extends StatefulWidget {
  FitnessPage({super.key});

  @override
  State<FitnessPage> createState() => _FitnessPageState();
}

class _FitnessPageState extends State<FitnessPage> {
  List<Wellness>? wellnessData;

  Wellness? today;

  DateTime oldest = DateTime.now().subtract(Duration(days: 100));

  DateTime newest = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadWellnessData();
    });
  }

  void loadWellnessData() {
    Provider.of<AuthenticatedUserModel>(context, listen: false)
        .getIntervalsClient()!
        .getWellnessData(
          newest: newest,
          oldest: oldest,
        )
        .then((loadedWellnessData) => setState(() {
              wellnessData = loadedWellnessData;
            }));

    Provider.of<AuthenticatedUserModel>(context, listen: false)
        .getIntervalsClient()!
        .getCurrentWellnessData()
        .then((loadedWellnessData) => setState(() {
              today = loadedWellnessData;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness')),
      drawer: NavDrawer(),
      body: Column(
        children: [
          ChooseDateRange(
            oldest: oldest,
            newest: newest,
            updateOldestAndNewestDates: (o, n) {
              setState(() {
                oldest = o;
                newest = n;
                loadWellnessData();
              });
            },
          ),
          ...today == null
              ? [CircularProgressIndicator()]
              : [WellnessSummary(today: today!)],
          FitnessGraph(
              oldest: oldest, newest: newest, wellnessData: wellnessData),
        ],
      ),
    );
  }
}

class WellnessSummary extends StatelessWidget {
  final Wellness today;

  WellnessSummary({super.key, required this.today});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Fitness: ${today.ctl}'),
        Text('Fatigue: ${today.atl}'),
      ],
    );
  }
}

class FitnessGraph extends StatelessWidget {
  final DateTime oldest;

  final DateTime newest;

  final List<Wellness>? wellnessData;

  FitnessGraph(
      {super.key,
      required this.oldest,
      required this.newest,
      required this.wellnessData});

  @override
  Widget build(BuildContext context) {
    if (wellnessData == null) {
      return Center(child: const CircularProgressIndicator());
    }

    FitnessGraphDataCalculator fitnessGraphData = FitnessGraphDataCalculator(
        wellnessData: wellnessData!, oldest: oldest, newest: newest);

    return Padding(
        padding: const EdgeInsets.only(
          left: 12,
          bottom: 12,
          right: 20,
          top: 20,
        ),
        child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(builder: (context, constraints) {
              return LineChart(
                LineChartData(
                    minY: fitnessGraphData.minY,
                    maxY: fitnessGraphData.maxY,
                    gridData: FlGridData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        color: Colors.blue,
                        spots: fitnessGraphData.fitnessSpots,
                        isCurved: true,
                        isStrokeCapRound: true,
                        barWidth: 1,
                        belowBarData: BarAreaData(
                          show: false,
                        ),
                        dotData: const FlDotData(show: false),
                      ),
                      LineChartBarData(
                        color: Colors.red,
                        spots: fitnessGraphData.fatigueSpots,
                        isCurved: true,
                        isStrokeCapRound: true,
                        barWidth: 1,
                        belowBarData: BarAreaData(
                          show: false,
                        ),
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            minIncluded: true,
                            maxIncluded: true,
                            reservedSize: 34,
                            interval: 10,
                            showTitles: true,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                interval: fitnessGraphData.bottomAxisInterval,
                                reservedSize: 30,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  // value is the number of milliseconds since the epoch
                                  DateTime dateTime =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          value.ceil());

                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                        DateFormat('MMM d').format(dateTime)),
                                  );
                                },
                                minIncluded: false,
                                maxIncluded: false)))),
              );
            })));
  }
}

class FitnessGraphDataCalculator {
  final List<Wellness> wellnessData;

  final DateTime oldest;

  final DateTime newest;

  double get minY {
    return 0.0;
  }

  double get maxY {
    // Find the highest fitness OR fatigue value
    double highestValue = 0.0;

    for (var wellness in wellnessData) {
      double highest = wellness.atl ?? wellness.ctl ?? 0.0;
      if ((wellness.ctl ?? 0.0) > highest) {
        highest = wellness.ctl ?? 0.0;
      }

      if (highest > highestValue) {
        highestValue = highest;
      }
    }

    // If the highest value is 0.0, return 10.0
    if (highestValue == 0.0) {
      return 10.0;
    }

    // Else, return the highest value rounded up to the nearest 10
    return (highestValue / 10.0).ceil() * 10.0;
  }

  List<FlSpot> get fitnessSpots {
    return wellnessData
        .where((wellness) => wellness.ctl != null)
        .map((wellness) => FlSpot(
            wellness.date.millisecondsSinceEpoch.toDouble(), wellness.ctl!))
        .toList();
  }

  List<FlSpot> get fatigueSpots {
    return wellnessData
        .where((wellness) => wellness.atl != null)
        .map((wellness) => FlSpot(
            wellness.date.millisecondsSinceEpoch.toDouble(), wellness.atl!))
        .toList();
  }

  Duration get durationOfGraph {
    return newest.difference(oldest);
  }

  double get bottomAxisInterval {
    // We know the number of milliseconds since the epoch. We want to show 7 axis entries.
    // Let's get the interval between the oldest and the newest
    Duration totalAxisDuration = durationOfGraph;

    // Now we divide this by 7 to get the duration of each of the elements
    Duration interval =
        Duration(milliseconds: (totalAxisDuration.inMilliseconds / 5).ceil());

    // Now we return the interval in milliseconds, which is what the graph uses
    return interval.inMilliseconds.toDouble();
  }

  FitnessGraphDataCalculator(
      {required this.wellnessData, required this.oldest, required this.newest});
}
