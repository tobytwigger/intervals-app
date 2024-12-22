import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/ui/components/summary-cards/summary_card.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class StravaActivitySummaryCard extends StatelessWidget {
  final Activity activity;

  bool tight;

  void Function()? onTap;

  StravaActivitySummaryCard({super.key, required this.activity, this.tight = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      onTap: onTap,
        tight: tight,
        title: Text('Strava Workout'),
        icon: Icon(Icons.broken_image_outlined),
        data: [
          if(activity.startDateLocal != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Icon(Icons.watch_later_outlined),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Text(DateFormat('Hm').format(activity.startDateLocal!)),
                ),
              ],
            ),
        ],
        actions: [
          TextButton(
            onPressed: () async {
              final Uri _url =
              Uri.parse('https://strava.com/activities/${activity!.id}');

              if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
                throw Exception('Could not launch $_url');
              }
            },
            child: Text('View on Strava'),
          ),
        ],
        // image: activity.skylineChartBytes == null
        //     ? null
        //     : SkylineImage(skylineData: activity.skylineChartData!)
      // image: activity.workoutDoc != null
      //     ? WorkoutDocImage(steps: activity.workoutDoc!.steps, totalSeconds: activity.workoutDoc!.duration ?? 0)
      //     : null,
    );

    return Card(
        child: Column(
          children: [
            ListTile(
              title: Text(activity.name ?? 'Unknown Workout'),
              subtitle: Text('Description'),
            ),
          ],
        )
    );
  }

}