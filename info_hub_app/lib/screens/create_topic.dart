import 'dart:io';
import 'package:flutter/material.dart';
import '/resources/save_video.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTopicScreen extends StatefulWidget {
  const CreateTopicScreen({Key? key}) : super(key: key);

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

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _topicFormKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text('Create a Topic',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                const Text(
                  'fields marked with an asterisk (*) are required',
                  style: TextStyle(color: Colors.grey),
                ),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    prefixIcon: Icon(Icons.drive_file_rename_outline_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: validateTitle,
                ),
                const SizedBox(height: 10.0),
                TextFormField(
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
                              color: Colors.red, fontWeight: FontWeight.bold),
                        )
                      : const Text(
                          'Change video',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 50.0),
                publishBtn(context),
              ],
            )),
      ),
    );
  }

  OutlinedButton publishBtn(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(minimumSize: const Size(200, 50)),
      onPressed: () {
        if (_topicFormKey.currentState!.validate()) {
          _uploadTopic();
          Navigator.pop(context);
        }
      },
      child: const Text(
        "PUBLISH TOPIC",
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _pickVideo() async {
    _videoController?.pause();
    _videoURL = await pickVideoFromDevice();
    _initializeVideoPlayer();
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

  void _initializeVideoPlayer() {
    _videoController?.pause();
    _videoController?.dispose();
    if (_videoURL != null) {
      _videoController = VideoPlayerController.file(File(_videoURL!))
        ..initialize().then((_) {
          setState(() {});
          _videoController!.pause();
        });
    }
  }

  Widget _videoPreviewWidget() {
    return Column(
      children: [
        SizedBox(
          width: 280,
          height: 80 * (_videoController!.value.aspectRatio),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_videoController!.value.isPlaying) {
                        _videoController!.pause();
                      } else {
                        _videoController!.play();
                      }
                    });
                  },
                  child: Center(
                    child: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Text(
          'the above is a preview of your video.',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(
          height: 30,
          child: GestureDetector(
            onTap: _clearVideoSelection,
            child: const Icon(
              Icons.delete_forever_rounded,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  void _clearVideoSelection() {
    setState(() {
      _videoURL = null;
      _downloadURL = null;
      _videoController?.dispose();
      _videoController = null;
    });
  }

  void _uploadTopic() async {
    if (_videoController != null) {
      _downloadURL = await StoreData().uploadVideo(_videoURL!);
    }

    CollectionReference topicCollectionRef =
        FirebaseFirestore.instance.collection('topics');
    topicCollectionRef.add({
      'title': titleController.text,
      'description': descriptionController.text,
      'articleLink': articleLinkController.text,
      'videoUrl': _downloadURL,
    });
  }
}
