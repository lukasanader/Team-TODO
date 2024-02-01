import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThreadApp extends StatefulWidget {
  const ThreadApp({Key? key}) : super(key: key);

  @override
  _ThreadAppState createState() => _ThreadAppState();
}

class _ThreadAppState extends State<ThreadApp> {
  var firestoreDb = FirebaseFirestore.instance.collection("thread").snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Testing Da threads"),
      ),
      body: StreamBuilder(
        stream: firestoreDb,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, int index) {
                return Text(snapshot.data!.docs[index]['thread title']);
              });
        },
      ),
    );
  }
}
