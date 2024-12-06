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
    apiKey: 'AIzaSyBxggb7jyq1UQa3hm-oNdfyszkv-noaeLs',
    appId: '1:301222612357:web:faa4c585a1751e4c3548ec',
    messagingSenderId: '301222612357',
    projectId: 'mundotlaxcala',
    authDomain: 'mundotlaxcala.firebaseapp.com',
    storageBucket: 'mundotlaxcala.firebasestorage.app',
    measurementId: 'G-LV85JB3D8D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBLi0R2DKHX_8-aZUJm6vn51-wqKmeWXFc',
    appId: '1:301222612357:android:b033733e5be413c13548ec',
    messagingSenderId: '301222612357',
    projectId: 'mundotlaxcala',
    storageBucket: 'mundotlaxcala.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC7osELQyeTLLspkGv3DxOkBb8rFKvLh0o',
    appId: '1:301222612357:ios:d046e5530dee03f93548ec',
    messagingSenderId: '301222612357',
    projectId: 'mundotlaxcala',
    storageBucket: 'mundotlaxcala.firebasestorage.app',
    iosClientId: '301222612357-6bkj092nkk7lj0bndahl2n06mvvsqmii.apps.googleusercontent.com',
    iosBundleId: 'com.example.tlaxcalaWorld',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC7osELQyeTLLspkGv3DxOkBb8rFKvLh0o',
    appId: '1:301222612357:ios:d046e5530dee03f93548ec',
    messagingSenderId: '301222612357',
    projectId: 'mundotlaxcala',
    storageBucket: 'mundotlaxcala.firebasestorage.app',
    iosClientId: '301222612357-6bkj092nkk7lj0bndahl2n06mvvsqmii.apps.googleusercontent.com',
    iosBundleId: 'com.example.tlaxcalaWorld',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBxggb7jyq1UQa3hm-oNdfyszkv-noaeLs',
    appId: '1:301222612357:web:1924a9a546116b803548ec',
    messagingSenderId: '301222612357',
    projectId: 'mundotlaxcala',
    authDomain: 'mundotlaxcala.firebaseapp.com',
    storageBucket: 'mundotlaxcala.firebasestorage.app',
    measurementId: 'G-JGQXTZV053',
  );
}