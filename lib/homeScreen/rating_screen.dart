import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restart_app/restart_app.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:uober/global/global_variable.dart';

class RatingScreen extends StatefulWidget {
  String? driverId;

  RatingScreen({this.driverId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
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
                filledIconData: Icons.blur_off,
                halfFilledIconData: Icons.blur_on,
                color: Colors.amber,
                borderColor: Colors.amber,
                spacing: 0.0,
                onRatingChanged: (value) {
                  cRatingStars = value;
                  if (cRatingStars == 1) {
                    setState(() {
                      titleRating = "Very Bad";
                    });
                  }
                  if (cRatingStars == 2) {
                    setState(() {
                      titleRating = "Bad";
                    });
                  }

                  if (cRatingStars == 3) {
                    setState(() {
                      titleRating = "good";
                    });
                  }

                  if (cRatingStars == 4) {
                    setState(() {
                      titleRating = "very good";
                    });
                  }

                  if (cRatingStars == 5) {
                    setState(() {
                      titleRating = "Excellent";
                    });
                  }
                },
              ),
              const SizedBox(
                height: 12.0,
              ),
              Text(
                titleRating,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 18.0,
              ),
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
                      Navigator.pop(context); // Close the rating dialog
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 60)),
                child: Text(
                  "Rate",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(
                height: 12.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
