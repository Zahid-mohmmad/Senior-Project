import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points_plus/flutter_polyline_points_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:uober/appInfo/app_info.dart';
import 'package:uober/authentication/login_screen.dart';
import 'package:uober/controllers/authentication_controller.dart';
import 'package:uober/controllers/manage_drivers.dart';
import 'package:uober/controllers/push_notication.dart';
import 'package:uober/global/global_variable.dart';
import 'package:uober/global/trip_var.dart';
import 'package:uober/homeScreen/rating_screen.dart';

import 'package:uober/homeScreen/search_destination_screen.dart';
import 'package:uober/models/direction_details.dart';
import 'package:uober/models/online_nearby_drivers.dart';
import 'package:uober/widgets/info_dialog.dart';
import 'package:uober/widgets/loading_dialog.dart';
import 'package:uober/widgets/payment_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uober/homeScreen/dashboard.dart';
import 'package:uober/homeScreen/notification.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;

  Position? currentPositionOfUser;
  DirectionDetails? directionDetailsInstance;
  AuthenticationController authenticationController =
      AuthenticationController();
  List<LatLng> polyLineCoOrdinates = [];
  Set<Polyline> polylineset = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  bool isDrawerOpened = true;
  String stateOfApp = "normal";
  bool nearbyOnlineKeysLoaded = false;
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  double requestContainerHeight = 0;
  double tripContainerHeight = 0;
  BitmapDescriptor? carIconNearbyDriver;
  DatabaseReference? tripRequestReference;
  List<OnlineNearbyDrivers>? availableNearbyDriversList;
  List<OnlineNearbyDrivers> femaleDriversList = [];
  List<OnlineNearbyDrivers> maleDriversList = [];

  StreamSubscription<DatabaseEvent>? tripstreamSubscription;
  bool requestingDetailsInfo = false;

  GlobalKey<ScaffoldState> skey =
      GlobalKey<ScaffoldState>(); // the key to handle the

  updateAvailableNearbyOnlineDriversOnMap() {
    //first clear the users maps
    setState(() {
      markerSet.clear();
    });

    //then set a markers temporary set
    Set<Marker> markersTempSet = Set<Marker>();

    //use for each loop to get the drivers location from the list one by one if there more then one and add the to the markes set
    for (OnlineNearbyDrivers eachOnlineNearbyriver
        in ManageDriversMethods.withinRadiusOnlineDriversList) {
      //getting the online driver latitude and longitude
      LatLng driverCurrentPosition = LatLng(
          eachOnlineNearbyriver.latDriver!, eachOnlineNearbyriver.lngDriver!);
      //add the markers to the map
      Marker driverMarker = Marker(
        markerId: MarkerId("driver ID = ${eachOnlineNearbyriver.uidDriver}"),
        position: driverCurrentPosition,
        icon: carIconNearbyDriver!,
      );

      markersTempSet.add(driverMarker);
    }
    setState(() {
      markerSet = markersTempSet;
    });
  }

  initializeGeoFireListener() {
    Geofire.initialize("onlineDrivers");
    //within the radius of 24 of the user drivers will be visable who are online
    Geofire.queryAtLocation(currentPositionOfUser!.latitude,
            currentPositionOfUser!.longitude, 24)!
        .listen((driverEvent) {
      if (driverEvent != null) {
        var onlineDriverchild = driverEvent[
            "callBack"]; // this will call back the drivers that are online in the onlinedrivers node database
        switch (onlineDriverchild) {
          case Geofire.onKeyEntered:
            //when the driver is outside the radius but comes inside the user radius will be shown

            //create an instance of the online nearby class to convert json into normal format

            OnlineNearbyDrivers onlineNearbyDriversInstance =
                OnlineNearbyDrivers();
            onlineNearbyDriversInstance.uidDriver =
                driverEvent["key"]; //gets the driver uid
            onlineNearbyDriversInstance.latDriver =
                driverEvent["latitude"]; //gets the latitude of the driver
            onlineNearbyDriversInstance.lngDriver =
                driverEvent["longitude"]; //gets the longitude of the driver

            //here adding the drivers in the list when they become online adding of list starts from here it wil keep adding the drivers
            ManageDriversMethods.withinRadiusOnlineDriversList
                .add(onlineNearbyDriversInstance);

            if (nearbyOnlineKeysLoaded == true) {
              //update drivers on googlemap
              updateAvailableNearbyOnlineDriversOnMap();
            }

            break;
          case Geofire.onKeyExited:
            //when the driver becomes offline the on key exited will be fired like a volcano to the driver will
            //be removed from the user map

            ManageDriversMethods.removeDriverFromList(driverEvent["key"]);

            updateAvailableNearbyOnlineDriversOnMap();

            //update drivers from the google map
            break;
          case Geofire.onKeyMoved:
            //the movement of the driver within the radius until he disappers will be visible to the user

            OnlineNearbyDrivers onlineNearbyDriversInstance =
                OnlineNearbyDrivers();
            onlineNearbyDriversInstance.uidDriver =
                driverEvent["key"]; //gets the driver uid
            onlineNearbyDriversInstance.latDriver =
                driverEvent["latitude"]; //gets the latitude of the driver
            onlineNearbyDriversInstance.lngDriver =
                driverEvent["longitude"]; //gets the longitude of the driver

            ManageDriversMethods.updateOnlineNearbyDriversLocation(
                onlineNearbyDriversInstance);
            //update drivers on google map
            updateAvailableNearbyOnlineDriversOnMap();
            break;
          case Geofire.onGeoQueryReady:
            //display the online drivers within the radius and nearest
            nearbyOnlineKeysLoaded = true;

            //update drivers on google map

            updateAvailableNearbyOnlineDriversOnMap();
            break;
        }
      }
    }); //listen here will see if user goes offline it will disappear and if goes out of the radius it will stop showing it

    //
  }

  //send request to the driver

  getCurrentLiveLocationOfUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    LatLng positionIfUser = LatLng(
        currentPositionOfUser!.latitude,
        currentPositionOfUser!
            .longitude); //to show the location of the user we need longitude and latitude
    CameraPosition cameraPosition =
        CameraPosition(target: positionIfUser, zoom: 15);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    await AuthenticationController.convertGeocodingCoordinates(
        positionOfUser, context);
    await getUserInfoAndCheckBlockStatus();

    await initializeGeoFireListener();
  }

  getUserInfoAndCheckBlockStatus() async {
    DatabaseReference usersRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
            userPhone = (snap.snapshot.value as Map)["phone"];
            gender = (snap.snapshot.value as Map)["gender"];
          });
        } else {
          FirebaseAuth.instance.signOut();

          Navigator.push(
              context, MaterialPageRoute(builder: (c) => const LoginScreen()));
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }
    });
  }

  makeDriverNearbyCarIcone() {
    if (carIconNearbyDriver == null) {
      ImageConfiguration configuration =
          createLocalImageConfiguration(context, size: const Size(0.5, 0.5));
      BitmapDescriptor.fromAssetImage(configuration, "images/tracking.png")
          .then((iconImage) {
        carIconNearbyDriver = iconImage;
      });
    }
  }

  resetAppNow() {
    setState(() {
      polyLineCoOrdinates.clear();
      polylineset.clear();
      markerSet.clear();
      circleSet.clear();
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 0;
      tripContainerHeight = 0;
      searchContainerHeight = 276;
      bottomMapPadding = 300;
      isDrawerOpened = true;
      status = "";
      nameDriver = "";
      photoDriver = "";
      phoneNumberDriver = "";
      carDetailsDriver = "";
      tripStatusDisplay = "Driver is Arriving";
    });
  }

  cancelRideRequest() {
    //remove the trip request from the database
    //it will cancel or delete the request from the database
    tripRequestReference!.remove();

    setState(() {
      stateOfApp = "normal";
    });
  }

  displayUserRideDetailsContainer() async {
    //async becaus it waits for the api response
    //draw the route between pick up and drop of location using directions API
    await retrieveDirectionDetails();

    //draw route between pickup and drop off location
    setState(() {
      searchContainerHeight = 0; //it will close the search container make it 0
      bottomMapPadding = 240;
      rideDetailsContainerHeight = 300; //open the container of
      isDrawerOpened = false;
    });
  }

  retrieveDirectionDetails() async {
    var pickUpLocation =
        Provider.of<AppInfo>(context, listen: false).pickuplocation;
    var dropOffDestinationLocation =
        Provider.of<AppInfo>(context, listen: false).dropoffLocation;

    var pickupGeoGraphicCoOrdinates =
        LatLng(pickUpLocation!.latitude!, pickUpLocation.longitude!);
    var dropOffDestinationGeoGraphicCoOrdinates = LatLng(
        dropOffDestinationLocation!.latitude!,
        dropOffDestinationLocation.longitude!);

    //show dialog for the waiting until it procedes
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          const LoadingDialog(messageText: "please wait"),
    );

    //Direction Api request and response through the method created in authentication controller
    var detailsFromDirectionApi =
        await AuthenticationController.getDirectionDetailsFromApi(
            pickupGeoGraphicCoOrdinates,
            dropOffDestinationGeoGraphicCoOrdinates);

    setState(() {
      directionDetailsInstance = detailsFromDirectionApi;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    //there will be many points from user pick up location to the destination thats why store in a list
    List<PointLatLng> latLngPointsFromPickupToDestination =
        polylinePoints.decodePolyline(directionDetailsInstance!.encodedPoints!);
    if (latLngPointsFromPickupToDestination.isNotEmpty) {
      latLngPointsFromPickupToDestination.forEach((PointLatLng latLngPoint) {
        //getting points one by one from the list using for each loop and adding it to the polyline coordinates list
        polyLineCoOrdinates
            .add(LatLng(latLngPoint.latitude, latLngPoint.longitude));
      });
    }

    polylineset.clear();
    setState(() {
      //setting the route between the pick up location and destination and its color and style width etc
      Polyline polyline = Polyline(
        polylineId: const PolylineId("polylineID"),
        color: Colors.black,
        points: polyLineCoOrdinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineset.add(polyline);
    });
    LatLngBounds boundsLatlng;
    //fit the polyline into the map
    if (pickupGeoGraphicCoOrdinates.latitude >
            dropOffDestinationGeoGraphicCoOrdinates.latitude &&
        pickupGeoGraphicCoOrdinates.longitude >
            dropOffDestinationGeoGraphicCoOrdinates.longitude) {
      boundsLatlng = LatLngBounds(
          southwest: dropOffDestinationGeoGraphicCoOrdinates,
          northeast: pickupGeoGraphicCoOrdinates);
    } else if (pickupGeoGraphicCoOrdinates.longitude >
        dropOffDestinationGeoGraphicCoOrdinates.longitude) {
      boundsLatlng = LatLngBounds(
        southwest: LatLng(pickupGeoGraphicCoOrdinates.latitude,
            dropOffDestinationGeoGraphicCoOrdinates.longitude),
        northeast: LatLng(dropOffDestinationGeoGraphicCoOrdinates.latitude,
            pickupGeoGraphicCoOrdinates.longitude),
      );
    } else if (pickupGeoGraphicCoOrdinates.latitude >
        dropOffDestinationGeoGraphicCoOrdinates.latitude) {
      boundsLatlng = LatLngBounds(
          southwest: LatLng(dropOffDestinationGeoGraphicCoOrdinates.latitude,
              pickupGeoGraphicCoOrdinates.longitude),
          northeast: LatLng(pickupGeoGraphicCoOrdinates.latitude,
              dropOffDestinationGeoGraphicCoOrdinates.longitude));
    } else {
      boundsLatlng = LatLngBounds(
          southwest: pickupGeoGraphicCoOrdinates,
          northeast: dropOffDestinationGeoGraphicCoOrdinates);
    }

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatlng, 72));
//pick up location marker
    Marker pickUpPointMarker = Marker(
      markerId: const MarkerId("pickUpPointMarkerID"),
      position: pickupGeoGraphicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
          title: pickUpLocation.placeName, snippet: "Pickup location"),
    );
//destinaion point marker
    Marker dropOffDestinationPointMarker = Marker(
      markerId: const MarkerId("dropOffDestinationPointMarkerID"),
      position: dropOffDestinationGeoGraphicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(
          title: dropOffDestinationLocation.placeName,
          snippet: "drop off location"),
    );

    setState(() {
      markerSet.add(pickUpPointMarker);
      markerSet.add(dropOffDestinationPointMarker);
    });
    //add circles in pickup location
    Circle picUpPointsCircle = Circle(
      circleId: const CircleId("pickUpCircleID"),
      strokeColor: Colors.green,
      strokeWidth: 4,
      radius: 14,
      center: pickupGeoGraphicCoOrdinates,
      fillColor: Colors.black,
    );

    //add circles in destination location
    Circle dropOffDestinationPointsCircle = Circle(
      circleId: const CircleId("pickUpCircleID"),
      strokeColor: Colors.yellow,
      strokeWidth: 4,
      radius: 14,
      center: dropOffDestinationGeoGraphicCoOrdinates,
      fillColor: Colors.black,
    );

    setState(() {
      circleSet.add(picUpPointsCircle);
      circleSet.add(dropOffDestinationPointsCircle);
    });
  }

  displayRequestContainer() {
    setState(() {
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 220;
      bottomMapPadding = 200;
      isDrawerOpened = true;
    });

    //send and save the trip request to the database

    maketripRequest();
  }

  maketripRequest() {
    //creating a parent node in database as triprequest and assigning each to a unique id with push
    tripRequestReference =
        FirebaseDatabase.instance.ref().child("tripRequest").push();

    //user pick up location get it with the provider
    var pickUpLocation =
        Provider.of<AppInfo>(context, listen: false).pickuplocation;

    var dropOffLocation =
        Provider.of<AppInfo>(context, listen: false).dropoffLocation;

    //get the geographic coordinates

    Map pickUpCoordinatesMap = {
      "latitude": pickUpLocation!.latitude.toString(),
      "longitude": pickUpLocation.longitude.toString(),
    };

    Map dropOfLocationCoordinateMap = {
      "latitude": dropOffLocation!.latitude.toString(),
      "longitude": dropOffLocation.longitude.toString(),
    };

    Map driverCoordinates = {
      "latitude": "",
      "longitude": "",
    };
    //all the information required for a new trip to be saved in parent node trip request in a MAP
    Map dataMap = {
      "tripID":
          tripRequestReference!.key, // to get the unique key or id of the trip
      "publishDateTime": DateTime.now().toString(),
      "userName": userName,
      "userPhone": userPhone,
      "userID": userID,
      "pickUpLatlng": pickUpCoordinatesMap,
      "dropOffLatlng": dropOfLocationCoordinateMap,
      "pickUpAddress": pickUpLocation.placeName,
      "dropOffAdress": dropOffLocation.placeName,

      //driver records are empty until he/ or she accepts the request then they will be updated
      "driverID":
          "waiting", //at first there is no driver thats why it is waiting
      "carDetails": "",
      "driverLocation": driverCoordinates,
      "driverName": "",
      "driverPhone": "",
      "driverPhoto": "",
      "fareAmount": "",
      "staus": "new",
      "gender": "",
    };

    //saving it to the database with the help of the reference
    tripRequestReference!.set(dataMap);

    //listen if any updates occur in database and get it
    tripstreamSubscription =
        tripRequestReference!.onValue.listen((eventSnapshot) async {
      //when a user send rq user have to wait for which driver will accept it thats why we have to listen

      //when driver accepts the rq the data of the driver wil be extracted

      if (eventSnapshot.snapshot.value == null) {
        return;
      }
      if ((eventSnapshot.snapshot.value as Map)["driverName"] != null) {
        nameDriver = (eventSnapshot.snapshot.value as Map)["driverName"];
      }
      if ((eventSnapshot.snapshot.value as Map)["driverPhone"] != null) {
        phoneNumberDriver =
            (eventSnapshot.snapshot.value as Map)["driverPhone"];
      }
      if ((eventSnapshot.snapshot.value as Map)["driverPhoto"] != null) {
        photoDriver = (eventSnapshot.snapshot.value as Map)["driverPhoto"];
      }
      if ((eventSnapshot.snapshot.value as Map)["gender"] != null) {
        driverGender = (eventSnapshot.snapshot.value as Map)["gender"];
      }
      if ((eventSnapshot.snapshot.value as Map)["carDetails"] != null) {
        carDetailsDriver = (eventSnapshot.snapshot.value as Map)["carDetails"];
      }

      if ((eventSnapshot.snapshot.value as Map)["status"] != null) {
        status = (eventSnapshot.snapshot.value as Map)["status"];
      }

      if ((eventSnapshot.snapshot.value as Map)["driverLocation"] != null) {
        double driverLatitude = double.parse(
            (eventSnapshot.snapshot.value as Map)["driverLocation"]["latitude"]
                .toString());
        double driverLongitude = double.parse(
            (eventSnapshot.snapshot.value as Map)["driverLocation"]["longitude"]
                .toString());

        LatLng currentLocationLatlng = LatLng(driverLatitude, driverLongitude);

        if (status == "accepted") {
          updateFromDriverCurrentLocationToPickUp(currentLocationLatlng);
        } else if (status == "arrived") {
          setState(() {
            tripStatusDisplay = "Driver is on ur location - Get in!";
          });
        } else if (status == "ontrip") {
          updateFromDriverCurrentLocationToDropOffLocaion(
              currentLocationLatlng);
        }
      }
      if (status == "accepted") {
        displayTripDetailsContainer();
        Geofire.stopListener();
        setState(() {
          //when the driver accepts a rq then remove all other online drivers from the users map
          markerSet.removeWhere(
              (element) => element.markerId.value.contains("driver"));
        });
      }
      if (status == "ended") {
        if ((eventSnapshot.snapshot.value as Map)["fareAmount"] != null) {
          double fareAmount = double.parse(
              (eventSnapshot.snapshot.value as Map)["fareAmount"].toString());

          var response = await showDialog(
              context: context,
              builder: (BuildContext context) =>
                  PaymentDialog(fareAmount: fareAmount.toString()));

          if (response == "Paid") {
            if ((eventSnapshot.snapshot.value as Map)["driverID"] != null) {
              String driverId =
                  (eventSnapshot.snapshot.value as Map)["driverID"].toString();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => RatingScreen(
                            driverId: driverId,
                          )));
            }
            tripRequestReference!.onDisconnect();
            tripRequestReference = null;
            tripstreamSubscription!.cancel();
            tripstreamSubscription = null;
            resetAppNow();
          }
        }
      }
    });
  }

  displayTripDetailsContainer() {
    setState(() {
      //remove the request container
      requestContainerHeight = 0;

      //set the height of trip container
      tripContainerHeight = 291;
      bottomMapPadding = 281;
    });
  }

  updateFromDriverCurrentLocationToPickUp(currentLocationLatlng) async {
    if (!requestingDetailsInfo) {
      requestingDetailsInfo = true;
      var userPickUpLocationLatlng = LatLng(
          currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
      var directionDetailsPickUp =
          await AuthenticationController.getDirectionDetailsFromApi(
              currentLocationLatlng, userPickUpLocationLatlng);

      if (directionDetailsPickUp == null) {
        return;
      }
      setState(() {
        tripStatusDisplay =
            "The driver is on his way - ${directionDetailsPickUp.durationTextString}";
      });
      requestingDetailsInfo = false;
    }
  }

  updateFromDriverCurrentLocationToDropOffLocaion(currentLocationLatlng) async {
    if (!requestingDetailsInfo) {
      requestingDetailsInfo = true;

      var dropOffLocationLatlng =
          Provider.of<AppInfo>(context, listen: false).dropoffLocation;

      var userDropOffLocationLatlng = LatLng(
          dropOffLocationLatlng!.latitude!, dropOffLocationLatlng.longitude!);
      var directionDetailsPickUp =
          await AuthenticationController.getDirectionDetailsFromApi(
              currentLocationLatlng, userDropOffLocationLatlng);

      if (directionDetailsPickUp == null) {
        return;
      }
      setState(() {
        tripStatusDisplay =
            "Taking You to ur destination - ${directionDetailsPickUp.durationTextString}";
      });
      requestingDetailsInfo = false;
    }
  }

  noDriverAvailable() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => InfoDialog(
              title: "No Drivers Available",
              description:
                  "No Drivers Available nearby location please try again within minutes",
            ));
  }

  searchDriver() {
    if (availableNearbyDriversList!.isEmpty) {
      //if no drivers available cancel the request
      cancelRideRequest();
      //and reset the app
      resetAppNow();
      //show the dialog box to the user that no drivers available
      noDriverAvailable();

      return;
    } else {
      var currentDriver = availableNearbyDriversList![0];

      //send notifiaction to this current driver

      sendNotifictionToDriver(currentDriver);

      //once the notifiaction is sent to the driver then remove the driver from the list
      availableNearbyDriversList!.removeAt(0);
    }
  }

  sendNotifictionToDriver(OnlineNearbyDrivers currentDriver) {
    DatabaseReference currentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("newTripStatus");
    //change the trip status and asssign  trip id to the driver
    currentDriverRef.set(tripRequestReference!.key);

    //get the driver unique  device token

    DatabaseReference tokenofDriver = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("deviceToken");

    tokenofDriver.once().then((dataSnapshot) {
      if (dataSnapshot.snapshot.value != null) {
        String deviceToken = dataSnapshot.snapshot.value.toString();

//send notifiaction to the driver
        PushNotification.sendNotificationToCurrentDriver(
            deviceToken, context, tripRequestReference!.key.toString());

        //send notifiaction to the driver
      } else {
        return;
      }
    });
    const oneTickPerSecond = Duration(seconds: 1);
    var timerCountDown = Timer.periodic(oneTickPerSecond, (timer) {
      //when user is not requesting or cancelled stop timer
      requestTimeoutDriver = requestTimeoutDriver - 1;
      if (stateOfApp != "requesting") {
        timer.cancel();
        currentDriverRef.set("canceelled");
        currentDriverRef.onDisconnect();
        requestTimeoutDriver = 20;
      }

      //when the users request is accepted  by online nearest available driver
      //when the trip request becomes accepted stop the timer
      currentDriverRef.onValue.listen((dataSnapshot) {
        if (dataSnapshot.snapshot.value.toString() == "accepted") {
          timer.cancel();
          currentDriverRef.onDisconnect();
          requestTimeoutDriver = 20;
        }
      });

      //if the timer is out of 20 seconds and driver didnt accept or cancel the request then the request will be sent to another driver
      if (requestTimeoutDriver == 0) {
        currentDriverRef.set("Timeout"); //change the status of the trip in db
        timer.cancel(); //cancel the timer
        currentDriverRef.onDisconnect(); //disconnect the db reference
        requestTimeoutDriver = 20; //reinitialize the timer

        //send notification to the nearest driver
        searchDriver();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    makeDriverNearbyCarIcone();
    return SafeArea(
      child: Scaffold(
        key: skey,
        drawer: Container(
          width: 255,
          color: Colors.white,
          child: Drawer(
            backgroundColor: Colors.white,
            child: ListView(
              children: [
                //header
                Container(
                  color: Colors.blue,
                  height: 160,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.blue),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 60,
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Profile",
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(
                  height: 1,
                  color: Colors.white,
                  thickness: 1,
                ),

                const SizedBox(
                  height: 10,
                ),

                //body

                ListTile(
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.info,
                      color: Colors.black,
                    ),
                  ),
                  title: Text(
                    "About",
                    style: GoogleFonts.roboto(color: Colors.black),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Get.to(const LoginScreen());
                  },
                  child: ListTile(
                    leading: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      "Logout",
                      style: GoogleFonts.roboto(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            //googleMapAPI
            GoogleMap(
              padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              polylines: polylineset,
              markers: markerSet,
              circles: circleSet,
              initialCameraPosition: googlePlexInitialPosition,
              onMapCreated: (GoogleMapController mapController) {
                controllerGoogleMap = mapController;
                googleMapCompleterController.complete(controllerGoogleMap);

                getCurrentLiveLocationOfUser();
                setState(() {
                  bottomMapPadding = 300;
                });
              },
            ),

            //drawer button to turn it on and off
            Positioned(
              top: 42,
              left: 19,
              child: GestureDetector(
                onTap: () {
                  if (isDrawerOpened == true) {
                    skey.currentState!
                        .openDrawer(); // user will open the drawer
                  } else {
                    resetAppNow();
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7)),
                        ]),
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(5)),
                        child: const Icon(Icons.menu, color: Colors.black87))),
              ),
            ),
            Positioned(
                top: 42,
                right: 19,
                child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)),
                    child: IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.black87),
                        onPressed: () {
                          // handle notification tap
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => NotificationsPage()));
                        }))),
            Positioned(
              left: 0,
              right: 0,
              bottom: 120,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 130,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.amber),
                    color: Colors.amber.withOpacity(0.3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          var responseFromSearchPage = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => const SearchDestinationScreen(),
                            ),
                          );
                          if (responseFromSearchPage == "p") {
                            displayUserRideDetailsContainer();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50, // Adjust the height as needed
                          margin: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber),
                            color: Colors.white,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 20),
                                    Text(
                                      "Where would you go?",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          var responseFromSearchPage = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => const SearchDestinationScreen(),
                            ),
                          );
                          if (responseFromSearchPage == "p") {
                            displayUserRideDetailsContainer();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 40, // Adjust the height as needed
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.amber,
                          ),
                          child: Center(
                            child: Text(
                              "Ride Now",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //ride details container
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        blurRadius: 15.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16),
                        child: SizedBox(
                          height: 190,
                          child: Card(
                            elevation: 18,
                            child: Container(
                              width: MediaQuery.of(context).size.width * .70,
                              color: Colors.black,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, bottom: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            (directionDetailsInstance != null)
                                                ? directionDetailsInstance!
                                                    .distanceTextString!
                                                : "",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 16,
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            (directionDetailsInstance != null)
                                                ? directionDetailsInstance!
                                                    .durationTextString!
                                                : "",
                                            style: GoogleFonts.montserrat(
                                                fontSize: 16,
                                                color: Colors.white70,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            stateOfApp = "requesting";
                                          });

                                          displayRequestContainer();

                                          //get nearest available drivers

                                          //assign the list of online drivers to this list
                                          availableNearbyDriversList =
                                              ManageDriversMethods
                                                  .withinRadiusOnlineDriversList;

                                          //search driver until the request is accepted
                                          searchDriver();
                                        },
                                        child: Image.asset(
                                          "images/car-rental.png",
                                          height: 100,
                                          width: 100,
                                          color: Colors.orange,
                                        )),
                                    Text(
                                      (directionDetailsInstance != null)
                                          ? "BHD ${(authenticationController.calculateFareAmount(directionDetailsInstance!)).toStringAsFixed(1)}"
                                          : "",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //request container

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: requestContainerHeight,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 0.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: 200,
                        child: LoadingAnimationWidget.flickr(
                            leftDotColor: Colors.orange,
                            rightDotColor: Colors.white,
                            size: 60),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          resetAppNow();
                          cancelRideRequest();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(width: 1, color: Colors.orange),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            //trip details container
            // Positioned widget containing the trip details container

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: tripContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black, // Added background color for visibility
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 0.5, // Adjusted blur radius for shadow
                      spreadRadius: 0.5,
                      offset: Offset(0.0, 0.0),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      // Display the details of the trip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              tripStatusDisplay,
                              style: GoogleFonts.roboto(
                                fontSize: 19,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Other widgets in the Row
                        ],
                      ),
                      const SizedBox(height: 6),
                      // A divider
                      Container(
                        height: 1,
                        color: Colors
                            .amber, // Changed color to amber for visibility
                      ),
                      const SizedBox(height: 19),
                      // Display the image of the driver photo, name, gender, and car details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: Image.network(
                              photoDriver == ''
                                  ? "https://firebasestorage.googleapis.com/v0/b/uober-1ea68.appspot.com/o/driveral.png?alt=media&token=29671c17-00d8-4bf9-9474-adb3d3b6a43f"
                                  : photoDriver,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 40),
                          Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Adjusted alignment
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nameDriver,
                                style: GoogleFonts.roboto(
                                    fontSize: 29,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                driverGender,
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                carDetailsDriver,
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // A divider
                      Container(
                        height: 1,
                        color: Colors
                            .amber, // Changed color to amber for visibility
                      ),
                      const SizedBox(height: 20),
                      // Phone icon to call the driver and chat icon to message driver
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              launchUrl(Uri.parse("tel://$phoneNumberDriver"));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.call,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 30),
                          GestureDetector(
                            onTap: () async {
                              final phone =
                                  "973$phoneNumberDriver"; // Concatenating Bahrain country code
                              const message =
                                  "Hello, I'm the one who requested for the ride ."; //  pre-filled message
                              final url =
                                  "https://wa.me/$phone?text=${Uri.encodeFull(message)}";

                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title:
                                          const Text("WhatsApp not installed"),
                                      content: const Text(
                                        "Please install WhatsApp to chat with the driver.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.chat,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
