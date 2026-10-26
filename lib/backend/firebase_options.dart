// Public Firebase application configuration downloaded using Firebase CLI.
// These values identify the app; they are not server service-account credentials.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class RaystoFirebaseOptions {
  static FirebaseOptions get currentPlatform => switch (defaultTargetPlatform) {
    TargetPlatform.android => android,
    TargetPlatform.iOS => ios,
    _ => throw UnsupportedError(
      'Raysto Firebase supports Android and iOS only.',
    ),
  };
  static const android = FirebaseOptions(
    apiKey: "AIzaSyAbZsZJP-NUeYUbFH4ml8sh3bn--fwewEQ",
    appId: "1:110106610042:android:0c26736df2eb8f90076ec3",
    messagingSenderId: "110106610042",
    projectId: "raysto-38505",
    databaseURL:
        "https://raysto-38505-default-rtdb.europe-west1.firebasedatabase.app",
    storageBucket: "raysto-38505.firebasestorage.app",
  );
  static const ios = FirebaseOptions(
    apiKey: "AIzaSyCSRwJKsIDfzoJyyms6adwZOJrmfyxEIJk",
    appId: "1:110106610042:ios:455ee13e4e8e6103076ec3",
    messagingSenderId: "110106610042",
    projectId: "raysto-38505",
    databaseURL:
        "https://raysto-38505-default-rtdb.europe-west1.firebasedatabase.app",
    iosBundleId: "com.gmrt.raysto",
    iosClientId: "110106610042-e4g6jirssnau63fl3ahi94sv2kjl78s6.apps.googleusercontent.com",
    storageBucket: "raysto-38505.firebasestorage.app",
  );
}
