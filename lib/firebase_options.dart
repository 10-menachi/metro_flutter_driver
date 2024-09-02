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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrHaw5OtXLfChnPf8A6QHFbPyp76WjtYo',
    appId: '1:394465491097:android:6fdb52b7bcacbff8e1a008',
    messagingSenderId: '394465491097',
    projectId: 'metroberry-cbbd8',
    storageBucket: 'metroberry-cbbd8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCVu12VO7_NBTkyVdnE14r381kHDzYZKI',
    appId: '1:394465491097:ios:848d3a584628c005e1a008',
    messagingSenderId: '394465491097',
    projectId: 'metroberry-cbbd8',
    storageBucket: 'metroberry-cbbd8.appspot.com',
    androidClientId: '394465491097-5gkt7agea88d12t83d53v8ki3liilqhq.apps.googleusercontent.com',
    iosClientId: '394465491097-j6a5kuee0ssclh3kn8deg1phpjv9lr2c.apps.googleusercontent.com',
    iosBundleId: 'com.driver.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB4aOxLRrvhTVBmdmMy4ZZawtzKPAtdG3Q',
    appId: '1:394465491097:web:6a1be2067fbbd5f3e1a008',
    messagingSenderId: '394465491097',
    projectId: 'metroberry-cbbd8',
    authDomain: 'metroberry-cbbd8.firebaseapp.com',
    storageBucket: 'metroberry-cbbd8.appspot.com',
    measurementId: 'G-L9VRX5F45V',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCCVu12VO7_NBTkyVdnE14r381kHDzYZKI',
    appId: '1:394465491097:ios:848d3a584628c005e1a008',
    messagingSenderId: '394465491097',
    projectId: 'metroberry-cbbd8',
    storageBucket: 'metroberry-cbbd8.appspot.com',
    iosBundleId: 'com.driver.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB4aOxLRrvhTVBmdmMy4ZZawtzKPAtdG3Q',
    appId: '1:394465491097:web:19a098cd60e9647fe1a008',
    messagingSenderId: '394465491097',
    projectId: 'metroberry-cbbd8',
    authDomain: 'metroberry-cbbd8.firebaseapp.com',
    storageBucket: 'metroberry-cbbd8.appspot.com',
    measurementId: 'G-28ZV47GM66',
  );

}