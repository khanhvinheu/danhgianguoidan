import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCjEZNOGXbJcAVgI_4uWVTr9bPQtPLCmic',
    appId: '1:777018023832:android:91900ce2af56c0e138d5ed',
    messagingSenderId: 'your-android-messaging-sender-id',
    projectId: 'danhgia-3606f',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCjEZNOGXbJcAVgI_4uWVTr9bPQtPLCmic',
    appId: '1:777018023832:android:91900ce2af56c0e138d5ed',
    messagingSenderId: 'your-android-messaging-sender-id',
    projectId: 'danhgia-3606f',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCjEZNOGXbJcAVgI_4uWVTr9bPQtPLCmic',
    appId: '1:777018023832:android:91900ce2af56c0e138d5ed',
    messagingSenderId: 'your-android-messaging-sender-id',
    projectId: 'danhgia-3606f',
  );
}