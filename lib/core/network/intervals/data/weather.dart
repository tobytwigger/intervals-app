class Weather {
  final double? averageTemp;

  final double? minTemp;

  final double? maxTemp;

  final double? averageWeatherTemp;

  final double? minWeatherTemp;

  final double? maxWeatherTemp;

  final double? averageFeelsLike;

  final double? minFeelsLike;

  final double? maxFeelsLike;

  final double? averageWindSpeed;

  final double? minWindSpeed;

  final double? maxWindSpeed;

  final double? averageWindGust;

  final double? minWindGust;

  final double? maxWindGust;

  final double? prevailingWindDeg;

  final double? averageYaw;

  final double? maxRain;

  final double? maxShowers;

  final double? maxSnow;

  final int? averageClouds;

  final String? description;

  Weather({
    this.averageTemp,
    this.minTemp,
    this.maxTemp,
    this.averageWeatherTemp,
    this.minWeatherTemp,
    this.maxWeatherTemp,
    this.averageFeelsLike,
    this.minFeelsLike,
    this.maxFeelsLike,
    this.averageWindSpeed,
    this.minWindSpeed,
    this.maxWindSpeed,
    this.averageWindGust,
    this.minWindGust,
    this.maxWindGust,
    this.prevailingWindDeg,
    this.averageYaw,
    this.maxRain,
    this.maxShowers,
    this.maxSnow,
    this.averageClouds,
    this.description,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      averageTemp: json['average_temp'] == null
          ? null
          : double.parse(json['average_temp'].toString()),
      minTemp: json['min_temp'] == null
          ? null
          : double.parse(json['min_temp'].toString()),
      maxTemp: json['max_temp'] == null
          ? null
          : double.parse(json['max_temp'].toString()),
      averageWeatherTemp: json['average_weather_temp'] == null
          ? null
          : double.parse(json['average_weather_temp'].toString()),
      minWeatherTemp: json['min_weather_temp'] == null
          ? null
          : double.parse(json['min_weather_temp'].toString()),
      maxWeatherTemp: json['max_weather_temp'] == null
          ? null
          : double.parse(json['max_weather_temp'].toString()),
      averageFeelsLike: json['average_feels_like'] == null
          ? null
          : double.parse(json['average_feels_like'].toString()),
      minFeelsLike: json['min_feels_like'] == null
          ? null
          : double.parse(json['min_feels_like'].toString()),
      maxFeelsLike: json['max_feels_like'] == null
          ? null
          : double.parse(json['max_feels_like'].toString()),
      averageWindSpeed: json['average_wind_speed'] == null
          ? null
          : double.parse(json['average_wind_speed'].toString()),
      minWindSpeed: json['min_wind_speed'] == null
          ? null
          : double.parse(json['min_wind_speed'].toString()),
      maxWindSpeed: json['max_wind_speed'] == null
          ? null
          : double.parse(json['max_wind_speed'].toString()),
      averageWindGust: json['average_wind_gust'] == null
          ? null
          : double.parse(json['average_wind_gust'].toString()),
      minWindGust: json['min_wind_gust'] == null
          ? null
          : double.parse(json['min_wind_gust'].toString()),
      maxWindGust: json['max_wind_gust'] == null
          ? null
          : double.parse(json['max_wind_gust'].toString()),
      prevailingWindDeg: json['prevailing_wind_deg'] == null
          ? null
          : double.parse(json['prevailing_wind_deg'].toString()),
      averageYaw: json['average_yaw'] == null
          ? null
          : double.parse(json['average_yaw'].toString()),
      maxRain: json['max_rain'] == null
          ? null
          : double.parse(json['max_rain'].toString()),
      maxShowers: json['max_showers'] == null
          ? null
          : double.parse(json['max_showers'].toString()),
      maxSnow: json['max_snow'] == null
          ? null
          : double.parse(json['max_snow'].toString()),
      averageClouds: json['average_clouds'],
      description: json['description'],
    );
  }
}

class WeatherForecast {
  final String provider;

  final String? location;

  final String? label;

  final double? lat;

  final double? lon;

  List<DailyWeatherForecastEntry> daily;

  List<HourlyWeatherForecastEntry> hourly;

  WeatherForecast({
    required this.provider,
    this.location,
    this.label,
    this.lat,
    this.lon,
    required this.daily,
    required this.hourly,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      provider: json['provider'],
      location: json['location'],
      label: json['label'],
      lat: json['lat'] == null
          ? null
          : double.parse(json['lat'].toString()),
      lon: json['lon'] == null
          ? null
          : double.parse(json['lon'].toString()),
      daily: (json['daily'] as List)
          .map((i) => DailyWeatherForecastEntry.fromJson(i))
          .toList(),
      hourly: (json['hourly'] as List)
          .map((i) => HourlyWeatherForecastEntry.fromJson(i))
          .toList(),
    );
  }
}

class DailyWeatherForecastEntry {
  final DateTime date;

  final double? pressure;

  final double? humidity;

  final double? dewPoint;

  final double? clouds;

  final double? windSpeed;

  final double? windDeg;

  final double? windGust;

  final double? rain;

  final double? snow;

  final List<WeatherForecastTile> weather;

  final String? sunrise;

  final String? sunset;

  final double? moonPhase;

  final Temperature? temp;

  final TemperatureFeelsLike? feelsLike;

  DailyWeatherForecastEntry({
    required this.date,
    this.pressure,
    this.humidity,
    this.dewPoint,
    this.clouds,
    this.windSpeed,
    this.windDeg,
    this.windGust,
    this.rain,
    this.snow,
    this.sunrise,
    this.sunset,
    this.moonPhase,
    this.temp,
    this.feelsLike,
    this.weather = const [],
  });

  factory DailyWeatherForecastEntry.fromJson(Map<String, dynamic> json) {
    return DailyWeatherForecastEntry(
        date: DateTime.parse(json['id']),
        pressure: json['pressure'] == null
            ? null
            : double.parse(json['pressure'].toString()),
        humidity: json['humidity'] == null
            ? null
            : double.parse(json['humidity'].toString()),
        dewPoint: json['dew_point'] == null
            ? null
            : double.parse(json['dew_point'].toString()),
        clouds: json['clouds'] == null
            ? null
            : double.parse(json['clouds'].toString()),
        windSpeed: json['wind_speed'] == null
            ? null
            : double.parse(json['wind_speed'].toString()),
        windDeg: json['wind_deg'] == null
            ? null
            : double.parse(json['wind_deg'].toString()),
        windGust: json['wind_gust'] == null
            ? null
            : double.parse(json['wind_gust'].toString()),
        rain:
            json['rain'] == null ? null : double.parse(json['rain'].toString()),
        snow:
            json['snow'] == null ? null : double.parse(json['snow'].toString()),
        sunrise: json['sunrise'],
        sunset: json['sunset'],
        moonPhase: json['moon_phase'] == null
            ? null
            : double.parse(json['moon_phase'].toString()),
        temp: json['temp'] == null ? null : Temperature.fromJson(json['temp']),
        feelsLike: json['feels_like'] == null
            ? null
            : TemperatureFeelsLike.fromJson(json['feels_like']),
        weather: (json['weather'] as List)
            .map((i) => WeatherForecastTile.fromJson(i))
            .toList()
    );
  }
}

class HourlyWeatherForecastEntry {
  final DateTime date;

  final double? pressure;

  final double? humidity;

  final double? dewPoint;

  final double? clouds;

  final double? windSpeed;

  final double? windDeg;

  final double? windGust;

  final double? rain;

  final double? snow;

  final List<WeatherForecastTile> weather;

  final String? sunrise;

  final String? sunset;

  final double? moonPhase;

  // Changes are here

  final double? temp;

  final double? feelsLike;

  final int mins;

  HourlyWeatherForecastEntry({
    required this.date,
    this.pressure,
    this.humidity,
    this.dewPoint,
    this.clouds,
    this.windSpeed,
    this.windDeg,
    this.windGust,
    this.rain,
    this.snow,
    this.sunrise,
    this.sunset,
    this.moonPhase,
    this.temp,
    this.feelsLike,
    required this.mins,
    this.weather = const [],
  });

  factory HourlyWeatherForecastEntry.fromJson(Map<String, dynamic> json) {
    return HourlyWeatherForecastEntry(
        date: DateTime.parse(json['id']),
        pressure: json['pressure'] == null
            ? null
            : double.parse(json['pressure'].toString()),
        humidity: json['humidity'] == null
            ? null
            : double.parse(json['humidity'].toString()),
        dewPoint: json['dew_point'] == null
            ? null
            : double.parse(json['dew_point'].toString()),
        clouds: json['clouds'] == null
            ? null
            : double.parse(json['clouds'].toString()),
        windSpeed: json['wind_speed'] == null
            ? null
            : double.parse(json['wind_speed'].toString()),
        windDeg: json['wind_deg'] == null
            ? null
            : double.parse(json['wind_deg'].toString()),
        windGust: json['wind_gust'] == null
            ? null
            : double.parse(json['wind_gust'].toString()),
        rain:
            json['rain'] == null ? null : double.parse(json['rain'].toString()),
        snow:
            json['snow'] == null ? null : double.parse(json['snow'].toString()),
        sunrise: json['sunrise'],
        sunset: json['sunset'],
        moonPhase: json['moon_phase'] == null
            ? null
            : double.parse(json['moon_phase'].toString()),
        temp:
            json['temp'] == null ? null : double.parse(json['temp'].toString()),
        feelsLike: json['feels_like'] == null
            ? null
            : double.parse(json['feels_like'].toString()),
        mins: json['mins']!,
        weather: (json['weather'] as List)
            .map((i) => WeatherForecastTile.fromJson(i))
            .toList()
    );
  }
// },
}

class WeatherForecastTile {
  final int id;

  final String? description;

  final String? icon;

  WeatherForecastTile({
    required this.id,
    this.description,
    this.icon,
  });

  factory WeatherForecastTile.fromJson(Map<String, dynamic> json) {
    return WeatherForecastTile(
      id: json['id'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class Temperature {
  final double? day;

  final double? night;

  final double? eve;

  final double? morn;

  final double? min;

  final double? max;

  Temperature({
    this.day,
    this.night,
    this.eve,
    this.morn,
    this.min,
    this.max,
  });

  factory Temperature.fromJson(Map<String, dynamic> json) {
    return Temperature(
      day: json['day'] == null
          ? null
          : double.parse(json['day'].toString()),
      night: json['night'] == null
          ? null
          : double.parse(json['night'].toString()),
      eve: json['eve'] == null
          ? null
          : double.parse(json['eve'].toString()),
      morn: json['morn'] == null
          ? null
          : double.parse(json['morn'].toString()),
      min: json['min'] == null
          ? null
          : double.parse(json['min'].toString()),
      max: json['max'] == null
          ? null
          : double.parse(json['max'].toString()),
    );
  }
}

class TemperatureFeelsLike {
  final double? day;

  final double? night;

  final double? eve;

  final double? morn;

  TemperatureFeelsLike({
    this.day,
    this.night,
    this.eve,
    this.morn,
  });

  factory TemperatureFeelsLike.fromJson(Map<String, dynamic> json) {
    return TemperatureFeelsLike(
      day: json['day'] == null
          ? null
          : double.parse(json['day'].toString()),
      night: json['night'] == null
          ? null
          : double.parse(json['night'].toString()),
      eve: json['eve'] == null
          ? null
          : double.parse(json['eve'].toString()),
      morn: json['morn'] == null
          ? null
          : double.parse(json['morn'].toString()),
    );
  }
}
