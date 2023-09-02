import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kabbs_universal_rider/global/global.dart';
import 'package:kabbs_universal_rider/widgets/info_design_ui.dart';

class ProfileScreen extends StatefulWidget {

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(userModelCurrentInfo!.name!, style: TextStyle(
              fontSize: 40.0,
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),),
            const SizedBox(height: 15, width: 200, child: Divider(color: Colors.white)),
            const SizedBox(height: 38.0),
            // Phone
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo!.phone,
              iconData: Icons.phone_iphone_rounded,
            ),
            // email
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo!.email,
              iconData: Icons.email_outlined,
            ),

            const SizedBox(height: 20.0),

            ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white38
                ),
                child: Text("close", style: TextStyle(color: Colors.white))
            )
          ],
        ),
      ),
    );
  }
}
