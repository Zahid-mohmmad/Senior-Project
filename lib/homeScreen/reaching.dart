import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator package
import 'package:uober/global/global_variable.dart';

class Reaching extends StatefulWidget {
  const Reaching({Key? key}) : super(key: key);

  @override
  State<Reaching> createState() => _ReachingState();
}

class _ReachingState extends State<Reaching> {
  late GoogleMapController _controller;
  late LatLng _userLocation; // Variable to hold user's location
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _getLocation() async {
    try {
      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Update the user's location variable
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });

      //add a marker to the userlocation

      // Move camera to the user's location with zoom level 14.5
      _controller
          .animateCamera(CameraUpdate.newLatLngZoom(_userLocation, 14.5));
    } catch (e) {
      // print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "To UOB",
          style: TextStyle(
            color: Colors.amber,
            fontFamily: 'poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: googlePlexInitialPosition,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          _markers:
          {
            Marker(markerId: MarkerId("UserLocation"), position: _userLocation);
          }
        },
      ),
    );
  }
}
