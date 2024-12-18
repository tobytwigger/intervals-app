import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      drawer: const NavDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Normal profile stuff'),
            Text('Sports and their settings, in tabs'),
          ],
        ),
      ),
    );
  }
}