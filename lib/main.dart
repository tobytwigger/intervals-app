import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/core/network/intervals/intervals.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/screens/activities_index.dart';
import 'package:intervals/screens/activities_show.dart';
import 'package:intervals/screens/auth.dart';
import 'package:intervals/screens/calendar.dart';
import 'package:intervals/screens/fitness.dart';
import 'package:intervals/screens/today.dart';
import 'package:intervals/services/notifications.dart';
import 'package:intervals/widget/widget_home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
print('calling with task ${task}');

    if(task == 'notifyAboutNewActivities') {
      print('picked up task');
      final prefs = await SharedPreferences.getInstance();

      //  Get when to check from
      DateTime oldest = DateTime.now().subtract(Duration(minutes: 30, days: 4));
      String? lastCheckedDatetime = prefs.getString('notifyAboutNewActivitiesLastChecked');
      if(lastCheckedDatetime != null) {
        oldest = DateTime.parse(lastCheckedDatetime);
      }
print(oldest.toString());
      prefs.setString('notifyAboutNewActivitiesLastChecked', DateTime.now().toIso8601String());
      prefs.remove('notifyAboutNewActivitiesLastChecked');
      // TODO Does this work fine with different timezones?

      // Log the user in
      AuthenticatedUserModel model = AuthenticatedUserModel();
      await model.initToken();

      Intervals? intervals = model.getIntervalsClient();

      if(intervals == null) {
        print('No access to intervals');
        return true;
      }

      List<Activity> activities = await intervals.loadActivitiesInDuration(
        oldest: oldest,
        newest: DateTime.now()
      );

      // Iterate through each of the activities
      activities.forEach((activity) {
        // Notify the user!
      });

      return true;
    } else {
      print("Native called background task: $task"); //simpleTask will be emitted here.
      return Future.value(true);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifications.init();

  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );

  // Workmanager().registerOneOffTask(
  //     'notify-about-new-activities-started-${DateTime.now().toIso8601String()}',
  //     'notifyAboutNewActivities',
  //     initialDelay: const Duration(seconds: 15)
  // );
  //
  // Workmanager().registerPeriodicTask(
  //     'notify-about-new-activities-started-${DateTime.now().toIso8601String()}',
  //     'notifyAboutNewActivities',
  //     frequency: const Duration(minutes: 15)
  // );
  HomeWidget.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final authenticatedUserModel = AuthenticatedUserModel();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  late final _router = GoRouter(
      initialLocation: '/activities',
      refreshListenable: authenticatedUserModel,
      redirect: (BuildContext context, GoRouterState state) {
        var authenticatedUserModel =
            Provider.of<AuthenticatedUserModel>(context, listen: false);
        if (!authenticatedUserModel.isLoggedIn) {
          return '/login';
        } else if (state.fullPath == '/login') {
          return '/';
        }

        return null;
      },
      navigatorKey: _rootNavigatorKey,
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(path: '/today', builder: (context, state) => const TodayPage()),
        GoRoute(path: '/calendar', builder: (context, state) => const CalendarPage()),
        GoRoute(path: '/', redirect: (_, __) => '/activities'),
        GoRoute(path: '/fitness', builder: (context, state) => FitnessPage()),
        GoRoute(
            path: '/activities',
            builder: (context, state) => const ActivitiesIndexPage(),
            routes: [
              GoRoute(
                  path: '/:id',
                  builder: (context, state) {
                    // TODO Make typesafe
                    final String activityId = state.pathParameters['id']!;
                    return ActivitiesShowPage(activityId: activityId);
                  }),
            ]),

        // GoRoute(path: '/login', builder: (context, state) => const LoginPage())
      ]);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    authenticatedUserModel.initToken();

    return ChangeNotifierProvider<AuthenticatedUserModel>.value(
        value: authenticatedUserModel,
        child: MaterialApp.router(
          routerConfig: _router,
          title: 'Intervals.icu',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a purple toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
        ));
  }
}
