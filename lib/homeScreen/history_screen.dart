import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  final completedTripRequestsOfCurrentDriver =
      FirebaseDatabase.instance.ref().child("tripRequest");

  bool _isCancelledSelected = true;

  // Function to format DateTime to display only date
  String _formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "History",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
              height: 20), // Add some space between AppBar and ListView
          Container(
            color: Colors.amber, // Background color of toggle buttons
            child: ToggleButtons(
              isSelected: [_isCancelledSelected, !_isCancelledSelected],
              onPressed: (index) {
                setState(() {
                  _isCancelledSelected = index == 0;
                });
              },
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Cancelled',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            _isCancelledSelected ? Colors.black : Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Completed',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            !_isCancelledSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: completedTripRequestsOfCurrentDriver.onValue,
              builder: (BuildContext context, snapshotData) {
                if (snapshotData.hasError) {
                  return _buildNoRecordsAvailable();
                }
                if (snapshotData.data == null ||
                    snapshotData.data!.snapshot.value == null) {
                  return _buildNoRecordsAvailable();
                }
                Map? dataTrips = snapshotData.data!.snapshot.value as Map?;
                if (dataTrips == null) {
                  return _buildNoRecordsAvailable();
                }
                List tripsList = [];

                dataTrips.forEach(
                    (key, value) => tripsList.add({"key": key, ...value}));

                if (tripsList.isEmpty) {
                  return _buildNoRecordsAvailable();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: tripsList.length,
                  itemBuilder: ((context, index) {
                    if (_isCancelledSelected) {
                      // Show cancelled trips
                      if (tripsList[index]["status"] != null &&
                          tripsList[index]["status"] == "cancelled" &&
                          tripsList[index]["driverID"] ==
                              FirebaseAuth.instance.currentUser!.uid) {
                        return _buildTripContainer(tripsList[index]);
                      } else {
                        return Container();
                      }
                    } else {
                      // Show completed trips
                      if (tripsList[index]["status"] != null &&
                          tripsList[index]["status"] == "ended" &&
                          tripsList[index]["driverID"] ==
                              FirebaseAuth.instance.currentUser!.uid) {
                        return _buildTripContainer(tripsList[index]);
                      } else {
                        return Container();
                      }
                    }
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripContainer(Map trip) {
    const SizedBox(
      height: 20,
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width - 16,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.amber),
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  trip["userName"] ?? "",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey),
                  const SizedBox(
                    width: 18,
                  ),
                  Expanded(
                    child: Text(
                      trip["pickUpAddress"].toString(),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.amber),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.amber),
                  const SizedBox(
                    width: 18,
                  ),
                  Expanded(
                    child: Text(
                      trip["dropOffAdress"].toString(),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.date_range,
                      color: Colors.black), // Date icon
                  const SizedBox(
                      width: 18), // Add some space between icon and text
                  Expanded(
                    child: Text(
                      _formatDate(trip["publishDateTime"]),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 90), // Add some space between date and amount
                  Expanded(
                    child: Text(
                      "${trip["fareAmount"]} BHD",
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoRecordsAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_car,
            size: 80,
            color: Colors.black,
          ),
          Text(
            "No records available",
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
