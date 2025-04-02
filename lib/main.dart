import 'package:flutter/material.dart';
import 'package:evaluate_app/pages/my_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:evaluate_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions.currentPlatform, // Thêm tùy chọn này nếu cần
    );
    print("🔥 Firebase connected successfully!");
  } catch (e) {
    print("❌ Firebase connection failed: $e");
  }
  runApp(MyApp());
}
