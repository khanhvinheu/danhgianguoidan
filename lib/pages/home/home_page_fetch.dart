import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _FirestoreExampleState createState() => _FirestoreExampleState();
}

class _FirestoreExampleState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String testValue = "Loading...";

  void getData() async {
    DocumentSnapshot snapshot =
        await _firestore
            .collection("danhgianguoidan")
            .doc("438gh8mzjDFh6oims62O")
            .get();

    if (snapshot.exists) {
      setState(() {
        testValue = snapshot["test"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firestore Data")),
      body: Center(child: Text("Test Value: $testValue")),
    );
  }
}
