class MapData {
  final List<LatLng> coordinates;

  final LatLng topLeftBound;

  final LatLng bottomRightBound;

  MapData({
    required this.coordinates,
    required this.topLeftBound,
    required this.bottomRightBound,
  });

  factory MapData.fromJson(Map<String, dynamic> json) {

    // Determine bounds
    // List<LatLng> bounds = new List<List<double>>.from(json['bounds']);
    // List<LatLng> coordinates = new List<List<double>>.from(json['latlngs']);

    var listOfLatLngs = json['latlngs'] as List;
    var listOfBounds = json['bounds'] as List;

    return MapData(
        coordinates: listOfLatLngs.where((i) => i != null)
            .map((i) => LatLng.fromJson(i)).toList(),
        topLeftBound: LatLng.fromJson(listOfBounds[0]),
        bottomRightBound: LatLng.fromJson(listOfBounds[1]),
    );
  }

}

class LatLng {
  final double lat;

  final double lng;

  LatLng({
    required this.lat,
    required this.lng,
  });

  factory LatLng.fromJson(List<dynamic> json) {
    return LatLng(lat: json[0], lng: json[1]);
  }

}