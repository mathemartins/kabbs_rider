import 'package:flutter/material.dart';
import 'package:kabbs_universal_rider/models/directions.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickLocation;
  Directions? userDropOffLocation;

  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    userPickLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }
}