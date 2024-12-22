import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  Widget title;

  Widget? subtitle;

  Icon icon;

  List<Widget> data = [];

  Widget? leadingData;

  Widget? trailingData;

  Widget? image;

  List<Widget> actions = [];

  bool tight;

  void Function()? onTap;

  SummaryCard(
      {super.key,
      required this.title,
      this.tight = false,
      this.subtitle,
      this.onTap,
      this.leadingData,
      this.trailingData,
      this.image,
      required this.icon,
      this.actions = const [],
      this.data = const []});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: tight ? 150 : null,
        child: Card(
            margin: tight ? EdgeInsets.zero : null,
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(
                    children: [
                      if(tight && image != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: icon,
                        ),
                      leadingData != null
                          ? Padding(
                          padding: tight
                              ? EdgeInsets.zero
                              : EdgeInsets.only(left: 8.0),
                          child: leadingData!)
                          : Container(),
                    ]
                  ),

                  Row(
                    children: data.map((datum) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: datum,
                      );
                    }).toList(),
                  ),
                  trailingData != null
                      ? Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: trailingData!)
                      : Container(),
                ]),
                ListTile(
                  leading: image != null && tight
                      ? SizedBox(width: 60, height: 60, child: image!)
                      : icon,
                  title: Center(child: title),
                  subtitle: subtitle != null ? Center(child: subtitle) : null,
                ),
                if (image != null && !tight)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 8.0),
                    child: SizedBox(height: 100, child: image!),
                  ),
                if (actions.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
              ],
            ),

        ),
      ),
    );
  }
}
