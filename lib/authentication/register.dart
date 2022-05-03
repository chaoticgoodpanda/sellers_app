import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/mainScreens/home_screen.dart';
import 'package:sellers_app/widgets/custom_text_field.dart';
import 'package:sellers_app/widgets/error_dialog.dart';
import 'package:sellers_app/widgets/loading_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:shared_preferences/shared_preferences.dart';

import '../global/global.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;

  String sellerImageUrl = "";
  String sellerAddress = "";

  Future<void> _getImage() async
  {
    // allow seller to upload image from gallery
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);

    // set the image from the gallery as the display image
    setState(() {
      imageXFile;
    });
  }

  getCurrentLocation() async
  {
    Position newPosition = await Geolocator.getCurrentPosition(
      // to get exact location of cafe/restaurant of seller
      // use bestForNavigation for buyer's place since seller traveling there
      desiredAccuracy: LocationAccuracy.high,
    );
    position = newPosition;
    // returns multiple locations latlong coordinates as a List
    placeMarks = await placemarkFromCoordinates(position!.latitude, position!.longitude);

    // get the correct address from 0th index
    Placemark pMark = placeMarks![0];

    // get the textual address from latLong coordinates
    sellerAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare}, '
        '${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, '
        '${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

    locationController.text = sellerAddress;
  }

  Future<void> formValidation() async
  {
    if(imageXFile == null)
      {
        showDialog(
            context: context,
            builder: (c)
            {
              return ErrorDialog(
                message: "Please select an image.",
              );
            }
        );
      }
    else
      {
        // if the passwords match and all the required fields are filled out
        if(passwordController.text == confirmPasswordController.text) {
          if (passwordController.text.isNotEmpty && emailController.text.isNotEmpty &&
          nameController.text.isNotEmpty && phoneController.text.isNotEmpty &&
          locationController.text.isNotEmpty) {
            // start uploading the image to storage and then save data to Firestore DB
            showDialog(context: context, builder: (c)
            {
              return LoadingDialog(
                message: "Registering account...",
              );
            });

            // the filename is the date & seconds
            String fileName = DateTime.now().millisecondsSinceEpoch.toString();
            // access the firebase storage in the sellers folder
            fStorage.Reference reference = fStorage.FirebaseStorage.instance.ref().child("sellers")
            .child(fileName);
            // upload the file
            fStorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
            fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
            await taskSnapshot.ref.getDownloadURL().then((url) {
              sellerImageUrl = url;

              // save info to firestore DB
              registerSeller();
            });

          } else {
            showDialog(
                context: context,
                builder: (c)
                {
                  return ErrorDialog(
                    message: "All required fields have not been filled out.",
                  );
                }
            );
          }


        }
        else {
          showDialog(
              context: context,
              builder: (c)
              {
                return ErrorDialog(
                  message: "Passwords do not match.",
                );
              }
          );
        }
      }
  }

  // authenticate the user's id
  void registerSeller() async
  {
    User? currentUser;
    // create the new user on Firebase
    await firebaseAuth.createUserWithEmailAndPassword(email: emailController.text.trim(),
        password: passwordController.text.trim()).then((auth) {
          // assign the currentUser to the authorized user
          currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: error.message.toString(),
            );
          }
      );
    });
    
    if (currentUser != null)
      {
        // save their data to the Firestore
        saveDataToFirestore(currentUser!).then((value) {
          // stop the progress bar from loading
          Navigator.pop(context);
          // send user to the homepage
          Route newRoute = MaterialPageRoute(builder: (c) => HomeScreen());
          Navigator.pushReplacement(context, newRoute);
        });
      }
  }

  // for the currentUser, persist their user data to the Firestore
  Future saveDataToFirestore(User currentUser) async
  {
    // sets the users' data by id in the sellers folder in Firestore
    FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).set(
        {
          "sellerUID": currentUser.uid,
          "sellerEmail": currentUser.email,
          "sellerName": nameController.text.trim(),
          "sellerAvatarUrl": sellerImageUrl,
          "phone": phoneController.text.trim(),
          "address": sellerAddress,
          "status": "Approved",
          "earnings": 0.0,
          "lat": position!.latitude,
          "lng": position!.longitude,
        });

    // save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("photoUrl", sellerImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 10,),
            InkWell(
              onTap: ()
              {
                _getImage();
              },
              child: CircleAvatar(
                // whatever width of screen is, take 20% of it
                radius: MediaQuery.of(context).size.width * 0.20,
                backgroundColor: Colors.white,
                // if image file uploaded from gallery or camera isn't null, assign it
                backgroundImage: imageXFile == null ? null : FileImage(File(imageXFile!.path)),
                child: imageXFile == null
                ?
                Icon(
                  Icons.add_photo_alternate,
                  size: MediaQuery.of(context).size.width * 0.20,
                  color: Colors.grey,
                ) : null,
              ),
            ),
            const SizedBox(height: 10,),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    data: Icons.person,
                    controller: nameController,
                    hintText: "Name",
                    isObscure: false,
                  ),
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
                  CustomTextField(
                    data: Icons.lock,
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    isObscure: true,
                  ),
                  CustomTextField(
                    data: Icons.phone,
                    controller: phoneController,
                    hintText: "Phone Number",
                    isObscure: false,
                  ),
                  CustomTextField(
                    data: Icons.my_location,
                    controller: locationController,
                    hintText: "Cafe/Restaurant Address",
                    isObscure: false,
                    enabled: true,
                  ),
                  Container(
                    width: 400,
                    height: 40,
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      label: const Text(
                        "Get my Current Location",
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        getCurrentLocation();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        )
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25,),
            ElevatedButton(
              child: const Text(
                "Sign up",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              onPressed: ()
              {
                formValidation();
              },
            ),
            const SizedBox(height: 30,)
          ],
        ),
      ),
    );
  }
}
