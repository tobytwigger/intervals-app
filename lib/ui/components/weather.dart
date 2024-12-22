import 'package:flutter/material.dart';
import 'package:intervals/core/network/intervals/data/weather.dart';
import 'package:intl/intl.dart';

class WeatherTileIcon extends StatelessWidget {
  final WeatherForecastTile icon;

  WeatherTileIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: icon.description,
        child: Image.network(
            'http://openweathermap.org/img/wn/${icon.icon}.png')
      // child: Icon(_getIcon(forecast.daily.first.weather.first.icon))
    );
  }
}











class FullWeatherWidget extends StatelessWidget {
  final WeatherForecast forecast;

  final DailyWeatherForecastEntry todaysWeather;

  const FullWeatherWidget(
      {super.key, required this.forecast, required this.todaysWeather});

  List<HourlyWeatherForecastEntry> get hourlyForecast => forecast.hourly
      .where((hour) => DateTime(hour.date.year, hour.date.month, hour.date.day)
      .isAtSameMomentAs(DateTime(todaysWeather.date.year,
      todaysWeather.date.month, todaysWeather.date.day)))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          // Sunrise and sunset
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.grey),
                    Column(
                        children: [
                          Text(todaysWeather.sunrise!),
                          Text(todaysWeather.sunset!),
                        ]
                    )
                  ]
              ),

              Row(
                  children: [
                    Column(
                        children: [
                          Text('Rain', style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          )),
                          Text('Humidity', style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          )),
                        ]
                    ),
                    Column(
                        children: [
                          Text('${(todaysWeather.rain?.toStringAsFixed(1) ?? 0)}mm'),
                          Text('${(todaysWeather.humidity?.ceil()?.toString() ?? 0)}%'),
                        ]
                    )
                  ]
              ),

            ]
        ),
        for (var day in hourlyForecast)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(DateFormat('h aaa').format(day.date)),
              WeatherTileIcon(day.weather.first),
              Column(
                children: [
                  Text('${day.temp!.round().toString()}°'),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                      children: [
                        if (day.windDeg != null)
                          Transform.rotate(
                            angle: day.windDeg! + 180,
                            origin: Offset(0, 0),
                            child: Icon(
                              Icons.arrow_upward,
                            ),
                          ),
                      ]
                  ),
                  Column(
                    children: [
                      Text((day.windSpeed?.round() ?? 0).toString()),
                      Text((day.windGust?.round() ?? 0).toString()),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text('km/h',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            )),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text('km/h',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            )),
                      ),
                    ],
                  ),

                ],
              ),
              //   if (day.windDeg != null)
              //     Transform.rotate(
              //       angle: day.windDeg! + 180,
              //       origin: Offset(0, 0),
              //       child: IconButton(
              //         icon: Icon(
              //           Icons.arrow_upward,
              //         ),
              //         onPressed: null,
              //       ),
              //     ),
            ],
          ),
      ],
    );
  }
}









