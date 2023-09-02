import 'package:flutter/material.dart';
import 'package:kabbs_universal_rider/global/global.dart';
import 'package:kabbs_universal_rider/mainScreens/about_screen.dart';
import 'package:kabbs_universal_rider/mainScreens/profile_screen.dart';
import 'package:kabbs_universal_rider/mainScreens/trips_history_screen.dart';
import 'package:kabbs_universal_rider/splashScreen/splash_screen.dart';

// ignore: must_be_immutable
class MyDrawer extends StatefulWidget {
  String? name;
  String? email;

  MyDrawer({this.name, this.email});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Drawer Header
          Container(
            height: 165,
            color: Colors.blue,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Colors.black54),
              child: Row(
                children: [
                  Icon(Icons.person, size: 40, color: Colors.blueGrey),
                  SizedBox(width: 16,),
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(widget.name.toString(), style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),),
                    Text(widget.email.toString(), style: TextStyle(fontSize: 12, color: Colors.white),)
                  ],)
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),

          GestureDetector(
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => TripsHistoryScreen()));},
            child: ListTile(
              leading: Icon(Icons.history, color: Colors.grey,),
              title: Text("History", style: TextStyle(color: Colors.grey),),
            ),
          ),

          GestureDetector(
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));},
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.blueGrey,),
              title: Text("Profile", style: TextStyle(color: Colors.white),),
            ),
          ),

          GestureDetector(
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => AboutScreen()));},
            child: ListTile(
              leading: Icon(Icons.account_balance_outlined, color: Colors.blueGrey,),
              title: Text("About", style: TextStyle(color: Colors.white),),
            ),
          ),

          GestureDetector(
            onTap: (){
              firebaseAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => MySplashScreen()));
            },
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.blueGrey,),
              title: Text("Sign Out", style: TextStyle(color: Colors.white),),
            ),
          )
        ],
      ),
    );
  }
}
