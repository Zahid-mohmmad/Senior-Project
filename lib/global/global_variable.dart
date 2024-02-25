import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";
String profileImageUrl = "";
String userimage = " ";
String userPhone = "";
String gender = "";
double cRatingStars = 0.0;
String titleRating = "";

String userID = FirebaseAuth.instance.currentUser!.uid;
String googleMapKey = "AIzaSyCE7a0H835hPtBcnv_MsApr9KDVHNY3U0U";
//firebase messaging server key
String serverKey =
    "key=AAAAz7n5h7A:APA91bHfntyxTWZSHgBNDTAhDa56ISdH6_rda08GtENRxXr5B7GbOkY7GPHCBZFq-vVh3VWUumFOUQVuGAn9Bnm90sITkUa2c2FJCf9CPTlf1xU-ZrpKYAHPZMVJwEgwDMZQsuusNNtK";

const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);
