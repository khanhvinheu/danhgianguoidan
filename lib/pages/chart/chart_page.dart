import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  @override
  void initState() {
    super.initState();
    fetchFeedbackData();
  }

  void fetchFeedbackData() async {
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

    setState(() {
      satisfactionCounts = tempCounts;
      feedbackList = tempFeedbackList;
    });
  }

  String formatTimestamp(DateTime timestamp) {
    // Format date as 'dd/MM/yyyy hh:mm a'
    return DateFormat('dd/MM/yyyy hh:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thống kê phản hồi')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Bar Chart
              Container(
                height: 300, // Adjust this value as needed
                child: BarChart(
                  BarChartData(
                    barGroups:
                        satisfactionCounts.entries.map((entry) {
                          return BarChartGroupData(
                            x: satisfactionCounts.keys.toList().indexOf(
                              entry.key,
                            ),
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
              SizedBox(height: 16),
              // Feedback List
              Text('DANH SÁCH PHẢN HỒI'),
              ListView.builder(
                shrinkWrap:
                    true, // Allows ListView to take only the required space
                itemCount: feedbackList.length,
                itemBuilder: (context, index) {
                  var feedback = feedbackList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(feedback['feedback']),
                      subtitle: Text(
                        'Satisfaction: ${feedback['satisfaction']}',
                      ),
                      trailing: Text(
                        'Timestamp:${formatTimestamp(feedback['timestamp'])}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  );
                },
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
