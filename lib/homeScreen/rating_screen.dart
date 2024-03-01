import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restart_app/restart_app.dart';
import 'package:uober/global/global_variable.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => RatingScreen(driverId: '123'),
            );
          },
          child: Text('Rate Driver'),
        ),
      ),
    );
  }
}

class RatingScreen extends StatefulWidget {
  String? driverId;

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
        .ref()
        .child("drivers")
        .child(widget.driverId!)
        .child("ratings");

    rateDriverRef.once().then((DatabaseEvent snapshot) {
      if (!snapshot.snapshot.exists) {
        rateDriverRef.set(
            cRatingStars.toStringAsFixed(1)); // Save with one decimal place
      } else {
        double oldRatings = double.parse(snapshot.snapshot.value.toString());
        double avgRating = (oldRatings + cRatingStars) / 2;
        rateDriverRef
            .set(avgRating.toStringAsFixed(1)); // Save with one decimal place
      }
    });
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
              const SizedBox(
                height: 22.0,
              ),
              Text(
                "Rate the Driver",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 22.0,
              ),
              const Divider(
                height: 4.0,
                thickness: 4.0,
              ),
              const SizedBox(
                height: 22.0,
              ),
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
              const SizedBox(height: 12.0),
              Text(
                titleRating,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 18.0),
              ElevatedButton(
                  onPressed: () {
                    DatabaseReference rateDriverR = FirebaseDatabase.instance
                        .ref()
                        .child("drivers")
                        .child(widget.driverId!)
                        .child("ratings");

                    rateDriverR.once().then((snap) {
                      //if it is the drivers first trip then add the rating directly
                      if (snap.snapshot.value == null) {
                        rateDriverR.set(cRatingStars.toString());
                        SystemNavigator.pop();
                        Restart.restartApp();
                      } else {
                        double oldRatings =
                            double.parse(snap.snapshot.value.toString());

                        double avgRating = (oldRatings + cRatingStars) / 2;
                        rateDriverR.set(avgRating.toString());
                        SystemNavigator.pop();
                        Restart.restartApp();
                      }
                    });
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: Text(
                    "Rate",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
