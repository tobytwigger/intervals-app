import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: const NavDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Any settings like units')
          ],
        ),
      ),
    );
  }
}