import 'package:evaluate_app/apps/router/routerName.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:transparent_image/transparent_image.dart';

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
              // Logo or Splash Image
              FadeInImage.memoryNetwork(
                fit: BoxFit.cover,
                height: 50,
                width: 50,
                placeholder: kTransparentImage,
                image:
                    'https://plus.unsplash.com/premium_photo-1677252438450-b779a923b0f6?q=80&w=1480&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              ),
              const SizedBox(height: 20),
              Text('Hãy góp ý cho tôi', style: TextStyle(color: Colors.white),),
              
              const SizedBox(height: 20),

              // Add the "Góp Ý" button here
              ElevatedButton(
                onPressed: () {
                  // Navigate to the feedback screen
                  context.pushNamed(RouterName.home);
                },
                child: const Text('Góp Ý'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
