import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/athlete.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/ui/forms/date_range_selector.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';
import 'package:provider/provider.dart';

class TotalsPage extends StatefulWidget {
  const TotalsPage({super.key});

  @override
  State<TotalsPage> createState() => _TotalsPageState();
}

class _TotalsPageState extends State<TotalsPage> {
  DateTime startDate = DateTime(DateTime.now().year, 1, 1);

  DateTime endDate = DateTime.now();

  List<AthleteSummary> athleteSummaries = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _getAthleteSummaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const NavDrawer(),
        appBar: AppBar(
          title: const Text('Totals'),
        ),
        body: Column(
          children: [
            if (athleteSummaries.isEmpty) ...<Widget>[
              Center(child: const CircularProgressIndicator())
            ],
            if (athleteSummaries.isNotEmpty) ...[
              ChooseDateRange(
                oldest: startDate,
                newest: endDate,
                updateOldestAndNewestDates:
                    (DateTime newStartDate, DateTime newEndDate) {
                  setState(() {
                    startDate = newStartDate;
                    endDate = newEndDate;
                  });
                },
              ),
              ShowStats(
                athleteSummaries: athleteSummaries,
              ),
            ]
          ],
        ));
  }

  Future<void> _getAthleteSummaries() async {
    List<AthleteSummary> athleteSummaries =
        await Provider.of<AuthenticatedUserModel>(context, listen: false)
            .getIntervalsClient()!
            .getAthleteSummary(
              start: startDate,
              end: endDate,
            );

    setState(() {
      this.athleteSummaries = athleteSummaries;
    });
  }
}

class ShowStats extends StatelessWidget {
  final List<AthleteSummary> athleteSummaries;

  const ShowStats({super.key, required this.athleteSummaries});

  @override
  Widget build(BuildContext context) {
    TotalsCalculator totals = TotalsCalculator(athleteSummaries);

    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: [
        ListTile(
          title: const Text('Total distance'),
          subtitle: Column(
            children: [
              Text('${(totals.totalDistance / 1000).toStringAsFixed(2)}km'),
              ...totals.sportSummaries.entries
                  .map((e) => Text(
                      '${e.key}: ${((e.value.distance ?? 0) / 1000).toStringAsFixed(2)}km')),
            ],
          )
              ,
        ),
        ListTile(
            title: const Text('Total moving time'),
            subtitle: Text(Duration(seconds: totals.totalTime).pretty(
              tersity: DurationTersity.minute,
              upperTersity: DurationTersity.hour,
              abbreviated: true,
            ))),
        ListTile(
          title: const Text('Total training load'),
          subtitle: Text(totals.totalTrainingLoad.toString()),
        ),
        ListTile(
          title: const Text('Total calories'),
          subtitle: Text(totals.totalCalories.toString()),
        ),
        ListTile(
          title: const Text('Total elevation gain'),
          subtitle: Text('${totals.totalElevationGain.ceil().toString()}m'),
        ),
        ListTile(
          title: const Text('Power'),
          subtitle: Column(
            children: [
              Text(
                  'Time in Z1: ${totals.timeInZone(PowerZone.z1).pretty(upperTersity: DurationTersity.hour)}'),
              Text(
                  'Time in Z2: ${totals.timeInZone(PowerZone.z2).pretty(upperTersity: DurationTersity.hour)}'),
              Text(
                  'Time in Z3: ${totals.timeInZone(PowerZone.z3).pretty(upperTersity: DurationTersity.hour)}'),
              Text(
                  'Time in Z4: ${totals.timeInZone(PowerZone.z4).pretty(upperTersity: DurationTersity.hour)}'),
              Text(
                  'Time in Z5: ${totals.timeInZone(PowerZone.z5).pretty(upperTersity: DurationTersity.hour)}'),
              Text(
                  'Time in Z6: ${totals.timeInZone(PowerZone.z6).pretty(upperTersity: DurationTersity.hour)}'),
              Text(
                  'Time in Z7: ${totals.timeInZone(PowerZone.z7).pretty(upperTersity: DurationTersity.hour)}'),
              Text(
                  'Time in SS: ${totals.timeInZone(PowerZone.ss).pretty(upperTersity: DurationTersity.hour)}'),
            ],
          ),
        ),
      ],
    );
  }
}
