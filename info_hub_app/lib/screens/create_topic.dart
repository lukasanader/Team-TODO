import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateTopicScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  const CreateTopicScreen({Key? key, required this.firestore})
      : super(key: key);

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final articleLinkController = TextEditingController();
  final _topicFormKey = GlobalKey<FormState>();

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
    _videoController?.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
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
                      maxLines: 8,
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
                    const SizedBox(height: 5.0),
                    ElevatedButton.icon(
                      onPressed: _pickVideo,
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
                    _videoURL != null
                        ? _videoPreviewWidget()
                        : const Text('no video selected'),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (_topicFormKey.currentState!.validate()) {
                    _uploadTopic();
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

  void _pickVideo() async {
    _videoController?.pause();
    _videoURL = await pickVideoFromDevice();
    await _initializeVideoPlayer();
  }

  Future<String?> pickVideoFromDevice() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'wmv'],
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_videoURL != null) {
      _videoController = VideoPlayerController.file(File(_videoURL!));

      await _videoController?.initialize();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 150,
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _clearVideoSelection,
                tooltip: 'Remove Video',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: Text(
              'the above is a preview of your video.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  void _uploadTopic() async {
    if (_videoController != null) {
      _downloadURL = await StoreData().uploadVideo(_videoURL!);
    }

    final topicDetails = {
      'title': titleController.text,
      'description': descriptionController.text,
      'articleLink': articleLinkController.text,
      'videoUrl': _downloadURL,
    };

    CollectionReference topicCollectionRef =
        widget.firestore.collection('topics');

    await topicCollectionRef.add(topicDetails);

    titleController.clear();
    descriptionController.clear();
    articleLinkController.clear();
  }

  void _clearVideoSelection() {
    setState(() {
      _videoURL = null;
      _downloadURL = null;
      _videoController?.dispose();
      _chewieController?.dispose();
      _videoController = null;
    });
  }
}

final FirebaseStorage _storage = FirebaseStorage.instance;

class StoreData {
  Future<String> uploadVideo(String videoUrl) async {
    Reference ref = _storage.ref().child('videos/${DateTime.now()}.mp4');
    await ref.putFile(File(videoUrl));
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }
}
