import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/athlete.dart';
import 'package:intervals/data/data/goal.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/data/repositories/goal_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/*
 *
 * Index page
 *
 */
class GoalsShowPage extends StatefulWidget {
  final int goalId;

  const GoalsShowPage({super.key, required this.goalId});

  @override
  State<StatefulWidget> createState() => _GoalsShowPageState();
}

class _GoalsShowPageState extends State<GoalsShowPage> {
  Goal? goal;

  GoalProgress? goalProgress;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadGoal();
    });
  }

  Future<void> loadGoal() async {
    var model = GoalModel();
    await model.init();

    Goal _goal = await model.get(widget.goalId);

    setState(() {
      goal = _goal;
      loadGoalProgress();
    });
  }

  Future<void> loadGoalProgress() async {
    if (goal == null) {
      return;
    }

    List<AthleteSummary> summaries =
        await Provider.of<AuthenticatedUserModel>(context, listen: false)
            .getIntervalsClient()!
            .getAthleteSummary(
              start: goal!.start,
              end: goal!.end,
            );

    setState(() {
      goalProgress = GoalProgress.fromSummaries(summaries, goal!);
    });
  }

  @override
  Widget build(BuildContext context) {
    var appBarName = 'Loading goal...';

    if (goal != null) {
      appBarName = goal!.name;
    }

    return Scaffold(
        appBar: AppBar(title: Text(appBarName)),
        body: (goal == null || goalProgress == null)
            ? CircularProgressIndicator()
            : ShowGoal(goal: goal!, goalProgress: goalProgress!));
  }
}

class ShowGoal extends StatelessWidget {
  final Goal goal;

  final GoalProgress goalProgress;

  ShowGoal({super.key, required this.goal, required this.goalProgress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GoalProgressBar(
          goal: goal,
          goalProgress: goalProgress,
        ),
        GoalSummary(goal: goal, goalProgress: goalProgress),
        ListTile(
          title: Text('Required per day'),
          subtitle: Text(goalProgress.goalRequiredPerDay.toStringAsFixed(2) +
              goal.metric.units),
        ),
        ListTile(
          title: Text('Now required per day'),
          subtitle: Text(
              goalProgress.remainingGoalRequiredPerDay.toStringAsFixed(2) +
                  goal.metric.units),
        ),
        ListTile(
          title: Text('Behind by'),
          subtitle: Text(
              '${goalProgress.behindGoalNowBy.toStringAsFixed(2)}${goal.metric.units} (${goalProgress.behindGoalByPercentage.floor().toString()}%)'
          ),
        ),
        GoalProgressGraph(
          goal: goal,
          goalProgress: goalProgress,
        )
      ],
    );
  }
}

class GoalProgressBar extends StatelessWidget {
  final Goal goal;

  final GoalProgress goalProgress;

  GoalProgressBar({super.key, required this.goal, required this.goalProgress});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: goalProgress.percentage / 100,
    );
  }
}

class GoalSummary extends StatelessWidget {
  final Goal goal;

  final GoalProgress goalProgress;

  GoalSummary({super.key, required this.goal, required this.goalProgress});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(goal.name),
      subtitle: Text('Current: ${goalProgress.totalToDateFormatted}'),
      trailing: Text(
        '${goalProgress.percentage.ceil().toString()}%',
        style: TextStyle(
          fontSize: 24.0,
        ),
      ),
    );
  }
}

class GoalProgressGraph extends StatelessWidget {
  final Goal goal;

  final GoalProgress goalProgress;

  const GoalProgressGraph(
      {super.key, required this.goal, required this.goalProgress});

  @override
  Widget build(BuildContext context) {
    double dailyRollingAverage = goalProgress.dailyRollingAverage;

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
                    minX: 0,
                    maxX: 52,
                    minY: 0,
                    maxY: goal.goalValue.toDouble(),
                    gridData: FlGridData(show: false),
                    lineBarsData: [
                      // Actual cumulative values
                      LineChartBarData(
                        color: Colors.blue,
                        spots: goalProgress.weeklyCumulativeValues
                            .where((value) =>
                                value.weekStart.isBefore(DateTime.now()))
                            .map((value) {
                          return FlSpot(
                            // Number of elapsed weeks
                            (value.weekStart.difference(goal.start).inDays / 7)
                                .toDouble(),
                            value.getCumulativeForMetric(goal.metric),
                          );
                        }).toList(),
                        isCurved: true,
                        isStrokeCapRound: true,
                        barWidth: 1,
                        belowBarData: BarAreaData(
                          show: false,
                        ),
                        dotData: const FlDotData(show: false),
                      ),

                      // 42 day rolling average of actual cumulative values
                      LineChartBarData(
                        color: Colors.blue,
                        dashArray: [1,3],
                        spots: List.generate(
                                goalProgress.remainingWeeks, (index) => index)
                            .map((value) {
                          return FlSpot(
                            (value + goalProgress.elapsedWeeks).toDouble(),
                            goalProgress.totalToDate +
                                (dailyRollingAverage * 7 * (value + 1)),
                            // goalProgress.totalToDate +  goalProgress.dailyRollingAverage * () * 7,
                          );
                        }).toList(),
                        isCurved: true,
                        isStrokeCapRound: true,
                        barWidth: 1,
                        belowBarData: BarAreaData(
                          show: false,
                        ),
                        dotData: const FlDotData(show: false),
                      ),

                      // Required cumulative values
                      LineChartBarData(
                        color: Colors.green,
                        spots: List.generate(52, (index) => index).map((value) {
                          return FlSpot(
                            value.toDouble(),
                            goalProgress.goalRequiredPerDay * value * 7,
                          );
                        }).toList(),
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
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            minIncluded: true,
                            maxIncluded: true,
                            reservedSize: 50,
                            showTitles: true,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                // TODO Support by week too!
                                interval: 10,
                                reservedSize: 30,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  // value is the number of weeks into the year
                                  DateTime dateTime = goal.start.add(Duration(days: (value * 7).round()));

                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(DateFormat('MMM d').format(dateTime)),
                                  );
                                },
                                minIncluded: false,
                                maxIncluded: false)))),
              );
            })));
  }
}
