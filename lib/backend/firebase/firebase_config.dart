import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDrMJqHh07-_O7jKsn1wIHMjI3Kn4nGQEE",
            authDomain: "i-m-f-s-l-staff-n2anb4.firebaseapp.com",
            projectId: "i-m-f-s-l-staff-n2anb4",
            storageBucket: "i-m-f-s-l-staff-n2anb4.firebasestorage.app",
            messagingSenderId: "893340272831",
            appId: "1:893340272831:web:1139d7a1ed5902ff6f1e0a",
            measurementId: "G-Q063G603PP"));
  } else {
    await Firebase.initializeApp();
  }
}
