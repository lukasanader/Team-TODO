import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/analytics/topics/analytics_view_topic.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'view_topic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TopicCard extends StatelessWidget {
  final QueryDocumentSnapshot _topic;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  final FirebaseAuth auth;
  final ThemeManager themeManager;

  const TopicCard(
      this.firestore, this.auth, this.storage, this._topic, this.themeManager,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 15,
            right: 15,
            child: Container(
              height: 1, // Set thickness to 2 pixels
              color: Colors.grey, // Set color to grey
            ),
          ),
          Card(
            margin: EdgeInsets.all(2.0), // Ensure card is below the divider
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
              child: Text(
                _topic['title'],
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
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
