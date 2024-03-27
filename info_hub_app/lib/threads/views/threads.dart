import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:info_hub_app/threads/views/custom_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/controllers/name_generator_controller.dart';
import 'package:info_hub_app/threads/models/thread_model.dart';
import 'package:info_hub_app/threads/controllers/thread_controller.dart';

class ThreadApp extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final String topicId;
  final String topicTitle;

  const ThreadApp({
    super.key,
    required this.firestore,
    required this.auth,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  _ThreadAppState createState() => _ThreadAppState();
}

class _ThreadAppState extends State<ThreadApp> {
  late ThreadController controller;
  late TextEditingController titleInputController;
  late TextEditingController descriptionInputController;

  @override
  void initState() {
    super.initState();
    controller =
        ThreadController(firestore: widget.firestore, auth: widget.auth);
    titleInputController = TextEditingController();
    descriptionInputController = TextEditingController();
  }

  void refreshData() {
    setState(() {
      controller =
          ThreadController(firestore: widget.firestore, auth: widget.auth);
    });
  }

  @override
  void dispose() {
    titleInputController.dispose();
    descriptionInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topicTitle,
          style: const TextStyle(
            fontSize: 20.0,
          ),
        ),
        elevation: 4.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: Container(),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(0),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog(context);
        },
        child: const Icon(FontAwesomeIcons.questionCircle),
      ),
      body: StreamBuilder<List<Thread>>(
        stream: controller.getThreadListStream(widget.topicId),
        builder: (context, AsyncSnapshot<List<Thread>> snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          List<Thread> threads = snapshot.data!;

          return ListView.builder(
            itemCount: threads.length,
            itemBuilder: (context, int index) {
              Thread thread = threads[index];

              return CustomCard(
                key: ObjectKey(thread.id),
                index: index,
                thread: thread,
                threadId: thread.id,
                controller: controller,
              );
            },
          );
        },
      ),
    );
  }

  _showDialog(BuildContext context) async {
    bool showErrorTitle = false;
    bool showErrorDescription = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(12.0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text("Please fill out the form"),
                    TextField(
                      key: const Key('Title'),
                      autofocus: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: "Title",
                        errorText:
                            showErrorTitle && titleInputController.text.isEmpty
                                ? "Please enter a title"
                                : null,
                      ),
                      controller: titleInputController,
                    ),
                    TextField(
                      key: const Key('Description'),
                      autofocus: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: "Description",
                        errorText: showErrorDescription &&
                                descriptionInputController.text.isEmpty
                            ? "Please enter a description"
                            : null,
                      ),
                      controller: descriptionInputController,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    titleInputController.clear();
                    descriptionInputController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      showErrorTitle = titleInputController.text.isEmpty;
                      showErrorDescription =
                          descriptionInputController.text.isEmpty;
                    });

                    if (!showErrorTitle && !showErrorDescription) {
                      String docId = controller.getCurrentUserId();
                      String userProfilePhoto =
                          await controller.getUserProfilePhoto(docId);
                      String roleType = await controller.getUserRoleType(docId);
                      String authorName = generateUniqueName(docId);

                      Thread newThread = Thread(
                        id: '',
                        title: titleInputController.text,
                        description: descriptionInputController.text,
                        creator: docId,
                        authorName: authorName,
                        timestamp: DateTime.now(),
                        isEdited: false,
                        roleType: roleType,
                        userProfilePhoto: userProfilePhoto,
                        topicId: widget.topicId,
                        topicTitle: widget.topicTitle,
                      );

                      await controller.addThread(newThread);

                      titleInputController.clear();
                      descriptionInputController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
