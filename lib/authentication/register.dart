import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/widgets/custom_text_field.dart';
import 'package:sellers_app/widgets/error_dialog.dart';

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
    String sellerAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare}, '
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
