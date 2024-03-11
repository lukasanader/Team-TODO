import 'dart:io';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:info_hub_app/topics/quiz/create_quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class CreateTopicScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  const CreateTopicScreen({
    Key? key,
    required this.firestore,
    required this.storage,
  }) : super(key: key);

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController articleLinkController = TextEditingController();
  final GlobalKey<FormState> _topicFormKey = GlobalKey<FormState>();
  List<String> _tags = [];
  List<String> options = ['Patient', 'Parent', 'Healthcare Professional'];
  String quizID = '';
  bool quizAdded = false;

  String? _videoURL;
  String? _imageUrl;
  bool changingMedia = false;

  List<Map<String, String>> mediaUrls = [];

  int currentIndex = 0;

  String? _downloadURL;
  String? _mediaType;
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
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ChipsChoice<String>.multiple(
                        value: _tags,
                        onChanged: (val) => setState(() => _tags = val),
                        choiceItems: C2Choice.listFrom<String, String>(
                          source: options,
                          value: (i, v) => v,
                          label: (i, v) => v,
                        ),
                        choiceCheckmark: true,
                        choiceStyle: C2ChipStyle.outlined(),
                      ),
                    ),
                    if (_tags.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Please select at least one tag.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
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
                      maxLength: 500,
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
                    Row(
                      children: [
                        ElevatedButton.icon(
                          key: const Key('uploadMediaButton'),
                          onPressed: () {
                            if (_videoURL != null || _imageUrl != null) {
                              changingMedia = true;
                            }
                            if (_videoURL == null && _imageUrl == null) {
                              changingMedia = false;
                            }
                            _showMediaUploadOptions(context);
                          },
                          icon: const Icon(
                            Icons.cloud_upload_outlined,
                          ),
                          label: _videoURL != null || _imageUrl != null
                              ? const Text(
                                  'Change Media',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const Text(
                                  'Upload Media',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_videoURL != null || _imageUrl != null)
                          ElevatedButton.icon(
                            onPressed: () {
                              changingMedia = false;
                              _showMediaUploadOptions(context);
                            },
                            icon: const Icon(
                              Icons.add,
                            ),
                            label: const Text(
                              'Add More Media',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    if (_videoURL != null && _chewieController != null)
                      _videoPreviewWidget(),
                    if (_imageUrl != null) _imagePreviewWidget(),
                    if (_videoURL != null || _imageUrl != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (mediaUrls.length > 1)
                            IconButton(
                              key: const Key('previousVideoButton'),
                              icon: const Icon(Icons.arrow_circle_left_rounded,
                                  color: Color.fromRGBO(150, 100, 200, 1.0)),
                              onPressed: () async {
                                if (currentIndex - 1 >= 0) {
                                  currentIndex -= 1;
                                  if (mediaUrls[currentIndex]['mediaType'] ==
                                      'video') {
                                    _videoURL = mediaUrls[currentIndex]['url'];
                                    _imageUrl = null;
                                    setState(() {});
                                    await _initializeVideoPlayer();
                                    setState(() {});
                                  } else if (mediaUrls[currentIndex]
                                          ['mediaType'] ==
                                      'image') {
                                    _imageUrl = mediaUrls[currentIndex]['url'];
                                    _videoURL = null;
                                    setState(() {});
                                    await _initializeImage();
                                    setState(() {});
                                  }
                                }
                              },
                              tooltip: 'Previous Video',
                            ),
                          if (mediaUrls.length > 1)
                            IconButton(
                              key: const Key('nextVideoButton'),
                              icon: const Icon(Icons.arrow_circle_right_rounded,
                                  color: Color.fromRGBO(150, 100, 200, 1.0)),
                              onPressed: () async {
                                if (currentIndex + 1 < mediaUrls.length) {
                                  currentIndex += 1;
                                  if (mediaUrls[currentIndex]['mediaType'] ==
                                      'video') {
                                    _videoURL = mediaUrls[currentIndex]['url'];
                                    _imageUrl = null;
                                    setState(() {});
                                    await _initializeVideoPlayer();
                                    setState(() {});
                                  } else if (mediaUrls[currentIndex]
                                          ['mediaType'] ==
                                      'image') {
                                    _imageUrl = mediaUrls[currentIndex]['url'];
                                    _videoURL = null;
                                    setState(() {});
                                    await _initializeImage();
                                    setState(() {});
                                  }
                                }
                              },
                              tooltip: 'Next Video',
                            ),
                        ],
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
                onPressed: () {
                  if (_topicFormKey.currentState!.validate() &&
                      _tags.isNotEmpty) {
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

  Future<void> _showMediaUploadOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Upload Image'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromDevice();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Upload Video'),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromDevice();
              },
            ),
          ],
        );
      },
    );
    return;
  }

  Future<void> _pickImageFromDevice() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: !changingMedia,
      );
      if (result != null) {
        for (PlatformFile file in result.files) {
          String imagePath = file.path!;
          setState(() {
            _imageUrl = imagePath;

            Map<String, String> imageInfo = {
              'url': imagePath,
              'mediaType': 'image',
            };
            if (!changingMedia) {
              mediaUrls.add(imageInfo);
              currentIndex = mediaUrls.length - 1;
            } else {
              mediaUrls[currentIndex] = imageInfo;
            }
            _videoURL = null; // Reset video if any
          });
          if (file == result.files.last) {
            await _initializeImage();
          }
        }
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _pickVideoFromDevice() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'wmv'],
        allowMultiple: !changingMedia,
      );

      if (result != null) {
        for (PlatformFile file in result.files) {
          String videoPath = file.path!;
          setState(() {
            _videoURL = videoPath;

            Map<String, String> videoInfo = {
              'url': videoPath,
              'mediaType': 'video',
            };
            if (!changingMedia) {
              mediaUrls.add(videoInfo);
              currentIndex = mediaUrls.length - 1;
            } else {
              mediaUrls[currentIndex] = videoInfo;
            }
            _imageUrl = null; // Reset image if any
          });
          if (file == result.files.last) {
            await _initializeVideoPlayer();
          }
        }
      }
    } catch (e) {
      print("Error picking video: $e");
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _disposeVideoPlayer();
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

  void _disposeVideoPlayer() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;

    _chewieController?.pause();
    _chewieController?.dispose();
    _chewieController = null;
  }

  Future<void> _initializeImage() async {
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
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
          Text(
            'The above is a preview of your video.                         ${currentIndex + 1} / ${mediaUrls.length}',
            style: const TextStyle(color: Colors.grey),
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Aligns the button to the right
            children: [
              IconButton(
                key: const Key('deleteVideoButton'),
                icon: const Icon(Icons.delete_forever_outlined,
                    color: Colors.red),
                onPressed: _clearVideoSelection,
                tooltip: 'Remove Video',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePreviewWidget() {
    if (_imageUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.file(File(_imageUrl!)),
          Text(
            'The above is a preview of your image.                    ${currentIndex + 1} / ${mediaUrls.length}',
            style: const TextStyle(color: Colors.grey),
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Aligns the button to the right
            children: [
              IconButton(
                key: const Key('deleteImageButton'),
                icon: const Icon(Icons.delete_forever_outlined,
                    color: Colors.red),
                onPressed: _clearImageSelection,
                tooltip: 'Remove Image',
              ),
            ],
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  void _uploadTopic() async {
    List<Map<String, String>> mediaList = [];
    for (var item in mediaUrls) {
      if (item['mediaType'] == 'video') {
        _downloadURL = await _storeData().uploadFile(item['url']!);

        Map<String, String> uploadData = {
          'url': _downloadURL!,
          'mediaType': 'video',
        };
        mediaList.add(uploadData);
      } else if (item['mediaType'] == 'image') {
        _downloadURL = await _storeData().uploadFile(item['url']!);

        Map<String, String> uploadData = {
          'url': _downloadURL!,
          'mediaType': 'image',
        };
        mediaList.add(uploadData);
      }
    }

    final topicDetails = {
      'title': titleController.text,
      'description': descriptionController.text,
      'articleLink': articleLinkController.text,
      'media': mediaList,
      'views': 0,
      'likes': 0,
      'dislikes': 0,
      'date': DateTime.now(),
      'tags': _tags,
      'quizID': quizID
    };

    CollectionReference topicCollectionRef =
        widget.firestore.collection('topics');

    await topicCollectionRef.add(topicDetails);
  }

  void _clearImageSelection() {
    List<Map<String, String>> oldMediaUrls = [...mediaUrls];
    setState(() {
      mediaUrls.removeAt(currentIndex);
      if (mediaUrls.length + 1 > 1) {
        if (currentIndex - 1 >= 0) {
          currentIndex -= 1;
        } else {
          currentIndex += 1;
        }
        if (oldMediaUrls[currentIndex]['mediaType'] == 'video') {
          _videoURL = oldMediaUrls[currentIndex]['url'];
          _imageUrl = null;
          setState(() {});
          _initializeVideoPlayer();
          setState(() {});
        } else if (oldMediaUrls[currentIndex]['mediaType'] == 'image') {
          _imageUrl = oldMediaUrls[currentIndex]['url'];
          _videoURL = null;
          setState(() {});
          _initializeImage();
          setState(() {});
        }
      } else {
        _imageUrl = null;
        setState(() {});
      }
    });
  }

  void _clearVideoSelection() {
    List<Map<String, String>> oldMediaUrls = [...mediaUrls];
    setState(() {
      _disposeVideoPlayer();
      mediaUrls.removeAt(currentIndex);
      if (mediaUrls.length + 1 > 1) {
        if (currentIndex - 1 >= 0) {
          currentIndex -= 1;
        } else {
          currentIndex += 1;
        }
        if (oldMediaUrls[currentIndex]['mediaType'] == 'video') {
          _videoURL = oldMediaUrls[currentIndex]['url'];
          _imageUrl = null;
          setState(() {});
          _initializeVideoPlayer();
          setState(() {});
        } else if (oldMediaUrls[currentIndex]['mediaType'] == 'image') {
          _imageUrl = oldMediaUrls[currentIndex]['url'];
          _videoURL = null;
          setState(() {});
          _initializeImage();
          setState(() {});
        }
      } else {
        _videoURL = null;
        setState(() {});
      }
    });
  }

  void addQuiz(String qid) {
    setState(() {
      quizID = qid;
      quizAdded = true;
    });
  }

  StoreData _storeData() {
    return StoreData(widget.storage);
  }

  // Validation functions
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
}

class StoreData {
  final FirebaseStorage _storage;

  StoreData(this._storage);

  Future<String> uploadFile(String url) async {
    Reference ref = _storage.ref().child('media/${basename(url)}');
    await ref.putFile(File(url));
    return await ref.getDownloadURL();
  }
}
