import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:info_hub_app/analytics/topics/analytics_view_topic.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class AdminTopicCard extends StatelessWidget {
  final QueryDocumentSnapshot _topic;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  const AdminTopicCard(this.firestore, this.storage, this._topic, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: AdminAnalyticsTopic(
              firestore: firestore,
              storage: storage,
              topic: _topic,
            ),
            withNavBar: false,
          );
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(_topic['title']),
          ),
        ));
  }
}
