import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/analytics/topics/analytics_view_topic.dart';
import 'package:info_hub_app/controller/activity_controller.dart';
import 'package:info_hub_app/main.dart';
import '../controller/create_topic_controllers/topic_controller.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '../view/topic_view/topic_view.dart';
import '../view/topic_creation_view/topic_creation_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:info_hub_app/model/topic_model.dart';

class TopicCard extends StatelessWidget {
  final Topic _topic;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  final FirebaseAuth auth;
  final String type;

  const TopicCard(
      this.firestore, this.auth, this.storage, this._topic, this.type,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final date = _topic.date;

    final mediaList = _topic.media as List<dynamic>;

    final media = mediaList.isNotEmpty ? mediaList.first : null;
    final mediaThumbnail = media != null ? media['thumbnail'] as String? : null;
    final mediaType = media != null ? media['mediaType'] as String? : null;
    bool containsVideo = mediaList.isNotEmpty &&
        mediaList.any((element) => element['mediaType'] == 'video');

    Widget mediaWidget = const SizedBox.shrink();

    if (mediaType == 'image' || mediaType == 'video') {
      mediaWidget = SizedBox(
        width: 50,
        height: 50,
        child: Image.network(
          mediaThumbnail!,
          fit: BoxFit.cover,
        ),
      );
    }
    return GestureDetector(
        onTap: () {
          if (type == "topic") {
            ActivityController(auth: auth, firestore: firestore)
                .addActivity(_topic.id!, 'topics');
            TopicController(auth: auth, firestore: firestore)
                .incrementView(_topic);
          }
          if (type == "adminTopic") {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (BuildContext context) {
                  return AdminTopicAnalytics(
                    firestore: firestore,
                    storage: storage,
                    topic: _topic,
                  );
                },
              ),
            );
          } else {
            if (type == "topic") {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: TopicView(
                  firestore: firestore,
                  auth: auth,
                  storage: storage,
                  topic: _topic,
                  themeManager: themeManager,
                ),
                withNavBar: false,
              );
            } else {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: TopicCreationView(
                  firestore: firestore,
                  auth: auth,
                  storage: storage,
                  draft: _topic,
                  themeManager: themeManager,
                ),
                withNavBar: false,
              );
            }
          }
        },
        child: buildSmallTopicCard(date, containsVideo, mediaWidget));
  }

  Widget buildSmallTopicCard(
      DateTime? date, bool containsVideo, Widget mediaWidget) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _topic.title ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  if (date != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        if (containsVideo)
                          const Icon(
                            Icons.play_circle_outline_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),

                        if (containsVideo) const SizedBox(width: 8),
                        Text(
                          formatDate(date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ), // Text
                      ],
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: mediaWidget,
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
