// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:info_hub_app/controller/create_topic_controllers/topic_question_controller.dart';
import 'package:info_hub_app/model/topic_models/topic_question_model.dart';
import 'package:info_hub_app/controller/notification_controllers/notification_controller.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/view/ask_question_view/question_card.dart';
import 'transitions/checkmark_transition.dart';
import '../../model/topic_models/topic_model.dart';
import '../../controller/create_topic_controllers/form_controller.dart';
import '../../controller/create_topic_controllers/media_upload_controller.dart';
import 'widgets/topic_form_widget.dart';
import 'widgets/add_quiz_widget.dart';
import 'widgets/media_upload_widget.dart';
import 'widgets/media_display_widget.dart';
import 'package:info_hub_app/view/topic_creation_view/categories/category_controller.dart';
import 'package:info_hub_app/view/topic_creation_view/categories/category_model.dart';

/// View Responsible for Topic creation
class TopicCreationView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final Topic? topic;
  final Topic? draft;
  final FirebaseAuth auth;
  final List<PlatformFile>? selectedFiles;
  final ThemeManager themeManager;

  const TopicCreationView({
    super.key,
    required this.firestore,
    required this.storage,
    this.topic,
    this.draft,
    this.selectedFiles,
    required this.auth,
    required this.themeManager,
  });

  @override
  State<TopicCreationView> createState() => TopicCreationViewState();
}

class TopicCreationViewState extends State<TopicCreationView> {
  late GlobalKey<FormState> topicFormKey = GlobalKey<FormState>();
  int currentIndex = 0;
  List<dynamic> questions = [];
  Topic? updatedTopicDoc;
  List<String> options = ['Patient', 'Parent', 'Healthcare Professional'];
  String quizID = '';
  bool quizAdded = false;
  Topic? topic;
  List<String> categoriesOptions = [];

  final TextEditingController newCategoryNameController =
      TextEditingController();

  late FormController formController;
  late MediaUploadController mediaUploadController;
  bool editing = false;
  bool drafting = false;

  @override
  void dispose() {
    super.dispose();
    // Dispose video controllers
    mediaUploadController.videoController?.dispose();
    mediaUploadController.chewieController?.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCategoryList();
  }

  @override
  void initState() {
    super.initState();
    updatedTopicDoc = null;
    // Initialize form and media upload controllers
    formController = FormController(
        widget.auth, widget.firestore, widget.topic, widget.draft, this, null);
    formController.initializeData();

    mediaUploadController = MediaUploadController(
        widget.auth, widget.firestore, widget.storage, formController, this);
    mediaUploadController.initializeData();

    formController.mediaUploadController = mediaUploadController;
    editing = formController.editing;
    drafting = formController.drafting;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(
              formController.appBarTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: <Widget>[
              // Save as draft button (visible only when not editing or publishing a draft)
              if (!editing && !drafting)
                TextButton(
                  key: const Key('draft_btn'),
                  onPressed: () async {
                    if (formController.validateTitleResult(
                        formController.titleController.text)) {
                      await formController.uploadTopic(context, true);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please provide a title for your draft.'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save Draft',
                  ),
                )
              else if (drafting)
                TextButton(
                  key: const Key('delete_draft_btn'),
                  onPressed: () async {
                    formController.deleteDraft(false);
                    updateState();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Delete this draft',
                  ),
                )
            ]),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: topicFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TopicFormWidget(
                        formController: formController,
                        screen: this,
                        firestore: widget.firestore,
                      ),
                      const SizedBox(height: 10.0),
                      AddQuizWidget(screen: this),
                      const SizedBox(height: 10.0),
                      MediaUploadWidget(
                          mediaUploadController: mediaUploadController),
                      const SizedBox(height: 10.0),
                      // Shows preview of selected media
                      MediaDisplayWidget(
                          mediaUploadController: mediaUploadController,
                          screen: this),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(),
                                onPressed: () async {
                                  // Check if the form's current state is valid and Publish the topic
                                  if (topicFormKey.currentState!.validate() &&
                                      formController.tags.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CheckmarkAnimationScreen(),
                                      ),
                                    );
                                    await Future.delayed(
                                        const Duration(seconds: 2));
                                    topic = await formController.uploadTopic(
                                        context, false);
                                    Navigator.pop(context);
                                    if (drafting) {
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
                                    } else if (editing) {
                                      Navigator.pop(context, updatedTopicDoc);
                                    } else {
                                      Navigator.pop(context);
                                    }

                                    await _showDeleteQuestionDialog(context,
                                        formController.titleController.text);
                                  }
                                },
                                child: Text(
                                  editing ? "UPDATE TOPIC" : "PUBLISH TOPIC",
                                  style: const TextStyle(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Refreshes the screen
  void updateState() {
    setState(() {});
  }

  /// Shows questions related to topic and allows for their deletion
  Future<void> _showDeleteQuestionDialog(
      BuildContext context, String title) async {
    final controller =
        TopicQuestionController(firestore: widget.firestore, auth: widget.auth);
    List<TopicQuestion> questions =
        await controller.getRelevantQuestions(title);
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
                            NotificationController(
                                    auth: widget.auth,
                                    firestore: widget.firestore,
                                    uid: questions[index].uid)
                                .createNotification(
                                    'Question Reply',
                                    'A topic has been created in response to your question.',
                                    DateTime.now(),
                                    '/topic',
                                    topic!.id);
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
                                      for (int i = 0;
                                          i < questions.length;
                                          i++) {
                                        NotificationController(
                                                auth: widget.auth,
                                                firestore: widget.firestore,
                                                uid: questions[i].uid)
                                            .createNotification(
                                                'Question Reply',
                                                'A topic has been created in response to your question.',
                                                DateTime.now(),
                                                '/topic',
                                                topic!.id);
                                      }
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

  /// Retreieve the list of categories
  Future getCategoryList() async {
    List<Category> categoryList =
        await CategoryController(widget.firestore).getCategoryList();

    List<String> tempList = [];

    for (Category category in categoryList) {
      tempList.add(category.name.toString());
    }

    categoriesOptions = tempList;
    updateState();
  }
}
