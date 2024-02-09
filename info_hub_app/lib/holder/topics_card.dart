import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '/screens/view_topic.dart';

class TopicCard extends StatelessWidget {
  final QueryDocumentSnapshot _topic;

  TopicCard(this._topic);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
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
