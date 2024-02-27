import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
      //google places API to autocomplete locations in search space
      String apiPlacesUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchedLocation&key=$googleMapKey&components=country:bh";

      //send a request to the api using the method created in authentication controller
      var placesApiResponse =
          await AuthenticationController.sendRequestToApi(apiPlacesUrl);

      if (placesApiResponse == "error") {
        return;
      }

      if (placesApiResponse["status"] ==
          "OK") //check if the staus of the api is okay and the prediction is being successfu;
      {
        var predictionListResultInJson = placesApiResponse["predictions"];
        //converting the list from json format as it is saved in prediction class as a list to normal format
        var predictionsList = (predictionListResultInJson as List)
            .map((eachPlacePrediction) =>
                Prediction.fromJson(eachPlacePrediction))
            .toList();
        //assign the list to the drop off prediction list
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Container(
                height: 250,
                decoration:
                    const BoxDecoration(color: Colors.orange, boxShadow: [
                  BoxShadow(
                      color: Colors.black,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7)),
                ]),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24, top: 48, right: 24, bottom: 20),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 6,
                      ),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 40,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Plan Your Ride",
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Row(
                        //pickup text field
                        children: [
                          Image.asset(
                            "images/destination.png",
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: TextField(
                                  controller: pickupTextEditingController,
                                  decoration: InputDecoration(
                                      hintText: "Enter Pickup",
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide.none),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.only(
                                          left: 11, top: 9, bottom: 9)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Row(
                        //drop off text field
                        children: [
                          Image.asset(
                            "images/destination.png",
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(5),
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
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide.none),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.only(
                                        left: 11, top: 9, bottom: 9)),
                              ),
                            ),
                          ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //display the predicted locations of results users searching for
            (dropOffPredictionList.isNotEmpty)
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          child: PredictionPlacesUI(
                              predictedPlaceData: dropOffPredictionList[index]),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                        height: 5,
                      ),
                      itemCount: dropOffPredictionList.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
