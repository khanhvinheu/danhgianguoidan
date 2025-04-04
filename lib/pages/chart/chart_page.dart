import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evaluate_app/apps/router/routerName.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> satisfactionCounts = {
    'Hài lòng về thái độ phục vụ': 0,
    'Hài lòng về thời gian phục vụ': 0,
    'Chưa hài lòng về thái độ phục vụ': 0,
    'Chưa hài lòng về thời gian phục vụ': 0,
  };

  List<Map<String, dynamic>> feedbackList = [];
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchFeedbackData();
  }

  void fetchFeedbackData() async {
    final prefs = await SharedPreferences.getInstance();
    final counter =
        prefs.getString('selectedStore') ??
        "No store selected"; // Default value nếu không tìm thấy

    // Start loading
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot =
        await _firestore
            .collection('feedbacks')
            .where('counter', isEqualTo: counter)
            .get();
    Map<String, int> tempCounts = {
      'Hài lòng về thái độ phục vụ': 0,
      'Hài lòng về thời gian phục vụ': 0,
      'Chưa hài lòng về thái độ phục vụ': 0,
      'Chưa hài lòng về thời gian phục vụ': 0,
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
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
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
                    height: 250, // Adjust this value as needed
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
                          getDrawingHorizontalLine:
                              (value) => FlLine(
                                color: Colors.grey.shade300,
                                strokeWidth: 1,
                              ),
                        ),
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
                                  satisfactionCounts.keys.elementAt(
                                    value.toInt(),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  satisfactionCounts.keys.elementAt(
                                    value.toInt(),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                // Lấy tiêu đề từ keys của satisfactionCounts
                                String title = satisfactionCounts.keys
                                    .elementAt(value.toInt());

                                return Container(
                                  width: screenWidth / 6,
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    maxLines: 1, // Giới hạn tối đa 2 dòng
                                    overflow:
                                        TextOverflow
                                            .ellipsis, // Thêm dấu ba chấm nếu tiêu đề quá dài
                                    softWrap: true, // Cho phép xuống dòng
                                    style: TextStyle(
                                      fontSize:
                                          10, // Giảm kích thước font nếu cần
                                    ),
                                  ),
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
      case 'Hài lòng về thái độ phục vụ':
        return Colors.green;
      case 'Hài lòng về thời gian phục vụ':
        return Colors.blue;
      case 'Chưa hài lòng về thái độ phục vụ':
        return Colors.orange;
      case 'Chưa hài lòng về thời gian phục vụ':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
