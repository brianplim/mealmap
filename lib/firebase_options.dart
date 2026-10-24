import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBB658vQJeLVzS-QF2uS_gl_axG0_mf-AU',
    appId: '1:505627318963:web:c4a33f1a8a7c1939466ec6',
    messagingSenderId: '505627318963',
    projectId: 'mealmap-58f1b',
    authDomain: 'mealmap-58f1b.firebaseapp.com',
    storageBucket: 'mealmap-58f1b.firebasestorage.app',
    measurementId: 'G-XEM2LW2QJF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBB658vQJeLVzS-QF2uS_gl_axG0_mf-AU',
    appId: '1:505627318963:android:c4a33f1a8a7c1939466ec6',
    messagingSenderId: '505627318963',
    projectId: 'mealmap-58f1b',
    storageBucket: 'mealmap-58f1b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBB658vQJeLVzS-QF2uS_gl_axG0_mf-AU',
    appId: '1:505627318963:ios:c4a33f1a8a7c1939466ec6',
    messagingSenderId: '505627318963',
    projectId: 'mealmap-58f1b',
    storageBucket: 'mealmap-58f1b.firebasestorage.app',
  );

  static const FirebaseOptions macos = web;
  static const FirebaseOptions windows = web;
  static const FirebaseOptions linux = web;
}
