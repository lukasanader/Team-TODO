import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:info_hub_app/services/database.dart';
import '/screens/view_topic.dart';

class TopicCard extends StatelessWidget {
  final QueryDocumentSnapshot _topic;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  TopicCard(this._topic,this.firestore,this.auth);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          DatabaseService(uid: auth.currentUser!.uid, firestore: firestore ).addTopicActivity(_topic);
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (BuildContext context) {
              return ViewTopicScreen(
                topic: _topic,
              );
            }),
          );
        },
        child: Container(
            child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(_topic['title']),
          ),
        )));
  }
}
