import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intervals/core/network/intervals/data/events.dart';
import 'package:intervals/core/network/intervals/data/weather.dart';
import 'package:intervals/core/network/intervals/data/wellness.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {

  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const NavDrawer(),
        appBar: AppBar(title: const Text('Today')),
        body: TodayPageView(
            date: date,
            onDateChange: (newDate) {
              setState(() {
                date = newDate;
              });
            },
        ));
  }
}







class TodayPageView extends StatefulWidget {
  final DateTime date;

  // Callback for when the date changes
  final ValueChanged<DateTime> onDateChange;

  const TodayPageView({super.key, required this.date, required this.onDateChange});

  @override
  State<TodayPageView> createState() => _TodayPageViewState();
}

class _TodayPageViewState extends State<TodayPageView> {
  Wellness? wellness;

  List<Events>? events;

  WeatherForecast? weatherForecast;

  late PageController _pageViewController;

  @override
  void initState() {
    super.initState();

    _pageViewController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadTodayData();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isReady = wellness != null && events != null;

    return RefreshIndicator(
            onRefresh: () async {
              await _loadTodayData();
            },
            child: Stack(
              children: <Widget>[
                Scaffold(
                    body: isReady
                        ? Column(
                            children: [
                              ChangeDate(
                                date: widget.date,
                                onDateChange: widget.onDateChange,
                              ),
                              PageView(
                                  controller: _pageViewController,
                                  onPageChanged: (currentPageIndex) {
                                    print('Page changed to $currentPageIndex');
                                    // _pa.index = currentPageIndex;
                                    // setState(() {
                                    //   _currentPageIndex = currentPageIndex;
                                    // });
                                  },
                                  children: <Widget>[
                                    TodayLoadingPage(),
                                    TodayLoadingPage(),
                                    Today(
                                        wellness: wellness!,
                                        events: events!,
                                        forecast: weatherForecast
                                    ),
                                    TodayLoadingPage(),
                                    TodayLoadingPage()
                                  ])
                            ],
                          )
                        : const CircularProgressIndicator())
              ],
            )
    );
  }

  Future<void> _loadTodayData() async {
    var model = Provider.of<AuthenticatedUserModel>(context, listen: false);
    var client = model.getIntervalsClient()!;

    var _wellnessFuture = client.getWellnessDataForDay(widget.date);
    var _eventsFuture = client.getEvents(
      oldest: widget.date,
      newest: widget.date,
    );

    // Check if the weather date is within two weeks of today
    Future<WeatherForecast?> _weatherFuture = Future.value(null);
    if (widget.date.difference(DateTime.now()).abs().inDays < 14) {
      _weatherFuture = client.getWeatherForecast();
    }

    final (_wellness, _events, _weather) =
        await (_wellnessFuture, _eventsFuture, _weatherFuture).wait;

    setState(() {
      wellness = _wellness;
      events = _events;
      weatherForecast = _weather;
    });
  }
}

class TodayLoadingPage extends StatelessWidget {
  const TodayLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class ChangeDate extends StatelessWidget {
  final DateTime date;

  final ValueChanged<DateTime> onDateChange;

  const ChangeDate({
    super.key,
    required this.date,
    required this.onDateChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            onDateChange(date.subtract(const Duration(days: 1)));
          },
        ),
        GestureDetector(
          onTap: () async {
            var newDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(1990),
              lastDate: DateTime(2040),
            );

            if (newDate != null) {
              onDateChange(newDate);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(DateFormat('EEE, MMM d yyyy').format(date)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            onDateChange(date.add(const Duration(days: 1)));
          },
        ),
      ],
    );
  }
}

class Today extends StatelessWidget {
  final Wellness wellness;

  final List<Events> events;

  final WeatherForecast? forecast;

  Today({
    super.key,
    required this.wellness,
    required this.events,
    this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Fitness: ${wellness.ctl}'),
        Text('Fatigue: ${wellness.atl}'),
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, int index) {
            assert(events[index] is Events);

            return ListTile(
                onTap: () {
                  GoRouter.of(context).push('/event/${events[index].id}');
                },
                title: Text(events[index].name ?? 'M/A'));
          },
          itemCount: events.length,
        ),
        if (forecast != null) ...[WeatherWidget(forecast!)],
      ],
    );
    return Text('Today');
  }
}

class WeatherWidget extends StatelessWidget {
  final WeatherForecast forecast;

  WeatherWidget(this.forecast);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Weather'),
        Text('Temp: ${forecast.hourly.first.temp}'),
      ],
    );
  }
}

