import 'dart:convert';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uober/appInfo/app_info.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uober/global/global_variable.dart';
import 'package:uober/homeScreen/reaching.dart';
import 'package:url_launcher/url_launcher.dart';

class DriversListingPage extends StatefulWidget {
  @override
  _DriversListingPageState createState() => _DriversListingPageState();
}

class _DriversListingPageState extends State<DriversListingPage> {
  List<DriverListing> availableDrivers = [];
  List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Sunday'];
  String selectedDay = 'Monday';
  String email = userEmail;
  Map<String, String> driverSelectedDays = {};

  @override
  void initState() {
    super.initState();
    availableDrivers.forEach((driver) {
      driverSelectedDays[driver.id] = 'Monday';
    });
    fetchAvailableDrivers();
    trackBookingStatusChanges();
  }

  void fetchAvailableDrivers() async {
    try {
      final ref = FirebaseDatabase.instance.ref("drivers");
      final snap = await ref.get();

      setState(() {
        availableDrivers = snap.children
            .map((e) => DriverListing.fromMap(e.value as Map<dynamic, dynamic>))
            .toList();
      });
    } catch (error) {
      //print("Error fetching available drivers: $error");
    }
  }

  void bookDriver(DriverListing driver, String selectedDay) {
    if (selectedDay.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Select a Day"),
            content: const Text("Please select a day before booking."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final bookingRef = FirebaseDatabase.instance.ref("bookings");
    final newBookingRef = bookingRef.push();

    var pickUpLocation =
        Provider.of<AppInfo>(context, listen: false).pickuplocation;

    DateTime now = DateTime.now();
    Map pickUpCoordinatesMap = {
      "latitude": pickUpLocation!.latitude.toString(),
      "longitude": pickUpLocation.longitude.toString(),
    };

    newBookingRef.set({
      "bookingId": newBookingRef.key,
      "driverId": driver.id,
      "userId": userId,
      "userName": userName,
      "gender": gender,
      "day": selectedDay,
      "pickUpLatlng": pickUpCoordinatesMap,
      "status": "pending",
      "bookingDateTime": now.toIso8601String(),
      "PickUpAddress": pickUpLocation.placeName,
      "userPhone": userPhone,
    });

    DatabaseReference tokenofDriver = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(driver.id)
        .child("deviceToken");

    tokenofDriver.once().then((dataSnapshot) {
      if (dataSnapshot.snapshot.value != null) {
        String deviceToken = dataSnapshot.snapshot.value.toString();

        PushNotification.sendNotificationToCurrentDriver(
            deviceToken, context, newBookingRef.key.toString(), driver);
      }
    });
  }

  void trackBookingStatusChanges() {
    final bookingRef = FirebaseDatabase.instance.ref("bookings");
    bookingRef.onChildChanged.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;

      Map<dynamic, dynamic>? bookingData =
          dataSnapshot.value as Map<dynamic, dynamic>?;

      if (bookingData != null) {
        String bookingId = dataSnapshot.key ?? '';
        String status = bookingData['status'] ?? '';

        if (status == 'rejected') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Booking Rejected"),
                content: const Text(
                    "The driver rejected your booking. Please find another driver."),
                actions: [
                  TextButton(
                    onPressed: () {
                      DatabaseReference bookingRefToDelete = FirebaseDatabase
                          .instance
                          .ref("bookings")
                          .child(bookingId);
                      bookingRefToDelete.remove().then((_) {
                        Navigator.pop(context);
                      }).catchError((error) {
                        //   print("Error deleting booking: $error");
                      });
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        } else if (status == 'accepted') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Booking Successful"),
                content: const Text(
                    "You have successfully booked the driver. Please be ready on time."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        } else if (status == 'arriving') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Driver on the way"),
                content:
                    const Text("The driver is on their way. Please be ready."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
          playSound();
        } else if (status == 'arrived') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Driver has arrived"),
                content:
                    const Text("The driver is at your door. Please get in."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );

          // Play sound when the driver has arrived
          playSound();
        } else if (status == "reaching") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Taking you to your classes"),
                content:
                    const Text("Preparing to navigate to reaching class..."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Reaching()),
                      );
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      }
    });
  }

  void playSound() {
    AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
    audioPlayer.open(
      Audio('audio/notifications-sound.mp3'),
    );
    audioPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Available Drivers",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          itemCount: availableDrivers.length,
          itemBuilder: (context, index) {
            final driver = availableDrivers[index];

            return Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(
                  color: Colors.orange,
                  width: 1.0,
                ),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                leading: const CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 2, 61, 110),
                  child: Icon(
                    FontAwesomeIcons.circleUser,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
                title: Text(
                  driver.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 1, 56, 101),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.car,
                          size: 14.0,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          "Car Model: ${driver.carModel}",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    const Row(
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
                    const SizedBox(height: 4.0),
                    const Row(
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
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DropdownButton<String>(
                          value: driverSelectedDays.containsKey(driver.id)
                              ? driverSelectedDays[driver.id]
                              : 'Monday', // Changed this line
                          onChanged: (newValue) {
                            setState(() {
                              driverSelectedDays[driver.id] = newValue!;
                            });
                          },
                          items: days
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value.substring(0, 3),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(width: 16.0),
                        GestureDetector(
                          onTap: () => _launchWhatsApp(driver.phone),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.green,
                              size: 20.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        GestureDetector(
                          onTap: () => _makePhoneCall(driver.phone),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Colors.amber,
                              size: 20.0,
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
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () {
                      bookDriver(driver, selectedDay);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Your request has been sent successfully"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text(
                      "Book",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  playSound();
                  // Any other logic you want to execute when the ListTile is tapped
                },
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
      print("Could not launch WhatsApp");
    }
  }

  void _makePhoneCall(String phone) async {
    final phoneUrl = "tel:$phone";
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      //  print("Could not make a phone call");
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
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      carModel: data['car_details'] != null
          ? data['car_details']['carModel'] ?? ''
          : '',
      departureToMW: data['departureToMW'] ?? '',
      departureToUTH: data['departureToUTH'] ?? '',
    );
  }
}

class PushNotification {
  static sendNotificationToCurrentDriver(String deviceToken,
      BuildContext context, String bookingId, DriverListing driver) async {
    final userName = FirebaseAuth.instance.currentUser!.displayName;

    final pickUpLocation = Provider.of<AppInfo>(context, listen: false)
        .pickuplocation!
        .placeName
        .toString();
    final dropOffLocation = Provider.of<AppInfo>(context, listen: false)
        .dropoffLocation!
        .placeName
        .toString();

    String day = '';
    if (driver.departureToMW != null) {
      day = 'Monday';
    } else if (driver.departureToUTH != null) {
      day = 'Wednesday';
    }

    Map<String, String> headerNotificationMap = {
      "Content-Type": "application/json",
      "Authorization": serverKey,
    };
    Map titleBodyNotificationMap = {
      "title": "A Booking Request",
      "body":
          "From: $userName\nDay: $day\nTime: ${driver.departureToMW != null ? driver.departureToMW : driver.departureToUTH}\nPickup: $pickUpLocation\nDrop-off: $dropOffLocation",
    };

    Map dataMapNotification = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "bookingId": bookingId,
      "userName": userName,
    };

    Map bodyNotificationMap = {
      "notification": titleBodyNotificationMap,
      "data": dataMapNotification,
      "priority": "high",
      "to": deviceToken,
    };

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
