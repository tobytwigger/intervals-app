import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/services/notifications.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';
import 'package:provider/provider.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticatedUserModel>(
      builder: (context, userModel, child) {
        if(userModel.isLoggedIn == false) {
          return Text('Logging out...');
        }
        return Scaffold(
          drawer: const NavDrawer(),
          appBar: AppBar(title: const Text('Today')),
          body: Column(children: [
            Text('Welcome, ${userModel.user!.name}'),
            FloatingActionButton(
                onPressed: () async {
                  await _showNotification();
                }
            )
          ]),
        );
      }
    );
  }

  Future<void> _showNotification() async {
    Notifications.notify(
      1,
      'My Title',
      'Some body for the notification'
    );

  }

}
