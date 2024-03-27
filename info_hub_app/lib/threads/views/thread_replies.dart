import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:info_hub_app/threads/views/reply_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/controllers/name_generator_controller.dart';
import 'package:info_hub_app/threads/models/thread_model.dart';
import 'package:info_hub_app/threads/models/thread_replies_model.dart';
import 'package:info_hub_app/threads/controllers/thread_controller.dart';

class ThreadReplies extends StatefulWidget {
  final String threadId;
  final String threadTitle;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ThreadReplies({
    super.key,
    required this.threadId,
    required this.threadTitle,
    required this.firestore,
    required this.auth,
  });

  @override
  State<ThreadReplies> createState() => _ThreadRepliesState();
}

class _ThreadRepliesState extends State<ThreadReplies> {
  final ThreadController threadController;
  late TextEditingController contentInputController;
  List<Reply> localReplies = [];
  bool _isAddingReply = false;

  _ThreadRepliesState()
      : threadController = ThreadController(
            firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance);

  @override
  void initState() {
    super.initState();
    contentInputController = TextEditingController();
    threadController.getReplies(widget.threadId).listen((snapshot) {
      setState(() {
        localReplies = snapshot.docs
            .map((doc) =>
                Reply.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    contentInputController.dispose();
    super.dispose();
  }

  void _addReplyToLocalList(String content, String creatorId) async {
    if (_isAddingReply || content.isEmpty) return;
    if (mounted) {
      setState(() {
        _isAddingReply = true;
      });
    }

    String authorName = generateUniqueName(creatorId);
    String userProfilePhoto =
        await threadController.getUserProfilePhoto(creatorId);
    String tempReplyId = DateTime.now().millisecondsSinceEpoch.toString();
    String roleType = await threadController.getUserRoleType(creatorId);

    Reply newReply = Reply(
      id: tempReplyId,
      content: content,
      creator: creatorId,
      authorName: authorName,
      timestamp: DateTime.now(),
      isEdited: false,
      userProfilePhoto: userProfilePhoto,
      threadId: widget.threadId,
      threadTitle: widget.threadTitle,
      roleType: roleType,
    );

    setState(() => localReplies.add(newReply));

    threadController.addReply(newReply).then((docRef) {
      int index = localReplies.indexWhere((r) => r.id == tempReplyId);
      if (index != -1) {
        setState(() {
          localReplies[index].id = docRef.id;
        });
      }
    }).whenComplete(() => setState(() => _isAddingReply = false));
  }

  void _showDialog(BuildContext context) async {
    bool showErrorContent = false;

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
                    const Text("Please enter your reply"),
                    TextField(
                      key: const Key('Content'),
                      autofocus: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: "Reply Content",
                        errorText:
                            showErrorContent ? "Please enter a reply" : null,
                      ),
                      controller: contentInputController,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    contentInputController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (!_isAddingReply &&
                        contentInputController.text.isNotEmpty) {
                      String docId = threadController.getCurrentUserId();
                      _addReplyToLocalList(contentInputController.text, docId);
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        showErrorContent = true;
                      });
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => contentInputController.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(context),
        child: const Icon(FontAwesomeIcons.reply),
      ),
      body: FutureBuilder<Thread>(
        future: threadController.getThreadDocument(widget.threadId),
        builder: (context, AsyncSnapshot<Thread> threadSnapshot) {
          if (!threadSnapshot.hasData) return const CircularProgressIndicator();
          Thread thread = threadSnapshot.data!;
          var threadTitle = thread.title;
          var threadDescription = thread.description;
          var threadAuthor = thread.authorName;
          var threadTimestamp = thread.timestamp;
          String formattedDate = threadController.formatDate(threadTimestamp);

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    side: const BorderSide(color: Colors.grey, width: 1.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              threadTitle,
                              style: const TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(threadDescription,
                          style: const TextStyle(fontSize: 16.0)),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("By $threadAuthor",
                              style: const TextStyle(
                                  fontSize: 14.0, fontStyle: FontStyle.italic)),
                          Text(formattedDate,
                              style: const TextStyle(fontSize: 14.0)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: localReplies.length,
                  itemBuilder: (context, index) {
                    var reply = localReplies[index];
                    return ReplyCard(
                      reply: reply,
                      controller: threadController,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}