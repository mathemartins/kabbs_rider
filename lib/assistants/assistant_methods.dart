import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kabbs_universal_rider/assistants/request_assistant.dart';
import 'package:kabbs_universal_rider/global/global.dart';
import 'package:kabbs_universal_rider/global/map_key.dart';
import 'package:kabbs_universal_rider/infoHandler/app_info.dart';
import 'package:kabbs_universal_rider/models/direction_details_info.dart';
import 'package:kabbs_universal_rider/models/directions.dart';
import 'package:kabbs_universal_rider/models/trip_history_model.dart';
import 'package:kabbs_universal_rider/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AssistantMethods {

  static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async
  {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress="";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if(requestResponse != "Error Occurred, Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static void readCurrentOnlineUserInfo() async{
    currentFirebaseUser = firebaseAuth.currentUser!; //FirebaseAuth.instance.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child("users").child(currentFirebaseUser!.uid);
    userRef.once().then((snap){
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
        print("name: " + userModelCurrentInfo!.name.toString());
      }
    });
  }

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng origionPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${origionPosition.latitude},${origionPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    if(responseDirectionApi == "Error Occurred, Failed. No Response.") {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){
    double baseFare = 300;
    double timeTravalledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 100;
    double distanceTravelledFareAmountPerKilometer = (directionDetailsInfo.duration_value! / 1000) * 100;
    double totalFareAmount = timeTravalledFareAmountPerMinute + distanceTravelledFareAmountPerKilometer + baseFare;

    return double.parse(totalFareAmount.toStringAsExponential(1));
  }

  static void sendNotificationToDriverNow(String deviceRegistrationToken, String userRideRequestId, context) async {
    String destinationAddress = userDropOffAddress;
    Map<String, String> headerNotification= {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map<String, String> bodyNotification={
      "body": "Destination: \n $destinationAddress",
      "title": "Hey!, You have a new ride request",
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": 1,
      "status": "done",
      "rideRequestId": userRideRequestId!
    };

    Map officialFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken
    };

    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"), headers: headerNotification, body: jsonEncode(officialFormat),
    );
  }

  // retrieve trip keys for active user
  // trip key = rideRequestId
  static void readTripKeysForOnlineUser(context){
    FirebaseDatabase.instance.ref().child("All Ride Requests").orderByChild("username").equalTo(userModelCurrentInfo!.name).once().then((snap) {
      if (snap.snapshot.value != null) {
        Map keysTripsId = snap.snapshot.value as Map;

        // Count total trips and share it with the provider
        int overallTripCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false).updateOverallTripCounter(overallTripCounter);

        // Share trip keys with provider
        List<String> tripsKeyList = [];
        keysTripsId.forEach((key, value) {
          tripsKeyList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateOverallTripKeys(tripsKeyList);

        // Get trip keys data
        readTripsHistoryInformation(context);
      }  
    });
  }

  static void readTripsHistoryInformation(context) {
    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeyList;
    for(String eachKey in tripsAllKeys) {
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(eachKey).once().then((value) {
        var eachTripHistory = TripHistoryModel.fromSnapshot(value.snapshot);
        if ((value.snapshot.value as Map)["status"] == "ended") {
          Provider.of<AppInfo>(context, listen: false).updateOverallTripInformation(eachTripHistory);
        }
      });
    }
  }
}