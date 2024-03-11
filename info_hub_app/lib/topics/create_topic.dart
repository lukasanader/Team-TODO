import 'dart:io';
import 'package:flutter/material.dart';
import 'package:info_hub_app/ask_question/question_card.dart';
import 'package:info_hub_app/ask_question/question_service.dart';
import 'package:info_hub_app/topics/quiz/create_quiz.dart';
import 'package:info_hub_app/topics/quiz/quiz_service.dart';

import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateTopicScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  const CreateTopicScreen(
      {super.key, required this.firestore, required this.storage});

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final articleLinkController = TextEditingController();
  final _topicFormKey = GlobalKey<FormState>();
  List<dynamic> questions=[];
  String quizID = '';
  bool quizAdded=false;

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
  String? _downloadURL;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void dispose() {
    super.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'Create a Topic',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                        _videoController?.pause();
                        String? videoURL = await pickVideoFromDevice();

                        if (videoURL != null) {
                          setState(() {
                            _videoURL = videoURL;
                          });
                          await _initializeVideoPlayer();
                        }
                      },
                      icon: const Icon(
                        Icons.cloud_upload_outlined,
                      ),
                      label: _videoURL == null
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
                      _videoPreviewWidget(),
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
                  Navigator.push(context,
                          MaterialPageRoute(
                            builder :(context) => CreateQuiz(firestore: widget.firestore,addQuiz: addQuiz),
                          ),
                          );
                },
                child: 
                Row(
                  children: [
                    const SizedBox(width: 150,),
                    const Text(
                      "ADD QUIZ",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      
                      ),
                    ),
                    if(quizAdded)
                      const Icon(Icons.check, color: Colors.green,)
                    ]
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async{
                  if (_topicFormKey.currentState!.validate()) {
                    _uploadTopic();
                    _showDeleteQuestionDialog();
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "PUBLISH TOPIC",
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

 Future<void> _showDeleteQuestionDialog() async {
  
  questions =await QuestionService(firestore: widget.firestore).getRelevantQuestions(titleController.text);
  
  // ignore: use_build_context_synchronously
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
        return Dialog(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: questions.isEmpty ? 1 : questions.length,
                  itemBuilder: (context, index) {
                    if (questions.isEmpty) {
                      return const ListTile(
                        title: Text('There are currently no more questions!'),
                      );
                    } else {
                      return QuestionCard(
                          questions[index] as QueryDocumentSnapshot,
                          widget.firestore,
                          () async {
                              List<dynamic> updatedQuestions = await QuestionService(firestore: widget.firestore).getRelevantQuestions(titleController.text);
                              setState(() {
                                questions = updatedQuestions;
                              });
                            },);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children:[
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirmation"),
                        content: const Text(
                            "Are you sure you want to remove all these questions?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async{
                              // Delete the question from the database
                              QuestionService(firestore: widget.firestore).deleteQuestions(questions);
                              setState(() {questions =[];},);
                              Navigator.of(context).pop();
                            },
                            child: const Text("Confirm"),
                          ),
                        ],
                      );
                    },
                  );
                    
                  },
                  child: const Text('Delete all'),
                ), 
                ElevatedButton(
                  onPressed: () async {Navigator.of(context).pop();},
                  child: const Text('Done'),
                ),
                ]
                )
              ],
            ),
          ),
        ),
        );
        }
      );
    },
  );
 

 }

  


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

  Future<void> _initializeVideoPlayer() async {
    if (_videoURL != null && _videoURL!.isNotEmpty) {
      _videoController = VideoPlayerController.file(File(_videoURL!));

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoInitialize: true,
        looping: false,
        aspectRatio: 16 / 9,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown
        ],
        allowedScreenSleep: false,
      );
      _chewieController!.addListener(() {
        if (!_chewieController!.isFullScreen) {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        }
      });
      setState(() {});
    }
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'the above is a preview of your video.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _uploadTopic() async {
    if (_videoController != null) {
      _downloadURL = await StoreData(widget.storage).uploadVideo(_videoURL!);
    }

    final topicDetails = {
      'title': titleController.text,
      'description': descriptionController.text,
      'articleLink': articleLinkController.text,
      'videoUrl': _downloadURL,
      'views': 0,
      'likes': 0,
      'dislikes': 0,
      'date': DateTime.now(),
    };

    CollectionReference topicCollectionRef =
        widget.firestore.collection('topics');

    await topicCollectionRef.add(topicDetails);
  }

  void _clearVideoSelection() {
    setState(() {
      _videoURL = null;
      _downloadURL = null;
      if (_videoController != null) {
        _videoController!.pause();
        _videoController!.dispose();
        _videoController = null;
      }
      if (_chewieController != null) {
        _chewieController!.pause();
        _chewieController!.dispose();
        _chewieController = null;
      }
    });

    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  }

  void addQuiz(String qid){
    setState(() {
      quizID=qid;
      quizAdded=true;
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


