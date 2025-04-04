import 'dart:developer' as developer; // For logging

import 'package:evaluate_app/apps/router/routerName.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Feedback List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FeedbackScreen(),
    );
  }
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String selectedStore = "";

  @override
  void initState() {
    super.initState();
    _loadSelectedStore();
  }

  Future<void> _loadSelectedStore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final store = prefs.getString('selectedStore') ?? "No store selected";
      developer.log('Loaded selectedStore: $store', name: 'SharedPreferences');
      setState(() {
        selectedStore = store;
      });
    } catch (e) {
      developer.log('Error loading store preference: $e', name: 'SharedPreferences');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading store preference: $e')),
      );
    }
  }

  String formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
      }
      return 'Không có dữ liệu';
    } catch (e) {
      developer.log('Error formatting timestamp: $e', name: 'Timestamp');
      return 'Invalid timestamp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 31, 44, 52),
        title: const Text(
          'DANH SÁCH GÓP Ý',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.goNamed(RouterName.chart),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('feedbacks')
              .where('counter', isEqualTo: selectedStore.isEmpty ? "No store selected" : selectedStore)         
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              developer.log('Firestore error: ${snapshot.error}', name: 'Firestore');
              if (snapshot.error.toString().contains('failed-precondition')) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                          'The query requires an index. Please create it in the Firebase Console.'),
                      TextButton(
                        onPressed: () {
                          // Optionally open the Firebase Console link
                          // For example: launchUrl(Uri.parse('https://console.firebase.google.com/v1/r/project/danhgia-3606f/firestore/indexes?create_composite=...'));
                        },
                        child: const Text('Create Index Now'),
                      ),
                    ],
                  ),
                );
              }
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              developer.log('No data found for selectedStore: $selectedStore', name: 'Firestore');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Không có dữ liệu.'),
                    const SizedBox(height: 10),
                    // Text('Current store: $selectedStore'),
                    TextButton(
                      onPressed: _loadSelectedStore, // Retry loading store
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final feedbacks = snapshot.data!.docs;
            developer.log('Found ${feedbacks.length} documents', name: 'Firestore');

            return ListView.builder(
              itemCount: feedbacks.length,
              itemExtent: 80, // Optimize by setting fixed height
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemBuilder: (context, index) {
                final data = feedbacks[index].data() as Map<String, dynamic>?;

                if (data == null) {
                  developer.log('Invalid data at index $index', name: 'Firestore');
                  return const ListTile(title: Text('Invalid data'));
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      data['satisfaction']?.toString() ?? 'Không có tiêu đề',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      data['feedback']?.toString() ?? 'Không có nội dung',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      formatTimestamp(data['timestamp']),   
                      style: TextStyle(color: Colors.grey.shade500),                   
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}