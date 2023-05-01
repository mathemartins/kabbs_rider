import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kabbs_universal_rider/authentication/login_screen.dart';
import 'package:kabbs_universal_rider/global/global.dart';
import 'package:kabbs_universal_rider/splashScreen/splash_screen.dart';
import 'package:kabbs_universal_rider/widgets/progress_dialog.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  void validateForm(){
    if (nameTextEditingController.text.length <= 3) {
      Fluttertoast.showToast(msg: "Name must be first name and last name");
    } else if (!emailTextEditingController.text.contains("@")){
      Fluttertoast.showToast(msg: "Enter a valid email address");
    } else if (phoneTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "Enter a valid phone number");
    } else if (passwordTextEditingController.text.length < 6){
      Fluttertoast.showToast(msg: "Password must be at least 6 characters");
    } else {
      saveRiderInfo();
    }
  }

  void saveRiderInfo() async {
    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context){
      return ProgressDialog(message: "Processing, Please Wait..",);
    });

    final User? firebaseUser = (
        await firebaseAuth.createUserWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim()
        ).catchError((onError){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error: " + onError.toString());
        })
    ).user;

    if (firebaseUser != null) {
      Map userMap = {
        "id": firebaseUser.uid,
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };
      DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");
      usersRef.child(firebaseUser.uid).set(userMap);
      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: "Account has been created");
      Navigator.push(context, MaterialPageRoute(builder: (context) => MySplashScreen()));
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been created!");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(60.0),
                child: Image.asset("images/logo.png"),
              ),
              const SizedBox(height: 10,),
              const Text("Register as a Rider",
                style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 20,
                    color: Colors.grey,
                  fontWeight: FontWeight.bold
                ),
              ),

              TextField(
                controller: nameTextEditingController,
                style: const TextStyle(color: Colors.grey, fontFamily: 'ProductSans'),
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  hintText: "John Doe",
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
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.grey, fontFamily: 'ProductSans'),
                decoration: const InputDecoration(
                  labelText: "Phone",
                  hintText: "+234 80 11 22 33 44",
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
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => CarInfoScreen()));
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.deepPurple, shadowColor: Colors.grey),
                  child: const Text(
                    "Proceed As A Rider",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'ProductSans')
                  )
              ),

              TextButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));}, child: const Text(
                "Already have an account?, Login Here..",
                style: TextStyle(fontSize: 13, fontFamily: 'ProductSans', color: Colors.grey),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
