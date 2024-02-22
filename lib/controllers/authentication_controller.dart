import 'dart:convert';

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uober/appInfo/app_info.dart';
import 'package:uober/authentication/login_screen.dart';
import 'package:uober/global/global_variable.dart';
import 'package:uober/homeScreen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uober/models/address_model.dart';
import 'package:uober/models/direction_details.dart';

import 'package:http/http.dart' as http;

class AuthenticationController extends GetxController {
  static AuthenticationController authController = Get.find();
  late Rx<User?> firebaseCurrentUser;

  XFile? imageFile;

  late Rx<File?> pickedFile;
  File? get profileImage => pickedFile.value;
  //pick image from gallery
  pickImageFileFromGallery() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      Get.snackbar("Profile Image", "you have successfullu picked your image.");
    }
    pickedFile = Rx<File?>(File(imageFile!.path));
  }

  //take a pic from the camera
  captureImageFromPhoneCamera() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      Get.snackbar(
          "Profile Image", "you have successfully captured your image.");
    }
    pickedFile = Rx<File?>(File(imageFile!.path));
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    // creating a folder inside the firbase storage as profile images and saving images of all people
    Reference referenceStorage = FirebaseStorage.instance
        .ref()
        .child("Profile Images")
        .child(FirebaseAuth.instance.currentUser!.uid);

    UploadTask task = referenceStorage.putFile(imageFile);
    TaskSnapshot snapshot = await task;

    String downloadUrlOfImage = await snapshot.ref.getDownloadURL();
    return downloadUrlOfImage;
  }

//check connectivity of the internet
  checkConnectivity(BuildContext context) async {
    var cr = await Connectivity().checkConnectivity();
    if (cr != ConnectivityResult.mobile && cr != ConnectivityResult.wifi) {
      if (!context.mounted) return;
      Get.snackbar("No Connection",
          "Please check your cellular network or conneck to wifi");
    }
  }

  //check if user is logged in if yes directly send the user to the home screen otherwise in login page
  checkIfUserIsLoggedIn(User? currentUser) {
    if (currentUser ==
        null) // if current user is null it means user is not logged in

    {
      Get.to(const LoginScreen());
    } else {
      Get.to(const HomeScreen());
    }
  }

  //send request to api method
  static sendRequestToApi(String urlApi) async {
    //http dependecy  is  used to to send requests  to api
    http.Response responseFromGeoCodingApi = await http.get(Uri.parse(urlApi));

    //check if the response is successful or not
    try {
      if (responseFromGeoCodingApi.statusCode == 200) {
        String dataFromApi = responseFromGeoCodingApi.body;

        //it will come in json format convert it into normal code
        var dataDecodedFromJson = jsonDecode(dataFromApi);
        return dataDecodedFromJson;
      } else {
        return "error";
      }
    } catch (errorMessage) {
      return "error";
    }
  }

  //convert users geocoding cordinates too human readable locations with geocoding api and reverse geocoding
  static Future<String> convertGeocodingCoordinates(
      Position position, BuildContext context) async {
    //providing the reverse coding api of reverse geocoding which converts coordinates into human readable location
    //here i have provided the latitude and longitude from position dependency
    String humanReadableCoordinates = "";
    String apiGeocodingUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";
    //calling the method responseFromApi to send a request to api
    var responseFromApi = await sendRequestToApi(apiGeocodingUrl);

    if (responseFromApi != "error") {
      //taking the formatted address which is the human readable adrress from the api contained in results
      humanReadableCoordinates =
          responseFromApi["results"][0]["formatted_address"];
      //creatin an instance of the adrees class
      Address addressinstance = Address();
      addressinstance.humanReadableAddress = humanReadableCoordinates;
      addressinstance.placeName = humanReadableCoordinates;
      addressinstance.latitude = position.latitude;
      addressinstance.longitude = position.longitude;

      //share the data using provider to display in search page

      Provider.of<AppInfo>(context, listen: false)
          .updatePickupLocation(addressinstance);
    }

    return humanReadableCoordinates;
  }

//Directions Api it will provide the time distance of the destination

//using direction details class to convert the json format to normal format
  static Future<DirectionDetails?> getDirectionDetailsFromApi(
      LatLng source, LatLng destination) async {
    //destination for dropof location and origin for pickup as they are defined in this directions api
    String directionApiUrl =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";
    //send and get response from api through send request apo method
    var responseFromApi = await sendRequestToApi(directionApiUrl);

    //check the response of the api
    if (responseFromApi == "error") {
      return null;
    }

    //create an instance of the direction details class to convert the details from json to normal format
    DirectionDetails details = DirectionDetails();
    //getting the json data and assiging it to the normal format of class directiondetails
    details.distanceTextString =
        responseFromApi["routes"][0]["legs"][0]["distance"]["text"];
    details.distanceValueDigits =
        responseFromApi["routes"][0]["legs"][0]["distance"]["value"];
    details.durationTextString =
        responseFromApi["routes"][0]["legs"][0]["duration"]["text"];
    details.durationValueDigits =
        responseFromApi["routes"][0]["legs"][0]["duration"]["value"];

    details.encodedPoints =
        responseFromApi["routes"][0]["overview_polyline"]["points"];
    //return the instance that contains all the information of direction api
    return details;
  }

  //calculate the fare amount
  calculateFareAmount(DirectionDetails directionDetails) {
    double distancePerKmAmount = 0.1;
    double distanceperTenMinuteAmount = 0.1;
    double baseFareAmount = 0.1;

    double totalDistanceTraveledFareAmount =
        (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;
    double totalDurationSpentFareAmunt =
        (directionDetails.durationValueDigits! / 600) *
            distanceperTenMinuteAmount;

    double totalFareAmount = baseFareAmount +
        totalDistanceTraveledFareAmount +
        totalDurationSpentFareAmunt;

    if (totalFareAmount > 1.5) {
      totalFareAmount = 1.5;
    }
    return totalFareAmount;
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    firebaseCurrentUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    firebaseCurrentUser.bindStream(FirebaseAuth.instance.authStateChanges());

    ever(firebaseCurrentUser, checkIfUserIsLoggedIn);
  }

  static getCurrentUser() {}

  getUserGender() {}
}
