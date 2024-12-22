import 'package:duration/duration.dart';
import 'package:intervals/core/network/intervals/data/events.dart' as intervals_events;
import 'package:units_converter/units_converter.dart' as converter;

class Length {
  final double lengthInMeters;

  Length({
    required this.lengthInMeters
  });

  factory Length.fromMeters(double length) {
    return Length(lengthInMeters: length);
  }

  String get lengthInKilometers => (lengthInMeters / 1000).toStringAsFixed(2);

  String display() {
    if(lengthInMeters < 1000) {
      return '${lengthInMeters.toStringAsFixed(0)} m';
    }

    return '${lengthInKilometers} km';
  }
}

class Time {
  final Duration duration;

  Time({
    required this.duration,
  });

  String display() {
    String prettifiedText = duration.pretty(
      upperTersity: DurationTersity.hour,
      abbreviated: true,
      delimiter: '',
      spacer: '',
    );

    // replace 'min' with 'm',
    prettifiedText = prettifiedText.replaceAll('min', 'm');

    return prettifiedText;
  }

  factory Time.fromSeconds(int seconds) {
    return Time(duration: Duration(seconds: seconds));
  }
}

class Power {

  final double valueInWatts;

  Power({
    required this.valueInWatts,
  });

  factory Power.fromPercentOfFtp(double percentageOfFtp, List<intervals_events.ZoneTimes> zoneTimes) {
    // Order by minWatts
    zoneTimes.sort((a, b) => (a.minWatts ?? 0).compareTo((b.minWatts ?? 0)));

    // First zoneTime where max is greater than v
    intervals_events.ZoneTimes zoneTime = zoneTimes.firstWhere((zoneTime) => (zoneTime.max ?? 0) >= percentageOfFtp);

    double ftp = ((zoneTime.maxWatts ?? 0) * 100) / (zoneTime.max!);

    double valueInWatts = ftp * percentageOfFtp;

    // Find the time of zone which has max and min around v
    return Power(valueInWatts: valueInWatts);
  }

}