enum DefaultStreams {
  time, watts, cadence, heartrate, distance, altitude, latlng, velocity_smooth, moving, grade_smooth, temp, torque, wind_speed, wind_deg, apparent_wind_deg
}

class StreamEntry {
  int? windDegrees;

  int? apparentWindDegrees;

  double? windSpeed;

  StreamEntry({
    this.windDegrees,
    this.apparentWindDegrees,
    this.windSpeed
  });
}

class FullStream<T> {
  final DefaultStreams type;

  final List<T?> data;

  FullStream({
    required this.type,
    required this.data
  });

  factory FullStream.fromJson(Map<String, dynamic> json) {
    List<T?> dataList = List<T?>.from(json['data'] as List);

    return FullStream<T>(
        type: DefaultStreams.values.byName(json['type']),
        data: dataList
    );
  }

  StreamEntry addToEntry(StreamEntry streamEntry, int i) {
    try {
      switch (type) {
        case DefaultStreams.wind_speed:
          streamEntry.windSpeed = data[i] == null ? null : double.parse(data[i].toString());
        case DefaultStreams.wind_deg:
          streamEntry.windDegrees = data[i] == null ? null : int.parse(data[i].toString());
        case DefaultStreams.apparent_wind_deg:
          streamEntry.apparentWindDegrees = data[i] == null ? null : int.parse(data[i].toString());
        default:
          throw Exception('Type of ${type.name} not supported yet');

      }
    } catch (e) {
      throw Exception('Could not cast type ${type.name} for value ${data[i].toString()}');
    }

    return streamEntry;
  }

}