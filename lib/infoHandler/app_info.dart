import 'package:flutter/material.dart';
import 'package:kabbs_universal_rider/models/directions.dart';
import 'package:kabbs_universal_rider/models/trip_history_model.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickLocation;
  Directions? userDropOffLocation;
  int? countTotalTrips = 0;
  List<String> historyTripsKeyList = [];
  List<TripHistoryModel> allTripHistoryInformationList = [];


  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    userPickLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  void updateOverallTripCounter(int overallTripCounter) {
    countTotalTrips = overallTripCounter;
    notifyListeners();
  }

  void updateOverallTripKeys(List<String> tripsKeyList) {
    historyTripsKeyList = tripsKeyList;
    notifyListeners();
  }

  void updateOverallTripInformation(TripHistoryModel eachTripHistory) {
    allTripHistoryInformationList.add(eachTripHistory);
    notifyListeners();
  }
}