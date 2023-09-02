import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AboutScreen extends StatefulWidget {

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Container(
            height: 230,
            child: Center(
              child: Image.asset("images/car_logo.png", width: 260),
            ),
          ),

          Column(
            children: [
              // Company
              Text("KABBS Universal", style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black
              )),

              const SizedBox(height: 20.0),

              // About company
              Text(
                  "KABBS Universal is a dynamic and innovative ride-sharing and logistics company that has"
                  "redefined the way people and goods move within urban landscapes. Founded on the "
                  "principles of convenience, efficiency, and reliability, KABBS Universal has emerged as a "
                  "prominent player in the transportation industry.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black
              )),

              const SizedBox(height: 10.0),

              Text("Transportation Services:", style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              )),

              const SizedBox(height: 10.0),

              Text(
                  "We offer a wide range of transportation services to cater to the diverse needs "
                  "of its customers. Whether it's a convenient ride from one location to another or efficient "
                  "logistics solutions for businesses, KABBS Universal has it covered.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black
                  )),

              const SizedBox(height: 10.0),

              Text("Ride-Sharing Platform:", style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              )),

              const SizedBox(height: 10.0),

              Text(
                  "As a ride-sharing platform, KABBS Universal connects passengers with experienced and "
                  "professional drivers. Through a user-friendly mobile app, customers can easily request rides, "
                  "track their drivers in real-time, and enjoy safe and comfortable journeys to their destinations.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black
                  )),

              const SizedBox(height: 10.0),

              Text("Logistics Expertise:", style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              )),

              const SizedBox(height: 10.0),

              Text(
                  "Beyond ride-sharing, KABBS Universal has extended its expertise to the world of logistics. "
                  "The company provides businesses with streamlined and cost-effective logistics solutions, "
                  "ensuring the timely and secure delivery of goods. With a robust network of drivers and a "
                  "commitment to punctuality, KABBS Universal is a trusted partner for businesses seeking"
                  "efficient supply chain management.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black
                  )),

              const SizedBox(height: 20.0),

              Text("Innovation and Technology:", style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              )),

              const SizedBox(height: 10.0),

              Text(
                  "At the core of KABBS Universal's success is its dedication to innovation and technology. The "
                  "company employs cutting-edge tools and algorithms to optimize routes, minimize wait "
                  "times, and enhance the overall transportation experience. This commitment to staying at the"
                  "forefront of technological advancements sets KABBS Universal apart in the industry.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black
                  )),

              const SizedBox(height: 20.0),

              ElevatedButton(
                  onPressed: () => SystemNavigator.pop(),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blueGrey
                  ),
                  child: Text("close", style: TextStyle(color: Colors.white))
              ),

              const SizedBox(height: 20.0),
            ],
          )
        ],
      ),
    );
  }
}
