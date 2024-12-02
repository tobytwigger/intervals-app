import 'dart:convert';
import 'package:intervals/core/network/intervals/data/activity.dart';
import '../widget/widget_config.dart';

const String group = 'group.com.intervals.intervals.widget';

const String widgetName = 'HomeWidget';

const int maxTasks = 3;

class HomeWidget {
  static Future<void> init() async {
    await WidgetConfig.init(group);
  }

  static Future<void> updateTasksOnWidget(List<Activity> tasks) async {
    tasks = tasks.take(maxTasks).toList();

    List<Object> tasksMapList =
        tasks.map((task) => Activity.toWidgetMap(task)).toList();

    String tasksJson = jsonEncode(tasksMapList);

    await WidgetConfig.saveWidgetData('tasks', tasksJson);

    await WidgetConfig.updateWidget(widgetName);
  }
}
