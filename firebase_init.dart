import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseInit {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        // TODO: Replace with your own Firebase config from google-services.json
        // These options are read automatically from google-services.json on Android
        // You can also provide them explicitly:
        // options: const FirebaseOptions(
        //   apiKey: 'YOUR_API_KEY',
        //   appId: 'YOUR_APP_ID',
        //   messagingSenderId: 'YOUR_SENDER_ID',
        //   projectId: 'YOUR_PROJECT_ID',
        //   storageBucket: 'YOUR_STORAGE_BUCKET',
        // ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
      }
    }
  }
}
