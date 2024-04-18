import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points_plus/flutter_polyline_points_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uober/global/global_variable.dart';
import 'package:uober/widgets/payment_dialog.dart';

class Reaching extends StatefulWidget {
  const Reaching({Key? key}) : super(key: key);

  @override
  State<Reaching> createState() => _ReachingState();
}

class _ReachingState extends State<Reaching> {
  final Completer<GoogleMapController> _controller = Completer();

  late final LatLng _uobLocation = const LatLng(
    26.05333826499873,
    50.513233984051304,
  );

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor uobIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;

      // Call getPolyPoints() here after setting currentLocation
      getPolyPoints();
    });

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              zoom: 13.5,
              target: LatLng(newLoc.latitude!, newLoc.longitude!))));

      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleMapKey,
      PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
      PointLatLng(_uobLocation.latitude, _uobLocation.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) =>
          polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
      setState(() {});
    }
  }

  void trackBookingStatusChanges() {
    final bookingRef = FirebaseDatabase.instance.ref("bookings");
    bookingRef.onChildChanged.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;

      Map<dynamic, dynamic>? bookingData =
          dataSnapshot.value as Map<dynamic, dynamic>?;

      if (bookingData != null) {
        String status = bookingData['status'] ?? '';

        if (status == 'completed') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return PaymentDialog(
                  fareAmount:
                      '1'); // Show payment dialog with fixed fare amount of 1 BHD
            },
          );
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    trackBookingStatusChanges(); // Call trackBookingStatusChanges here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "To UOB",
            style: TextStyle(
              color: Colors.amber,
              fontFamily: 'poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: currentLocation == null
          ? const Center(
              child: Text("Loading"),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 14),
              polylines: {
                Polyline(
                    polylineId: const PolylineId("route"),
                    points: polylineCoordinates,
                    color: Colors.black,
                    width: 6)
              },
              markers: {
                Marker(
                    markerId: const MarkerId("userLocation"),
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!)),
                Marker(
                    markerId: const MarkerId("uobLocation"),
                    position: _uobLocation),
              },
              onMapCreated: (mapController) {
                _controller.complete(mapController);
              },
            ),
    );
  }
}
