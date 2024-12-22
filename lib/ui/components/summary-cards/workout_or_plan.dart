import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intervals/core/network/intervals/intervals.dart';
import 'package:intervals/core/network/intervals/data/events.dart';
import 'package:intervals/ui/components/summary-cards/activity.dart';
import 'package:intervals/ui/components/summary-cards/strava_card.dart';
import 'package:intervals/ui/components/summary-cards/workout_plan.dart';

class WorkoutOrPlanSummaryCard extends StatelessWidget {
  final WorkoutOrPlan workoutOrPlan;

  final bool tight;

  WorkoutOrPlanSummaryCard({required this.workoutOrPlan, this.tight = false});

  @override
  Widget build(BuildContext context) {
    if (workoutOrPlan.activity?.source == 'STRAVA') {
      return StravaActivitySummaryCard(activity: workoutOrPlan.activity!, onTap: () {
        GoRouter.of(context).push('/activity/${workoutOrPlan.activity!.id}');
      }, tight: tight);
    }

    if (workoutOrPlan.activity != null) {
      return ActivitySummaryCard(activity: workoutOrPlan.activity!, event: workoutOrPlan.event, onTap: () {
        GoRouter.of(context).push('/activity/${workoutOrPlan.activity!.id}');
      }, tight: tight);
    }

    if (workoutOrPlan.event != null) {
      switch (workoutOrPlan.event!.category) {
        case EventCategory.workout:
          return WorkoutPlanSummaryCard(event: workoutOrPlan.event!, onTap: () {
            GoRouter.of(context).push('/event/${workoutOrPlan.event!.id}');
          }, tight: tight);
        default:
          return Text(workoutOrPlan.event!.name ?? 'Unknown Event');
      }
    }


    if (workoutOrPlan.activity?.source == 'STRAVA') {
      return StravaActivitySummaryCard(activity: workoutOrPlan.activity!, tight: true);
    }

    if (workoutOrPlan.activity != null) {
      return ActivitySummaryCard(activity: workoutOrPlan.activity!, event: workoutOrPlan.event, tight: true);
    }

    if (workoutOrPlan.event != null) {
      switch (workoutOrPlan.event!.category) {
        case EventCategory.workout:
          return WorkoutPlanSummaryCard(event: workoutOrPlan.event!, tight: true);
        default:
          return Text(workoutOrPlan.event!.name ?? 'Unknown Event');
      }
    }

    throw Exception('Workout plan doesn\'t have an activity or event');
  }
}