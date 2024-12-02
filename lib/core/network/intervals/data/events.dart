class Events {
  final String id;

  final DateTime? startDate;

  final int? icuTrainingLoad;

  final double? atl;

  final double? ctl;

  final String? type;

  final String? uid;

  final String? athleteId;

  final String? category;

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
  });
// TODO Use a better jsn serialization library
  factory Events.fromJson(Map<String, dynamic> json) {
    DateTime _startDateLocal = DateTime.parse(json['start_date_local']);
    DateTime _endDateLocal = DateTime.parse(json['end_date_local']);

    Events event =  Events(
      id: json['id'] is int ? json['id'].toString() : json['id'] as String,
      startDate: _startDateLocal,
      icuTrainingLoad: json['icu_training_load'] as int?,
      atl: json['icu_atl'] as double?,
      ctl: json['icu_ctl'] as double?,
      type: json['type'] as String?,
      uid: json['uid'] as String?,
      athleteId: json['athlete_id'] as String?,
      category: json['category'] as String?,
      endDate: _endDateLocal,
      name: json['name'] as String?,
      description: json['description'] as String?,
      indoor: json['indoor'] as bool?,
      notOnFitnessChart: json['not_on_fitness_chart'] as bool?,
      showAsNote: json['show_as_note'] as bool?,
      showOnCtlLine: json['show_on_ctl_line'] as bool?,
      workoutDoc: json['workout_doc'] == null ? null : WorkoutDoc.fromJson(json['workout_doc']),
      sharedEventId: json['shared_event_id'] as int?,
      loadTarget: json['load_target'] as int?,
      timeTarget: json['time_target'] as int?,
      distanceTarget: json['distance_target'] as double?,
      distance: json['distance'] as double?,
      icuIntensity: json['icu_intensity'] as double?,
      pairedActivityId: json['paired_activity_id'] as String?,
    );

    return event;
  }

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
    return WorkoutDoc(
      steps: (json['steps'] as List).map((i) => StepEntry.fromJson(i)).toList(),
      distance: json['distance'],
      duration: json['duration'],
      zoneTimes: ((json['zoneTimes'] ?? []) as List).map((i) => ZoneTimes.fromJson(i)).toList(),
      description: json['description'],
      averageWatts: json['averageWatts'],
      normalizedPower: json['normalizedPower'],
      variabilityIndex: json['variabilityIndex'],
      polarizationIndex: json['polarizationIndex'],
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

  factory StepEntry.fromJson(Map<String, dynamic> json) {
    if(json['reps'] != null) {
      return StepEntry(
        stepRepeat: StepRepeat.fromJson(json),
      );
    }
    return StepEntry(
      step: Step.fromJson(json),
    );
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

  factory StepRepeat.fromJson(Map<String, dynamic> json) {
    return StepRepeat(
      reps: json['reps'],
      text: json['text'],
      steps: (json['steps'] as List).map((i) => Step.fromJson(i)).toList(),
      distance: json['distance'],
      duration: json['duration'],
    );
  }
}

class Step {
  final Power? power;

  final bool? warmup;

  final int? duration;

  Step({
    this.power,
    this.warmup,
    this.duration,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      power: Power.fromJson(json['power']),
      warmup: json['warmup'],
      duration: json['duration'],
    );
  }
}

class Power {
  final String units;

  final double? value;

  final double? max;

  final double? min;

  Power({
    required this.units,
    this.value,
    this.max,
    this.min,
  });

  factory Power.fromJson(Map<String, dynamic> json) {
    return Power(
      units: json['units'] as String,
      value: (json['value'] is int) ? json['value'].toDouble() : json['value'] as double?,
      max: (json['value'] is int) ? json['value'].toDouble() : json['value'] as double?,
      min: (json['value'] is int) ? json['value'].toDouble() : json['value'] as double?,
    );
  }
}