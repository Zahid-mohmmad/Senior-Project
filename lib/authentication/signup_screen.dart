import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uober/authentication/login_screen.dart';
import 'package:uober/controllers/authentication_controller.dart';
import 'package:uober/widgets/custom_text_field_widget.dart';
import 'package:uober/widgets/loading_dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool showprogressBar = false;
//instance of authentication_controller class for the image file methods
  var authenticationController = AuthenticationController.authController;

  //personnel info

  TextEditingController userNametextEditingController = TextEditingController();
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();
  TextEditingController phonetextEditingController = TextEditingController();
  TextEditingController agetextEditingController = TextEditingController();
  TextEditingController majortextEditingController = TextEditingController();
  TextEditingController gendertextEditingController = TextEditingController();
  XFile? imageFile;

  String urlOfUploadedImage = "";

  checkIfNetworkIsAvailable() {
    authenticationController.checkConnectivity(context);

    if (imageFile != null) //image validation
    {
      signUpFormValidation();
    } else {
      Get.snackbar("image not selected", "Please select the image first");
    }
  }

  signUpFormValidation() {
    if (userNametextEditingController.text.trim().length < 3) {
      Get.snackbar(
          "User name incorrect", "Please write your user name correctly");
    } else if (phonetextEditingController.text.trim().length != 8) {
      Get.snackbar("Number Incorrecr", "please write the number correctly");
    } else if (!emailtextEditingController.text.contains("@stu.uoob.edu.bh")) {
      Get.snackbar(
          "email incorrect", "Please use your university email to continue");
    } else if (passwordtextEditingController.text.trim().length < 8) {
      Get.snackbar(
          "Password is weak", "Please write 8 or more digits to continue");
    } else if (majortextEditingController.text.trim().isEmpty) {
      Get.snackbar("major field empty", "Please fill out all the fields");
    } else if (agetextEditingController.text.trim().isEmpty) {
      Get.snackbar("vehicle color field is empty",
          "Please write the color of your vehicle");
    } else if (gendertextEditingController.text.isEmpty) {
      Get.snackbar(
          "gender field is empty", "Please write your gender of your vehicle");
    } else {
      //uploadImageToStorage();
      registerNewUser();
    }
  }

  uploadImageToStorage() async {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage =
        FirebaseStorage.instance.ref().child("Images").child(imageIDName);

    // UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    // TaskSnapshot snapshot = await uploadTask;
    // urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    // setState(() {
    //urlOfUploadedImage;
    // });

    //  registerNewUser();
  }

  registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          const LoadingDialog(messageText: "Registering your account..."),
    );

    final User? userFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
      email: emailtextEditingController.text.trim(),
      password: passwordtextEditingController.text.trim(),
    )
            .catchError((errorMsg) {
      Navigator.pop(context);
      Get.snackbar(
          "error", "an error occured while creating the account $errorMsg");
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef =
        FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);

    Map usersDataMap = {
      "photo": urlOfUploadedImage,
      "name": userNametextEditingController.text.trim(),
      "email": emailtextEditingController.text.trim(),
      "phone": phonetextEditingController.text.trim(),
      "gender": gendertextEditingController.text.trim(),
      "major": majortextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };
    usersRef.set(usersDataMap);
    Get.snackbar(
        "Registration Successful", "U have successffly register in UOBER! ");
    Navigator.push(
        context, MaterialPageRoute(builder: (c) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Text(
                  "Create an Account To get started now",
                  style: GoogleFonts.roboto(
                      fontSize: 20,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                // if image is not picked from camera or gallery it will show the avatar
                authenticationController.imageFile == null
                    ?
                    //choose image circle avatar
                    const CircleAvatar(
                        radius: 70,
                        backgroundImage:
                            AssetImage("images/profile_avatar.jpg"),
                        backgroundColor: Colors.orange,
                      )
                    : Container(
                        // otherwise the image chosen by user in this container
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            image: DecorationImage(
                                fit: BoxFit.fitHeight,
                                image: FileImage(File(imageFile as String)))),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await authenticationController
                            .pickImageFileFromGallery();
                        setState(() {
                          // Update the state after picking the image
                          authenticationController.imageFile = imageFile;
                        });
                      },
                      icon: const Icon(
                        Icons.image_outlined,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      onPressed: () async {
                        await authenticationController
                            .captureImageFromPhoneCamera();
                        setState(() {
                          // Update the state after capturing the image
                          authenticationController.imageFile = imageFile;
                        });
                      },
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                //personal info
                //username
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 55,
                  child: CustomTextFieldWidget(
                    editingController: userNametextEditingController,
                    labelText: "User Name",
                    iconData: Icons.person_2_outlined,
                    isObscure: false,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 55,
                  child: CustomTextFieldWidget(
                    editingController: emailtextEditingController,
                    labelText: "Email",
                    iconData: Icons.email_outlined,
                    isObscure: false,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //password
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 55,
                  child: CustomTextFieldWidget(
                    editingController: passwordtextEditingController,
                    labelText: "Password",
                    iconData: Icons.lock_open_outlined,
                    isObscure: true,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),
                //age
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 55,
                  child: CustomTextFieldWidget(
                    editingController: agetextEditingController,
                    labelText: "age",
                    iconData: Icons.numbers,
                    isObscure: false,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                //phone number
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 55,
                  child: CustomTextFieldWidget(
                    editingController: phonetextEditingController,
                    labelText: "Phone",
                    iconData: Icons.phone,
                    isObscure: false,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //city
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 55,
                  child: CustomTextFieldWidget(
                    editingController: majortextEditingController,
                    labelText: "Major",
                    iconData: Icons.book_online_outlined,
                    isObscure: false,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //country
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 55,
                  child: CustomTextFieldWidget(
                    editingController: gendertextEditingController,
                    labelText: "Gender",
                    iconData: Icons.people,
                    isObscure: false,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                const SizedBox(
                  height: 10,
                ),

                Container(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 55,
                  decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      )),
                  child: InkWell(
                    onTap: () async {
                      checkIfNetworkIsAvailable();
                    },
                    child: Center(
                      child: Text(
                        "Register",
                        style: GoogleFonts.roboto(
                            fontSize: 24,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?  ",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Text(
                        "Login here",
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    showprogressBar == true
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.yellow),
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
