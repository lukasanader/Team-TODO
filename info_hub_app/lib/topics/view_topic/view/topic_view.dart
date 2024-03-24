import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:info_hub_app/controller/quiz_controller.dart';
import 'package:info_hub_app/model/quiz_model.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:info_hub_app/topics/create_topic/helpers/quiz/complete_quiz.dart';
import 'package:flutter/services.dart';
import 'package:info_hub_app/topics/create_topic/view/topic_creation_view.dart';
import 'dart:async';
import 'package:info_hub_app/threads/threads.dart';
import 'package:info_hub_app/controller/activity_controller.dart';
import 'package:info_hub_app/topics/create_topic/model/topic_model.dart';

class ViewTopicScreen extends StatefulWidget {
  final Topic topic;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;
  final ThemeManager themeManager;

  const ViewTopicScreen({
    required this.firestore,
    required this.topic,
    required this.storage,
    required this.auth,
    required this.themeManager,
    Key? key,
  }) : super(key: key);

  @override
  State<ViewTopicScreen> createState() => _ViewTopicScreenState();
}

class _ViewTopicScreenState extends State<ViewTopicScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  late Topic updatedTopic;
  bool vidAvailable = false;
  bool imgAvailable = false;

  int currentIndex = 0;

  String? _videoURL;
  String? _imageUrl;

  int likes = 0;
  int dislikes = 0;
  bool saved = false;

  @override
  void initState() {
    super.initState();
    updatedTopic = widget.topic;
    initData();
    _isAdmin();
    checkUserLikedAndDislikedTopics();
    updateLikesAndDislikesCount();
  }

  Future<void> initData() async {
    if (updatedTopic.media!.isNotEmpty) {
      if (updatedTopic.media![currentIndex]['mediaType'] == 'video') {
        _videoURL = updatedTopic.media![currentIndex]['url'];
        _imageUrl = null;

        await initializeVideoPlayer();
      } else {
        _imageUrl = updatedTopic.media![currentIndex]['url'];
        _videoURL = null;
        await initializeImage();
      }
    }
    final user = widget.auth.currentUser;
    if (user != null) {
      final userDocSnapshot =
          await widget.firestore.collection('Users').doc(user.uid).get();

      if (userDocSnapshot.exists) {
        Map<String, dynamic> userData = userDocSnapshot.data()!;

        setState(() {
          if (userData['savedTopics'] != null) {
            saved = userData['savedTopics'].contains(widget.topic.id);
          }
        });
      }
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

  Widget _videoPreviewWidget() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          ),
          Text(
            '                                                                  ${currentIndex + 1} / ${updatedTopic.media!.length}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _imagePreviewWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(_imageUrl!),
        Text(
          '                                                                   ${currentIndex + 1} / ${updatedTopic.media!.length}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
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

  Future<void> initializeVideoPlayer() async {
    bool isLoading = true; // Initialize isLoading to true

    // Show loading indicator
    setState(() {
      isLoading = true;
    });

    if (isLoading) {
      const Center(
        child: CircularProgressIndicator(), // Show loading indicator
      );
    }

    _disposeVideoPlayer();

    if (_videoURL != null && _videoURL!.isNotEmpty) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(_videoURL!));

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoInitialize: true,
        looping: false,
        aspectRatio: 16 / 9,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        allowedScreenSleep: false,
      );

      // Hide loading indicator after initialization
      setState(() {
        isLoading = false;
      });
    }

    // Return loading indicator if isLoading is true
    if (isLoading) {
      const Center(
        child: CircularProgressIndicator(), // Show loading indicator
      );
    }
  }

  void _disposeVideoPlayer() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;

    _chewieController?.pause();
    _chewieController?.dispose();
    _chewieController = null;
  }

  @override
  void dispose() {
    super.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
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
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color.fromRGBO(200, 0, 0, 1.0),
          title: Text(
            updatedTopic.title!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            if (userIsAdmin)
              IconButton(
                key: const Key('edit_btn'),
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Navigate to edit screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateTopicScreen(
                        topic: updatedTopic,
                        firestore: widget.firestore,
                        storage: widget.storage,
                        auth: widget.auth,
                        themeManager: widget.themeManager,
                      ),
                    ),
                  ).then((updatedTopic) {
                    if (updatedTopic != null) {
                      setState(() {
                        this.updatedTopic = updatedTopic;
                        initData();
                      });
                    }
                  });
                },
              ),
            IconButton(
              key: const Key('save_btn'),
              icon: saved
                  ? const Icon(Icons.bookmark, color: Colors.white)
                  : const Icon(Icons.bookmark_border, color: Colors.white),
              onPressed: () {
                saveTopic();
              },
            ),
          ]),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_videoURL != null && _chewieController != null)
                    _videoPreviewWidget(),
                  if (_imageUrl != null) _imagePreviewWidget(),
                  if (_videoURL != null || _imageUrl != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (updatedTopic.media!.length > 1)
                          IconButton(
                            key: const Key('previousMediaButton'),
                            icon: const Icon(Icons.arrow_circle_left_rounded,
                                color: Color.fromRGBO(150, 100, 200, 1.0)),
                            onPressed: () async {
                              if (currentIndex - 1 >= 0) {
                                currentIndex -= 1;
                                if (updatedTopic.media![currentIndex]
                                        ['mediaType'] ==
                                    'video') {
                                  _videoURL =
                                      updatedTopic.media![currentIndex]['url'];
                                  _imageUrl = null;
                                  setState(() {});
                                  await initializeVideoPlayer();
                                  setState(() {});
                                } else if (updatedTopic.media![currentIndex]
                                        ['mediaType'] ==
                                    'image') {
                                  _imageUrl =
                                      updatedTopic.media![currentIndex]['url'];
                                  _videoURL = null;
                                  setState(() {});
                                  await initializeImage();
                                  setState(() {});
                                }
                              }
                            },
                            tooltip: 'Previous Video',
                          ),
                        if (updatedTopic.media!.length > 1)
                          IconButton(
                            key: const Key('nextMediaButton'),
                            icon: const Icon(Icons.arrow_circle_right_rounded,
                                color: Color.fromRGBO(150, 100, 200, 1.0)),
                            onPressed: () async {
                              if (currentIndex + 1 <
                                  updatedTopic.media!.length) {
                                currentIndex += 1;
                                if (updatedTopic.media![currentIndex]
                                        ['mediaType'] ==
                                    'video') {
                                  _videoURL =
                                      updatedTopic.media![currentIndex]['url'];
                                  _imageUrl = null;
                                  setState(() {});
                                  await initializeVideoPlayer();
                                  setState(() {});
                                } else if (updatedTopic.media![currentIndex]
                                        ['mediaType'] ==
                                    'image') {
                                  _imageUrl =
                                      updatedTopic.media![currentIndex]['url'];
                                  _videoURL = null;
                                  setState(() {});
                                  await initializeImage();
                                  setState(() {});
                                }
                              }
                            },
                            tooltip: 'Next Video',
                          ),
                      ],
                    ),
                  const SizedBox(height: 30),
                  SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${updatedTopic.description}',
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
                                  color: hasLiked ? Colors.blue : Colors.grey),
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
                              icon: const Icon(FontAwesomeIcons.comments,
                                  size: 20),
                              onPressed: () {
                                // Navigate to the Threads screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ThreadApp(
                                        firestore: widget.firestore,
                                        auth: widget.auth,
                                        topicId: widget.topic.id!,
                                        topicTitle: widget.topic.title!),
                                  ),
                                );
                              },
                            ),
                            // complete quiz
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CompleteQuiz(
                                          firestore: widget.firestore,
                                          topic: widget.topic,
                                          auth: widget.auth)),
                                );
                              },
                              child: const Text('QUIZ!!'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (updatedTopic.articleLink != '')
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      launchUrl(Uri.parse(updatedTopic.articleLink!));
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
                    key: const Key('delete_topic_button'),
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
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Delete the topic
                                  deleteTopic();
                                  Navigator.pop(context,
                                      widget.topic.id); // Close the dialog
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
          ],
        ),
      ),
    );
  }

  Future<void> initializeImage() async {
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      setState(() {});
    }
  }

  deleteTopic() async {
    ActivityController(firestore: widget.firestore, auth: widget.auth)
        .deleteActivity(widget.topic.id!);
    QuizController(firestore: widget.firestore,auth: widget.auth).deleteQuiz(widget.topic.quizID!);   
    removeTopicFromUsers();
    // If the topic has a video URL, delete the corresponding video from storage
    if (updatedTopic.media!.isNotEmpty) {
      for (var item in updatedTopic.media!) {
        await deleteMediaFromStorage(updatedTopic.media!.indexOf(item));
      }
    }

    // Delete the topic document from Firestore
    await widget.firestore.collection('topics').doc(widget.topic.id).delete();

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> deleteMediaFromStorage(int index) async {
    String fileUrl = updatedTopic.media![index]['url'];

    // get reference to the video file
    Reference ref = widget.storage.refFromURL(fileUrl);

    // Delete the file
    await ref.delete();
  }

  Future<void> saveTopic() async {
    final user = widget.auth.currentUser;
    if (user != null) {
      final userDocRef = widget.firestore.collection('Users').doc(user.uid);
      if (!saved) {
        await userDocRef.update({
          'savedTopics': FieldValue.arrayUnion([widget.topic.id])
        });
        saved = true;
      } else {
        await userDocRef.update({
          'savedTopics': FieldValue.arrayRemove([widget.topic.id])
        });
        saved = false;
      }
      setState(() {});
    }
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

      if (userData.containsKey('savedTopics') &&
          userData['savedTopics'].contains(widget.topic.id)) {
        // Remove the topic from saved topics list
        userData['savedTopics'].remove(widget.topic.id);
      }

      await userSnapshot.reference.update(userData);
    }
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
}
