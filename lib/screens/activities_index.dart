import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/core/network/intervals/intervals.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/lib/core/network/intervals/data/skyline_chart.pb.dart';
import 'package:intervals/ui/components/charts/skyline.dart';
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
        GoRouter.of(context).push('/activity/${activity.id}');
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
          : ActivityImage(skylineData: activity.skylineChartData!),
      trailing: Text(activity.icuTrainingLoad?.toString() ?? 'N/A'),
    );
  }
}

