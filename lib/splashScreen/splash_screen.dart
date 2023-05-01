import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kabbs_universal_rider/assistants/assistant_methods.dart';
import 'package:kabbs_universal_rider/authentication/login_screen.dart';
import 'package:kabbs_universal_rider/global/global.dart';
import 'package:kabbs_universal_rider/mainScreens/main_screen.dart';

class MySplashScreen extends StatefulWidget {
  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    firebaseAuth.currentUser != null ? AssistantMethods.readCurrentOnlineUserInfo() : null;
    Timer(Duration(seconds: 5), () async {
      if (await firebaseAuth.currentUser != null) {
        currentFirebaseUser = firebaseAuth.currentUser!;
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black12,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/logo.png"),
              SizedBox(height: 5,),
              Text("KABBS Universal Rider", style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                fontWeight: FontWeight.bold
              ))
            ],
          ),
        ),
      ),
    );
  }
}
