class IntervalUser {
  final Athlete athlete;

  const IntervalUser({
    required this.athlete,
  });

  factory IntervalUser.fromJson(Map<String, dynamic> json) {
    return IntervalUser(athlete: Athlete.fromJson(json['athlete']));
  }

}

class Athlete {
  final String id;
  final String name;
  final String? profile_medium;
  final String? city;
  final String? state;
  final String? country;
  final String? timezone;
  final String? sex;
  final String? bio;
  final String? website;
  final String? email;

  Athlete({required this.id,
    required this.name,
    this.profile_medium,
    this.city,
    this.state,
    this.country,
    this.timezone,
    this.sex,
    this.bio,
    this.website,
    this.email});

  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: json['id'],
      name: json['name'],
      profile_medium: json['profile_medium'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      timezone: json['timezone'],
      sex: json['sex'],
      bio: json['bio'],
      website: json['website'],
      email: json['email'],
    );
  }
}

class AthleteSummary {
  final int? movingTime;

  final int? elapsedTime;

  final int? calories;

  final double? totalElevationGain;

  final int? trainingLoad;

  final double? distance;

  final DateTime startDate;

  final Map<PowerZone, TimeInZone> timeInZones;

  final Map<String, SportSummary> sportSummaries;

  // TODO Handle categories (e.g. splitting goals by sport)

  AthleteSummary({
    required this.startDate,
    this.movingTime,
    this.elapsedTime,
    this.calories,
    this.totalElevationGain,
    this.trainingLoad,
    this.distance,
    this.timeInZones = const {},
    this.sportSummaries = const {},
  });

  factory AthleteSummary.fromJson(Map<String, dynamic> json) {
    List<int> timeInZonesList = (json['timeInZones'] as List<dynamic>)
        .map((e) => e as int)
        .toList();


    // List<int> timeInZonesList = json['timeInZones'] as List<int>;

    Map<PowerZone, TimeInZone> timeInZones = {};
    Map<String, SportSummary> sportSummaries = {};

    // Check length of timeInZones is 8
    if(json.containsKey('timeInZones') && json['timeInZones'] != null && json['timeInZones'].length == 8) {
      PowerZone.values.forEach((zone) {
        timeInZones[zone] = TimeInZone(
          zone: zone,
          timeInZone: Duration(
              seconds: timeInZonesList[PowerZone.values.indexOf(zone)]
          ),
        );
      });
    }

    // Check length of timeInZones is 8
    if(json.containsKey('byCategory') && json['byCategory'] != null && json['byCategory'].length > 0) {
      json['byCategory'].forEach((categoryData) {
        sportSummaries[categoryData['category']] = SportSummary.fromJson(categoryData);
      });
    }

    return AthleteSummary(
      startDate: DateTime.parse(json['date']),
      movingTime: json['moving_time'],
      elapsedTime: json['elapsed_time'],
      calories: json['calories'],
      totalElevationGain: json['total_elevation_gain'],
      trainingLoad: json['training_load'],
      distance: json['distance'],
      timeInZones: timeInZones,
      sportSummaries: sportSummaries,
    );
  }
}

class TotalsCalculator {
  final List<AthleteSummary> athleteSummaries;
  Map<String, SportSummary> sportSummaries = {};

  TotalsCalculator(this.athleteSummaries) {
    // Save new summaries here
    Map<String, SportSummary> summaries = {};

    // Iterate through each of the weekly summaries
    athleteSummaries.forEach((element) {
      // Iterate through each of the sports
      element.sportSummaries.forEach((key, value) {
        // Try and add the summary to the existing summary
        if(summaries.containsKey(key)) {
          summaries[key] = SportSummary(
            movingTime: (summaries[key]?.movingTime ?? 0) + value.movingTime!,
            elapsedTime: (summaries[key]?.elapsedTime ?? 0) + value.elapsedTime!,
            calories: (summaries[key]?.calories ?? 0) + value.calories!,
            totalElevationGain: (summaries[key]?.totalElevationGain ?? 0) + value.totalElevationGain!,
            trainingLoad: (summaries[key]?.trainingLoad ?? 0) + value.trainingLoad!,
            distance: (summaries[key]?.distance ?? 0) + value.distance!,
            category: key,
          );
        } else {
          summaries[key] = value;
        }
      });
    });

    sportSummaries = summaries;
  }

  double get totalDistance {
    return athleteSummaries.fold(0, (previousValue, element) => previousValue + (element.distance ?? 0));
  }

  int get totalTime {
    return athleteSummaries.fold(0, (previousValue, element) => previousValue + (element.movingTime ?? 0));
  }

  int get totalCalories {
    return athleteSummaries.fold(0, (previousValue, element) => previousValue + (element.calories ?? 0));
  }

  double get totalElevationGain {
    return athleteSummaries.fold(0, (previousValue, element) => previousValue + (element.totalElevationGain ?? 0));
  }

  int get totalTrainingLoad {
    return athleteSummaries.fold(0, (previousValue, element) => previousValue + (element.trainingLoad ?? 0));
  }

  Duration timeInZone(PowerZone powerZone) {
    return Duration(
      seconds: athleteSummaries.fold(0, (previousValue, element) => previousValue + (element.timeInZones[powerZone]?.timeInZone.inSeconds ?? 0))
    );
  }

}


enum PowerZone {
  z1,
  z2,
  z3,
  z4,
  z5,
  z6,
  z7,
  ss
}

class TimeInZone {
  final PowerZone zone;

  final Duration timeInZone;

  TimeInZone({required this.zone, required this.timeInZone});
}

class SportSummary {
  final int? movingTime;

  final int? elapsedTime;

  final int? calories;

  final double? totalElevationGain;

  final int? trainingLoad;

  /// Distance in meters
  final double? distance;

  final String category;

  SportSummary({
    this.movingTime,
    this.elapsedTime,
    this.calories,
    this.totalElevationGain,
    this.trainingLoad,
    this.distance,
    required this.category,
  });

  factory SportSummary.fromJson(Map<String, dynamic> json) {
    return SportSummary(
      movingTime: json['moving_time'],
      elapsedTime: json['elapsed_time'],
      calories: json['calories'],
      totalElevationGain: json['total_elevation_gain'],
      trainingLoad: json['training_load'],
      distance: json['distance'],
      category: json['category'],
    );
  }

  @override
  String toString() {
    return 'SportSummary{movingTime: $movingTime, elapsedTime: $elapsedTime, calories: $calories, totalElevationGain: $totalElevationGain, trainingLoad: $trainingLoad, distance: $distance, category: $category}';
  }
}