import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initializes the notification plugin with platform-specific settings.
  static Future<void> init() async {
    // Android specific initialisation settings
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("@mipmap/ic_launcher");

    // Initialisation settings for all platforms
    const InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
    );

    // Initialize the plugin with the specified settings and callback handlers.
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onDidReceiveNotificationResponse: onDidReceiveLocalNotification,
      // onDidReceiveBackgroundNotificationResponse: onDidReceiveLocalNotification,
    );

    // Request notification permissions specifically for Android.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static void notify(int id, String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker'
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: 'item x');
  }
}