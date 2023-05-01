import 'package:firebase_auth/firebase_auth.dart';
import 'package:kabbs_universal_rider/models/direction_details_info.dart';
import 'package:kabbs_universal_rider/models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List dList = []; //online-active drivers Information List
DirectionDetailsInfo? tripDirectionDetailsInfo;
