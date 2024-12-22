import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/events.dart';
import 'package:intervals/ui/components/charts/skyline.dart';
import 'package:intervals/ui/components/summary-cards/summary_card.dart';
import 'package:intervals/ui/icons/icon.dart';

class WorkoutPlanSummaryCard extends StatelessWidget {
  final Events event;

  bool tight;

  void Function()? onTap;

  WorkoutPlanSummaryCard(
      {super.key, required this.event, this.tight = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final DateTime latestToStartActivity = DateTime(event.startDate!.year,
        event.startDate!.month, event.startDate!.day, 23, 59, 59);

    final DateTime now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final bool latestToStartIsInFuture =
        event.startDate != null && latestToStartActivity.isAfter(now);

    return SummaryCard(
      onTap: onTap,
      tight: tight,
      title: Text(event.name ?? 'Unknown Workout'),
      subtitle: event.icuTrainingLoad != null
          ? Text('Load ${event.icuTrainingLoad.toString()}')
          : null,
      icon: Icon(IconRepository.fromSport(event.type)),
      leadingData: latestToStartIsInFuture
          ? const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 2.0),
                child: Icon(Icons.calendar_today),
              ),
              Text('Planned'),
            ],
          )
          : const Icon(Icons.close, color: Colors.red),
      data: [
        if (event.movingTime != null) Text(event.movingTime!.display()),
      ],
      image: event.workoutDoc != null
          ? WorkoutDocImage(
              steps: event.workoutDoc!.steps,
              totalSeconds: event.workoutDoc!.duration ?? 0)
          : null,
    );

    return Card(
        child: Column(
      children: [
        ListTile(
          title: Text(event.name ?? 'Unknown Workout'),
          subtitle: Text('Description'),
        ),
      ],
    ));
  }
}
