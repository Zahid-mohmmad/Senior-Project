import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restart_app/restart_app.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rating App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? rating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await showDialog<double>(
              context: context,
              builder: (BuildContext context) => RatingScreen(driverId: '123'),
            );
            if (result != null) {
              setState(() {
                rating = result;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thank you for rating: $rating'),
                ),
              );
            }
          },
          child: Text('Rate Driver'),
        ),
      ),
    );
  }
}

class RatingScreen extends StatefulWidget {
  final String? driverId;

  RatingScreen({this.driverId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double cRatingStars = 0;
  String titleRating = "";
  bool isRated = false;

  void _saveRating() {
    DatabaseReference rateDriverRef = FirebaseDatabase.instance
        .reference()
        .child("drivers")
        .child(widget.driverId!)
        .child("ratings");

    rateDriverRef.once().then((DataSnapshot snapshot) {
          if (!snapshot.exists) {
            rateDriverRef.set(cRatingStars.toString());
          } else {
            double oldRatings = double.parse(snapshot.value.toString());
            double avgRating = (oldRatings + cRatingStars) / 2;
            rateDriverRef.set(avgRating.toString());
          }
        } as FutureOr Function(DatabaseEvent value));
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thank You!'),
          content: const Text('Your rating has been saved.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                SystemNavigator.pop();
                Restart.restartApp();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _rateDriver() {
    if (!isRated) {
      setState(() {
        isRated = true;
      });
      _saveRating();
      _showThankYouDialog();

      // Navigate back to HomeScreen after a delay of 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context, cRatingStars);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Colors.amber,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 22.0),
              Text(
                "Rate the Driver",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 22.0),
              const Divider(
                height: 4.0,
                thickness: 4.0,
              ),
              const SizedBox(height: 22.0),
              SmoothStarRating(
                allowHalfRating: false,
                starCount: 5,
                rating: cRatingStars,
                size: 46.0,
                onRatingChanged: (value) {
                  setState(() {
                    cRatingStars = value;
                  });
                },
              ),
              const SizedBox(height: 22.0),
              const Divider(
                height: 4.0,
                thickness: 4.0,
              ),
              const SizedBox(height: 22.0),
              ElevatedButton(
                onPressed: _rateDriver,
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                ),
                child: const Text('Rate'),
              ),
              const SizedBox(height: 22.0),
            ],
          ),
        ),
      ),
    );
  }
}
