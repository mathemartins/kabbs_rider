import 'package:firebase_auth/firebase_auth.dart';
import 'package:kabbs_universal_rider/models/direction_details_info.dart';
import 'package:kabbs_universal_rider/models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List dList = []; //online-active drivers Information List
DirectionDetailsInfo? tripDirectionDetailsInfo;
String? chosenDriverId = "";
String cloudMessagingServerToken = "key=AAAAIt8pyfE:APA91bFfOMICoxix42xt1DCSs8t817oFUXc4XNbWe6U5IJ0QVtKPM2qj8X7a0t9crS7kGG9qUPl3T2aVaGykX0LSabxcQwbArqN15p6EBK4LSsL4qizQJXMPBlvieetrEYM-JU8hSlWg";
String userDropOffAddress = "";
String driverCarDetails = "";
String driverCarPlate = "";
String driverCategory = "";
String driverName = "";
String driverPhone = "";
double countRatingStar = 0.0;
String titleStarsRating = "";

