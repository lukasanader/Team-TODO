import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/threads/views/threads.dart';
import 'package:info_hub_app/topics/create_topic/controllers/topic_controller.dart';

class ActivityCard extends StatelessWidget {
  final dynamic _activity;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ActivityCard(this._activity, this.firestore, this.auth, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget childWidget;
    childWidget = Text(
      '${_activity['title']} : ${calculateDaysAgo(_activity['viewDate'])} days ago',
    );
    return GestureDetector(
      onTap: () async {
        String topicTitle =
            await TopicController(auth: auth, firestore: firestore)
                .getTopicTitle(_activity['topicId']);
        // ignore: use_build_context_synchronously
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreadApp(
                firestore: firestore,
                auth: auth,
                topicId: _activity['topicId'],
                topicTitle: topicTitle,
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
