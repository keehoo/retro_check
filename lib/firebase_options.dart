// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyABVtZyFG32TcOCtMemP17a4I2Wg0XfY9s',
    appId: '1:325366404592:web:df65770fa3e888655ef935',
    messagingSenderId: '325366404592',
    projectId: 'game-swap-hub',
    authDomain: 'game-swap-hub.firebaseapp.com',
    storageBucket: 'game-swap-hub.appspot.com',
    measurementId: 'G-X3GD0QN0ER',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD6JnTYOlsTl2QIwM8GGHH2_MzUL3s1e6E',
    appId: '1:325366404592:android:f90b14e031dece1e5ef935',
    messagingSenderId: '325366404592',
    projectId: 'game-swap-hub',
    storageBucket: 'game-swap-hub.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDrTq94HGBqQWeZEvo0nC9oCU26QPXlx_w',
    appId: '1:325366404592:ios:c4d46ba18c30747b5ef935',
    messagingSenderId: '325366404592',
    projectId: 'game-swap-hub',
    storageBucket: 'game-swap-hub.appspot.com',
    iosBundleId: 'com.kubickiengineering.retroCheck',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDrTq94HGBqQWeZEvo0nC9oCU26QPXlx_w',
    appId: '1:325366404592:ios:7f8e4d9950e557df5ef935',
    messagingSenderId: '325366404592',
    projectId: 'game-swap-hub',
    storageBucket: 'game-swap-hub.appspot.com',
    iosBundleId: 'com.example.retroCheck',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyABVtZyFG32TcOCtMemP17a4I2Wg0XfY9s',
    appId: '1:325366404592:web:045b976950e551fe5ef935',
    messagingSenderId: '325366404592',
    projectId: 'game-swap-hub',
    authDomain: 'game-swap-hub.firebaseapp.com',
    storageBucket: 'game-swap-hub.appspot.com',
    measurementId: 'G-JFK72GEXX3',
  );
}
