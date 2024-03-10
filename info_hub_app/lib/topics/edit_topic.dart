import 'dart:io';
import 'package:flutter/material.dart';
import 'package:info_hub_app/topics/quiz/create_quiz.dart';

import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/topics/view_topic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditTopicScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final QueryDocumentSnapshot topic;
  final FirebaseAuth auth;

  const EditTopicScreen(
      {Key? key,
      required this.topic,
      required this.firestore,
      required this.auth,
      required this.storage})
      : super(key: key);

  @override
  State<EditTopicScreen> createState() => _EditTopicScreenState();
}

class _EditTopicScreenState extends State<EditTopicScreen> {
  late QueryDocumentSnapshot<Object?> updatedTopicDoc;
  late String prevTitle;
  late String prevDescription;
  late String prevArticleLink;

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController articleLinkController;
  final _topicFormKey = GlobalKey<FormState>();
  String quizID = '';
  bool quizAdded = false;

  @override
  void initState() {
    super.initState();
    prevTitle = widget.topic['title'];
    prevDescription = widget.topic['description'];
    prevArticleLink = widget.topic['articleLink'];

    titleController = TextEditingController(text: prevTitle);
    descriptionController = TextEditingController(text: prevDescription);
    articleLinkController = TextEditingController(text: prevArticleLink);

    // Initialize the video player if there's a video URL available
    _videoURL = widget.topic['videoUrl'];
    updatedTopicDoc = widget.topic;

    _initializeVideoPlayer();
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a Title.';
    }
    return null;
  }

  String? validateArticleLink(String? value) {
    if (value != null && value.isNotEmpty) {
      final url = Uri.tryParse(value);
      if (url == null || !url.hasAbsolutePath || !url.isAbsolute) {
        return 'Link is not valid, please enter a valid link';
      }
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a Description';
    }
    return null;
  }

  String? _videoURL;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void dispose() {
    super.dispose();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Edit Topic',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewTopicScreen(
                    firestore: widget.firestore,
                    topic: updatedTopicDoc,
                    storage: widget.storage,
                    auth: widget.auth),
              ),
            );
          },
        ),
      ),
      body: Form(
        key: _topicFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      key: const Key('titleField'),
                      controller: titleController,
                      maxLength: 70,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        prefixIcon:
                            Icon(Icons.drive_file_rename_outline_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: validateTitle,
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      key: const Key('descField'),
                      controller: descriptionController,
                      maxLines: 5, // Reduced maxLines
                      maxLength: 350,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        prefixIcon: Icon(Icons.description_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: validateDescription,
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      key: const Key('linkField'),
                      controller: articleLinkController,
                      decoration: const InputDecoration(
                        labelText: 'Link article',
                        prefixIcon: Icon(Icons.link_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: validateArticleLink,
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton.icon(
                      key: const Key('uploadVideoButton'),
                      onPressed: () async {
                        _videoPlayerController?.pause();
                        String? videoURL;
                        videoURL = await pickVideoFromDevice();

                        if (videoURL != null) {
                          if (_videoURL != null) {
                            // Dispose the old video player if exists
                            _videoPlayerController?.dispose();
                            _chewieController?.dispose();
                          }
                          setState(() {
                            _videoURL = videoURL;
                          });
                          _initializeVideoPlayer();
                        }
                      },
                      icon: const Icon(
                        Icons.cloud_upload_outlined,
                      ),
                      label: _videoURL == null ||
                              _videoURL!
                                  .isEmpty // Check if video URL is null or empty
                          ? const Text(
                              'Upload a video',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            )
                          : const Text(
                              'Change video',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    if (_videoURL != null && _chewieController != null)
                      SizedBox(
                        height: 250,
                        child: Chewie(controller: _chewieController!),
                      ),
                    if (_videoURL != null && _chewieController != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              key: const Key('deleteButton'),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: _clearVideoSelection,
                              tooltip: 'Remove Video',
                            ),
                          ],
                        ),
                      ),
                    if (_videoURL != null &&
                        _chewieController != null &&
                        _videoURL == widget.topic['videoUrl'])
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'the above is a preview of your video.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    if (_videoURL != null &&
                        _chewieController != null &&
                        _videoURL != widget.topic['videoUrl'])
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'the above is a preview of your edited video.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateQuiz(
                            firestore: widget.firestore, addQuiz: addQuiz),
                      ),
                    );
                  },
                  child: Row(children: [
                    const SizedBox(
                      width: 150,
                    ),
                    const Text(
                      "ADD QUIZ",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (quizAdded)
                      const Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                  ])),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  if (_topicFormKey.currentState!.validate()) {
                    await _uploadTopic();
                  }
                },
                child: const Text(
                  "UPDATE TOPIC",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> updatedData = {};

  Future<String?> pickVideoFromDevice() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'wmv'],
      );
      return result!.files.first.path;
    } catch (e) {
      return null;
    }
  }

  void _initializeVideoPlayer() async {
    if (_videoURL != null && _videoURL!.isNotEmpty) {
      if (_videoURL!.startsWith('http') || _videoURL!.startsWith('https')) {
        // Network URL
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(_videoURL!));
      } else {
        // File URL
        _videoPlayerController = VideoPlayerController.file(File(_videoURL!));
      }

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

  Future<void> deleteVideoFromStorage(String videoUrl) async {
    String fileUrl = widget.topic['videoUrl'];

    // get reference to the video file
    Reference videoRef = widget.storage.refFromURL(fileUrl);

    // Delete the file
    await videoRef.delete();
  }

  Future<void> _uploadTopic() async {
    String oldVideoUrl = widget.topic['videoUrl'];
    if (_videoURL == widget.topic['videoUrl'] &&
        titleController.text == widget.topic['title'] &&
        descriptionController.text == widget.topic['description'] &&
        articleLinkController.text == widget.topic['articleLink']) {
      // If no changes have been made, directly navigate to the view topic screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ViewTopicScreen(
            firestore: widget.firestore,
            topic: widget.topic,
            storage: widget.storage,
            auth: widget.auth,
          ),
        ),
      );
      return;
    } else {
      // Navigate to the animation screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckmarkAnimationScreen(
            firestore: widget.firestore,
            topic: widget.topic,
            storage: widget.storage,
            auth: widget.auth,
          ),
        ),
      );

      QuerySnapshot? data;
      String? newVideoURL;

      await Future.delayed(const Duration(seconds: 2));

      // Check if a new video was selected
      if (_videoURL != widget.topic['videoUrl']) {
        // store new video
        if (_videoURL != '') {
          newVideoURL = await StoreData(widget.storage).uploadVideo(_videoURL!);
        } else {
          newVideoURL = '';
        }

        final topicDetails = {
          'title': titleController.text,
          'description': descriptionController.text,
          'articleLink': articleLinkController.text,
          'videoUrl': newVideoURL,
          'views': widget.topic['views'],
          'likes': widget.topic['likes'],
          'dislikes': widget.topic['dislikes'],
          'date': widget.topic['date'],
        };

        CollectionReference topicCollectionRef =
            widget.firestore.collection('topics');

        await topicCollectionRef.doc(widget.topic.id).update(topicDetails);

        while (true) {
          CollectionReference topicCollRef =
              widget.firestore.collection('topics');
          data = await topicCollRef.orderBy('title').get();

          for (QueryDocumentSnapshot doc in data.docs) {
            // Check if the document ID matches the ID of the topic
            if (doc.id == widget.topic.id) {
              updatedTopicDoc = doc as QueryDocumentSnapshot<Object>;
              break; // Exit the loop since we found the most recent version of the topic
            }
          }

          if (updatedTopicDoc['videoUrl'] != widget.topic['videoUrl']) {
            // If the updated topic document's video URL is different from the old URL,

            final topicDetails = {
              'title': titleController.text,
              'description': descriptionController.text,
              'articleLink': articleLinkController.text,
              'videoUrl': newVideoURL,
              'views': widget.topic['views'],
              'likes': widget.topic['likes'],
              'dislikes': widget.topic['dislikes'],
              'date': widget.topic['date'],
            };

            await topicCollectionRef.doc(widget.topic.id).update(topicDetails);

            break;
          }
        }

        if (oldVideoUrl != '') {
          await deleteVideoFromStorage(widget.topic['videoUrl']);
        } else {}
      } else {
        final topicDetails = {
          'title': titleController.text,
          'description': descriptionController.text,
          'articleLink': articleLinkController.text,
          'videoUrl': widget.topic['videoUrl'],
          'views': widget.topic['views'],
          'likes': widget.topic['likes'],
          'dislikes': widget.topic['dislikes'],
          'date': widget.topic['date'],
        };

        CollectionReference topicCollectionRef =
            widget.firestore.collection('topics');

        await topicCollectionRef.doc(widget.topic.id).update(topicDetails);
      }

      // Navigate to the view topic screen after upload is complete
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ViewTopicScreen(
            firestore: widget.firestore,
            topic: updatedTopicDoc,
            storage: widget.storage,
            auth: widget.auth,
          ),
        ),
      );
    }
  }

  void _clearVideoSelection() {
    setState(() {
      _videoURL = '';
      if (_videoPlayerController != null) {
        _videoPlayerController!.pause();
        _videoPlayerController!.dispose();
        _videoPlayerController = null;
      }
      if (_chewieController != null) {
        _chewieController!.pause();
        _chewieController!.dispose();
        _chewieController = null;
      }
    });

    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void addQuiz(String qid) {
    setState(() {
      quizID = qid;
      quizAdded = true;
    });
  }
}

class StoreData {
  final FirebaseStorage _storage;

  StoreData(this._storage);

  Future<String> uploadVideo(String videoUrl) async {
    Reference ref = _storage.ref().child('videos/${DateTime.now()}.mp4');
    await ref.putFile(File(videoUrl));
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }
}

class CheckmarkAnimationScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final QueryDocumentSnapshot topic;
  final FirebaseAuth auth;
  const CheckmarkAnimationScreen(
      {Key? key,
      required this.topic,
      required this.firestore,
      required this.auth,
      required this.storage})
      : super(key: key);

  @override
  _CheckmarkAnimationScreenState createState() =>
      _CheckmarkAnimationScreenState();
}

class _CheckmarkAnimationScreenState extends State<CheckmarkAnimationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitDoubleBounce(
              color: Colors.green,
              size: 70.0,
            ),
            SizedBox(height: 20),
            Text(
              'Your changes are on the way..',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
