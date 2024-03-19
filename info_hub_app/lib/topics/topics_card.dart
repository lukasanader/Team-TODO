import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/analytics/topics/analytics_view_topic.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'view_topic.dart';
import 'create_topic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TopicCard extends StatelessWidget {
  final QueryDocumentSnapshot _topic;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  final FirebaseAuth auth;

  const TopicCard(this.firestore, this.auth, this.storage, this._topic,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          DatabaseService(uid: auth.currentUser!.uid, firestore: firestore ).addTopicActivity(_topic);
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: ViewTopicScreen(
              firestore: firestore,
              auth: auth,
              storage: storage,
              topic: _topic,
              themeManager: themeManager,
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
            screen: AdminTopicAnalytics(
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

class TopicDraftCard extends StatelessWidget {
  final QueryDocumentSnapshot _draft;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  final FirebaseAuth auth;

  const TopicDraftCard(this.firestore, this.auth, this.storage, this._draft,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: CreateTopicScreen(
              firestore: firestore,
              auth: auth,
              storage: storage,
              draft: _draft,
              themeManager: themeManager,
            ),
            withNavBar: false,
          );
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(_draft['title']),
          ),
        ));
  }
}
