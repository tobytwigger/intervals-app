import 'package:home_widget/home_widget.dart';

// Utility class for widget configuration and interaction
class WidgetConfig {
  // Sets the app group ID (required for iOS widget communication)
  static Future<void> init(String group) async {
  }

  // Saves key-value data for the widget
  static Future<void> saveWidgetData(String key, String value) async {
    await HomeWidget.saveWidgetData(key, value);
  }

  // Triggers the widget to refresh its display
  static Future<void> updateWidget(String widgetName) async {
    await HomeWidget.updateWidget(iOSName: widgetName, androidName: widgetName);
  }
}
