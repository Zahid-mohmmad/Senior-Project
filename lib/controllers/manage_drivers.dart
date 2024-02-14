import 'package:uober/models/online_nearby_drivers.dart';

class ManageDriversMethods {
  // create a list of type online nearby drivers class

  static List<OnlineNearbyDrivers> withinRadiusOnlineDriversList = [];

  //if any driver exited or moved outside the radius of the user will be moved from the list
  static void removeDriverFromList(String driverID) {
    int index = withinRadiusOnlineDriversList
        .indexWhere((driver) => driver.uidDriver == driverID);

    if (withinRadiusOnlineDriversList
        .isNotEmpty) //same as in linked list form data structures
    {
      withinRadiusOnlineDriversList.removeAt(index);
    }
  }

// when a driver comes inside the radius to update the radius we use this method as a list of drivers no matter how many even if 10
  static void updateOnlineNearbyDriversLocation(
      OnlineNearbyDrivers onlinedriverInfo) {
    int index = withinRadiusOnlineDriversList
        .indexWhere((driver) => driver.uidDriver == onlinedriverInfo.uidDriver);

    withinRadiusOnlineDriversList[index].latDriver = onlinedriverInfo.latDriver;
    withinRadiusOnlineDriversList[index].lngDriver = onlinedriverInfo.lngDriver;
  }
}
