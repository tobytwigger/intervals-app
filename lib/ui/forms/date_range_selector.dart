
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChooseDateRange extends StatelessWidget {
  final DateTime oldest;

  final DateTime newest;

  void Function(DateTime oldest, DateTime newest)? updateOldestAndNewestDates;

  ChooseDateRange(
      {super.key,
        required this.oldest,
        required this.newest,
        this.updateOldestAndNewestDates});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(DateFormat('dd/MM/yyyy').format(oldest)),
        const Text(' - '),
        Text(DateFormat('dd/MM/yyyy').format(newest)),
        IconButton(
            onPressed: () {
              showDateRangePicker(
                context: context,
                initialDateRange: DateTimeRange(start: oldest, end: newest),
                firstDate: DateTime(1990, 1, 1),
                lastDate: DateTime(2040, 1, 1),
              ).then((range) {
                if (updateOldestAndNewestDates != null && range != null) {
                  updateOldestAndNewestDates!(range.start, range.end);
                }
              });
            },
            icon: const Icon(Icons.edit)),
      ],
    );
  }
}