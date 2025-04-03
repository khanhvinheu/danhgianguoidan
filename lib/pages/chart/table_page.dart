import 'package:evaluate_app/apps/router/routerName.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Feedback List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FeedbackScreen(),
    );
  }
}

class FeedbackScreen extends StatelessWidget {
  @override
  String formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
    }
    return 'Không có dữ liệu';
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 31, 44, 52),
        title: Text('DANH SÁCH GÓP Ý', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.goNamed(RouterName.chart);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: StreamBuilder(
          stream:
              FirebaseFirestore.instance
                  .collection('feedbacks')
                  .orderBy(
                    'timestamp',
                    descending: true,
                  ) // Sort by timestamp, descending order
                  .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Không có dữ liệu.'));
            }

            var feedbacks = snapshot.data!.docs;

            return ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                var data = feedbacks[index].data() as Map<String, dynamic>;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(data['satisfaction'] ?? 'Không có tiêu đề'),
                    subtitle: Text(data['feedback'] ?? 'Không có nội dung'),
                    trailing: Text(formatTimestamp(data['timestamp'])),
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
