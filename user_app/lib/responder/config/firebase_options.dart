// Firebase configuration for the ResQLink user app (Android & iOS).

import 'dart:io';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'The user app is mobile-only. Web platform is not supported.',
      );
    }
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    throw UnsupportedError(
      'DefaultFirebaseOptions are not configured for this platform.',
    );
  }

  // ── Android ──────────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgCVsYq3wjQ8JnIFatHlmhnWFo2YrzgbU',
    appId: '1:17039585193:android:6bffe8915dbcdbeff35eb8',
    messagingSenderId: '17039585193',
    projectId: 'capstone-emergency-app',
    storageBucket: 'capstone-emergency-app.firebasestorage.app',
  );

  // ── iOS ───────────────────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC5dr8AB8s2xpcp-QRlstvsPZwYKfNrdLU',
    appId: '1:17039585193:ios:dad9803f4d34e686f35eb8',
    messagingSenderId: '17039585193',
    projectId: 'capstone-emergency-app',
    storageBucket: 'capstone-emergency-app.firebasestorage.app',
    iosBundleId: 'com.example.userApp',
  );
}
