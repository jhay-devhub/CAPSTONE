// How to get your Firebase web config values:
//  1. Go to https://console.firebase.google.com
//  2. Select your project → Project Settings → General
//  3. Under "Your apps", click Add app → Web (</>) if you haven't already
//  4. Copy the values from the firebaseConfig object into the fields below.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  // ─── FILL IN YOUR FIREBASE WEB CONFIG VALUES BELOW ─────────────────────────

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAlF2YI3f5Nh3djH3I1sy7PsxR4VlLAx_c',
    appId: '1:17039585193:web:65401c8c3025c3abf35eb8',
    messagingSenderId: '17039585193',
    projectId: 'capstone-emergency-app',
    authDomain: 'capstone-emergency-app.firebaseapp.com',
    storageBucket: 'capstone-emergency-app.firebasestorage.app',
    measurementId: 'G-2V556E3SDH',
  );
}
