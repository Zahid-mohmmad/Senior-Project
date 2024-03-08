import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uober/appInfo/app_info.dart';
import 'package:uober/global/global_variable.dart';
import 'package:url_launcher/url_launcher.dart';

class DriversListingPage extends StatefulWidget {
  @override
  _DriversListingPageState createState() => _DriversListingPageState();
}

class _DriversListingPageState extends State<DriversListingPage> {
  List<DriverListing> availableDrivers = [];

  @override
  void initState() {
    super.initState();
    fetchAvailableDrivers();
  }

  void fetchAvailableDrivers() async {
    try {
      final ref = FirebaseDatabase.instance.ref("drivers");
      final snap = await ref.get();

      setState(() {
        availableDrivers = snap.children
            .map((e) => DriverListing.fromMap(e.value as Map<dynamic, dynamic>))
            .toList();
        //  print("Available drivers: $availableDrivers");
      });
    } catch (error) {
      //print("Error fetching available drivers: $error");
    }
  }

  void bookDriver(DriverListing driver) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final bookingRef = FirebaseDatabase.instance.ref("bookings");
    final newBookingRef = bookingRef.push();
    newBookingRef.set({
      "driverId": driver.id,
      "userId": userId,
      "status": "pending", // Initial status is pending
    });

    // Get the driver's device token
    DatabaseReference tokenofDriver = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(driver.id)
        .child("deviceToken");

    tokenofDriver.once().then((dataSnapshot) {
      if (dataSnapshot.snapshot.value != null) {
        String deviceToken = dataSnapshot.snapshot.value.toString();

        // Send notification to the driver
        PushNotification.sendNotificationToCurrentDriver(
            deviceToken, context, newBookingRef.key.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Available Drivers",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          itemCount: availableDrivers.length,
          itemBuilder: (context, index) {
            final driver = availableDrivers[index];

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  color: Colors.orange,
                  width: 1.0,
                ),
              ),
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                leading: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 2, 61, 110),
                  child: Icon(
                    FontAwesomeIcons.circleUser,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
                title: Text(
                  driver.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 1, 56, 101),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.car,
                          size: 14.0,
                          color: Colors.black,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          "Car Model: ${driver.carModel}",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.clock,
                          size: 14.0,
                          color: Colors.black,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          "Departure to MW: 9:00",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.clock,
                          size: 14.0,
                          color: Colors.black,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          "Departure to UTH: 8:00",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _launchWhatsApp(driver.phone),
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        GestureDetector(
                          onTap: () => _makePhoneCall(driver.phone),
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.phone,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () => bookDriver(driver),
                    child: Text(
                      "Book",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _launchWhatsApp(String phone) async {
    final whatsappUrl = "whatsapp://send?phone=$phone";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      //  print("Could not launch WhatsApp");
    }
  }

  void _makePhoneCall(String phone) async {
    final phoneUrl = "tel:$phone";
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      //   print("Could not make a phone call");
    }
  }
}

class DriverListing {
  final String id;
  final String name;
  final String phone;
  final String carModel;
  final String departureToMW;
  final String departureToUTH;

  DriverListing({
    required this.id,
    required this.name,
    required this.phone,
    required this.carModel,
    required this.departureToMW,
    required this.departureToUTH,
  });

  factory DriverListing.fromMap(Map data) {
    return DriverListing(
      id: data['id'] ?? '', // Use 'id' field instead of 'uid'
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      carModel: data['car_details'] != null
          ? data['car_details']['carModel'] ?? ''
          : '', // Access 'car_details' for car model
      departureToMW: '8:00 AM', // Default departure time for MW
      departureToUTH: '9:00 AM', // Default departure time for UTH
    );
  }
}

class PushNotification {
  static sendNotificationToCurrentDriver(
      String deviceToken, BuildContext context, String tripID) async {
    // Retrieve the gender and user name from your user data
    final userName = 'John Doe'; // Replace with actual user name
    final gender = 'Male'; // Replace with actual user gender

    // Get the location where the user wants to go
    final pickUpLocation = Provider.of<AppInfo>(context, listen: false)
        .pickuplocation!
        .placeName
        .toString();
    final dropOffLocation = Provider.of<AppInfo>(context, listen: false)
        .dropoffLocation!
        .placeName
        .toString();

    Map<String, String> headerNotificationMap = {
      "Content-Type": "application/json",

      // Enable the Firebase messaging API and get the server key
      "Authorization": serverKey,
    };

    Map titleBodyNotificationMap = {
      "title": "A Booking Request",
      "body":
          "From: $userName\nGender: $gender\nPickup: $pickUpLocation\nDrop-off: $dropOffLocation",
    };

    Map dataMapNotification = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "tripID": tripID,
      "userName": userName,
      "gender": gender,
    };

    // Combine all three maps
    Map bodyNotificationMap = {
      "notification": titleBodyNotificationMap,
      "data": dataMapNotification,
      "priority": "high",
      "to": deviceToken,
    };

    // Send request to Google Firebase Messaging API
    try {
      await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerNotificationMap,
        body: jsonEncode(bodyNotificationMap),
      );
    } catch (e) {
      return;
    }
  }
}