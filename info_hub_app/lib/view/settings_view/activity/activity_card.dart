import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/model/thread_models/thread_model.dart';
import 'package:info_hub_app/view/thread_view/threads.dart';

class ActivityCard extends StatelessWidget {
  final Thread _activity;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ActivityCard(this._activity, this.firestore, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget childWidget;
    childWidget = Text(
      '${_activity.title} : ${calculateDaysAgo(_activity.viewDate!)} days ago',
    );
    return GestureDetector(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreadApp(
                firestore: firestore,
                auth: auth,
                topicId: _activity.topicId,
                topicTitle: _activity.topicTitle,
              ),
            ));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: childWidget,
        ),
      ),
    );
  }

  String calculateDaysAgo(Timestamp activityDate) {
    DateTime date = activityDate.toDate();
    return DateTime.now().difference(date).inDays.toString();
  }
}
