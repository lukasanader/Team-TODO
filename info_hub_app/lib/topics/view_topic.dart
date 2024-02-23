import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewTopicScreen extends StatefulWidget {
  final QueryDocumentSnapshot topic;
  final FirebaseFirestore firestore;

  final FirebaseAuth auth;

  const ViewTopicScreen(
      {required this.firestore,
      required this.topic,
      required this.auth,
      Key? key})
      : super(key: key);

  @override
  State<ViewTopicScreen> createState() => _ViewTopicScreenState();
}

class _ViewTopicScreenState extends State<ViewTopicScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  bool vidAvailable = false;

  int likes = 0;
  int dislikes = 0;

  Future<bool> hasLikedTopic() async {
    User? user = widget.auth.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot =
          await widget.firestore.collection('Users').doc(user.uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          List<dynamic>? likedTopics = userData['likedTopics'];

          if (likedTopics != null && likedTopics.contains(widget.topic.id)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<bool> hasDislikedTopic() async {
    User? user = widget.auth.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot =
          await widget.firestore.collection('Users').doc(user.uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          List<dynamic>? dislikedTopics = userData['dislikedTopics'];

          if (dislikedTopics != null &&
              dislikedTopics.contains(widget.topic.id)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    if (widget.topic['videoUrl'] != null && widget.topic['videoUrl'] != "") {
      _initializeVideoPlayer();
      vidAvailable = true;
    }
    checkUserLikedAndDislikedTopics();
    updateLikesAndDislikesCount();
  }

  void updateLikesAndDislikesCount() {
    widget.firestore
        .collection('topics')
        .doc(widget.topic.id)
        .get()
        .then((doc) {
      setState(() {
        likes = doc['likes'];
        dislikes = doc['dislikes'];
      });
    });
  }

  void _initializeVideoPlayer() async {
    final videoUrl = widget.topic['videoUrl'] as String?;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoInitialize: true,
        looping: false,
        aspectRatio: 16 / 9,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        allowedScreenSleep: false,
      );
      _chewieController!.addListener(() {
        if (!_chewieController!.isFullScreen) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        }
      });

      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  bool hasLiked = false;
  bool hasDisliked = false;

  Future<void> _likeTopic() async {
    final user = widget.auth.currentUser;
    if (user != null) {
      final userDocRef = widget.firestore.collection('Users').doc(user.uid);
      setState(() {
        if (hasLiked) {
          likes -= 1;
          hasLiked = false;
        } else {
          likes += 1;
          hasLiked = true;
          if (hasDisliked) {
            dislikes -= 1;
            hasDisliked = false;
          }
        }
      });
      await userDocRef.update({
        'likedTopics': hasLiked
            ? FieldValue.arrayUnion([widget.topic.id])
            : FieldValue.arrayRemove([widget.topic.id]),
        'dislikedTopics': hasDisliked
            ? FieldValue.arrayUnion([widget.topic.id])
            : FieldValue.arrayRemove([widget.topic.id]),
      });

      widget.firestore
          .collection('topics')
          .doc(widget.topic.id)
          .update({'likes': likes, 'dislikes': dislikes});
    }
  }

  Future<void> _dislikeTopic() async {
    final user = widget.auth.currentUser;
    if (user != null) {
      final userDocRef = widget.firestore.collection('Users').doc(user.uid);
      setState(() {
        if (hasDisliked) {
          dislikes -= 1;
          hasDisliked = false;
        } else {
          dislikes += 1;
          hasDisliked = true;
          if (hasLiked) {
            likes -= 1;
            hasLiked = false;
          }
        }
      });
      await userDocRef.update({
        'dislikedTopics': hasDisliked
            ? FieldValue.arrayUnion([widget.topic.id])
            : FieldValue.arrayRemove([widget.topic.id]),
        'likedTopics': hasLiked
            ? FieldValue.arrayUnion([widget.topic.id])
            : FieldValue.arrayRemove([widget.topic.id]),
      });

      widget.firestore
          .collection('topics')
          .doc(widget.topic.id)
          .update({'likes': likes, 'dislikes': dislikes});
    }
  }

  Future<void> checkUserLikedAndDislikedTopics() async {
    hasLiked = await hasLikedTopic();
    hasDisliked = await hasDislikedTopic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(200, 0, 0, 1.0),
        title: Text(
          widget.topic['title'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vidAvailable && _chewieController != null)
                    SizedBox(
                      height: 250,
                      child: Chewie(controller: _chewieController!),
                    ),
                  const SizedBox(height: 30),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.topic['description']}',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _likeTopic();
                                },
                                icon: Icon(Icons.thumb_up,
                                    color:
                                        hasLiked ? Colors.blue : Colors.grey),
                              ),
                              Text("$likes"),
                              IconButton(
                                onPressed: () {
                                  _dislikeTopic();
                                },
                                icon: Icon(Icons.thumb_down,
                                    color:
                                        hasDisliked ? Colors.red : Colors.grey),
                              ),
                              Text("$dislikes"),
                              // Display likes
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.topic['articleLink'] != '')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    launchUrl(Uri.parse(widget.topic['articleLink']));
                  },
                  child: const Text('Read Article'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
