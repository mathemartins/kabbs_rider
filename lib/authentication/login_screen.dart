import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kabbs_universal_rider/authentication/signup_screen.dart';
import 'package:kabbs_universal_rider/global/global.dart';
import 'package:kabbs_universal_rider/splashScreen/splash_screen.dart';
import 'package:kabbs_universal_rider/widgets/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  void validateForm(){
    if (!emailTextEditingController.text.contains("@")){
      Fluttertoast.showToast(msg: "Enter a valid email address");
    } else if (passwordTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Invalid password");
    } else {
      loginRider();
    }
  }

  void loginRider() async {
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return ProgressDialog(message: "Processing, Please Wait..",);
    });

    final User? firebaseUser = (
        await firebaseAuth.signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim()
    ).catchError((onError){
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: " + onError.toString());
    })
    ).user;

    if (firebaseUser != null) {
      DatabaseReference driversRef = FirebaseDatabase.instance.reference().child("users");
      driversRef.child(firebaseUser.uid).once().then((driverKey){
        final snap = driverKey;
        if (snap.snapshot.value != null) {
          currentFirebaseUser = firebaseUser;
          Fluttertoast.showToast(msg: "Login Successful");
          Navigator.push(context, MaterialPageRoute(builder: (context) => MySplashScreen()));
        } else {
          Fluttertoast.showToast(msg: "Rider account does not exist");
          firebaseAuth.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (context) => MySplashScreen()));
        }
      });
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error during sign in");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(60.0),
                child: Image.asset("images/logo.png"),
              ),
              const SizedBox(height: 10,),
              const Text("Login as a Rider",
                style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold
                ),
              ),

              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.grey, fontFamily: 'ProductSans'),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "johndoe@email.com",
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'ProductSans', fontSize: 12),
                  labelStyle: TextStyle(color: Colors.grey, fontFamily: 'ProductSans', fontSize: 16),
                ),
              ),
              const SizedBox(height: 10,),

              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(color: Colors.grey, fontFamily: 'ProductSans'),
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "***********",
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'ProductSans', fontSize: 12),
                  labelStyle: TextStyle(color: Colors.grey, fontFamily: 'ProductSans', fontSize: 16),
                ),
              ),

              const SizedBox(height: 20,),

              ElevatedButton(
                  onPressed: (){
                    // validate and navigate user to the info screen
                    validateForm();
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.deepPurple, shadowColor: Colors.grey),
                  child: const Text(
                      "Login As A Rider",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'ProductSans')
                  )
              ),
              
              TextButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));}, child: const Text(
                "Don't have an account? register here...",
                style: TextStyle(fontSize: 13, fontFamily: 'ProductSans', color: Colors.grey),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
