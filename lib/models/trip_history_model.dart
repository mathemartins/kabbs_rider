import 'package:firebase_database/firebase_database.dart';

class TripHistoryModel {
  String? originAddress, destinationAddress, status, fareAmount, carDetails, driverName;
  int? time;

  TripHistoryModel({
    this.originAddress, this.destinationAddress, this.status, this.fareAmount,
    this.carDetails, this.driverName, this.time
  });

  TripHistoryModel.fromSnapshot(DataSnapshot snapshot) {
    print(snapshot.value as Map);
    time = (snapshot.value as Map)["time"] as int;
    originAddress = (snapshot.value as Map)["originAddress"];
    destinationAddress = (snapshot.value as Map)["destinationAddress"];
    status = (snapshot.value as Map)["status"];
    fareAmount = (snapshot.value as Map)["fareAmount"];
    carDetails = (snapshot.value as Map)["carDetails"];
    driverName = (snapshot.value as Map)["driverName"];

    print(time);
  }

  // Add a method to convert the epoch timestamp to a DateTime object.
  DateTime? getDateTimeFromTimestamp() {
    if (time != null) {
      return DateTime.fromMillisecondsSinceEpoch(time!);
    }
    return null;
  }
}