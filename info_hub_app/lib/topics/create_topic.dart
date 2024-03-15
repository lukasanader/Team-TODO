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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:info_hub_app/topics/view_topic.dart';
import 'package:path/path.dart' as path;
import 'package:info_hub_app/ask_question/question_card.dart';
import 'package:info_hub_app/ask_question/question_service.dart';

class CreateTopicScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  QueryDocumentSnapshot? topic;
  QueryDocumentSnapshot? draft;
  final FirebaseAuth auth;
  List<PlatformFile>? selectedFiles;

  CreateTopicScreen({
    Key? key,
    required this.firestore,
    required this.storage,
    this.topic,
    this.draft,
    this.selectedFiles,
    required this.auth,
  }) : super(key: key);

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  late TextEditingController titleController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  late TextEditingController articleLinkController = TextEditingController();
  late GlobalKey<FormState> _topicFormKey = GlobalKey<FormState>();
  late List<Map<String, dynamic>> mediaUrls;
  late List<Map<String, dynamic>> originalUrls;
  late List<dynamic> networkUrls;
  late int currentIndex;
  late String prevTitle;
  late String prevDescription;
  late String prevArticleLink;
  late String appBarTitle;
  List<dynamic> questions = [];
  late QueryDocumentSnapshot<Object?>? updatedTopicDoc;
  List<dynamic> _tags = [];
  List<String> options = ['Patient', 'Parent', 'Healthcare Professional'];
  String quizID = '';
  bool quizAdded = false;
  List<dynamic> _categories = [];
  List<String> _categoriesOptions = [];
  final TextEditingController _newCategoryNameController =
      TextEditingController();
  String? _videoURL;
  String? _imageUrl;
  bool changingMedia = false;
  bool editing = false;
  bool drafting = false;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCategoryList();
  }

  @override
  void initState() {
    super.initState();

    currentIndex = 0;
    editing = widget.topic != null;
    drafting = widget.draft != null;
    mediaUrls = [];
    originalUrls = [];
    networkUrls = [];
    appBarTitle = "Create a Topic";
    updatedTopicDoc = null;
    if (editing) {
      mediaUrls = [...widget.topic!['media']];
      originalUrls = [...mediaUrls];
      List<dynamic> tempUrls = [];
      for (var item in mediaUrls) {
        tempUrls.add(item['url']);
      }
      networkUrls = [...tempUrls];
      appBarTitle = "Edit Topic";
      prevTitle = widget.topic!['title'];
      prevDescription = widget.topic!['description'];
      prevArticleLink = widget.topic!['articleLink'];

      titleController = TextEditingController(text: prevTitle);
      descriptionController = TextEditingController(text: prevDescription);
      articleLinkController = TextEditingController(text: prevArticleLink);
      _tags = widget.topic!['tags'];
      _categories = widget.topic!['categories'];
      initData();
      updatedTopicDoc = widget.topic!;
    } else if (drafting) {
      mediaUrls = [...widget.draft!['media']];
      originalUrls = [...mediaUrls];
      List<dynamic> tempUrls = [];
      for (var item in mediaUrls) {
        tempUrls.add(item['url']);
      }
      networkUrls = [...tempUrls];
      appBarTitle = "Draft";
      prevTitle = widget.draft!['title'];
      prevDescription = widget.draft!['description'];
      prevArticleLink = widget.draft!['articleLink'];

      titleController = TextEditingController(text: prevTitle);
      descriptionController = TextEditingController(text: prevDescription);
      articleLinkController = TextEditingController(text: prevArticleLink);
      _tags = widget.draft!['tags'];
      _categories = widget.draft!['categories'];
      initData();
    }
  }

  Future<void> initData() async {
    if (widget.topic != null && widget.topic!['media']!.length > 0) {
      if (widget.topic!['media']![currentIndex]['mediaType']! == 'video') {
        _videoURL = widget.topic!['media']![currentIndex]['url']!;
        _imageUrl = null;

        await _initializeVideoPlayer();
      } else {
        _imageUrl = widget.topic!['media']![currentIndex]['url']!;
        _videoURL = null;
        await _initializeImage();
      }
    }
    if (widget.draft != null && widget.draft!['media'].length > 0) {
      if (widget.draft!['media']![currentIndex]['mediaType']! == 'video') {
        _videoURL = widget.draft!['media']![currentIndex]['url']!;
        _imageUrl = null;

        await _initializeVideoPlayer();
      } else {
        _imageUrl = widget.draft!['media']![currentIndex]['url']!;
        _videoURL = null;
        await _initializeImage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(
            appBarTitle,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              if (editing) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewTopicScreen(
                        firestore: widget.firestore,
                        topic: updatedTopicDoc!,
                        storage: widget.storage,
                        auth: widget.auth),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: <Widget>[
            if (!editing && !drafting)
              TextButton(
                key: const Key('draft_btn'),
                onPressed: () async {
                  await saveDraft(context);
                },
                child: const Text(
                  'Save Draft',
                  style: TextStyle(color: Colors.white),
                ),
              )
          ]),
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
                      child: ChipsChoice<dynamic>.multiple(
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                createNewCategoryDialog(context);
                              },
                              icon: const Icon(Icons.add)),
                          IconButton(
                              onPressed: () {
                                deleteCategoryDialog(context);
                              },
                              icon: const Icon(Icons.close)),
                          if (_categoriesOptions.isEmpty)
                            const Text('Add a category'),
                          if (_categoriesOptions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ChipsChoice<dynamic>.multiple(
                                value: _categories,
                                onChanged: (val) =>
                                    setState(() => _categories = val),
                                choiceItems: C2Choice.listFrom<String, String>(
                                  source: _categoriesOptions,
                                  value: (i, v) => v,
                                  label: (i, v) => v,
                                ),
                                choiceCheckmark: true,
                                choiceStyle: C2ChipStyle.outlined(),
                              ),
                            ),
                        ],
                      ),
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
                                    firestore: widget.firestore,
                                    addQuiz: addQuiz),
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
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            key: const Key('moreMediaButton'),
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
                              key: const Key('previousMediaButton'),
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
                              key: const Key('nextMediaButton'),
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
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200, // Adjust the width as needed
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        if (_topicFormKey.currentState!.validate() &&
                            _tags.isNotEmpty) {
                          await _uploadTopic(context);
                          await _showDeleteQuestionDialog(context);
                        }
                      },
                      child: Text(
                        editing ? "UPDATE TOPIC" : "PUBLISH TOPIC",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadTopic(context) async {
    List<Map<String, String>> mediaList = [];

    for (var item in mediaUrls) {
      String url = item['url']!;
      String mediaType = item['mediaType']!;

      if (networkUrls.contains(url)) {
        _downloadURL = url;
      } else {
        _downloadURL = await _storeData().uploadFile(url);
      }

      Map<String, String> uploadData = {
        'url': _downloadURL!,
        'mediaType': mediaType,
      };

      mediaList.add(uploadData);
    }
    CollectionReference topicCollectionRef =
        widget.firestore.collection('topics');

    if (!editing && !drafting) {
      final topicDetails = {
        'title': titleController.text,
        'description': descriptionController.text,
        'articleLink': articleLinkController.text,
        'media': mediaList,
        'views': 0,
        'likes': 0,
        'dislikes': 0,
        'tags': _tags,
        'categories': _categories,
        'date': DateTime.now(),
      };
      await topicCollectionRef.add(topicDetails);
      Navigator.pop(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckmarkAnimationScreen(),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      final topicDetails = editing
          ? {
              'title': titleController.text,
              'description': descriptionController.text,
              'articleLink': articleLinkController.text,
              'media': mediaList,
              'views': widget.topic!['views'],
              'likes': widget.topic!['likes'],
              'categories': _categories,
              'dislikes': widget.topic!['dislikes'],
              'date': widget.topic!['date'],
              'tags': _tags,
            }
          : {
              'title': titleController.text,
              'description': descriptionController.text,
              'articleLink': articleLinkController.text,
              'media': mediaList,
              'views': widget.draft!['views'],
              'likes': widget.draft!['likes'],
              'categories': _categories,
              'dislikes': widget.draft!['dislikes'],
              'date': widget.draft!['date'],
              'tags': _tags,
            };

      for (var item in originalUrls) {
        if (!mediaList
            .map((map) => map['url'])
            .toList()
            .contains(item['url'])) {
          deleteMediaFromStorage(item['url']);
        }
      }

      if (editing) {
        await topicCollectionRef.doc(widget.topic!.id).update(topicDetails);
        QuerySnapshot? data = await topicCollectionRef.orderBy('title').get();
        for (QueryDocumentSnapshot doc in data.docs) {
          // Check if the document ID matches the ID of the topic
          if (doc.id == widget.topic!.id) {
            updatedTopicDoc = doc as QueryDocumentSnapshot<Object>;
            break;
          }
        }
      } else if (drafting) {
        await topicCollectionRef.add(topicDetails);
        Navigator.pop(context);
      }
      if (editing) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ViewTopicScreen(
              firestore: widget.firestore,
              topic: updatedTopicDoc!,
              storage: widget.storage,
              auth: widget.auth,
            ),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteQuestionDialog(context) async {
    questions = await QuestionService(firestore: widget.firestore)
        .getRelevantQuestions(titleController.text);

    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
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
                            title:
                                Text('There are currently no more questions!'),
                          );
                        } else {
                          return QuestionCard(
                            questions[index] as QueryDocumentSnapshot,
                            widget.firestore,
                            () async {
                              List<dynamic> updatedQuestions =
                                  await QuestionService(
                                          firestore: widget.firestore)
                                      .getRelevantQuestions(
                                          titleController.text);
                              setState(() {
                                questions = updatedQuestions;
                              });
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
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
                                    onPressed: () async {
                                      // Delete the question from the database
                                      QuestionService(
                                              firestore: widget.firestore)
                                          .deleteQuestions(questions);
                                      setState(
                                        () {
                                          questions = [];
                                        },
                                      );
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
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Done'),
                      ),
                    ])
                  ],
                ),
              ),
            ),
          );
        });
      },
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
    if (widget.selectedFiles == null) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: !changingMedia,
      );
      if (result != null && result.files.isNotEmpty) {
        // Check if files are selected
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
        }
        await _initializeImage();
      }
    } else {
      for (PlatformFile file in filterImages(widget.selectedFiles!)) {
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
      }
      if (filterImages(widget.selectedFiles!).isNotEmpty) {
        await _initializeImage();
      }
    }
  }

  List<PlatformFile> filterImages(List<PlatformFile> files) {
    return files.where((file) {
      // Get the file extension
      String extension = path.extension(file.path!).toLowerCase();

      // Check if the extension is for an image file
      return extension == '.jpg' || extension == '.jpeg' || extension == '.png';
    }).toList();
  }

  List<PlatformFile> filterVideos(List<PlatformFile> files) {
    return files.where((file) {
      // Get the file extension
      String extension = path.extension(file.path!).toLowerCase();

      // Check if the extension is for a video file
      return extension == '.mp4' ||
          extension == '.mov' ||
          extension == '.avi' ||
          extension == '.mkv' ||
          extension == '.wmv' ||
          extension == '.flv';
    }).toList();
  }

  Future<void> _pickVideoFromDevice() async {
    if (widget.selectedFiles == null) {
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
    } else {
      for (PlatformFile file in filterVideos(widget.selectedFiles!)) {
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
        if (file == filterVideos(widget.selectedFiles!).last) {
          await _initializeVideoPlayer();
        }
      }
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _disposeVideoPlayer();
    if (_videoURL != null && _videoURL!.isNotEmpty) {
      if (!networkUrls.contains(_videoURL)) {
        _videoController = VideoPlayerController.file(File(_videoURL!));
      } else {
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(_videoURL!));
      }

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
          if (!editing || networkUrls.contains(_videoURL))
            Text(
              'The above is a preview of your video.                         ${currentIndex + 1} / ${mediaUrls.length}',
              key: const Key('upload_text_video'),
              style: const TextStyle(color: Colors.grey),
            ),
          if (editing && !networkUrls.contains(_videoURL))
            Text(
              'The above is a preview of your new video.                    ${currentIndex + 1} / ${mediaUrls.length}',
              key: const Key('edit_text_video'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!networkUrls.contains(_imageUrl)) Image.file(File(_imageUrl!)),
        if (networkUrls.contains(_imageUrl)) Image.network((_imageUrl!)),
        if (!editing || networkUrls.contains(_imageUrl))
          Text(
            'The above is a preview of your image.                    ${currentIndex + 1} / ${mediaUrls.length}',
            key: const Key('upload_text_image'),
            style: const TextStyle(color: Colors.grey),
          ),
        if (editing && !networkUrls.contains(_imageUrl))
          Text(
            'The above is a preview of your new image.                    ${currentIndex + 1} / ${mediaUrls.length}',
            key: const Key('edit_text_image'),
            style: const TextStyle(color: Colors.grey),
          ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Aligns the button to the right
          children: [
            IconButton(
              key: const Key('deleteImageButton'),
              icon:
                  const Icon(Icons.delete_forever_outlined, color: Colors.red),
              onPressed: _clearImageSelection,
              tooltip: 'Remove Image',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> saveDraft(context) async {
    List<Map<String, String>> mediaList = [];

    for (var item in mediaUrls) {
      String url = item['url']!;
      String mediaType = item['mediaType']!;

      _downloadURL = await _storeData().uploadFile(url);

      Map<String, String> uploadData = {
        'url': _downloadURL!,
        'mediaType': mediaType,
      };

      mediaList.add(uploadData);
    }
    CollectionReference topicDraftsCollectionRef =
        widget.firestore.collection('topicDrafts');

    final draftDetails = {
      'title': titleController.text,
      'description': descriptionController.text,
      'articleLink': articleLinkController.text,
      'media': mediaList,
      'views': 0,
      'likes': 0,
      'dislikes': 0,
      'tags': _tags,
      'categories': _categories,
      'date': DateTime.now(),
      'userID': widget.auth.currentUser?.uid,
    };

    final topicDraftRef = await topicDraftsCollectionRef.add(draftDetails);
    final user = widget.auth.currentUser;
    if (user != null) {
      final userDocRef = widget.firestore.collection('Users').doc(user.uid);
      await userDocRef.update({
        'draftedTopics': FieldValue.arrayUnion([topicDraftRef.id])
      });
    }
    Navigator.pop(context);
  }

  Future<void> deleteMediaFromStorage(String url) async {
    // get reference to the file
    Reference ref = widget.storage.refFromURL(url);

    // Delete the file
    await ref.delete();
  }

  void _clearImageSelection() {
    List<Map<String, dynamic>> oldMediaUrls = [...mediaUrls];
    setState(() {
      if (mediaUrls.length == 1) {
        currentIndex = 0;
      }
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
    List<Map<String, dynamic>> oldMediaUrls = [...mediaUrls];
    setState(() {
      _disposeVideoPlayer();
      if (mediaUrls.length == 1) {
        currentIndex = 0;
      }
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

  void createNewCategoryDialog(context) {
    _newCategoryNameController.clear();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Create a new category"),
            content: TextField(
              controller: _newCategoryNameController,
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (!_categoriesOptions
                          .contains(_newCategoryNameController.text) &&
                      _newCategoryNameController.text.isNotEmpty) {
                    addCategory(_newCategoryNameController.text);
                    getCategoryList();
                    Navigator.of(context).pop();
                  } else {
                    return showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          title: Text('Warning!'),
                          content: Text(
                              "Make sure category names are different/not blank!"),
                        );
                      },
                    );
                  }
                },
                child: const Text("OK"),
              ),
            ],
          );
        });
  }

  Future getCategoryList() async {
    QuerySnapshot data =
        await widget.firestore.collection('categories').orderBy('name').get();

    List<Object> dataList = List.from(data.docs);
    List<String> tempList = [];

    for (dynamic category in dataList) {
      tempList.add(category['name']);
    }

    setState(() {
      _categoriesOptions = tempList;
    });
  }

  void deleteCategoryDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Delete a category"),
              content: SizedBox(
                height: 300,
                width: 200,
                child: ListView.builder(
                  itemCount: _categoriesOptions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_categoriesOptions[index]),
                      onTap: () {
                        deleteCategoryConfirmation(
                            _categoriesOptions[index], context);
                      },
                    );
                  },
                ),
              ),
            );
          });
        });
  }

  Future<void> deleteCategoryConfirmation(String categoryName, context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning!'),
          content: const Text("Are you sure you want to delete?"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                deleteCategory(categoryName);
                _categoriesOptions.remove(categoryName);
                getCategoryList();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteCategory(String categoryName) async {
    QuerySnapshot categoryToDelete = await widget.firestore
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .get();

    QueryDocumentSnapshot category = categoryToDelete.docs[0];
    await widget.firestore.collection('categories').doc(category.id).delete();

    setState(() {
      _categoriesOptions.remove(categoryName);
    });
  }

  Future<void> addCategory(String categoryName) async {
    await widget.firestore.collection('categories').add({'name': categoryName});
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

class CheckmarkAnimationScreen extends StatefulWidget {
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
