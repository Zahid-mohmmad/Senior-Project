import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uober/appInfo/app_info.dart';
import 'package:uober/controllers/authentication_controller.dart';
import 'package:uober/global/global_variable.dart';
import 'package:uober/homeScreen/dashboard.dart';
import 'package:uober/models/prediction.dart';
import 'package:uober/widgets/prediction_place_ui.dart';

class SearchDestinationScreen extends StatefulWidget {
  const SearchDestinationScreen({Key? key}) : super(key: key);

  @override
  State<SearchDestinationScreen> createState() =>
      _SearchDestinationScreenState();
}

class _SearchDestinationScreenState extends State<SearchDestinationScreen> {
  TextEditingController pickupTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<Prediction> dropOffPredictionList = [];

  searchLocation(String searchedLocation) async {
    if (searchedLocation.length > 1) {
      String apiPlacesUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchedLocation&key=$googleMapKey&components=country:bh";

      var placesApiResponse =
          await AuthenticationController.sendRequestToApi(apiPlacesUrl);

      if (placesApiResponse == "error") {
        return;
      }

      if (placesApiResponse["status"] == "OK") {
        var predictionListResultInJson = placesApiResponse["predictions"];
        var predictionsList = (predictionListResultInJson as List)
            .map((eachPlacePrediction) =>
                Prediction.fromJson(eachPlacePrediction))
            .toList();

        setState(() {
          dropOffPredictionList = predictionsList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userAddress = Provider.of<AppInfo>(context, listen: false)
            .pickuplocation!
            .humanReadableAddress ??
        "";
    pickupTextEditingController.text = userAddress;
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: Container(
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height *
                  0.2), // Position below top 20% of the screen
          width: MediaQuery.of(context).size.width, // Full width
          height: MediaQuery.of(context).size.height *
              0.8, // Cover 80% of the screen height
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 5.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const Dashboard(),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.clear,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                    Text(
                      "Plan Your Ride",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 40), // Space for icon
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.my_location,
                      color: Colors.amber,
                      size: 30,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors
                              .amber, // Change color to white with opacity
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: TextField(
                            controller: pickupTextEditingController,
                            decoration: InputDecoration(
                              hintText: "Enter Pickup",
                              fillColor: Colors.white, // Change to white
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide.none, // Remove border side
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.only(
                                left: 11,
                                top: 9,
                                bottom: 9,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.amber,
                      size: 30,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors
                              .amber, // Change color to white with opacity
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: TextField(
                            controller: dropOffTextEditingController,
                            onChanged: (inputText) {
                              searchLocation(inputText);
                            },
                            decoration: InputDecoration(
                              hintText: "To Where",
                              fillColor: Colors.white, // Change to white
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide.none, // Remove border side
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.only(
                                left: 11,
                                top: 9,
                                bottom: 9,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        child: PredictionPlacesUI(
                          predictedPlaceData: dropOffPredictionList[index],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 5),
                    itemCount: dropOffPredictionList.length,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
