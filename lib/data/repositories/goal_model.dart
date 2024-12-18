import 'package:intervals/data/data/goal.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class GoalModel {

  Future<Database>? database;
  
  init() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'intervalsicu_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE goals (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, duration Text, metric TEXT, value INTEGER, start TEXT)'
        );
      },
      version: 1
    );
  }

  Future<void> insertGoal(Goal goal) async {
    final db = await database;

    await db!.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<Goal>> goals() async {
      final db = await database;

      final List<Map<String, Object?>> goalMaps = await db!.query('goals');

      List<Goal> goals = [];

      for(final {
      'id': id as int,
      'duration': duration as String,
      'metric': metric as String,
      'start': start as String,
      'value': value as int,
      } in goalMaps) {
        goals.add(
            Goal(
                id: id,
                duration: GoalDuration.values.byName(duration),
                metric: GoalMetric.values.byName(metric),
                start: DateTime.parse(start),
                goalValue: value
            )
        );
      }

      return goals;
  }

  Future<void> delete(int? id) async {
    final db = await database;

    await db!.delete(
    'goals',
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  get(int goalId) async {
    final db = await database;

    final List<Map<String, Object?>> goalMaps = await db!.query(
        'goals',
        where: 'id = ?',
        whereArgs: [goalId]
    );

    if(goalMaps.length == 0) {
      throw Exception('No goal found');
    }

    List<Goal> goals = [];

    for(final {
    'id': id as int,
    'duration': duration as String,
    'metric': metric as String,
    'start': start as String,
    'value': value as int,
    } in goalMaps) {
      goals.add(
          Goal(
              id: id,
              duration: GoalDuration.values.byName(duration),
              metric: GoalMetric.values.byName(metric),
              start: DateTime.parse(start),
              goalValue: value
          )
      );
    }

    return goals.first;
  }
}