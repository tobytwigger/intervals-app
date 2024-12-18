import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:provider/provider.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Intervals.icu'),
          ),
          const DividerWithSubheader(label: 'Training'),
          DrawerEntry('Today', Icons.today,
            routes: ['/today'],
            route: '/today',
          ),
          DrawerEntry('Schedule', Icons.calendar_month,
            routes: ['/schedule'],
            route: '/schedule',
          ),
          const DividerWithSubheader(label: 'Analysis'),
          DrawerEntry('Fitness', Icons.show_chart,
            routes: ['/fitness'],
            route: '/fitness',
          ),
          DrawerEntry('Curves', Icons.stacked_line_chart,
            routes: ['/curves'],
            route: '/curves',
          ),
          DrawerEntry('Totals', Icons.bar_chart,
            routes: ['/totals'],
            route: '/totals',
          ),
          DrawerEntry('Goals', Icons.flag,
            routes: ['/goals'],
            route: '/goals',
          ),
          const DividerWithSubheader(),
          DrawerEntry('Profile', Icons.account_circle,
            routes: ['/profile'],
            route: '/profile',
          ),
          DrawerEntry('Settings', Icons.settings,
            routes: ['/settings'],
            route: '/settings',
          ),
          DrawerEntry('Logout', Icons.logout,
            onTap: () {
              Provider.of<AuthenticatedUserModel>(context, listen: false)
                  .logOut();
            },
          ),
        ],
      ),
    );
  }
}

class DrawerEntry extends StatelessWidget {
  final String title;

  final IconData? icon;

  final List<String> routes;

  final String? route;

  final GestureTapCallback? onTap;

  DrawerEntry(this.title, this.icon, {
    super.key,
    this.routes = const [],
    this.route,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool _isSelected = routes.contains(
        GoRouterState.of(context).fullPath
    );

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _isSelected,
      selectedColor: Colors.black,
      selectedTileColor: Colors.blue.withOpacity(0.4),
      onTap: onTap ?? (
        route != null
          ? () => GoRouter.of(context).go(route!)
          : null
      ),
    );
  }
}

class DividerWithSubheader extends StatelessWidget {
  final String? label;

  const DividerWithSubheader({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        ...label == null
            ? []
            : [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                          left: 16.0,
                          top: 16.0
                        ),
                        child: Text(
                            label!,
                          style: TextStyle(
                            color: Colors.black45,
                          ),
                        ))
                  ],
                )
              ],
      ],
    );
  }
}
