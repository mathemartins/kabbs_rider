import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kabbs_universal_rider/assistants/assistant_methods.dart';
import 'package:kabbs_universal_rider/assistants/geofire_assistant.dart';
import 'package:kabbs_universal_rider/global/global.dart';
import 'package:kabbs_universal_rider/infoHandler/app_info.dart';
import 'package:kabbs_universal_rider/mainScreens/rate_driver_screen.dart';
import 'package:kabbs_universal_rider/mainScreens/search_places_screen.dart';
import 'package:kabbs_universal_rider/mainScreens/select_nearest_active_driver_screen.dart';
import 'package:kabbs_universal_rider/models/active_nearby_available_drivers.dart';
import 'package:kabbs_universal_rider/widgets/my_drawer.dart';
import 'package:kabbs_universal_rider/widgets/pay_fare_amount_dialog.dart';
import 'package:kabbs_universal_rider/widgets/progress_dialog.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(6.508528, 3.374420), // Yaba Lagos Nigeria
    zoom: 16.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  late LocationPermission _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "your Name";
  String userEmail = "your Email";

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearbyAvailableDriversList = [];
  DatabaseReference? referenceRideRequest;
  String driverRideStatus = "Driver is coming";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;
  String userRideRequestStatus = "";
  bool requestPositionInfo = true;


  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }  
  }

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 16.4746);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(userCurrentPosition!, context);
    print(humanReadableAddress);

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    initializeGeofireListener();
    AssistantMethods.readTripKeysForOnlineUser(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  void saveRideRequestInformation(){
    referenceRideRequest = FirebaseDatabase.instance.reference().child("All Ride Requests").push();
    var originLocation = Provider.of<AppInfo>(context, listen: false).userPickLocation;
    var destinationLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      // key: value
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      // key: value
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };


    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().microsecondsSinceEpoch,
      "username": userModelCurrentInfo!.name,
      "phone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driver": "waiting",
    };

    referenceRideRequest?.set(userInformationMap);
    tripRideRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen((eventSnap) async {
      if (eventSnap.snapshot.value == null) {
        return;
      }

      if ((eventSnap.snapshot.value as Map)["carDetails"] != null) {
        DataSnapshot db_driverCarPlate = await FirebaseDatabase.instance.ref().child("drivers").child(
            (eventSnap.snapshot.value as Map)["driverId"].toString()
        ).child("car_details").child("plate_number").get();

        DataSnapshot db_driverCategory = await FirebaseDatabase.instance.ref().child("drivers").child(
            (eventSnap.snapshot.value as Map)["driverId"].toString()
        ).child("car_details").child("type").get();

        setState(() {
          driverCarDetails = "${(eventSnap.snapshot.value as Map)["carDetails"].toString()}";
          driverCarPlate = db_driverCarPlate.value.toString();
          driverCategory = db_driverCategory.value.toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["driverName"] != null){
        setState(() {
          driverName = (eventSnap.snapshot.value as Map)["driverName"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["driverPhone"] != null){
        print((eventSnap.snapshot.value as Map).toString());
        setState(() {
          driverPhone = (eventSnap.snapshot.value as Map)["driverPhone"].toString();
        });
      }

      if ((eventSnap.snapshot.value as Map)["status"] != null){
        userRideRequestStatus = (eventSnap.snapshot.value as Map)["status"].toString();
      }

      if ((eventSnap.snapshot.value as Map)["driverLocation"] != null){
        double driverCurrentPositionLat = double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["latitude"].toString());
        double driverCurrentPositionLng = double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["longitude"].toString());

        LatLng driverCurrentPositionLatLng = LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

        print("This is user ride request log");
        print(userRideRequestStatus);

        // status = accepted
        if (userRideRequestStatus == "accepted") {
          updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng);
        }  

        // status = arrived
        if (userRideRequestStatus == "arrived") {
          driverRideStatus = "Driver has arrived!";
        }

        // status = onTrip
        if (userRideRequestStatus == "onTrip") {
          updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
        }

        if (userRideRequestStatus == "ended") {
          if ((eventSnap.snapshot.value as Map)["fareAmount"] != null) {
            double fareAmount = double.parse((eventSnap.snapshot.value as Map)["fareAmount"].toString());
            var response = await showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) => PayFareAmountDialog(totalFareAmount: fareAmount,));
            if (response == "cashPayed") {
              // rate driver and trip
              if ((eventSnap.snapshot.value as Map)["driverId"] != null) {
                String assignedDriverId = (eventSnap.snapshot.value as Map)["driverId"].toString();
                Navigator.push(context, MaterialPageRoute(builder: (context) => RateDriverScreen(assignedDriverId: assignedDriverId)));
                referenceRideRequest!.onDisconnect();
                tripRideRequestInfoStreamSubscription!.cancel();
              }
            }
          }  
        }
      }

    });

    onlineNearbyAvailableDriversList = GeofireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();
  }

  updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;
      LatLng userPickUpAddress = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
          driverCurrentPositionLatLng, userPickUpAddress
      );
      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus = "Driver is ${directionDetailsInfo.duration_text.toString()} away";
      });
      requestPositionInfo = true;
    }  
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;
      var userDropOffLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;
      LatLng userDestinationPosition = LatLng(userDropOffLocation!.locationLatitude!, userDropOffLocation.locationLongitude!);
      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
          driverCurrentPositionLatLng, userDestinationPosition
      );
      if (directionDetailsInfo == null) {
        return;
      }
      setState(() {
        driverRideStatus = "Estimated Time Of Arrival - ${directionDetailsInfo.duration_text.toString()}";
      });
      requestPositionInfo = true;
    }
  }

  void searchNearestOnlineDrivers() async {
    if (onlineNearbyAvailableDriversList.length == 0) {
      referenceRideRequest?.remove();

      setState(() {
        polyLineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoOrdinatesList.clear();
      });

      Fluttertoast.showToast(msg: "No active driver!, Try again after sometime, restarting");
      Future.delayed(Duration(milliseconds: 4000), (){
        SystemNavigator.pop();
      });
      return;
    }
    await retrieveOnlineDriversInformation(onlineNearbyAvailableDriversList);
    var response = await Navigator.push(context, MaterialPageRoute(builder: (context) => SelectNearestActiveDriverScreen(referenceRideRequest: referenceRideRequest)));

    // ignore: unrelated_type_equality_checks
    if (response == "driverChose") {
      FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId!).once().then((snap) {
        if (snap.snapshot.value != null) {
          // Send push notification to driver
          sendNotificationToDriverNow(chosenDriverId!);

          //Display waiting response UI to user
          showWaitingResponseFromDriverUI();

          // Receive notification from driver ( Ride cancelled )
          FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId!).child("newRideStatus")
              .onValue.listen((eventSnapshot) {
                if (eventSnapshot.snapshot.value == "idle") {
                  Fluttertoast.showToast(msg: "The driver has cancelled your request, Please choose another driver");
                  Future.delayed(const Duration(milliseconds: 3000), () {
                    Fluttertoast.showToast(msg: "Please restart app now!");
                    SystemNavigator.pop();
                  });
                }


                if (eventSnapshot.snapshot.value == "accepted") {
                  showUIForAssignedDriverInfo();
                }  
          });
        } else {
          Fluttertoast.showToast(msg: "Driver went offline!, choose again!");
        }
      });
    }  
  }

  showUIForAssignedDriverInfo(){
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 230;
    });
  }

  void showWaitingResponseFromDriverUI() {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDriverContainerHeight = 220;
    });
  }

  sendNotificationToDriverNow(String chosenDriverId){
    // Assign rideRequest to newRideStatus on the drivers parent node for that specific driver
    FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId).child("newRideStatus").set(referenceRideRequest?.key);

    // Automate the push notification to the system
    FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId).child("token").once().then((snap) {
      if (snap.snapshot.value != null) {
        String deviceRegistrationToken = snap.snapshot.value.toString();
        // Send Notification
        AssistantMethods.sendNotificationToDriverNow(deviceRegistrationToken, referenceRideRequest!.key!.toString(), context);
        Fluttertoast.showToast(msg: "Notification sent successfully!");
      } else {
        Fluttertoast.showToast(msg: "Cannot access this driver, getting you another!");
        return;
      }
    });
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("drivers");
    for (int i=0; i<onlineNearbyAvailableDriversList.length; i++) {
      await reference.child(onlineNearestDriversList[i].driverId.toString()).once().then((dataSnapshot) {
        var driverKeyInfo = dataSnapshot.snapshot.value;
        dList.add(driverKeyInfo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearbyDriverIconMarker();
    return Scaffold(
      key: sKey,
      drawer: Container(
        width: 265,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.black,
          ),
          child: MyDrawer(
            name: userName,
            email: userEmail,
          ),
        ),
      ),
      body: Stack(
        children: [

          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            polylines: polyLineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              //for black theme google map
              // blackThemeGoogleMap();

              setState(() {
                bottomPaddingOfMap = 240;
              });

              locateUserPosition();
            },
          ),

          //custom hamburger button for drawer
          Positioned(
            top: 30,
            left: 14,
            child: GestureDetector(
              onTap: () {
                if(openNavigationDrawer) {
                  sKey.currentState?.openDrawer();
                } else {
                  //restart-refresh-minimize app programmatically
                  SystemNavigator.pop();
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child: Icon(
                  openNavigationDrawer ? Icons.menu : Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          //ui for searching location
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      //from
                      Row(
                        children: [
                          const Icon(Icons.add_location_alt_outlined, color: Colors.grey,),
                          const SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "From",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              Text(
                                // ignore: unnecessary_null_comparison
                                Provider.of<AppInfo>(context).userPickLocation != null
                                    ? (Provider.of<AppInfo>(context).userPickLocation!.locationName)!.substring(0,24) + "..."
                                    : "Enter Pick Up Address",
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10.0),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16.0),

                      //to
                      GestureDetector(
                        onTap: () async
                        {
                          //go to search places screen
                          var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SearchPlacesScreen()));

                          if(responseFromSearchScreen == "obtainedDropoff")
                          {
                            setState(() {
                              openNavigationDrawer = false;
                            });

                            //draw routes - draw polyline
                            await drawPolyLineFromOriginToDestination();
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.add_location_alt_outlined, color: Colors.grey,),
                            const SizedBox(width: 12.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "To",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                Text(
                                  Provider.of<AppInfo>(context).userDropOffLocation != null
                                      ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                      : "Where to go?",
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ), // user95ufemama
                      ),

                      const SizedBox(height: 10.0),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16.0),

                      ElevatedButton(
                        child: const Text(
                          "Request a Ride",
                        ),
                        onPressed: () {
                          if(Provider.of<AppInfo>(context, listen: false).userDropOffLocation != null) {
                            saveRideRequestInformation();
                          } else {
                            Fluttertoast.showToast(msg: "Please enter destination first");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue,
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),

          //ui for waiting for response from driver
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height:waitingResponseFromDriverContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        FadeAnimatedText(
                            "Waiting for response\nfrom driver...",
                            duration: const Duration(seconds: 6),
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(
                                fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold
                            )
                        ),
                        ScaleAnimatedText(
                            "Please wait..",
                            duration: const Duration(seconds: 10),
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(
                                fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold
                            )
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ),

          //ui for displaying assigned driver information
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: assignedDriverInfoContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ride status
                      Center(
                        child: Text(driverRideStatus.toUpperCase(), style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white54,
                        )),
                      ),
                      const SizedBox(height:16),
                      const Divider(height:1, thickness: 1, color: Colors.white),
                      const SizedBox(height:16),

                      // Vehicle details
                      Text(
                          "VEHICLE: $driverCarDetails".toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            letterSpacing: 1.1,
                            fontSize: 14, color: Colors.white54,
                          )
                      ),

                      const SizedBox(height:6),

                      // Vehicle details
                      Text("PLATE NUMBER: $driverCarPlate".toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16, color: Colors.white54,
                          )
                      ),

                      const SizedBox(height:6),

                      Text("Driver: $driverName".toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white54,
                          )
                      ),

                      const SizedBox(height:6),

                      // Vehicle details
                      Text("RIDE TYPE: $driverCategory".toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16, color: Colors.white54,
                          )
                      ),

                      const SizedBox(height:6),

                      const Divider(height:1, thickness: 1, color: Colors.white),

                      const SizedBox(height:6),

                      // Call Driver
                      Center(
                        child: ElevatedButton.icon(
                            onPressed: (){},
                            style: ElevatedButton.styleFrom(primary: Colors.blueAccent,),
                            icon: const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 16
                            ),
                            label: Text("Call Driver", style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              )
          )

        ],
      ),
    );
  }

  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Please wait...",),
    );

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoOrdinatesList.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty)
    {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng)
      {
        pLineCoOrdinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.black,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else
    {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId("originID"),
      fillColor: Colors.lightBlue,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  initializeGeofireListener() {
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(
        userCurrentPosition!.latitude, userCurrentPosition!.longitude, 15)!.listen((map) {
          if (map != null) {
            var callBack = map['callBack'];

            //latitude will be retrieved from map['latitude']
            //longitude will be retrieved from map['longitude']

            switch (callBack) {
              case Geofire.onKeyEntered:
                ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
                activeNearbyAvailableDriver.locationLatitude = map['latitude'];
                activeNearbyAvailableDriver.locationLongitude = map['longitude'];
                activeNearbyAvailableDriver.driverId = map['key'];
                GeofireAssistant.activeNearbyAvailableDriversList.add(activeNearbyAvailableDriver);
                if (activeNearbyDriverKeysLoaded == true) {
                  displayActiveDriversOnUsersMap();
                }
                break;

              case Geofire.onKeyExited:
                GeofireAssistant.deleteOfflineDriverFromList(map['key']);
                displayActiveDriversOnUsersMap();
                break;

              case Geofire.onKeyMoved:
                ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
                activeNearbyAvailableDriver.locationLatitude = map['latitude'];
                activeNearbyAvailableDriver.locationLongitude = map['longitude'];
                activeNearbyAvailableDriver.driverId = map['key'];
                GeofireAssistant.updateActiveNearbyAvailableDriverLocation(activeNearbyAvailableDriver);
                displayActiveDriversOnUsersMap();
                break;

              case Geofire.onGeoQueryReady:
                activeNearbyDriverKeysLoaded = true;
                displayActiveDriversOnUsersMap();
                break;
            }
          }

          setState(() {});
        });
  }

  void displayActiveDriversOnUsersMap() {
    setState(() {
      markersSet.clear();
      circlesSet.clear();
      Set <Marker> driversMarketSet = Set<Marker>();
      for (ActiveNearbyAvailableDrivers eachDriver in GeofireAssistant.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);
        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );
        driversMarketSet.add(marker);
      }
      setState(() {
        markersSet = driversMarketSet;
      });
    });
  }

  createActiveNearbyDriverIconMarker(){
    // ignore: unnecessary_null_comparison
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(0.8, 0.8));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png").then((value){
        activeNearbyIcon = value;
      });
    }  
  }

}

