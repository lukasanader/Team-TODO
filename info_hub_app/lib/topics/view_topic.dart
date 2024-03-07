import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/topics/edit_topic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'package:info_hub_app/threads/threads.dart';

class ViewTopicScreen extends StatefulWidget {
  final QueryDocumentSnapshot topic;

  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  final FirebaseAuth auth;

  const ViewTopicScreen(
      {required this.firestore,
      required this.topic,
      required this.storage,
      required this.auth,
      Key? key})
      : super(key: key);

  @override
  State<ViewTopicScreen> createState() => _ViewTopicScreenState();
}

class _ViewTopicScreenState extends State<ViewTopicScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  late QueryDocumentSnapshot updatedTopic;
  late QueryDocumentSnapshot upTopic;

  bool vidAvailable = false;

  int likes = 0;
  int dislikes = 0;

  @override
  void initState() {
    super.initState();
    updatedTopic = widget.topic;

    // Fetch topic details after 2 seconds
    updateTopic();

    upTopic = updatedTopic;

    _isAdmin();
    checkUserLikedAndDislikedTopics();
    updateLikesAndDislikesCount();

    if (updatedTopic['videoUrl'] != null && updatedTopic['videoUrl'] != "") {
      _initializeVideoPlayer();
      vidAvailable = true;
    }
  }

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

  void updateTopic() async {
    CollectionReference topicCollectionRef =
        widget.firestore.collection('topics');

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    for (QueryDocumentSnapshot doc in data.docs) {
      // Check if the document ID matches the ID of the topic
      if (doc.id == widget.topic.id) {
        // Found the updated topic document
        updatedTopic = doc as QueryDocumentSnapshot<Object>;
        break; // Exit the loop since we found the document
      }
    }
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
    final videoUrl = updatedTopic['videoUrl'] as String?;

    CollectionReference topicCollectionRef =
        widget.firestore.collection('topics');

    QuerySnapshot data = await topicCollectionRef.orderBy('title').get();

    for (QueryDocumentSnapshot doc in data.docs) {
      // Check if the document ID matches the ID of the topic
      if (doc.id == widget.topic.id) {
        // Found the updated topic document
        updatedTopic = doc as QueryDocumentSnapshot<Object>;
        break; // Exit the loop since we found the document
      }
    }

    print(videoUrl);
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

      if (hasLiked) {
        likes -= 1;
        await userDocRef.update({
          'likedTopics': FieldValue.arrayRemove([widget.topic.id])
        });
        hasLiked = false;
      } else {
        likes += 1;
        await userDocRef.update({
          'likedTopics': FieldValue.arrayUnion([widget.topic.id])
        });
        hasLiked = true;

        if (hasDisliked) {
          dislikes -= 1;
          await userDocRef.update({
            'dislikedTopics': FieldValue.arrayRemove([widget.topic.id])
          });
          hasDisliked = false;
        }
      }

      setState(() {});

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

      if (hasDisliked) {
        dislikes -= 1;
        await userDocRef.update({
          'dislikedTopics': FieldValue.arrayRemove([widget.topic.id])
        });
        hasDisliked = false;
      } else {
        dislikes += 1;
        await userDocRef.update({
          'dislikedTopics': FieldValue.arrayUnion([widget.topic.id])
        });
        hasDisliked = true;

        if (hasLiked) {
          likes -= 1;
          await userDocRef.update({
            'likedTopics': FieldValue.arrayRemove([widget.topic.id])
          });
          hasLiked = false;
        }
      }

      setState(() {});

      widget.firestore
          .collection('topics')
          .doc(widget.topic.id)
          .update({'dislikes': dislikes, 'likes': likes});
    }
  }

  Future<void> checkUserLikedAndDislikedTopics() async {
    hasLiked = await hasLikedTopic();
    hasDisliked = await hasDislikedTopic();
  }

  bool userIsAdmin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(200, 0, 0, 1.0),
        title: Text(
          updatedTopic['title'],
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
                            '${updatedTopic['description']}',
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
                              IconButton(
                                icon: Icon(FontAwesomeIcons.comments, size: 20),
                                onPressed: () {
                                  // Navigate to the Threads screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ThreadApp(
                                          firestore: widget.firestore,
                                          auth: widget.auth,
                                          topicId: widget.topic.id,
                                          topicTitle: widget.topic['title']),
                                    ),
                                  );
                                },
                              ),

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
          if (updatedTopic['articleLink'] != '')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    launchUrl(Uri.parse(updatedTopic['articleLink']));
                  },
                  child: const Text('Read Article'),
                ),
              ),
            ),
          if (userIsAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  key: Key('delete_topic_button'),
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text(
                              'Are you sure you want to delete this topic?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Delete the topic
                                deleteTopic();

                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: const Text(
                    'Delete Topic',
                    style: TextStyle(color: Colors.white),
                  ), // Te
                ),
              ),
            ),
          if (userIsAdmin)
            IconButton(
                key: Key('edit_btn'),
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTopicScreen(
                        topic: updatedTopic, // Pass your original topic data
                        firestore: widget.firestore,
                        auth: widget.auth,
                        storage: widget.storage,
                      ),
                    ),
                  );
                })
        ],
      ),
    );
  }

  Future<void> _isAdmin() async {
    User? user = widget.auth.currentUser;

    // Check if the user exists and if the user's roleType is 'admin'
    if (user != null) {
      DocumentSnapshot userSnapshot =
          await widget.firestore.collection('Users').doc(user.uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          userIsAdmin = userData['roleType'] == 'admin';
        }
      }
    }
  }

  deleteTopic() async {
    removeTopicFromUsers();
    // If the topic has a video URL, delete the corresponding video from storage
    if (updatedTopic['videoUrl'] != '' && updatedTopic['videoUrl'] != null) {
      await deleteVideoFromStorage(updatedTopic['videoUrl']);
    }

    // Delete the topic document from Firestore
    await widget.firestore.collection('topics').doc(widget.topic.id).delete();

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> deleteVideoFromStorage(String videoUrl) async {
    String fileUrl = updatedTopic['videoUrl'];

    // get reference to the video file
    Reference videoRef = widget.storage.refFromURL(fileUrl);

    // Delete the file
    await videoRef.delete();
  }

  Future<void> removeTopicFromUsers() async {
    // get all users
    QuerySnapshot<Map<String, dynamic>> usersSnapshot =
        await widget.firestore.collection('Users').get();

    // go through each user
    for (QueryDocumentSnapshot<Map<String, dynamic>> userSnapshot
        in usersSnapshot.docs) {
      Map<String, dynamic> userData = userSnapshot.data();

      // Check if user has liked topic
      if (userData.containsKey('likedTopics') &&
          userData['likedTopics'].contains(widget.topic.id)) {
        // Remove the topic from liked topics list
        userData['likedTopics'].remove(widget.topic.id);
      }

      // Check if user has disliked topic
      if (userData.containsKey('dislikedTopics') &&
          userData['dislikedTopics'].contains(widget.topic.id)) {
        // Remove the topic from disliked topics list
        userData['dislikedTopics'].remove(widget.topic.id);
      }

      await userSnapshot.reference.update(userData);
    }
  }
}
