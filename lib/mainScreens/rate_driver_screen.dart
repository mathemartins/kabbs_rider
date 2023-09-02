import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kabbs_universal_rider/global/global.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class RateDriverScreen extends StatefulWidget {
  String? assignedDriverId;
  RateDriverScreen({this.assignedDriverId});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.black38,
          child: Container(
            margin: const EdgeInsets.all(8),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 18,),
                const Text("RATE YOUR RIDE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 18,),
                const Divider(color: Colors.blueGrey, thickness: 1, height: 1,),
                const SizedBox(height: 18,),
                SmoothStarRating(
                  rating: countRatingStar,
                  allowHalfRating: false,
                  color: Colors.amber,
                  borderColor: Colors.amber,
                  starCount: 5,
                  size: 40,
                  onRatingChanged: (valueOfStarsChosen){
                    countRatingStar = valueOfStarsChosen;
                    if (countRatingStar == 1) {
                      setState(() {
                        titleStarsRating = "Very Bad";
                      });
                    }

                    if (countRatingStar == 2) {
                      setState(() {
                        titleStarsRating = "Bad";
                      });
                    }

                    if (countRatingStar == 3) {
                      setState(() {
                        titleStarsRating = "Good";
                      });
                    }

                    if (countRatingStar == 4) {
                      setState(() {
                        titleStarsRating = "Very Good";
                      });
                    }

                    if (countRatingStar == 5) {
                      setState(() {
                        titleStarsRating = "Excellent";
                      });
                    }
                  },
                ),
                const SizedBox(height: 8,),
                Text(titleStarsRating.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black),),
                const SizedBox(height: 18),
                ElevatedButton(
                    onPressed: (){
                      DatabaseReference rateDriverReference = FirebaseDatabase.instance.ref().child("drivers").child(widget.assignedDriverId!).child("ratings");
                      rateDriverReference.once().then((snap) {
                        if (snap.snapshot.value == null) {
                          rateDriverReference.set(countRatingStar.toString());
                          SystemNavigator.pop();
                        } else {
                          double pastRatings = double.parse(snap.snapshot.value.toString());
                          double newAverageRatings = (pastRatings + countRatingStar) / 2;
                          rateDriverReference.set(newAverageRatings.toString());
                          SystemNavigator.pop();
                        }
                        Fluttertoast.showToast(msg: "Restarting app now!");
                      });
                    },
                    style: ElevatedButton.styleFrom(primary: Colors.blueGrey, padding: EdgeInsets.symmetric(horizontal: 70)),
                    child: const Text("Submit", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white)),

                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
      ),
    );
  }
}
