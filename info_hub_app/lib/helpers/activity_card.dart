import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/screens/view_topic.dart';
import 'package:info_hub_app/services/database.dart';

class ActivityCard extends StatelessWidget{
  final Map<String,dynamic> _topic;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ActivityCard(this._topic,this.firestore,this.auth);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {},
        child: Container(
            child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(_topic['title']+ ' viewed: '+calculateDaysAgo(_topic['viewDate'])+ ' days ago'),
          ),
        )));
  }
  String calculateDaysAgo(Timestamp activityDate){
    DateTime date =activityDate.toDate();
    return DateTime.now().difference(date).inDays.toString();
  }
}

