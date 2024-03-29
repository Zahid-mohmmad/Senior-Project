// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAfrpDyXWVmPoKlN-eqq6c_A4g09pXVpBo',
    appId: '1:892178368432:web:c43bba497f80bbba387875',
    messagingSenderId: '892178368432',
    projectId: 'uober-1ea68',
    authDomain: 'uober-1ea68.firebaseapp.com',
    storageBucket: 'uober-1ea68.appspot.com',
    measurementId: 'G-WKK8TW4EWE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCE7a0H835hPtBcnv_MsApr9KDVHNY3U0U',
    appId: '1:892178368432:android:2ae7f064651331d7387875',
    messagingSenderId: '892178368432',
    projectId: 'uober-1ea68',
    storageBucket: 'uober-1ea68.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAjNIZPNUCHoIItGfPIfPahsi-9KHzY_io',
    appId: '1:892178368432:ios:a8858f5407178b8e387875',
    messagingSenderId: '892178368432',
    projectId: 'uober-1ea68',
    storageBucket: 'uober-1ea68.appspot.com',
    iosBundleId: 'com.example.uober',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAjNIZPNUCHoIItGfPIfPahsi-9KHzY_io',
    appId: '1:892178368432:ios:d1cb9e8c7751cc41387875',
    messagingSenderId: '892178368432',
    projectId: 'uober-1ea68',
    storageBucket: 'uober-1ea68.appspot.com',
    iosBundleId: 'com.example.uober.RunnerTests',
  );
}
