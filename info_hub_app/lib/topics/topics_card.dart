import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/analytics/topics/analytics_view_topic.dart';
import 'package:info_hub_app/main.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'view_topic.dart';
import 'package:info_hub_app/services/database.dart';
import 'create_topic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';

class TopicCard extends StatelessWidget {
  final QueryDocumentSnapshot _topic;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  final FirebaseAuth auth;

  const TopicCard(this.firestore, this.auth, this.storage, this._topic,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? topicData =
        _topic.data() as Map<String, dynamic>?;

    final date = (topicData != null && topicData.containsKey('date'))
        ? (topicData['date'] as Timestamp).toDate()
        : null;

    final mediaList = (topicData != null && topicData.containsKey('media'))
        ? topicData['media'] as List<dynamic>
        : null;
    final media = mediaList?.isNotEmpty ?? false ? mediaList!.first : null;
    final mediaUrl = media != null ? media['url'] as String? : null;
    final mediaType = media != null ? media['mediaType'] as String? : null;
    bool containsVideo = mediaList != null &&
        mediaList.isNotEmpty &&
        mediaList.any((element) => element['mediaType'] == 'video');

    Widget mediaWidget = const SizedBox.shrink();

    if (mediaType == 'video') {
      mediaWidget = FutureBuilder<Uint8List>(
        future: _getVideoThumbnail(mediaUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error loading thumbnail');
          } else {
            return Container(
              width: 50, // Adjust width as needed
              height: 50, // Adjust height as needed
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            );
          }
        },
      );
    } else if (mediaType == 'image') {
      mediaWidget = Image.network(
        mediaUrl!,
        fit: BoxFit.cover,
        width: 50, // Adjust width as needed
        height: 50, // Adjust height as needed
      );
    }

    return GestureDetector(
      onTap: () {
        DatabaseService(auth: auth, uid: auth.currentUser!.uid, firestore: firestore)
            .addTopicActivity(_topic);
        DatabaseService(auth: auth, uid: auth.currentUser!.uid, firestore: firestore)
            .incrementView(_topic);
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
                      _topic['title'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
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
                            _formatDate(date),
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
              width: 100, // Adjust width as needed
              child: mediaWidget,
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _getVideoThumbnail(String? videoUrl) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoUrl!,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 100,
      quality: 50,
    );
    return uint8list!;
  }

  String _formatDate(DateTime? date) {
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

// for demo. will be refactored

class AdminTopicCard extends StatelessWidget {
  final QueryDocumentSnapshot _topic;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  const AdminTopicCard(this.firestore, this.storage, this._topic, {super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? topicData =
        _topic.data() as Map<String, dynamic>?;

    final date = (topicData != null && topicData.containsKey('date'))
        ? (topicData['date'] as Timestamp).toDate()
        : null;

    final mediaList = (topicData != null && topicData.containsKey('media'))
        ? topicData['media'] as List<dynamic>
        : null;
    final media = mediaList?.isNotEmpty ?? false ? mediaList!.first : null;
    final mediaUrl = media != null ? media['url'] as String? : null;
    final mediaType = media != null ? media['mediaType'] as String? : null;
    bool containsVideo = mediaList != null &&
        mediaList.isNotEmpty &&
        mediaList.any((element) => element['mediaType'] == 'video');

    Widget mediaWidget = const SizedBox.shrink();

    if (mediaType == 'video') {
      mediaWidget = FutureBuilder<Uint8List>(
        future: _getVideoThumbnail(mediaUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error loading thumbnail');
          } else {
            return Container(
              width: 50, // Adjust width as needed
              height: 50, // Adjust height as needed
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            );
          }
        },
      );
    } else if (mediaType == 'image') {
      mediaWidget = Image.network(
        mediaUrl!,
        fit: BoxFit.cover,
        width: 50, // Adjust width as needed
        height: 50, // Adjust height as needed
      );
    }

    return GestureDetector(
      onTap: () {
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
      },
      child: Card(
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
                      _topic['title'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
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
                            _formatDate(date),
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
              width: 100, // Adjust width as needed
              child: mediaWidget,
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _getVideoThumbnail(String? videoUrl) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoUrl!,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 100,
      quality: 50,
    );
    return uint8list!;
  }

  String _formatDate(DateTime? date) {
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

class TopicDraftCard extends StatelessWidget {
  final QueryDocumentSnapshot _draft;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  final FirebaseAuth auth;

  const TopicDraftCard(this.firestore, this.auth, this.storage, this._draft,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? topicData =
        _draft.data() as Map<String, dynamic>?;

    final date = (topicData != null && topicData.containsKey('date'))
        ? (topicData['date'] as Timestamp).toDate()
        : null;

    final mediaList = (topicData != null && topicData.containsKey('media'))
        ? topicData['media'] as List<dynamic>
        : null;
    final media =
        mediaList != null && mediaList.isNotEmpty ? mediaList.first : null;
    final mediaUrl = media != null ? media['url'] as String? : null;
    final mediaType = media != null ? media['mediaType'] as String? : null;
    bool containsVideo = mediaList != null &&
        mediaList.isNotEmpty &&
        mediaList.any((element) => element['mediaType'] == 'video');

    Widget mediaWidget = const SizedBox.shrink();

    if (mediaType == 'video') {
      mediaWidget = FutureBuilder<Uint8List>(
        future: _getVideoThumbnail(mediaUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error loading thumbnail');
          } else {
            return Container(
              width: 50, // Adjust width as needed
              height: 50, // Adjust height as needed
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            );
          }
        },
      );
    } else if (mediaType == 'image') {
      mediaWidget = Image.network(
        mediaUrl!,
        fit: BoxFit.cover,
        width: 50, // Adjust width as needed
        height: 50, // Adjust height as needed
      );
    }

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
                      _draft['title'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
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
                            _formatDate(date),
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
            if (media != null)
              SizedBox(
                width: 100, // Adjust width as needed
                child: mediaWidget,
              ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _getVideoThumbnail(String? videoUrl) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoUrl!,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200,
      quality: 200,
    );
    return uint8list!;
  }

  String _formatDate(DateTime? date) {
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

class LargeTopicCard extends StatelessWidget {
  final QueryDocumentSnapshot _topic;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  const LargeTopicCard(
    this.firestore,
    this.auth,
    this.storage,
    this._topic, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? topicData =
        _topic.data() as Map<String, dynamic>?;

    final date = (topicData != null && topicData.containsKey('date'))
        ? (topicData['date'] as Timestamp).toDate()
        : null;

    final mediaList = (topicData != null && topicData.containsKey('media'))
        ? topicData['media'] as List<dynamic>
        : null;
    final media = mediaList?.isNotEmpty == true ? mediaList!.first : null;
    final mediaUrl = media != null ? media['url'] as String? : null;
    final mediaType = media != null ? media['mediaType'] as String? : null;

    Widget mediaWidget = SizedBox.shrink();

    if (mediaType == 'video') {
      mediaWidget = FutureBuilder<Uint8List>(
        future: mediaUrl != null
            ? _getVideoThumbnail(mediaUrl)
            : Future.value(Uint8List(0)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Text('Error loading thumbnail');
          } else {
            return Container(
              width: 400, // Adjust width as needed
              height: 180, // Adjust height as needed
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            );
          }
        },
      );
    } else if (mediaType == 'image') {
      mediaWidget = Container(
        width: 400, // Adjust width as needed
        height: 180, // Adjust height as needed
        child: Image.network(
          mediaUrl!,
          fit: BoxFit.cover,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        DatabaseService(auth: auth, uid: auth.currentUser!.uid, firestore: firestore)
            .addTopicActivity(_topic);
        DatabaseService(auth: auth, uid: auth.currentUser!.uid, firestore: firestore)
            .incrementView(_topic);
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
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mediaType != null)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (mediaUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: mediaWidget,
                        ),
                      if (mediaUrl != null) const SizedBox(height: 4),
                      Text(
                        topicData?['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      if (date != null)
                        Text(
                          '${_formatDate(date)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
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

  Future<Uint8List> _getVideoThumbnail(String videoUrl) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 350,
      quality: 100,
    );
    return uint8list!;
  }
}
