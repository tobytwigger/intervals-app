import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intervals/core/network/intervals/intervals.dart';
import 'package:intervals/data/data/authenticated_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticatedUserModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  AuthenticatedUser? user;

  bool _isLoggingIn = false;

  bool get isLoggingIn => _isLoggingIn;

  /// Check if the user is logged in.
  bool get isLoggedIn => user != null;

  Future<void> initToken() async {
    final prefs = await SharedPreferences.getInstance();

    String? apiKey = prefs.getString('apiKey');
    String? athleteId = prefs.getString('athleteId');

    if (apiKey != null && athleteId != null) {
      await logIn(apiKey, athleteId);
    }
  }

  // Log the user in
  Future<bool> logIn(String newToken, String athleteId) async {
    _isLoggingIn = true;
    notifyListeners();

    // Make a request to get the athlete.dart
    try {
      var intervalsUser =
          await Intervals(apiKey: newToken, athleteId: athleteId)
              .fetchCurrentUser();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('apiKey', newToken);
      await prefs.setString('athleteId', athleteId);

      user = AuthenticatedUser(
          token: newToken,
          athleteId: athleteId,
          name: intervalsUser.athlete.name);
    } on Exception {
      user = null;
    }

    _isLoggingIn = false;

    notifyListeners();

    return user != null;
  }

  /// Removes all items from the cart.
  Future<void> logOut() async {
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('apiKey');
    await prefs.remove('athleteId');

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  Intervals? getIntervalsClient() {
    if(isLoggedIn && user != null) {
      return new Intervals(
          apiKey: user!.token,
          athleteId: user!.athleteId
      );
    }

    return null;
  }
}
