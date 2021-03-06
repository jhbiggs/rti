// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD3_Q9--91UHWbrmbHVshMTfV5X2YjToWU',
    appId: '1:972193772481:web:4967ed6c15bf5d9a663540',
    messagingSenderId: '972193772481',
    projectId: 'rti4-db375',
    authDomain: 'rti4-db375.firebaseapp.com',
    databaseURL: 'https://rti4-db375-default-rtdb.firebaseio.com',
    storageBucket: 'rti4-db375.appspot.com',
    measurementId: 'G-Z6WVEYEL0T',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCxkGtiI0G-bobugI-VowSyHBgzI6HS-_g',
    appId: '1:972193772481:android:2d46b4fc4ab52cf0663540',
    messagingSenderId: '972193772481',
    projectId: 'rti4-db375',
    databaseURL: 'https://rti4-db375-default-rtdb.firebaseio.com',
    storageBucket: 'rti4-db375.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB7lcNfvsHXq12NS_KmXMof9OaML01GlRM',
    appId: '1:972193772481:ios:9c43d410b4e48253663540',
    messagingSenderId: '972193772481',
    projectId: 'rti4-db375',
    databaseURL: 'https://rti4-db375-default-rtdb.firebaseio.com',
    storageBucket: 'rti4-db375.appspot.com',
    iosClientId:
        '972193772481-1u62pdn5eftdkn71hp2sileksoms9hnf.apps.googleusercontent.com',
    iosBundleId: 'mindframe.com.mindframe.rti.app',
  );
}
