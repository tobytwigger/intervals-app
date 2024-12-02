import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intervals/core/network/intervals/data/activity.dart';
import 'package:intervals/core/network/intervals/data/athlete.dart';
import 'package:intervals/core/network/intervals/data/events.dart';
import 'package:intervals/core/network/intervals/data/map.dart';
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
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

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
}
