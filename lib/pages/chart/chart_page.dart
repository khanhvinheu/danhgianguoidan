import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evaluate_app/apps/router/routerName.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> satisfactionCounts = {
    'Rất hài lòng': 0,
    'Hài lòng': 0,
    'Không hài lòng': 0,
    'Tức giận': 0,
  };

  List<Map<String, dynamic>> feedbackList = [];
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchFeedbackData();
  }

  void fetchFeedbackData() async {
    // Start loading
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await _firestore.collection('feedbacks').get();
    Map<String, int> tempCounts = {
      'Rất hài lòng': 0,
      'Hài lòng': 0,
      'Không hài lòng': 0,
      'Tức giận': 0,
    };
    List<Map<String, dynamic>> tempFeedbackList = [];

    for (var doc in snapshot.docs) {
      String satisfaction = doc['satisfaction'] ?? '';
      String feedback = doc['feedback'] ?? '';
      Timestamp timestamp = doc['timestamp'] ?? Timestamp.now();

      // Count satisfaction feedbacks
      if (tempCounts.containsKey(satisfaction)) {
        tempCounts[satisfaction] = tempCounts[satisfaction]! + 1;
      }

      // Add feedback data to the list
      tempFeedbackList.add({
        'feedback': feedback,
        'satisfaction': satisfaction,
        'timestamp': timestamp.toDate(),
      });
    }

    // Update state after fetching data
    setState(() {
      satisfactionCounts = tempCounts;
      feedbackList = tempFeedbackList;
      isLoading = false; // Data loaded
    });
  }

  String formatTimestamp(DateTime timestamp) {
    // Format date as 'dd/MM/yyyy hh:mm a'
    return DateFormat('dd/MM/yyyy hh:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 31, 44, 52),
        title: Text('THỐNG KÊ PHẢN HỒI', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.goNamed(RouterName.splash);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.list, color: Colors.white),
            onPressed: () {
              context.goNamed(RouterName.table);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            children: [
              // Show loading indicator if data is still being fetched
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      height: 300, // Adjust this value as needed
                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(
                            show: true,
                            border: Border.symmetric(
                              horizontal: BorderSide(color: Colors.grey),
                              vertical: BorderSide(color: Colors.grey),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.shade300,
                              strokeWidth: 1,
                            ),
                          ),
                          barGroups: satisfactionCounts.entries.map((entry) {
                            return BarChartGroupData(
                              x: satisfactionCounts.keys.toList().indexOf(entry.key),
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.toDouble(),
                                  color: getColor(entry.key),
                                  width: 20,
                                ),
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    satisfactionCounts.keys.elementAt(value.toInt()),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    satisfactionCounts.keys.elementAt(value.toInt()),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    satisfactionCounts.keys.elementAt(value.toInt()),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Color getColor(String satisfaction) {
    switch (satisfaction) {
      case 'Rất hài lòng':
        return Colors.green;
      case 'Hài lòng':
        return Colors.blue;
      case 'Không hài lòng':
        return Colors.orange;
      case 'Tức giận':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
