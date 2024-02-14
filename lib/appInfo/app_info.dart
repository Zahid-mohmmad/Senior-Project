import 'package:flutter/material.dart';
import 'package:uober/models/address_model.dart';

class AppInfo extends ChangeNotifier {
  Address? pickuplocation;
  Address? dropoffLocation;

  void updatePickupLocation(Address pickup) {
    pickuplocation = pickup;
    notifyListeners();
  }

  void updateDropOffLocation(Address dropOff) {
    dropoffLocation = dropOff;
    notifyListeners();
  }
}
