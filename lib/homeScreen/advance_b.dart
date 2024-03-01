import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
        print("Available drivers: $availableDrivers");
      });
    } catch (error) {
      print("Error fetching available drivers: $error");
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
        title: Text("Available Drivers"),
      ),
      body: ListView.builder(
        itemCount: availableDrivers.length,
        itemBuilder: (context, index) {
          final driver = availableDrivers[index];

          return Card(
            child: ListTile(
              title: Text(driver.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Car Model: ${driver.carModel}"),
                  Text("Departure to MW: 900"),
                  Text("Departure to UTH: 800"),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _launchWhatsApp(driver.phone),
                        child: Icon(Icons.message, color: Colors.green),
                      ),
                      SizedBox(width: 30),
                      GestureDetector(
                        onTap: () => _makePhoneCall(driver.phone),
                        child: Icon(Icons.phone, color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => bookDriver(driver),
                child: Text("Book"),
              ),
            ),
          );
        },
      ),
    );
  }

  void _launchWhatsApp(String phone) async {
    final whatsappUrl = "whatsapp://send?phone=$phone";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      print("Could not launch WhatsApp");
    }
  }

  void _makePhoneCall(String phone) async {
    final phoneUrl = "tel:$phone";
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      print("Could not make a phone call");
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
    //get the location where user wants to go
    // Assuming the pickup and dropoff locations are accessible from the context
    // You may need to replace the following lines with your actual implementation
    String dropOffLocation = "Destination";
    String pickUpLocation = "Origin";

    Map<String, String> headerNotificationMap = {
      "Content-Type": "application/json",

      //enable the firebase messagin api and get the server key
      "Authorization": serverKey,
    };

    Map titleBodyNotificationMap = {
      "title": "A Booking Request",
      "body": "From: $pickUpLocation\nTo: $dropOffLocation",
    };

    Map dataMapNotification = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "tripID": tripID,
    };

    //combine all three maps

    Map bodyNotificationMap = {
      "notification": titleBodyNotificationMap,
      "data": dataMapNotification,
      "priority": "high",
      "to": deviceToken,
    };

    //send request to google firebase messaging api
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
