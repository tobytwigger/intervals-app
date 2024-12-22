import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconRepository {

  static IconData fromSport(String? sport) {
    if(sport == 'Ride') {
      return Icons.directions_bike_outlined;
    }
    if(sport == 'VirtualRide') {
      return Icons.electric_bike;
    }
    return Icons.question_mark;
  }


}