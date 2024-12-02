import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/core/network/intervals/intervals.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/lib/core/network/intervals/data/skyline_chart.pb.dart';
import 'package:intervals/widget/widget_home.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

/*
 *
 * Index page
 *
 */
class ActivitiesIndexPage extends StatelessWidget {
  const ActivitiesIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const NavDrawer(),
        appBar: AppBar(title: const Text('Activities')),
        body: const ActivitiesList());
  }
}

/*
 *
 * List of all activities
 *
 */

class ActivitiesList extends StatefulWidget {
  const ActivitiesList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ActivitiesListState();
  }
}

class _ActivitiesListState extends State<ActivitiesList> {
  final PagingController<int, Activity> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      Provider.of<AuthenticatedUserModel>(context, listen: false)
          .getIntervalsClient()!
          .loadActivities(page: pageKey)
          .then((activities) {
        if (activities.length > 0) {
          _pagingController.appendPage(activities, pageKey + 1);
        } else {
          _pagingController.appendLastPage(activities);
        }
        HomeWidget.updateTasksOnWidget(activities);
      }).catchError((error) {
        _pagingController.error = error;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Activity>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Activity>(
        itemBuilder: (context, activity, index) => ActivityLine(
          activity: activity,
        ),
      ),
    );
  }
}

class ActivityLine extends StatelessWidget {
  final Activity activity;

  const ActivityLine({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        GoRouter.of(context).push('/activities/${activity.id}');
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.name ?? 'N/A',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            activity.startDateLocal == null
                ? 'N/A'
                : DateFormat('dd/MM/yyyy HH:mm')
                    .format(activity.startDateLocal!),
            style: TextStyle(color: Colors.black87),
          )
        ],
      ),
      leading: activity.skylineChartBytes == null
          ? Text('No image')
          : SkylineImage(skylineData: activity.skylineChartData!),
      trailing: Text(activity.icuTrainingLoad?.toString() ?? 'N/A'),
    );
  }
}

class SkylineChartData {
  final double width;

  final double height;

  final Color color;

  SkylineChartData(
      {required this.width, required this.height, required this.color});
}

class SkylineImage extends StatelessWidget {
  final SkylineChart skylineData;

  final bool viewable;

  final double maxY;

  final double maxX;

  const SkylineImage({
    super.key,
    required this.skylineData,
    this.viewable = true,
    this.maxY = 80.0,
    this.maxX = 80.0
  });

  @override
  Widget build(BuildContext context) {
    List<SkylineChartData> data = createData(skylineData);

    List<Widget> children = [];

    data.forEach((chartRod) {
      children.add(SkylineImageRod(
        color: chartRod.color,
        width: chartRod.width,
        height: chartRod.height,
      ));
    });

    var imageBox = SizedBox(
        width: maxY,
        height: maxX,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: children));

    if(viewable) {
      return GestureDetector(
          onTap: () => _dialogBuilder(context),
          child: imageBox
      );
    } else {
      return imageBox;
    }
  }

  List<SkylineChartData> createData(SkylineChart skylineData) {
    var totalWidth =
        skylineData.width.reduce((carry, widthItem) => carry + widthItem);
    var maxIntensity = skylineData.intensity
        .reduce((carry, intensity) => carry < intensity ? intensity : carry);
    if (maxIntensity < 150) {
      maxIntensity = 150;
    }
    // TODO Check the arrays are all the same length
    List<SkylineChartData> data = [];

    for (final (index, width) in skylineData.width.indexed) {
      data.add(SkylineChartData(
          width: (width / totalWidth) * maxY,
          height: (skylineData.intensity[index] / maxIntensity) * maxX,
          color: convertZoneToColour(
              skylineData.zone[index], skylineData.numZones)));
    }

    return data;
  }

  convertZoneToColour(int zone, int numZones) {
    if (numZones == 7) {
      switch (zone) {
        case 1:
          return const Color.fromRGBO(0, 158, 128, 1);
        case 2:
          return const Color.fromRGBO(0, 158, 0, 1);
        case 3:
          return const Color.fromRGBO(255, 203, 14, 1);
        case 4:
          return const Color.fromRGBO(255, 127, 14, 1);
        case 5:
          return const Color.fromRGBO(221, 4, 71, 1);
        case 6:
          return const Color.fromRGBO(102, 51, 204, 1);
        case 7:
          return const Color.fromRGBO(80, 72, 97, 1);
      }
    }
    return Colors.blue;
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          content: SkylineImage(skylineData: skylineData, viewable: false, maxY: 200, maxX: 200),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


class SkylineImageRod extends StatelessWidget {
  final Color color;

  final double width;

  final double height;

  SkylineImageRod(
      {super.key,
      required this.width,
      required this.height,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: color,
        child: SizedBox(
          width: width,
          height: height,
        ));
  }
}
