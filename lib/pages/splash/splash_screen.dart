import 'package:evaluate_app/apps/router/routerName.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isConnected = true;
  bool _isLoading = true; // Indicates whether the connection is being checked
  bool _hasTriedAgain = false; // Flag to check if Retry was clicked

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  // Function to check network connection
  Future<void> _checkConnection() async {
    if (_hasTriedAgain) return; // Avoid retrying unnecessarily
    setState(() {
      _isLoading = true; // Start loading when checking connection
    });

    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    // Navigate to home if connected
    // context.pushReplacementNamed(RouterName.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, // Start from top
            end: Alignment.bottomCenter, // End at bottom
            colors: [
              const Color.fromARGB(255, 1, 112, 176), // Dark blue
              const Color.fromARGB(255, 1, 24, 71), // Lighter blue
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/robot.json',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                repeat: true, // Set to false to play only once
                reverse: true, // Play in reverse
                animate: true, // Auto-play animation
              ),
              const SizedBox(height: 0),
              Text(
                'Hãy góp ý cho tôi!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),

              const SizedBox(height: 20),

              // Add the "Góp Ý" button here
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the feedback screen
                    context.pushNamed(RouterName.home);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [const Text('Góp ý ngay', style: TextStyle(fontWeight: FontWeight.bold),), Icon(Icons.arrow_forward)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
