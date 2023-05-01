import 'package:kabbs_universal_rider/models/active_nearby_available_drivers.dart';

class GeofireAssistant {
  static List<ActiveNearbyAvailableDrivers> activeNearbyAvailableDriversList = [];
  static void deleteOfflineDriverFromList(String driverId) {
    int indexNumber = activeNearbyAvailableDriversList.indexWhere((element) => element.driverId == driverId);
    activeNearbyAvailableDriversList.removeAt(indexNumber);
  }
  static void updateActiveNearbyAvailableDriverLocation(ActiveNearbyAvailableDrivers driverOnTheMove){
    int indexNumber = activeNearbyAvailableDriversList.indexWhere((element) => element.driverId == driverOnTheMove.driverId);
    activeNearbyAvailableDriversList[indexNumber].locationLatitude = driverOnTheMove.locationLatitude;
    activeNearbyAvailableDriversList[indexNumber].locationLongitude = driverOnTheMove.locationLongitude;
  }
}