import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:info_hub_app/topics/create_topic/helpers/quiz/complete_quiz.dart';
import 'package:info_hub_app/topics/create_topic/view/topic_creation_view.dart';
import 'dart:async';
import 'package:info_hub_app/threads/threads.dart';
import 'package:info_hub_app/topics/create_topic/model/topic_model.dart';
import '../controllers/interaction_controller.dart';
import '../controllers/media_controller.dart';
import 'widgets/view_media_widget.dart';

/// View Responsible For Viewing Topics
class TopicView extends StatefulWidget {
  Topic topic;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;
  final ThemeManager themeManager;

  TopicView({
    required this.firestore,
    required this.topic,
    required this.storage,
    required this.auth,
    required this.themeManager,
    super.key,
  });

  @override
  State<TopicView> createState() => TopicViewState();
}

class TopicViewState extends State<TopicView> {
  late InteractionController interactionController;
  late MediaController mediaController;
  late Topic updatedTopic;

  @override
  void initState() {
    super.initState();
    updatedTopic = widget.topic;
    mediaController =
        MediaController(widget.auth, widget.firestore, updatedTopic, this);
    mediaController.initializeData();
    interactionController = InteractionController(
        widget.auth, widget.firestore, this, updatedTopic, mediaController);
    interactionController.initializeData();
    _isAdmin();
  }

  /// Refreshes the screen
  void updateState() {
    setState(() {});
  }

  /// Pops the screen
  void popScreen() {
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose video controllers
    mediaController.videoController?.dispose();
    mediaController.chewieController?.dispose();
  }

  bool userIsAdmin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Tooltip(
            message: updatedTopic.title!,
            child: Text(updatedTopic.title!),
          ),
          actions: <Widget>[
            // Edit button (only visible to admins)
            if (userIsAdmin)
              IconButton(
                key: const Key('edit_btn'),
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Navigate to edit screen
                  updatedTopic.id = widget.topic.id;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopicCreationView(
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
                        mediaController.initData();
                      });
                    }
                  });
                },
              ),
            // Save Topic button
            IconButton(
              key: const Key('save_btn'),
              icon: interactionController.saved
                  ? const Icon(Icons.bookmark)
                  : const Icon(Icons.bookmark_border),
              onPressed: () {
                interactionController.saveTopic();
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
                  // Shows the Media if it exists
                  ViewMediaWidget(
                      screen: this,
                      topic: updatedTopic,
                      mediaController: mediaController),
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
                        // Interaction buttons for like, dislike, comments, and quiz
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Optional
                            children: [
                              IconButton(
                                onPressed: () {
                                  interactionController.likeTopic();
                                },
                                icon: Icon(Icons.thumb_up,
                                    color: interactionController.hasLiked
                                        ? Colors.blue
                                        : Colors.grey),
                              ),
                              Text("${interactionController.likes}"),
                              IconButton(
                                onPressed: () {
                                  interactionController.dislikeTopic();
                                },
                                icon: Icon(Icons.thumb_down,
                                    color: interactionController.hasDisliked
                                        ? Colors.red
                                        : Colors.grey),
                              ),
                              Text("${interactionController.dislikes}"),
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
                              if (widget.topic.quizID != '')
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Read article button
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
            // Delete topic button (only visible to admins)
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
                                  interactionController.deleteTopic();
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

  Future<void> _isAdmin() async {
    User? user = widget.auth.currentUser;

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
