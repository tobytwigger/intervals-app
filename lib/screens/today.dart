import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/weather.dart';
import 'package:intervals/core/network/intervals/data/wellness.dart';
import 'package:intervals/core/network/intervals/intervals.dart';
import 'package:intervals/data/repositories/authenticated_user_model.dart';
import 'package:intervals/ui/colours.dart';
import 'package:intervals/ui/components/summary-cards/workout_or_plan.dart';
import 'package:intervals/ui/components/weather.dart';
import 'package:intervals/ui/partials/nav_drawer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TodayPage extends StatefulWidget {
  final DateTime? initialDisplayDate;

  const TodayPage({super.key, this.initialDisplayDate});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  DateTime initialDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day
  );

  DateTime currentDateView =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  late PageController _pageViewController;

  final initialPage = 100000;

  @override
  void initState() {
    super.initState();

    if(widget.initialDisplayDate != null) {
      initialDate = widget.initialDisplayDate!;
    }

    _pageViewController = PageController(
      initialPage: initialPage,
    );

    setState(() {
      currentDateView = initialDate;
    });

    _pageViewController.addListener(() {
      int index = _pageViewController.page!.round();

      final DateTime newDate =
          initialDate.add(Duration(days: index - initialPage));

      setState(() {
        currentDateView = newDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const NavDrawer(),
        appBar: AppBar(
          title: Text(_getDateText()),
          actions: [
            IconButton(
                onPressed: () {
                  _pageViewController.jumpToPage(initialPage);
                },
                icon: Icon(Icons.today))
          ],
        ),
        body: Column(children: [
          ChangeDate(
            date: currentDateView,
            onDateChange: (newDate) {
              setState(() {
                _pageViewController.jumpToPage(
                    initialPage + newDate.difference(initialDate).inDays);
              });
            },
          ),
          Expanded(
              child: PageView.builder(
                  controller: _pageViewController,
                  itemBuilder: (context, index) {
                    // index = initialIndex means TODAY.
                    final DateTime newDate =
                        initialDate.add(Duration(days: index - initialPage));

                    return TodayPageView(
                      date: newDate,
                    );
                  }))
        ]));
  }

  String _getDateText() {
    // If is today, return 'Today'
    if (currentDateView.isAtSameMomentAs(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
      return 'Today';
    }

    if (currentDateView.isAtSameMomentAs(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 1))) {
      return 'Yesterday';
    }

    if (currentDateView.isAtSameMomentAs(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1))) {
      return 'Tomorrow';
    }

    return DateFormat('EEE, MMM d yyyy').format(currentDateView);
  }
}

class TodayPageView extends StatefulWidget {
  final DateTime date;

  const TodayPageView({super.key, required this.date});

  @override
  State<TodayPageView> createState() => _TodayPageViewState();
}

class _TodayPageViewState extends State<TodayPageView> {
  Wellness? wellness;

  List<WorkoutOrPlan>? events;

  WeatherForecast? weatherForecast;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadTodayData();
    });
  }

  @override
  void didUpdateWidget(covariant TodayPageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.date != widget.date) {
      _loadTodayData();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isReady = wellness != null && events != null;

    return RefreshIndicator(
        onRefresh: () async {
          await _loadTodayData(full: true);
        },
        child: isReady
            ? Today(
                wellness: wellness!,
                events: events!,
                forecast: weatherForecast,
                date: widget.date,
              )
            : const CircularProgressIndicator());
  }

  Future<void> _loadTodayData({
    bool? full = false,
  }) async {
    var model = Provider.of<AuthenticatedUserModel>(context, listen: false);
    var client = model.getIntervalsClient()!;

    var _wellnessFuture = client.getWellnessDataForDay(widget.date);
    var _eventsFuture = client.getEventsWithActivities(
      oldest: widget.date,
      newest: widget.date,
    );

    // Check if the weather date is within two weeks of today
    Future<WeatherForecast?> _weatherFuture = Future.value(null);
    if (full == true ||
        (widget.date.difference(DateTime.now()).abs().inDays < 14 &&
            (weatherForecast == null ||
                weatherForecast!.daily.any((element) => DateTime(
                        element.date.year, element.date.month, element.date.day)
                    .isAtSameMomentAs(DateTime(widget.date.year,
                        widget.date.month, widget.date.day)))))) {
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
            DateTime newDate = date.subtract(const Duration(days: 1));

            newDate = DateTime(
              newDate.year,
              newDate.month,
              newDate.day,
            );

            onDateChange(newDate);
          },
        ),
        Expanded(
          child: InkWell(
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
            child: Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(DateFormat('EEE, MMM d yyyy').format(date)),
              ),
            ),
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

  final List<WorkoutOrPlan> events;

  final WeatherForecast? forecast;

  final DateTime date;

  Today({
    super.key,
    required this.wellness,
    required this.events,
    this.forecast,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    DailyWeatherForecastEntry? todaysWeather = null;

    if (forecast != null && forecast!.daily.isNotEmpty) {
      try {
        todaysWeather = forecast!.daily.firstWhere((forecastLoop) =>
            DateTime(date.year, date.month, date.day).isAtSameMomentAs(DateTime(
                forecastLoop.date.year,
                forecastLoop.date.month,
                forecastLoop.date.day)));
      } on StateError {
        // No weather data for today
        todaysWeather = null;
      }
    }

    return Column(
      children: [
        if (todaysWeather != null) ...[
          Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0),
              child: WeatherWidget(
                  forecast: forecast!, todaysWeather: todaysWeather))
        ],
        Padding(
            padding: EdgeInsets.symmetric(vertical: 2.0),
            child: WellnessWidget(wellness)),
        Expanded(
          child: events.length > 0
              ? Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, int index) {
                      assert(events[index] is WorkoutOrPlan);

                      return WorkoutOrPlanSummaryCard(
                          workoutOrPlan: events[index], tight: false);
                    },
                    itemCount: events.length,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'No events today',
                    style: TextStyle(
                      color: HexColor.fromHex('#666666'),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class WellnessWidget extends StatelessWidget {
  final Wellness wellness;

  const WellnessWidget(this.wellness);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(children: [
          const Column(
            children: [
              Icon(Icons.directions_bike, color: Colors.grey),
              Icon(Icons.battery_2_bar, color: Colors.grey),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: Column(
              children: [
                Text(
                    wellness.ctl == null
                        ? 'N/A'
                        : wellness.ctl!.ceil().toString(),
                    style: TextStyle(color: HexColor.fromHex('#8dd0ef'))),
                Text(
                    wellness.atl == null
                        ? 'N/A'
                        : wellness.atl!.ceil().toString(),
                    style: TextStyle(color: HexColor.fromHex('#b196e5'))),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                  (wellness.rampRate ?? 0) >= 0
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: (wellness.rampRate ?? 0) >= 0
                      ? Colors.green
                      : Colors.grey),
              Text(
                wellness.rampRate == null
                    ? 'N/A'
                    : wellness.rampRate!.toStringAsFixed(1),
                style: TextStyle(
                    color: (wellness.rampRate ?? 0) >= 0
                        ? Colors.green
                        : Colors.grey),
              ),
            ],
          )
        ]),
        Row(children: [
          const Column(
            children: [
              Icon(Icons.nightlight_round, color: Colors.grey),
              Icon(Icons.favorite, color: Colors.grey),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: Column(
              children: [
                Text(
                    wellness.sleepTime == null
                        ? 'N/A'
                        : wellness.sleepTime!.display(),
                    style: TextStyle(color: HexColor.fromHex('#8dd0ef'))),
                Text(
                    wellness.restingHR == null
                        ? 'N/A'
                        : wellness.restingHR!.toString(),
                    style: TextStyle(color: HexColor.fromHex('#b196e5'))),
              ],
            ),
          ),
        ]),
      ],
    );
  }
}

class WeatherWidget extends StatelessWidget {
  final WeatherForecast forecast;

  final DailyWeatherForecastEntry todaysWeather;

  WeatherWidget({required this.forecast, required this.todaysWeather});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog<String>(
            context: context,
            builder: (BuildContext context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FullWeatherWidget(
                            forecast: forecast, todaysWeather: todaysWeather),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ));
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                WeatherTileIcon(todaysWeather.weather.first),
                Column(
                  children: [
                    Text('${todaysWeather.temp!.max!.round().toString()}°'),
                    Text('${todaysWeather.temp!.min!.round().toString()}°'),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Transform.rotate(
                  angle: todaysWeather.windDeg! + 180,
                  origin: Offset(0, 0),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_upward,
                    ),
                    onPressed: null,
                  ),
                ),
                Column(
                  children: [
                    Text(todaysWeather.windSpeed!.round().toString()),
                    Text(todaysWeather.windGust!.round().toString()),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
