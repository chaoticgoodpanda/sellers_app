import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sellers_app/global/global.dart';
import 'package:sellers_app/mainScreens/home_screen.dart';
import 'package:sellers_app/widgets/error_dialog.dart';
import 'package:sellers_app/widgets/loading_dialog.dart';

import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  formValidation() {
    // see if email & password fields are filled out
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      // attempt login
      loginUser();
    } else {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(message: "Please provide an email and a password.",);
        }
      );
    }
  }

  loginUser() async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingDialog(message: "Authenticating user...",);
        }
    );

    User? currentUser;
    // check to see if current user exists in Firestore
    await firebaseAuth.signInWithEmailAndPassword(email: emailController.text.trim(),
        password: passwordController.text.trim())
    .then((auth) {
      currentUser = auth.user!;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(message: error.message.toString(),);
          }
      );
    });
    // if user successfully authenticated, log user in and send seller to home screen
    if (currentUser != null) {
      // retrieve user Firebase data
      readDataAndSetDataLocally(currentUser!).then((value) {
        Navigator.pop(context);
        // send the logged in user to the home screen
        Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      });
    }
  }

  // retrieve data from Firestore DB and set the data locally
  Future readDataAndSetDataLocally(User currentUser) async {
    // doc is for that specific user to login
    await FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).get()
        .then((snapshot) async {
          await sharedPreferences!.setString("uid", currentUser.uid);
          await sharedPreferences!.setString("email", snapshot.data()!["sellerEmail"]);
          // retrieve the seller name from the Firestore DB using the snapshot
          await sharedPreferences!.setString("name", snapshot.data()!["sellerName"]);
          await sharedPreferences!.setString("photoUrl", snapshot.data()!["sellerAvatarUrl"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Image.asset("images/seller.png",
                height: 270,
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.email,
                  controller: emailController,
                  hintText: "Email",
                  isObscure: false,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: passwordController,
                  hintText: "Password",
                  isObscure: true,
                ),
              ],
            )

          ),
          ElevatedButton(
            child: const Text(
              "Login",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            onPressed: () {
              formValidation();
            },
          ),
        ],
      ),
    );
  }
}
