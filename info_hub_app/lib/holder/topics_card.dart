import 'package:flutter/material.dart';
import 'package:info_hub_app/screens/create_topic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class TopicCard extends StatelessWidget {
  final QueryDocumentSnapshot _topic;

  TopicCard(this._topic);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(_topic['title']);
      },
      child: Container( 
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(_topic['title']),
          ),
        
        )    
    ) 
    );
  }
}