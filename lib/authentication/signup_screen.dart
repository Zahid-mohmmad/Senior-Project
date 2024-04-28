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
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool showprogressBar = false;
  var authenticationController = AuthenticationController.authController;

  TextEditingController userNametextEditingController = TextEditingController();
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();
  TextEditingController phonetextEditingController = TextEditingController();
  TextEditingController agetextEditingController = TextEditingController();
  TextEditingController majortextEditingController = TextEditingController();
  TextEditingController gendertextEditingController = TextEditingController();
  XFile? imageFile;
  String urlOfUploadedImage = "";
  String selectedGender = "";
  String selectedMajor = "Computer Science";
  List<String> majors = [
    "Computer Science",
    "Electrical Engineering",
    "Mechanical Engineering",
    "Civil Engineering",
    "Chemical Engineering",
    "Other"
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Create an Account to Get Started",
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  chooseImageFromGallery();
                },
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: imageFile == null
                      ? AssetImage("images/profile_avatar.jpg")
                      : FileImage(File(imageFile!.path)) as ImageProvider,
                  backgroundColor: Colors.orange,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              imageSelectionButtons(),
              const SizedBox(
                height: 20,
              ),
              CustomTextFieldWidget(
                editingController: userNametextEditingController,
                labelText: "User Name",
                iconData: Icons.person_2_outlined,
                isObscure: false,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextFieldWidget(
                editingController: emailtextEditingController,
                labelText: "Email",
                iconData: Icons.email_outlined,
                isObscure: false,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextFieldWidget(
                editingController: passwordtextEditingController,
                labelText: "Password",
                iconData: Icons.lock_open_outlined,
                isObscure: true,
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: agetextEditingController,
                decoration: InputDecoration(
                  labelText: "Age",
                  icon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextFieldWidget(
                editingController: phonetextEditingController,
                labelText: "Phone",
                iconData: Icons.phone,
                isObscure: false,
              ),
              const SizedBox(
                height: 20,
              ),
              DropdownButtonFormField<String>(
                value: selectedMajor,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMajor = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Major",
                  icon: Icon(Icons.book_online_outlined),
                ),
                items: majors.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    "Gender",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'male',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text('Male'),
                  ),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'female',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text('Female'),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  checkIfNetworkIsAvailable();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  "Register",
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 20,
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
    );
  }

  // Widget for image selection buttons
  Widget imageSelectionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () async {
            chooseImageFromGallery();
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
            captureImageFromCamera();
          },
          icon: const Icon(
            Icons.camera_alt_outlined,
            color: Colors.black,
            size: 30,
          ),
        ),
      ],
    );
  }

  checkIfNetworkIsAvailable() {
    authenticationController.checkConnectivity(context);

    if (imageFile != null) {
      signUpFormValidation();
    } else {
      Get.snackbar("Image not selected", "Please select an image first");
    }
  }

  signUpFormValidation() {
    if (userNametextEditingController.text.trim().length < 3) {
      Get.snackbar(
        "Username incorrect",
        "Please enter your username correctly",
      );
    } else if (phonetextEditingController.text.trim().length != 8) {
      Get.snackbar("Number incorrect", "Please enter a valid phone number");
    } else if (!emailtextEditingController.text.contains("@stu.uob.edu.bh")) {
      Get.snackbar(
        "Email incorrect",
        "Please use your university email to continue",
      );
    } else if (passwordtextEditingController.text.trim().length < 8) {
      Get.snackbar(
        "Password weak",
        "Please enter a password with at least 8 characters",
      );
    } else {
      uploadImageToStorage();
    }
  }

  uploadImageToStorage() async {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance
        .ref()
        .child("Images_of_users")
        .child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });

    registerNewUser();
  }

  registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Registering your account..."),
    );

    final User? userFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
      email: emailtextEditingController.text.trim(),
      password: passwordtextEditingController.text.trim(),
    )
            .catchError((errorMsg) {
      Navigator.pop(context);
      Get.snackbar(
        "Error",
        "An error occurred while creating the account: $errorMsg",
      );
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
    
    // Send verification email
    await userFirebase.sendEmailVerification();

    Get.snackbar(
      "Registration Successful",
      "A verification email has been sent. Please verify your email before logging in.",
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => const LoginScreen()),
    );
  }

  chooseImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
      Get.snackbar(
        "Profile Image",
        "You have successfully selected your image.",
      );
    }
  }

  void captureImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
      Get.snackbar(
        "Captured Image",
        "You have successfully captured an image.",
      );
    }
  }
}
