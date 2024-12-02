import 'package:flutter/material.dart';

class AppIcons {
  static const IconData VirtualRide = Icons.electric_bike;
  static const IconData Ride = Icons.pedal_bike;
  static const IconData WeightTraining = Icons.fitness_center;

  static IconData fromActivityType(String? type) {
    switch (type) {
      case 'Ride':
        return Ride;
        break;
      case 'VirtualRide':
        return VirtualRide;
        break;
      case 'WeightTraining':
        return WeightTraining;
        break;
      default:
        return Icons.question_mark;
        break;
    }
  }
}