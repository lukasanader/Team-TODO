import 'dart:io';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/controller/topic_question_controller.dart';
import 'package:info_hub_app/model/model.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:info_hub_app/topics/create_topic/helpers/quiz/create_quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/ask_question/question_card.dart';
import '../helpers/transitions/checkmark_transition.dart';
import '../model/topic_model.dart';
import '../controllers/form_controller.dart';
import '../controllers/media_upload_controller.dart';

class CreateTopicScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  Topic? topic;
  Topic? draft;
  final FirebaseAuth auth;
  List<PlatformFile>? selectedFiles;
  final ThemeManager themeManager;

  CreateTopicScreen({
    Key? key,
    required this.firestore,
    required this.storage,
    this.topic,
    this.draft,
    this.selectedFiles,
    required this.auth,
    required this.themeManager,
  }) : super(key: key);

  @override
  State<CreateTopicScreen> createState() => CreateTopicScreenState();
}

class CreateTopicScreenState extends State<CreateTopicScreen> {
  late GlobalKey<FormState> topicFormKey = GlobalKey<FormState>();
  int currentIndex = 0;
  List<dynamic> questions = [];
  late Topic? updatedTopicDoc;
  List<String> options = ['Patient', 'Parent', 'Healthcare Professional'];
  String quizID = '';
  bool quizAdded = false;
  List<String> _categoriesOptions = [];
  final TextEditingController _newCategoryNameController =
      TextEditingController();

  String? downloadURL;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  late FormController formController;
  late MediaUploadController mediaUploadController;
  bool editing = false;
  bool drafting = false;

  @override
  void dispose() {
    super.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCategoryList();
  }

  @override
  void initState() {
    super.initState();
    formController = FormController(
        widget.auth, widget.firestore, widget.topic, widget.draft, this, null);
    formController.initializeData();

    mediaUploadController = MediaUploadController(
        widget.auth, widget.firestore, widget.storage, formController, this);
    mediaUploadController.initializeData();

    formController.mediaUploadController = mediaUploadController;
    editing = formController.editing;
    drafting = formController.drafting;
    updatedTopicDoc = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(
              formController.appBarTitle,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              if (!editing && !drafting)
                TextButton(
                  key: const Key('draft_btn'),
                  onPressed: () async {
                    await formController.uploadTopic(context, true);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Save Draft',
                    style: TextStyle(color: Colors.white),
                  ),
                )
            ]),
        body: Form(
          key: topicFormKey,
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
                          value: formController.tags,
                          onChanged: (val) =>
                              setState(() => formController.tags = val),
                          choiceItems: C2Choice.listFrom<String, String>(
                            source: options,
                            value: (i, v) => v,
                            label: (i, v) => v,
                          ),
                          choiceCheckmark: true,
                          choiceStyle: C2ChipStyle.outlined(),
                        ),
                      ),
                      if (formController.tags.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Please select at least one tag.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      TextFormField(
                        key: const Key('titleField'),
                        controller: formController.titleController,
                        maxLength: 70,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          prefixIcon:
                              Icon(Icons.drive_file_rename_outline_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: formController.validateTitle,
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
                                  value: formController.categories,
                                  onChanged: (val) => setState(
                                      () => formController.categories = val),
                                  choiceItems:
                                      C2Choice.listFrom<String, String>(
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
                        controller: formController.descriptionController,
                        maxLines: 5, // Reduced maxLines
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          prefixIcon: Icon(Icons.description_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: formController.validateDescription,
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        key: const Key('linkField'),
                        controller: formController.articleLinkController,
                        decoration: const InputDecoration(
                          labelText: 'Link article',
                          prefixIcon: Icon(Icons.link_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: formController.validateArticleLink,
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
                                    auth: widget.auth,
                                    addQuiz: addQuiz,
                                    isEdit: editing,
                                    topic: widget.topic,
                                  ),
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
                              if (mediaUploadController.videoURL != null ||
                                  mediaUploadController.imageURL != null) {
                                mediaUploadController.changingMedia = true;
                              }
                              if (mediaUploadController.videoURL == null &&
                                  mediaUploadController.imageURL == null) {
                                mediaUploadController.changingMedia = false;
                              }
                              _showMediaUploadOptions(context);
                            },
                            icon: const Icon(
                              Icons.cloud_upload_outlined,
                            ),
                            label: mediaUploadController.videoURL != null ||
                                    mediaUploadController.imageURL != null
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
                          if (mediaUploadController.videoURL != null ||
                              mediaUploadController.imageURL != null)
                            ElevatedButton.icon(
                              key: const Key('moreMediaButton'),
                              onPressed: () {
                                mediaUploadController.changingMedia = false;
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
                      if (mediaUploadController.videoURL != null &&
                          _chewieController != null)
                        _videoPreviewWidget(),
                      if (mediaUploadController.imageURL != null)
                        _imagePreviewWidget(),
                      if (mediaUploadController.videoURL != null ||
                          mediaUploadController.imageURL != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (mediaUploadController.mediaUrls.length > 1)
                              IconButton(
                                key: const Key('previousMediaButton'),
                                icon: const Icon(
                                    Icons.arrow_circle_left_rounded,
                                    color: Color.fromRGBO(150, 100, 200, 1.0)),
                                onPressed: () async {
                                  if (currentIndex - 1 >= 0) {
                                    currentIndex -= 1;
                                    if (mediaUploadController
                                                .mediaUrls[currentIndex]
                                            ['mediaType'] ==
                                        'video') {
                                      mediaUploadController.videoURL =
                                          mediaUploadController
                                              .mediaUrls[currentIndex]['url'];
                                      mediaUploadController.imageURL = null;
                                      setState(() {});
                                      await initializeVideoPlayer();

                                      setState(() {});
                                    } else if (mediaUploadController
                                                .mediaUrls[currentIndex]
                                            ['mediaType'] ==
                                        'image') {
                                      mediaUploadController.imageURL =
                                          mediaUploadController
                                              .mediaUrls[currentIndex]['url'];
                                      mediaUploadController.videoURL = null;
                                      setState(() {});
                                      await initializeImage();
                                    }
                                  }
                                },
                                tooltip: 'Previous Video',
                              ),
                            if (mediaUploadController.mediaUrls.length > 1)
                              IconButton(
                                key: const Key('nextMediaButton'),
                                icon: const Icon(
                                    Icons.arrow_circle_right_rounded,
                                    color: Color.fromRGBO(150, 100, 200, 1.0)),
                                onPressed: () async {
                                  if (currentIndex + 1 <
                                      mediaUploadController.mediaUrls.length) {
                                    currentIndex += 1;
                                    if (mediaUploadController
                                                .mediaUrls[currentIndex]
                                            ['mediaType'] ==
                                        'video') {
                                      mediaUploadController.videoURL =
                                          mediaUploadController
                                              .mediaUrls[currentIndex]['url'];
                                      mediaUploadController.imageURL = null;
                                      setState(() {});
                                      await initializeVideoPlayer();
                                      setState(() {});
                                    } else if (mediaUploadController
                                                .mediaUrls[currentIndex]
                                            ['mediaType'] ==
                                        'image') {
                                      mediaUploadController.imageURL =
                                          mediaUploadController
                                              .mediaUrls[currentIndex]['url'];
                                      mediaUploadController.videoURL = null;
                                      setState(() {});
                                      await initializeImage();
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
                          if (topicFormKey.currentState!.validate() &&
                              formController.tags.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CheckmarkAnimationScreen(),
                              ),
                            );
                            await Future.delayed(const Duration(seconds: 2));
                            await formController.uploadTopic(context, false);
                            Navigator.pop(context);
                            if (drafting) {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            } else if (editing) {
                              Navigator.pop(context, updatedTopicDoc);
                            } else {
                              Navigator.pop(context);
                            }

                            await _showDeleteQuestionDialog(
                                context, formController.titleController.text);
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
      ),
    );
  }

  void updateState() {
    setState(() {});
  }

  Future<void> _showDeleteQuestionDialog(
      BuildContext context, String title) async {
    final controller =
        TopicQuestionController(firestore: widget.firestore, auth: widget.auth);
    List<TopicQuestion> questions =
        await controller.getRelevantQuestions(title);
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
                              questions[index], widget.firestore, () async {
                            List<TopicQuestion> updatedQuestions =
                                await controller.getRelevantQuestions(title);
                            setState(() {
                              questions = updatedQuestions;
                            });
                          }, widget.auth);
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
                                      controller.deleteAllQuestions(questions);
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
                mediaUploadController.pickFromDevice("image");
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Upload Video'),
              onTap: () {
                Navigator.pop(context);
                mediaUploadController.pickFromDevice("video");
              },
            ),
          ],
        );
      },
    );
    return;
  }

  Future<void> initializeVideoPlayer() async {
    disposeVideoPlayer();
    if (mediaUploadController.videoURL != null &&
        mediaUploadController.videoURL!.isNotEmpty) {
      if (!mediaUploadController.networkUrls
          .contains(mediaUploadController.videoURL)) {
        _videoController =
            VideoPlayerController.file(File(mediaUploadController.videoURL!));
      } else {
        _videoController = VideoPlayerController.networkUrl(
            Uri.parse(mediaUploadController.videoURL!));
      }

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoInitialize: true,
        looping: false,
        aspectRatio: 16 / 9,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        allowedScreenSleep: false,
      );
      setState(() {});
    }
  }

  void disposeVideoPlayer() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;

    _chewieController?.pause();
    _chewieController?.dispose();
    _chewieController = null;
  }

  Future<void> initializeImage() async {
    if (mediaUploadController.imageURL != null &&
        mediaUploadController.imageURL!.isNotEmpty) {
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
          if (!editing ||
              mediaUploadController.networkUrls
                  .contains(mediaUploadController.videoURL))
            Text(
              'The above is a preview of your video.       ${currentIndex + 1} / ${mediaUploadController.mediaUrls.length}',
              key: const Key('upload_text_video'),
              style: const TextStyle(color: Colors.grey),
            ),
          if (editing &&
              !mediaUploadController.networkUrls
                  .contains(mediaUploadController.videoURL))
            Text(
              'The above is a preview of your new video.    ${currentIndex + 1} / ${mediaUploadController.mediaUrls.length}',
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
                onPressed: mediaUploadController.clearSelection,
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
        if (!mediaUploadController.networkUrls
            .contains(mediaUploadController.imageURL))
          Image.file(File(mediaUploadController.imageURL!)),
        if (mediaUploadController.networkUrls
            .contains(mediaUploadController.imageURL))
          Image.network((mediaUploadController.imageURL!)),
        if (!editing ||
            mediaUploadController.networkUrls
                .contains(mediaUploadController.imageURL))
          Text(
            'The above is a preview of your image.          ${currentIndex + 1} / ${mediaUploadController.mediaUrls.length}',
            key: const Key('upload_text_image'),
            style: const TextStyle(color: Colors.grey),
          ),
        if (editing &&
            !mediaUploadController.networkUrls
                .contains(mediaUploadController.imageURL))
          Text(
            'The above is a preview of your new image.        ${currentIndex + 1} / ${mediaUploadController.mediaUrls.length}',
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
              onPressed: mediaUploadController.clearSelection,
              tooltip: 'Remove Image',
            ),
          ],
        ),
      ],
    );
  }

  void addQuiz(String qid) {
    setState(() {
      quizID = qid;
      quizAdded = true;
    });
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
