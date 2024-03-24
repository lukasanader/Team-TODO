import 'package:flutter/material.dart';
import 'package:info_hub_app/controller/topic_question_controller.dart';
import 'package:info_hub_app/model/model.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/ask_question/question_card.dart';
import '../helpers/transitions/checkmark_transition.dart';
import '../model/topic_model.dart';
import '../controllers/form_controller.dart';
import '../controllers/media_upload_controller.dart';
import 'widgets/topic_form_widget.dart';
import 'widgets/add_quiz_widget.dart';
import 'widgets/media_upload_widget.dart';
import 'widgets/media_display_widget.dart';
import 'package:info_hub_app/topics/create_topic/helpers/categories/category_controller.dart';
import 'package:info_hub_app/topics/create_topic/helpers/categories/category_model.dart';

/// View Responsible for Topic creation
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
  Topic? updatedTopicDoc;
  List<String> options = ['Patient', 'Parent', 'Healthcare Professional'];
  String quizID = '';
  bool quizAdded = false;
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
                      MediaDisplayWidget(
                          mediaUploadController: mediaUploadController,
                          screen: this),
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
                                    await Future.delayed(
                                        const Duration(seconds: 2));
                                    await formController.uploadTopic(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Refreshes the screen
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

  Future getCategoryList() async {
    List<Category> categoryList = await CategoryController(widget.firestore).getCategoryList();
    List<String> tempList = [];

    for (Category category in categoryList) {
      tempList.add(category.name.toString());
    }

    categoriesOptions = tempList;
    updateState();
  }
}
