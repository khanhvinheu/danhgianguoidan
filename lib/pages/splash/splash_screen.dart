import 'package:evaluate_app/apps/router/routerName.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isConnected = true;
  bool _isLoading = true; // Indicates whether the connection is being checked
  bool _hasTriedAgain = false; // Flag to check if Retry was clicked
  List<String> stores = [
    "Đất đai",
    "Đăng ký kinh doanh",
    "Chứng thực hộ tịch",
    "Xây dựng",
  ];
  String? selectedStore;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _loadSelectedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? store = prefs.getString('selectedStore');
    if (store != null) {
      setState(() {
        selectedStore = store;
      });
    }
  }

  Future<void> _selectStore(String store) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedStore', store);
    setState(() {
      selectedStore = store;
    });
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
    if (selectedStore != null) {
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

                const SizedBox(height: 10),
                Text(
                  'Quầy: ${selectedStore}',
                  style: TextStyle(color: Colors.white),
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
                      children: [
                        const Text(
                          'Góp ý ngay',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CHỌN QUẦY',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 31, 44, 52),
      ),
      body: ListView.builder(
        itemCount: stores.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              tileColor: index.isEven ? Colors.lightBlue.shade50 : Colors.white,
              leading: Icon(Icons.store, color: Colors.blue),
              title: Text(
                stores[index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                'Chọn quầy để nhận đánh giá và góp ý',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              onTap: () => _selectStore(stores[index]),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
            ),
          );
        },
      ),
    );
  }
}
