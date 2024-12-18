import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intervals/core/network/intervals/data/athlete.dart';
import 'package:intervals/core/network/intervals/intervals.dart';
import 'package:intervals/data/data/goal.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/data/repositories/goal_model.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  int _dummy = 0; // Increment this to update the future

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      drawer: const NavDrawer(),
      body: FutureBuilder(
          future: _loadGoalsFuture(),
          builder: (BuildContext context, AsyncSnapshot<List<Goal>> snapshot) {
            if (snapshot.hasError) {
              return Text(
                  '${snapshot.error.toString()} ${snapshot.stackTrace}');
            }
            if (snapshot.data == null) {
              return const Text('No goals could be loaded');
            }
            return ListGoals(
              goals: snapshot.data!,
              onDelete: (goal) async {
                var model = GoalModel();
                await model.init();

                await model.delete(goal.id);

                setState(() {
                  _dummy++;
                });
              },
            );
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newGoalDialogBuilder(context),
        label: const Text('New Goal'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<List<Goal>> _loadGoalsFuture() async {
    var model = GoalModel();
    await model.init();

    return await model.goals();
  }

  Future<void> _newGoalDialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return NewGoalForm(onComplete: () {
          setState(() {
            _dummy++;
          });
        });
      },
    );
  }
}

class ListGoals extends StatelessWidget {
  final List<Goal> goals;

  final void Function(Goal goal)? onDelete;

  const ListGoals({super.key, required this.goals, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, int index) {
        var goal = goals[index];

        return GoalTile(goal: goal, onDelete: onDelete);
      },
      itemCount: goals.length,
    );
  }
}

class GoalTile extends StatelessWidget {
  final Goal goal;

  final void Function(Goal goal)? onDelete;

  const GoalTile({super.key, required this.goal, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        background: Container(color: Colors.red),
        onDismissed: (DismissDirection direction) {
          if (onDelete != null) {
            onDelete!(goal);
          }
        },
        key: ValueKey<int>(goal.id!),
        // TODO Get error here,A dismissed Dismissible widget is still part of the tree
        child: ListTile(
          onTap: () {
            GoRouter.of(context).go('/goals/${goal.id}');
          },
          leading: FutureBuilder(
            future: _buildGoalProgress(Provider.of<AuthenticatedUserModel>(context, listen: false).getIntervalsClient()!),
            builder: (context, AsyncSnapshot<GoalProgress> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              Color color = Colors.green;
              double behindGoalBy = snapshot.data!.behindGoalNowBy;
              if(behindGoalBy > 0) {
                // If more than 10% of the total goal behind the goal, red. Otherwise, orange
                if(snapshot.data!.behindGoalByPercentage > 10) {
                  color = Colors.red;
                } else {
                  color = Colors.orange;
                }
              }
              return CircularProgressIndicator(
                  value: snapshot.data!.percentage / 100,
                  color: color
              );
            },
          ),
          title: Text(goal.name),
        ));
  }

  Future<GoalProgress> _buildGoalProgress(Intervals intervals) async {
    List<AthleteSummary> summaries =
    await intervals.getAthleteSummary(
      start: goal.start,
      end: goal.end,
    );

    return GoalProgress.fromSummaries(summaries, goal);
  }
}

enum GoalStartAtSelection {
  every, current, next;

  String get label {
    switch(this) {
      case GoalStartAtSelection.every:
        return 'every';
      case GoalStartAtSelection.current:
        return 'the current';
      case GoalStartAtSelection.next:
        return 'the next';
    }
  }

  IconData get icon {
    switch(this) {
      case GoalStartAtSelection.every:
        return Icons.repeat;
      case GoalStartAtSelection.current:
        return Icons.today;
      case GoalStartAtSelection.next:
        return Icons.arrow_forward;
    }
  }
}

class NewGoalForm extends StatefulWidget {
  final void Function()? onComplete;

  const NewGoalForm({super.key, this.onComplete});

  @override
  State<NewGoalForm> createState() => _NewGoalFormState();
}

class _NewGoalFormState extends State<NewGoalForm> {
  final _formKey = GlobalKey<FormState>();

  final valueController = TextEditingController();

  GoalDuration duration = GoalDuration.year;

  GoalMetric metric = GoalMetric.distance;

  GoalStartAtSelection startAtSelection = GoalStartAtSelection.current;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      content: Form(
          key: _formKey,
          child: Column(children: <Widget>[
            const Text(
              'New Goal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('I am aiming to get a')),

            DropdownButtonFormField(
              value: metric,
              onSaved: (value) => setState(() {
                metric = value ?? GoalMetric.distance;
              }),
              onChanged: (value) => setState(() {
                metric = value ?? GoalMetric.distance;
              }),
              items: <DropdownMenuItem<GoalMetric>>[
                DropdownMenuItem(
                    child: Row(children: [
                      Icon(GoalMetric.distance.icon),
                      Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(GoalMetric.distance.label))
                    ]),
                    value: GoalMetric.distance),
                DropdownMenuItem(
                    child: Row(children: [
                      Icon(GoalMetric.time.icon),
                      Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(GoalMetric.time.label))
                    ]),
                    value: GoalMetric.time),
                DropdownMenuItem(
                    child: Row(children: [
                      Icon(GoalMetric.trainingLoad.icon),
                      Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(GoalMetric.trainingLoad.label))
                    ]),
                    value: GoalMetric.trainingLoad),
              ],
              validator: (value) {
                if (value == null) {
                  return 'Please choose a value';
                }
                return null;
              },
            ),

            const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('of')),

            TextFormField(
              decoration: InputDecoration(
                  label: Text('${metric.label} (${metric.units})')),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
              controller: valueController,
              keyboardType: const TextInputType.numberWithOptions(),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly // Force only numbers
              ],
            ),

            const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('over')), // TODO Expand this to more options

            DropdownButtonFormField(
              value: startAtSelection,
              onSaved: (value) => setState(() {
                startAtSelection = value ?? GoalStartAtSelection.current;
              }),
              onChanged: (value) => setState(() {
                startAtSelection = value ?? GoalStartAtSelection.current;
              }),
              items: <DropdownMenuItem<GoalStartAtSelection>>[
                // DropdownMenuItem(
                //     value: GoalStartAtSelection.every,
                //     child: Row(children: [
                //       Icon(GoalStartAtSelection.every.icon),
                //       Padding(
                //           padding: const EdgeInsets.only(left: 4.0),
                //           child: Text(GoalStartAtSelection.every.label))
                //     ])),
                DropdownMenuItem(
                    value: GoalStartAtSelection.current,
                    child: Row(children: [
                      Icon(GoalStartAtSelection.current.icon),
                      Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(GoalStartAtSelection.current.label))
                    ])),
                DropdownMenuItem(
                    value: GoalStartAtSelection.next,
                    child: Row(children: [
                      Icon(GoalStartAtSelection.next.icon),
                      Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(GoalStartAtSelection.next.label))
                    ])),
              ],
              validator: (value) {
                if (value == null) {
                  return 'Please choose a value';
                }
                return null;
              },
            ),

            DropdownButtonFormField(
              value: duration,
              onSaved: (value) => setState(() {
                duration = value ?? GoalDuration.year;
              }),
              onChanged: (value) => setState(() {
                duration = value ?? GoalDuration.year;
              }),
              items: <DropdownMenuItem<GoalDuration>>[
                DropdownMenuItem(
                    value: GoalDuration.year,
                    child: Row(children: [
                      Icon(GoalDuration.year.icon),
                      Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(GoalDuration.year.label))
                    ])),
                DropdownMenuItem(
                    value: GoalDuration.month,
                    child: Row(children: [
                      Icon(GoalDuration.month.icon),
                      Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(GoalDuration.month.label))
                    ])),
                DropdownMenuItem(
                    value: GoalDuration.week,
                    child: Row(children: [
                      Icon(GoalDuration.week.icon),
                      Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(GoalDuration.week.label))
                    ])),
              ],
              validator: (value) {
                if (value == null) {
                  return 'Please choose a value';
                }
                return null;
              },
            ),

            //
            // Text('over the current'),
            //
            // SelectFormField<GoalDuration>(
            //   options: const [
            //     ButtonSegment<GoalDuration>(
            //         value: GoalDuration.year,
            //         label: Text('Year'),
            //         icon: Icon(Icons.calendar_today)),
            //     ButtonSegment<GoalDuration>(
            //         value: GoalDuration.month,
            //         label: Text('Month'),
            //         icon: Icon(Icons.calendar_month)),
            //   ],
            //   validator: (GoalDuration? value) {
            //     if(value == null) {
            //       return 'Please select a duration';
            //     }
            //     return null;
            //   },
            //   onUpdate: (GoalDuration? newValue) {
            //     setState(() {
            //       duration = newValue;
            //     });
            //   },
            //   hintText: Text('Goal duration'),
            // ),
          ])),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Save'),
          onPressed: () async {
            // Validate returns true if the form is valid, or false otherwise.
            if (_formKey.currentState!.validate()) {
              var model = GoalModel();
              await model.init();

              DateTime startAt = _getStartAtDate(duration, startAtSelection);

              Goal goal = Goal(
                  duration: duration,
                  metric: metric,
                  start: startAt,
                  goalValue: int.parse(valueController.text));

              await model.insertGoal(goal);

              if (widget.onComplete != null) {
                widget.onComplete!();
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
      ],
    );
  }

  DateTime _getStartAtDate(GoalDuration duration, GoalStartAtSelection startAtSelection) {
    int year = DateTime.now().year;
    int month = 1;
    int day = 1;

    if(startAtSelection == GoalStartAtSelection.current) {
      if(duration == GoalDuration.month) {
        month = DateTime.now().month;
      }
      if(duration == GoalDuration.week) {
        DateTime mostRecentMonday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
        month = mostRecentMonday.month;
        day = mostRecentMonday.day;
      }
    } else if(startAtSelection == GoalStartAtSelection.next) {
      if(duration == GoalDuration.year) {
        year++;
      } else if(duration == GoalDuration.month) {
        // Get first day of next month
        month = DateTime.now().month + 1;
      } else if(duration == GoalDuration.week) {
        // Get next monday
        DateTime mostRecentMonday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
        mostRecentMonday = mostRecentMonday.add(Duration(days: 7));
        month = mostRecentMonday.month;
        day = mostRecentMonday.day;
      }
    }

    return DateTime(year, month, day);
  }
}

