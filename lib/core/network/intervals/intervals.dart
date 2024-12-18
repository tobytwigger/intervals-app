import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/core/network/intervals/data/athlete.dart';
import 'package:intervals/core/network/intervals/data/events.dart';
import 'package:intervals/core/network/intervals/data/map.dart';
import 'package:intervals/core/network/intervals/data/streams.dart';
import 'package:intervals/core/network/intervals/data/weather.dart';
import 'package:intervals/core/network/intervals/data/wellness.dart';
import 'package:intl/intl.dart';

class Intervals {
  final String apiKey;
  final String athleteId;

  const Intervals({
    required this.apiKey,
    required this.athleteId,
  });

  static const String baseUrl = 'https://intervals.icu/api/';

  String parseUrl(String url) {
    return baseUrl + url;
  }

  String get authToken {
    final headerString = 'API_KEY:${apiKey}';
    final bytes = utf8.encode(headerString);
    return base64.encode(bytes);
  }

  Future<IntervalUser> fetchCurrentUser() async {
    final response = await http.get(
        Uri.parse('https://intervals.icu/api/v1/athlete/${athleteId}/profile'),
        headers: {HttpHeaders.authorizationHeader: 'Basic ${authToken}'});

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // return IntervalUser(id: 1, name: 'T', email: 'tt@tt.com');
      return IntervalUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load current user');
    }
  }

  Future<List<Activity>> loadActivities({required int page}) async {
    // Page is actually = how many months ago to load, so we'll load a month at a time.
    var now = DateTime.now();
    var daysToSubtract = 4 * page * 60; // Load every 60 days.
    var newest = now.subtract(Duration(days: daysToSubtract));
    var oldest = newest.subtract(Duration(days: 60));

    return loadActivitiesInDuration(
        oldest: oldest,
        newest: newest
    );
  }

  Future<List<Activity>> loadActivitiesInDuration({required DateTime oldest, required DateTime newest}) async {
    final response = await http.get(
      Uri.parse('https://intervals.icu/api/v1/athlete/${athleteId}/activities?')
          .replace(
          queryParameters: {
            'oldest': oldest.toIso8601String(),
            'newest': newest.toIso8601String(),
          }
      ),
      headers: {HttpHeaders.authorizationHeader: 'Basic ${authToken}'},
    );

    if (response.statusCode == 200) {
      var activities = jsonDecode(response.body) as List<dynamic>;

      return activities.map((activity) => Activity.fromJson(activity as Map<String, dynamic>)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load activities');
    }
  }

  Future<Activity> loadActivity(String id) async {
    final response = await http.get(
      Uri.parse('https://intervals.icu/api/v1/activity/${id}'),
      headers: {HttpHeaders.authorizationHeader: 'Basic ${authToken}'},
    );

    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load activities');
    }
  }

  Future<MapData> getMapData(String activityId) async {
    final response = await http.get(
      Uri.parse('https://intervals.icu/api/v1/activity/${activityId}/map'),
      headers: {HttpHeaders.authorizationHeader: 'Basic ${authToken}'},
    );

    if (response.statusCode == 200) {
      return MapData.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load activities');
    }
  }

  Future<List<Wellness>> getWellnessData({required DateTime oldest, required DateTime newest}) async {
    final response = await http.get(
      Uri.parse('https://intervals.icu/api/v1/athlete/${athleteId}/wellness')
          .replace(
          queryParameters: {
            'oldest': DateFormat('yyyy-MM-dd').format(oldest),
            'newest': DateFormat('yyyy-MM-dd').format(newest),
          }
      ),
      headers: {HttpHeaders.authorizationHeader: 'Basic ${authToken}'},
    );

    if (response.statusCode == 200) {
      var wellnessMaps = jsonDecode(response.body) as List<dynamic>;

      return wellnessMaps.map((wellness) => Wellness.fromJson(wellness as Map<String, dynamic>)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load wellness data');
    }
  }

  Future<Wellness> getCurrentWellnessData() async {
    return await getWellnessDataForDay(DateTime.now());
  }

  Future<Wellness> getWellnessDataForDay(DateTime day) async {
    String date = DateFormat('yyyy-MM-dd').format(day);

    final response = await http.get(
      Uri.parse('https://intervals.icu/api/v1/athlete/${athleteId}/wellness/${date}'),
      headers: {HttpHeaders.authorizationHeader: 'Basic ${authToken}'},
    );

    if (response.statusCode == 200) {
      return Wellness.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load wellness');
    }
  }

  /// Gets all the events from intervals.icu
  ///
  /// This function will load all events between [oldest] and [newest] (which default
  /// to 'now' and 'now + 6 days' in intervals.
  ///
  /// The events can be filtered by [category], e.g. WORKOUT,NOTES
  Future<List<Events>> getEvents({
    DateTime? oldest,
    DateTime? newest,
    List<String> category = const [],
  }) async {
    Map<String, String> queryParamters = {};
    if(oldest != null) {
      queryParamters['oldest'] = DateFormat('yyyy-MM-dd').format(oldest);
    }
    if(newest != null) {
      queryParamters['newest'] = DateFormat('yyyy-MM-dd').format(newest);
    }
    if(category.length > 0) {
      queryParamters['category'] = category.join(',');
    }

    final response = await http.get(
      Uri.parse('https://intervals.icu/api/v1/athlete/${athleteId}/events')
          .replace(
          queryParameters: queryParamters
      ),
      headers: {HttpHeaders.authorizationHeader: 'Basic ${authToken}'},
    );

    if (response.statusCode == 200) {
      var eventsMap = jsonDecode(response.body) as List<dynamic>;
      return eventsMap.map((event) => Events.fromJson(event as Map<String, dynamic>)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load events data');
    }
  }

  Future<List<AthleteSummary>> getAthleteSummary({
    DateTime? start,
    DateTime? end
  }) async {
    var queryParams = Map.of({
      'start': null as String?,
      'end': null as String?
    });
    if(start != null) {
      queryParams['start'] = DateFormat('yyyy-MM-dd').format(start);
    }
    if(end != null) {
      queryParams['end'] = DateFormat('yyyy-MM-dd').format(end);
    }

    final response = await http.get(
      Uri.parse('https://intervals.icu/api/v1/athlete/${athleteId}/athlete-summary')
          .replace(
            queryParameters: queryParams
      ),
      headers: {HttpHeaders.authorizationHeader: 'Basic ${authToken}'},
    );

    if (response.statusCode == 200) {
      var athleteSummaries = jsonDecode(response.body) as List<dynamic>;

      // Sort summaries by start date
      athleteSummaries.sort((a, b) => a['date'].compareTo(b['date']));

      return athleteSummaries
          .where((athleteSummary) => athleteSummary['athlete_id'] == athleteId) // Filter all athletes but me
          .map((athleteSummary) => AthleteSummary.fromJson(athleteSummary as Map<String, dynamic>)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load athlete summaries');
    }
  }

  Future<Weather> getWeatherSummaryForActivity(String activityId) async {
    final response = await http.get(
      Uri.parse('https://intervals.icu/api/v1/activity/${activityId}/weather-summary'),
      headers: {HttpHeaders.authorizationHeader: 'Basic ${authToken}'},
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load activity weather summary');
    }
  }

  Future<List<StreamEntry>> getStreamsForActivity(String activityId, List<DefaultStreams> streams) async {
    final response = await http.get(
      Uri.parse('https://intervals.icu/api/v1/activity/${activityId}/streams')
          .replace(
          queryParameters: {
            'types': streams.map((stream) => stream.name).join(','),
          }
      ),
      headers: {HttpHeaders.authorizationHeader: 'Basic ${authToken}'},
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body) as List<dynamic>;
      List<FullStream> fullStreams = [];
      for(var j in json) {
        if(j['valueType'] == 'java.lang.Integer') {
          fullStreams.add(FullStream<int>.fromJson(j));
        } else if(j['valueType'] == 'java.lang.Float') {
          fullStreams.add(FullStream<double>.fromJson(j));
        } else {
          throw Exception('Unsupported type of ${j['valueType'].toString()}');
        }
      }

      // Check all streams have the same length
      int? length = null;
      for(var stream in fullStreams) {
        if(length == null) {
          length = stream.data.length;
        } else {
          assert(stream.data.length == length);
        }
      }

      List<StreamEntry> entries = [];
      // Iterate through [length]
      for (var i = 0; i < (length ?? 0); i++) {
        StreamEntry streamEntry = StreamEntry();
        for(var stream in fullStreams) {
          streamEntry = stream.addToEntry(streamEntry, i);
        }
        entries.add(streamEntry);
      }

      return entries;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load activity weather summary');
    }
  }

  Future<Events?> getEventById({required int eventId}) async {
    final response = await http.get(
      Uri.parse('https://intervals.icu/api/v1/athlete/${athleteId}/events/${eventId}'),
      headers: {HttpHeaders.authorizationHeader: 'Basic ${authToken}'},
    );

    if (response.statusCode == 200) {
      return Events.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else if(response.statusCode == 404) {
      return null;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load events data');
    }
  }

  Future<WeatherForecast> getWeatherForecast() async {
    final response = await http.get(
      Uri.parse('https://intervals.icu/api/v1/athlete/${athleteId}/weather-forecast'),
      headers: {HttpHeaders.authorizationHeader: 'Basic ${authToken}'},
    );

    List<dynamic> forecasts = (jsonDecode(response.body) as Map<String, dynamic>)['forecasts'] as List<dynamic>;

    if (response.statusCode == 200) {
      return WeatherForecast.fromJson((forecasts.first)! as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load weather forecast');
    }
  }
}
