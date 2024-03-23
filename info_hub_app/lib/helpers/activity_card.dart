import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/topics/view_topic.dart';

class ActivityCard extends StatelessWidget {
  final Map<String, dynamic> _activity;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ActivityCard(this._activity, this.firestore, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget childWidget;
    if (_activity.containsKey('viewDate')) {
      childWidget = Text(
        '${_activity['title']} : ${calculateDaysAgo(_activity['viewDate'])} days ago',
      );
    } else {
      childWidget = Text(_activity['title']);
    }

    return GestureDetector(
      onTap: () {
        if
      },
      child: Container(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: childWidget,
          ),
        ),
      ),
    );
  }

  String calculateDaysAgo(Timestamp activityDate) {
    DateTime date = activityDate.toDate();
    return DateTime.now().difference(date).inDays.toString();
  }
}
