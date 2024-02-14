import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uober/appInfo/app_info.dart';
import 'package:uober/authentication/login_screen.dart';
import 'package:uober/controllers/authentication_controller.dart';
import 'package:uober/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(AuthenticationController());
  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) //if value of permission is true  then it is denied
    {
      //reuquest for permission of the location
      Permission.locationWhenInUse.request();
    }
  });

  runApp(ChangeNotifierProvider(
    create: (context) => AppInfo(),
    child: GetMaterialApp(
      title: 'Uober',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white),
      home: const LoginScreen(),
    ),
  ));
}
