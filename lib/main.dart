import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this file is correctly placed in your project
import 'auth_gate.dart'; // Assuming AuthGate is your root widget after Firebase initialization

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  
    return MaterialApp(
      title: 'Your App Title Here', // Update the title as needed
      home: AuthGate(), // Your AuthGate or similar root widget
      // Consider adding routes and theme as in your second main.dart if needed
    );
  }
}
