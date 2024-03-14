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
      debugShowCheckedModeBanner: false,
      title: 'Movie Rating App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.dark(
          primary: Color.fromARGB(255, 0, 238, 255), // Dark gray color
        ),
      ),
      builder: (context, child) {
        return Scaffold(
          body: SafeArea(
            child: Container(
              color: Colors.transparent, // Transparent color to allow the background color to show
              child: child,
            ),
          ),
        );
      },
      home: const AuthGate(),
    );
  }
}
