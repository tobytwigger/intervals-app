import 'dart:convert';
import 'package:intervals/lib/core/network/intervals/data/skyline_chart.pb.dart';
import 'package:intervals/locale/units.dart'; // Import the generated Protobuf file

class Activity {
  final String id;

  String? name;

  String? description;

  DateTime? startDateLocal;

  String? type;

  int? icuTrainingLoad;

  int? icuRecordingTime;

  int? elapsedTime;

  Length? distance;

  Time? movingTime;

  double? totalElevationGain;

  double? maxSpeed;

  double? averageSpeed;

  String? skylineChartBytes; // Base64-encoded Protobuf string

  double? compliance;

  String? source;

  int? powerLoad;

  int? hrLoad;

  double? icuIntensity;

  int? pairedEventId;

  SkylineChart? get skylineChartData {
    String? encodedData = skylineChartBytes;
    if (encodedData == null) {
      return null;
    }

    /*
      Install protoc:
        https://grpc.io/docs/protoc-installation/

      Compile the schema
        https://pub.dev/packages/protoc_plugin
        protoc --dart_out=lib skyline_chart.proto
     */

    // Decode Base64 to raw bytes
    final decodedBytes = base64Decode(encodedData);

    // Parse the Protobuf bytes
    return SkylineChart.fromBuffer(decodedBytes);
  }

  Activity({
    required this.id,
    this.name,
    this.description,
    this.startDateLocal,
    this.type,
    this.icuTrainingLoad,
    this.icuRecordingTime,
    this.elapsedTime,
    this.distance,
    this.movingTime,
    this.totalElevationGain,
    this.maxSpeed,
    this.averageSpeed,
    this.skylineChartBytes,
    this.compliance,
    this.source,
    this.powerLoad,
    this.hrLoad,
    this.icuIntensity,
    this.pairedEventId,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    DateTime? _startDateLocal = null;

    try {
      _startDateLocal = DateTime.parse(json['start_date_local']);
    } catch (e) {
      _startDateLocal = null;
    }

    return Activity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDateLocal: _startDateLocal,
      type: json['type'],
      icuTrainingLoad: json['icu_training_load'],
      icuRecordingTime: json['icu_recording_time'],
      elapsedTime: json['elapsed_time'],
      distance: json['distance'] == null ? null : Length.fromMeters(json['distance']),
      movingTime: json['moving_time'] != null ? Time(duration: Duration(seconds: json['moving_time'])) : null,
      totalElevationGain: json['total_elevation_gain'],
      maxSpeed: json['max_speed'],
      averageSpeed: json['average_speed'],
      skylineChartBytes: json['skyline_chart_bytes'],
      compliance: json['compliance'],
      source: json['source'],
      powerLoad: json['power_load'],
      hrLoad: json['hr_load'],
      icuIntensity: json['icu_intensity'],
      pairedEventId: json['paired_event_id'] as int?,
    );
  }

  static Object toWidgetMap(Activity activity) {
    final activityWidgetObj = {
      'name': activity.name,
    };

    return activityWidgetObj;
  }

  String toString() {
    return 'Activity: $name';
  }
}