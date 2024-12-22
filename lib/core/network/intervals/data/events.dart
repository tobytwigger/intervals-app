import 'package:intervals/locale/units.dart' as unit_locale;

class Events {
  final int id;

  final DateTime? startDate;

  final int? icuTrainingLoad;

  final double? atl;

  final double? ctl;

  final String? type;

  final String? uid;

  final String? athleteId;

  final EventCategory? category;

  final DateTime? endDate;

  final String? name;

  final String? description;

  final bool? indoor;

  final bool? notOnFitnessChart;

  final bool? showAsNote;

  final bool? showOnCtlLine;

  final WorkoutDoc? workoutDoc;

  final int? sharedEventId;

  final int? loadTarget;

  final int? timeTarget;

  final double? distanceTarget;

  final double? distance;

  final double? icuIntensity;

  final String? pairedActivityId;

  final int? joules;

  final int? joulesAboveFtp;

  final unit_locale.Time? movingTime;

  final String? color;

  Events({
    required this.id,
    this.startDate,
    this.icuTrainingLoad,
    this.atl,
    this.ctl,
    this.type,
    this.uid,
    this.athleteId,
    this.category,
    this.endDate,
    this.name,
    this.description,
    this.indoor,
    this.notOnFitnessChart,
    this.showAsNote,
    this.showOnCtlLine,
    this.workoutDoc,
    this.sharedEventId,
    this.loadTarget,
    this.timeTarget,
    this.distanceTarget,
    this.distance,
    this.icuIntensity,
    this.pairedActivityId,
    this.joules,
    this.joulesAboveFtp,
    this.movingTime,
    this.color,
  });

// TODO Use a better jsn serialization library
  factory Events.fromJson(Map<String, dynamic> json) {
    DateTime _startDateLocal = DateTime.parse(json['start_date_local']);
    DateTime _endDateLocal = DateTime.parse(json['end_date_local']);

    Events event = Events(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      startDate: _startDateLocal,
      icuTrainingLoad: json['icu_training_load'] as int?,
      atl: json['icu_atl'] as double?,
      ctl: json['icu_ctl'] as double?,
      type: json['type'] as String?,
      uid: json['uid'] as String?,
      athleteId: json['athlete_id'] as String?,
      category: EventCategory.values
          .byName((json['category'] as String).toLowerCase()),
      // TODO Catch if this errors
      endDate: _endDateLocal,
      name: json['name'] as String?,
      description: json['description'] as String?,
      indoor: json['indoor'] as bool?,
      notOnFitnessChart: json['not_on_fitness_chart'] as bool?,
      showAsNote: json['show_as_note'] as bool?,
      showOnCtlLine: json['show_on_ctl_line'] as bool?,
      movingTime: (json['moving_time'] as int?) != null
          ? unit_locale.Time(duration: Duration(seconds: json['moving_time']))
          : null,
      color: json['color'] as String?,
      workoutDoc: json['workout_doc'] == null
          ? null
          : WorkoutDoc.fromJson(json['workout_doc']),
      sharedEventId: json['shared_event_id'] as int?,
      loadTarget: json['load_target'] as int?,
      timeTarget: json['time_target'] as int?,
      distanceTarget: json['distance_target'] as double?,
      distance: json['distance'] as double?,
      icuIntensity: json['icu_intensity'] as double?,
      pairedActivityId: json['paired_activity_id'] as String?,
      joules: json['joules'] as int?,
      joulesAboveFtp: json['joules_above_ftp'] as int?,
    );

    return event;
  }

  bool get isInPast =>
      startDate?.isBefore(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day)) ??
      true;
}

class WorkoutDoc {
  final int? distance;

  final int? duration;

  final String? description;

  final int? averageWatts;

  final int? normalizedPower;

  final double? variabilityIndex;

  final double? polarizationIndex;

  final List<ZoneTimes> zoneTimes;

  final List<StepEntry> steps;

  WorkoutDoc({
    this.steps = const [],
    this.distance,
    this.duration,
    this.zoneTimes = const [],
    this.description,
    this.averageWatts,
    this.normalizedPower,
    this.variabilityIndex,
    this.polarizationIndex,
  });

  factory WorkoutDoc.fromJson(Map<String, dynamic> json) {
    List<ZoneTimes> localZoneTimes = ((json['zoneTimes'] ?? []) as List)
        .map((i) => ZoneTimes.fromJson(i))
        .toList();

    return WorkoutDoc(
      steps: (json['steps'] as List).map((i) => StepEntry.fromJson(i, localZoneTimes)).toList(),
      distance: json['distance'],
      duration: json['duration'],
      zoneTimes: localZoneTimes,
      description: json['description'],
      averageWatts: json['average_watts'],
      normalizedPower: json['normalized_power'],
      variabilityIndex: json['variability_index'],
      polarizationIndex: json['polarization_index'],
    );
  }
}

class ZoneTimes {
  final String id;

  final int? max;

  final String? name;

  final int? secs;

  final int? zone;

  final String? color;

  final int? maxWatts;

  final int? minWatts;

  final String? percentRange;

  ZoneTimes({
    required this.id,
    this.max,
    this.name,
    this.secs,
    this.zone,
    this.color,
    this.maxWatts,
    this.minWatts,
    this.percentRange,
  });

  factory ZoneTimes.fromJson(Map<String, dynamic> json) {
    return ZoneTimes(
      id: json['id'],
      max: json['max'],
      name: json['name'],
      secs: json['secs'],
      zone: json['zone'],
      color: json['color'],
      maxWatts: json['maxWatts'],
      minWatts: json['minWatts'],
      percentRange: json['percentRange'],
    );
  }
}

class StepEntry {
  final Step? step;

  final StepRepeat? stepRepeat;

  StepEntry({
    this.step,
    this.stepRepeat,
  });

  factory StepEntry.fromJson(Map<String, dynamic> json, List<ZoneTimes> zoneTimes) {
    if (json['reps'] != null) {
      return StepEntry(
        stepRepeat: StepRepeat.fromJson(json, zoneTimes),
      );
    }
    return StepEntry(
      step: Step.fromJson(json, zoneTimes),
    );
  }

  int? get duration {
    if (step != null) {
      return step!.duration;
    }

    if (stepRepeat != null) {
      return stepRepeat!.duration;
    }

    return null;
  }

  Power? get power {
    if (step != null) {
      return step!.power;
    }

    if (stepRepeat != null) {
      return stepRepeat!.steps.first.power;
    }

    return null;
  }
}

class StepRepeat {
  final int reps;

  final String? text;

  final List<Step> steps;

  final int? distance;

  final int? duration;

  StepRepeat({
    required this.reps,
    this.text,
    this.steps = const [],
    this.distance,
    this.duration,
  });

  factory StepRepeat.fromJson(Map<String, dynamic> json, List<ZoneTimes> zoneTimes) {
    return StepRepeat(
      reps: json['reps'],
      text: json['text'],
      steps: (json['steps'] as List).map((i) => Step.fromJson(i, zoneTimes)).toList(),
      distance: json['distance'],
      duration: json['duration'],
    );
  }
}

class Step {
  final Power? power;

  final bool warmup;

  final bool ramp;

  final int? duration;

  Step({
    this.power,
    this.warmup = false,
    this.ramp = false,
    this.duration,
  });

  factory Step.fromJson(Map<String, dynamic> json, List<ZoneTimes> zoneTimes) {
    return Step(
      ramp: (json['ramp'] ?? false) as bool,
      power: Power.fromJson(json['power'], zoneTimes),
      warmup: json['warmup'] ?? false,
      duration: json['duration'],
    );
  }
}

class Power {
  final String units;

  final unit_locale.Power? value;

  final double? max;

  final double? min;

  final String? colour;

  final double? end;

  final double? start;

  Power({
    required this.units,
    this.value,
    this.colour,
    this.max,
    this.min,
    this.end,
    this.start,
  });

  factory Power.fromJson(Map<String, dynamic> json, List<ZoneTimes> zoneTimes) {
    String u = json['units'] as String;
    double? v = (json['value'] is int)
        ? json['value'].toDouble()
        : json['value'] as double?;

    unit_locale.Power? valAsUnit = null;

    if(u == '%ftp' && v != null) {
      valAsUnit = unit_locale.Power.fromPercentOfFtp(v, zoneTimes);
    } else if(u == 'w') {
      valAsUnit = (v == null) ? null : unit_locale.Power(valueInWatts: v!);
    } else if (v != null && u != 'power_zone') {
      throw ArgumentError('Unknown power unit: $u');
    }

    return Power(
      units: json['units'] as String,
      value: valAsUnit,
      colour: v == null ? null : _getColourFromZone(v!, zoneTimes),
      max: (json['value'] is int)
          ? json['value'].toDouble()
          : json['value'] as double?,
      min: (json['value'] is int)
          ? json['value'].toDouble()
          : json['value'] as double?,
      end: (json['end'] is int)
          ? json['end'].toDouble()
          : json['end'] as double?,
      start: (json['start'] is int)
          ? json['start'].toDouble()
          : json['start'] as double?,
    );
  }

  static String _getColourFromZone(double val, List<ZoneTimes> zoneTimes) {
    // Order by minWatts
    zoneTimes.sort((a, b) => (a.minWatts ?? 0).compareTo((b.minWatts ?? 0)));

    // First zoneTime where max is greater than v
    ZoneTimes zoneTime = zoneTimes.firstWhere((zoneTime) => (zoneTime.max ?? 0) >= val);

    return zoneTime.color ?? 'grey';
  }

}

// TODO Ensure I've captured all the possible values, and handle the case where the value is not found
enum EventCategory {
  target,
  race_a,
  race_b,
  race_c,
  note,
  workout,
  season_start,
  sick;
}
