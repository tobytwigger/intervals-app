import 'package:flutter/material.dart';

class StatsEntry {
  final String label;
  final String value;

  StatsEntry({required this.label, required this.value});
}

// class StatsWidget extends StatelessWidget {
//   final List<List<StatsEntry>> stats;
//
//   StatsWidget({required this.stats});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         padding: EdgeInsets.all(8.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: stats.map((stat) {
//             return Expanded(
//               child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: stat.map((entry) {
//                     return _StatsWidgetEntry(entry: entry);
//               }).toList()),
//             );
//           }).toList(),
//         ));
//   }
// }
//

class HorizontalStatsWidgetEntry extends StatelessWidget {
  final String label;

  final String value;

  HorizontalStatsWidgetEntry({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.0,
            ),
          ),
        ),
        Text(value),
      ],
    );
  }
}

class VerticalStatsWidgetEntry extends StatelessWidget {
  final String label;

  final String value;

  VerticalStatsWidgetEntry({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.0,
            ),
          ),
        ),
        Text(value),
      ],
    );
  }
}
