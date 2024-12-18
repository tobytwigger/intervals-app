import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';

class CurvesPage extends StatelessWidget {
  const CurvesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Curves')),
      drawer: const NavDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('All these should be by bottom nav'),
            Text('Power curves (/api/v1/athlete/{id}/power-curves{ext}).'),
            Text('Heart rate curves (/api/v1/athlete/{id}/hr-curves{ext})'),
            Text('Power, inc. curves'),

          ],
        ),
      ),
    );
  }
}