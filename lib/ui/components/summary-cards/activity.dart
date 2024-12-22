import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/core/network/intervals/data/events.dart';
import 'package:intervals/ui/components/charts/skyline.dart';
import 'package:intervals/ui/components/summary-cards/summary_card.dart';
import 'package:intervals/ui/icons/icon.dart';

class ActivitySummaryCard extends StatelessWidget {
  final Activity activity;

  final Events? event;

  final bool tight;

  void Function()? onTap;

  ActivitySummaryCard({super.key, required this.activity, this.event, this.tight = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      onTap: onTap,
      tight: tight,
      title: Text(activity.name ?? event?.name ?? 'Unknown Workout'),
      subtitle: activity.icuTrainingLoad != null
          ? Text('Load ${activity.icuTrainingLoad.toString()}')
          : null,
      icon: Icon(IconRepository.fromSport(activity.type ?? event?.type ?? null)),
      data: [
        if(activity.movingTime != null)
          Text(activity.movingTime!.display()),
        if(activity.distance != null)
          Text(activity.distance!.display()),
      ],
      leadingData: event == null ? null : Row(
        children: [
          const Icon(Icons.check, color: Colors.green),
          if(activity.compliance != null)
            Text('${activity.compliance!.ceil().toString()}%'),
        ],
      ),
      image: activity.skylineChartBytes == null
          ? null
          : ActivityImage(skylineData: activity.skylineChartData!)
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