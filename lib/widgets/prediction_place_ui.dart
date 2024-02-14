import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uober/appInfo/app_info.dart';
import 'package:uober/controllers/authentication_controller.dart';
import 'package:uober/global/global_variable.dart';
import 'package:uober/models/address_model.dart';
import 'package:uober/models/prediction.dart';
import 'package:uober/widgets/loading_dialog.dart';

class PredictionPlacesUI extends StatefulWidget {
  Prediction? predictedPlaceData;

  PredictionPlacesUI({
    super.key,
    this.predictedPlaceData,
  });

  @override
  State<PredictionPlacesUI> createState() => _PredictionPlacesUIState();
}

class _PredictionPlacesUIState extends State<PredictionPlacesUI> {
//place details APi to get selected the searched locations from where2 text field

  fetchClickedPlaceDetails(String placeID) async {
    //wait until the details are being fetched from the api
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Getting details please wait"),
    );
    String placeDetailsApiUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$googleMapKey";
    //sending a request to the api and getting the response through the method created in authentication controller class
    var placeDetailsresponse =
        await AuthenticationController.sendRequestToApi(placeDetailsApiUrl);
    Navigator.pop(context); //close the loading dialog

    if (placeDetailsresponse == "error") {
      return;
    }
    if (placeDetailsresponse["status"] == "OK") {
      //create an instance of the adrress class
      Address dropOffLocation = Address();

      //if the status is ok of the api assign the place details response to the name of the place
      dropOffLocation.placeName = placeDetailsresponse["result"]["name"];
      //get the latiude of the pplace going to result then geometry then location in this order of json
      dropOffLocation.latitude =
          placeDetailsresponse["result"]["geometry"]["location"]["lat"];
      ////get the longitude of the place going to result then geometry then location in this order of json a
      dropOffLocation.longitude =
          placeDetailsresponse["result"]["geometry"]["location"]["lng"];
//and then the data shared or updated with the help of the provider
      dropOffLocation.placeID = placeID;
      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocation(dropOffLocation);

      Navigator.pop(context, "p");
    } 
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        fetchClickedPlaceDetails(widget.predictedPlaceData!.placeId.toString());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
      ),
      child: SizedBox(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Icon(
                  Icons.share_location_sharp,
                  color: Colors.black,
                ),
                const SizedBox(
                  width: 13,
                ),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.predictedPlaceData!.mainText.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      widget.predictedPlaceData!.secondaryText.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
