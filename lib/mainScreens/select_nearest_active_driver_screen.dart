import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kabbs_universal_rider/assistants/assistant_methods.dart';
import 'package:kabbs_universal_rider/global/global.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class SelectNearestActiveDriverScreen extends StatefulWidget {
  DatabaseReference referenceRideRequest;

  SelectNearestActiveDriverScreen({required this.referenceRideRequest});
  @override
  _SelectNearestActiveDriverScreenState createState() => _SelectNearestActiveDriverScreenState();
}

class _SelectNearestActiveDriverScreenState extends State<SelectNearestActiveDriverScreen> {
  String fareAmount = "";

  String getFareAmountAccordingToVehicleType(int index) {
    if (tripDirectionDetailsInfo != null) {
      if(dList[index]["car_details"]["type"].toString() == "bike") {
        fareAmount = (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) / 2).toStringAsFixed(0);
      }
      if(dList[index]["car_details"]["type"].toString() == "kabbs-regular") {
        fareAmount = (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!)).toString();
      }
      if(dList[index]["car_details"]["type"].toString() == "kabbs-go") {
        fareAmount = (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) / 1.5).toStringAsFixed(0);
      }
    }
    return fareAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text("Available Drivers", style: TextStyle(fontSize: 14),),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            widget.referenceRideRequest.remove();
            Fluttertoast.showToast(msg: "You have cancelled your ride!");
            SystemNavigator.pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: dList.length,
        itemBuilder: (BuildContext context, int index){
          return Card(
            color: Colors.grey,
            elevation: 3,
            shadowColor: Colors.black,
            margin: EdgeInsets.all(8),
            child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Image.asset("images/" + dList[index]["car_details"]["type"].toString() + ".png", width: 40,),
                ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(dList[index]["name"], style: TextStyle(fontSize: 12, color: Colors.black)),
                  Text(dList[index]["car_details"]["car_model"], style: TextStyle(fontSize: 12, color: Colors.black)),
                  SmoothStarRating(
                      allowHalfRating: false,
                      starCount: 5,
                      rating: 3.5,
                      size: 13.0,
                      color: Colors.black,
                      borderColor: Colors.black,
                      spacing:0.0
                  )
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "\₦ " + getFareAmountAccordingToVehicleType(index),
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  SizedBox(height: 1.0),
                  Text(
                      tripDirectionDetailsInfo != null ? tripDirectionDetailsInfo!.duration_text! : "",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                  ),
                  SizedBox(height: 1.0),
                  Text(
                      tripDirectionDetailsInfo != null ? tripDirectionDetailsInfo!.distance_text! : "",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}


