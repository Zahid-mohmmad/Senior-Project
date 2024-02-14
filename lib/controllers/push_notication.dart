import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:uober/appInfo/app_info.dart';
import 'package:uober/global/global_variable.dart';
import 'package:http/http.dart' as http;

class PushNotification {
  static sendNotificationToCurrentDriver(
      String deviceToken, BuildContext context, String tripID) async {
    //get the location where user wants to go
    String dropOffLocation = Provider.of<AppInfo>(context, listen: false)
        .dropoffLocation!
        .placeName
        .toString();
    String pickUpLocation = Provider.of<AppInfo>(context, listen: false)
        .pickuplocation!
        .placeName
        .toString();

    Map<String, String> headerNotificationMap = {
      "Content-Type": "application/json",

      //enable the firebase messagin api and get the server key
      "Authorization": serverKey,
    };

    Map titleBodyNotificationMap = {
      "title": "A $gender Student: $userName  Requesting a ride",
      "body": "at Location: $pickUpLocation \n To : $dropOffLocation",
    };

    Map dataMapNotification = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "tripID": tripID,
    };

    //combine all three maps

    Map bodyNotificationMap = {
      "notification": titleBodyNotificationMap,
      "data": dataMapNotification,
      "priority": "high",
      "to": deviceToken,
    };

    //send request to google firebase messaging api
    try {
       await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerNotificationMap,
        body: jsonEncode(bodyNotificationMap),
      );
    } catch (e) {
      return;
    }
  }
}
