import 'package:duration/duration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/athlete.dart';

class Goal {
  final int? id;

  final GoalDuration duration;

  final GoalMetric metric;

  final DateTime start;

  final int goalValue;

  Goal(
      {this.id,
      required this.duration,
      required this.metric,
      required this.start,
      required this.goalValue});

  String get units => metric.units;

  String get name => '${goalValue}${units} per ${duration.name}';

  DateTime get end {
    // Start at the start date. Then add the duration.
    switch (duration) {
      case GoalDuration.year:
        return DateTime(
          start.year + 1,
          start.month,
          start.day
        );
      case GoalDuration.month:
        return DateTime(
            start.year,
            start.month + 1,
            start.day
        );
      case GoalDuration.week:
        return DateTime(
          start.year,
          start.month,
          start.day + 7
        );
    }
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'duration': duration.name,
      'metric': metric.name,
      'start': start.toIso8601String(),
      'value': goalValue,
    };
  }

  @override
  String toString() {
    return 'Goal{id: $id, duration: ${duration.name}, metric: ${metric.name}, value: $goalValue, start at: ${start.toIso8601String()}}';
  }
}

enum GoalMetric {
  distance,
  time,
  trainingLoad;

  String get units {
    switch (this) {
      case GoalMetric.distance:
        return 'km';
        break;
      case GoalMetric.time:
        return 'h';
        break;
      case GoalMetric.trainingLoad:
        return 'TSS';
        break;
    }
  }

  String get label  {
    switch (this) {
      case GoalMetric.distance:
        return 'Distance';
        break;
      case GoalMetric.time:
        return 'Moving Time';
        break;
      case GoalMetric.trainingLoad:
        return 'TSS Score';
        break;
    }
  }

  IconData get icon  {
    switch (this) {
      case GoalMetric.distance:
        return Icons.horizontal_rule;
        break;
      case GoalMetric.time:
        return Icons.timer;
        break;
      case GoalMetric.trainingLoad:
        return Icons.electric_bolt;
        break;
    }
  }
}

enum GoalDuration {
  year, month, week;

  String get label  {
    switch (this) {
      case GoalDuration.year:
        return 'year';
        break;
      case GoalDuration.month:
        return 'month';
        break;
      case GoalDuration.week:
        return 'week';
        break;
    }
  }

  IconData get icon  {
    switch (this) {
      case GoalDuration.year:
        return Icons.calendar_view_month;
        break;
      case GoalDuration.month:
        return Icons.calendar_month;
        break;
      case GoalDuration.week:
        return Icons.calendar_view_week;
        break;
    }
  }
}

class WeeklyProgress {
  final DateTime weekStart;

  final double cumulativeTotalDistance;

  final double cumulativeTotalTime;

  final double cumulativeTotalTrainingLoad;

  final double totalDistance;

  final double totalMovingTime;

  final double totalTrainingLoad;

  WeeklyProgress({
    required this.weekStart,
    required this.totalDistance,
    required this.totalMovingTime,
    required this.totalTrainingLoad,
    required this.cumulativeTotalDistance,
    required this.cumulativeTotalTime,
    required this.cumulativeTotalTrainingLoad
  });

  double getForMetric(GoalMetric metric) {
    if(metric == GoalMetric.distance) {
      return totalDistance;
    } else if(metric == GoalMetric.time) {
      return totalMovingTime;
    } else if(metric == GoalMetric.trainingLoad) {
      return totalTrainingLoad;
    }

    return 0.0;
  }

  double getCumulativeForMetric(GoalMetric metric) {
    if(metric == GoalMetric.distance) {
      return cumulativeTotalDistance;
    } else if(metric == GoalMetric.time) {
      return cumulativeTotalTime;
    } else if(metric == GoalMetric.trainingLoad) {
      return cumulativeTotalTrainingLoad;
    }

    return 0.0;
  }
}

class GoalProgress {
  final Goal goal;

  final double totalDistance;

  final double totalMovingTime;

  final double totalTrainingLoad;

  final List<WeeklyProgress> weeklyCumulativeValues;

  double get totalToDate {
    double aim = 0;
    if (goal.metric == GoalMetric.distance) {
      aim = totalDistance;
    } else if (goal.metric == GoalMetric.time) {
      aim = totalMovingTime / 3600; // Convert to hours
    } else if (goal.metric == GoalMetric.trainingLoad) {
      aim = totalTrainingLoad;
    }

    return aim;
  }

  String get totalToDateFormatted {
    if (goal.metric == GoalMetric.distance) {
      return '${totalDistance.ceil().toString()}${goal.metric.units}';
    } else if (goal.metric == GoalMetric.time) {
      return Duration(seconds: totalMovingTime.ceil()).pretty(upperTersity: DurationTersity.hour);
    } else if (goal.metric == GoalMetric.trainingLoad) {
      return '${totalTrainingLoad.ceil().toString()}${goal.metric.units}';
    }

    return '';
  }

  double get goalRequiredPerDay {
    return goal.goalValue / ((goal.end.difference(goal.start)).inDays);
  }

  double get remainingGoalRequiredPerDay {
    double remainingGoal = goal.goalValue - totalToDate;
    return remainingGoal / ((goal.end.difference(DateTime.now())).inDays);
  }

  double get percentage {
    return (totalToDate / goal.goalValue) * 100;
  }

  GoalProgress({
    required this.goal,
    required this.totalDistance,
    required this.totalMovingTime,
    required this.totalTrainingLoad,
    required this.weeklyCumulativeValues
  });

  factory GoalProgress.fromSummaries(List<AthleteSummary> summaries, Goal goal) {
    double totalDistance = 0.0;
    double totalMovingTime = 0.0;
    double totalTrainingLoad = 0.0;
    List<WeeklyProgress> weeklyCumulativeValues = [];

    for(var summary in summaries) {
      totalDistance += summary.distance ?? 0;
      totalMovingTime += summary.movingTime ?? 0;
      totalTrainingLoad += summary.trainingLoad ?? 0;
      weeklyCumulativeValues.add(
          WeeklyProgress(
              weekStart: summary.startDate,
              totalDistance: (summary.distance ?? 0) / 1000,
              totalMovingTime: (summary.movingTime ?? 0) / 3600,
              totalTrainingLoad: (summary.trainingLoad ?? 0).toDouble(),
              cumulativeTotalDistance: totalDistance / 1000,
              cumulativeTotalTime: totalMovingTime,
              cumulativeTotalTrainingLoad: totalTrainingLoad
          )
      );
    }

    return GoalProgress(
        goal: goal,
        totalDistance: totalDistance / 1000,
        totalMovingTime: totalMovingTime,
        totalTrainingLoad: totalTrainingLoad,
        weeklyCumulativeValues: weeklyCumulativeValues
    );
  }

  int get remainingWeeks {
    return (goal.end.difference(DateTime.now()).inDays / 7).floor();
  }

  int get elapsedWeeks {
    return (DateTime.now().difference(goal.start).inDays / 7).ceil();
  }

  /// Gets the average of the last 42 days
  ///
  /// This function uses weeklyCumulativeValues to calculate the average of the last 42 days.
  /// It will take the last 7 entries, or as many as it can, determine the 'aim' based on the
  /// GoalMetric, and then return the average of these values divided by 7.
  double get dailyRollingAverage {
    int startAtIndex = weeklyCumulativeValues.length - 7;
    if(startAtIndex < 0) {
      startAtIndex = 0;
    }
    List<WeeklyProgress> lastSeven = weeklyCumulativeValues.sublist(startAtIndex);

    double aim = 0.0;
    for(var value in lastSeven) {
      aim += value.getForMetric(goal.metric);
    }

    // This is now the rolling weekly average
    aim = aim / weeklyCumulativeValues.length;

    return aim / 7; // Divide by 7 to get the daily average
  }

  /// Determines how far behind the goal the athlete is based on the current date
  double get behindGoalNowBy {
    // How far should we have gone by this point?
    int elapsedDays = DateTime.now().difference(goal.start).inDays;
    double estimatedCompletion = elapsedDays * goalRequiredPerDay;

    return estimatedCompletion - totalToDate;
  }

  get behindGoalByPercentage => (behindGoalNowBy / goal.goalValue) * 100;

}