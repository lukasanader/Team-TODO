import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:info_hub_app/threads/reply_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/name_generator.dart';

class ThreadReplies extends StatefulWidget {
  final String threadId;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ThreadReplies({
    Key? key,
    required this.threadId,
    required this.firestore,
    required this.auth,
  }) : super(key: key);

  @override
  State<ThreadReplies> createState() => _ThreadRepliesState();
}

class _ThreadRepliesState extends State<ThreadReplies> {
  late Stream<QuerySnapshot> replyStream;
  late Future<DocumentSnapshot> threadFuture;
  late TextEditingController contentInputController;
  List<Map<String, dynamic>> localReplies = [];
  bool _isAddingReply =
      false; // Declare the variable to track if a reply is being added

  @override
  void initState() {
    super.initState();
    threadFuture =
        widget.firestore.collection("thread").doc(widget.threadId).get();
    replyStream = widget.firestore
        .collection("replies")
        .where('threadId', isEqualTo: widget.threadId)
        .snapshots();
    contentInputController = TextEditingController();

    replyStream.listen((snapshot) {
      setState(() {
        localReplies = snapshot.docs
            .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
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

    DocumentSnapshot threadDoc =
        await widget.firestore.collection('thread').doc(widget.threadId).get();
    String threadTitle = threadDoc['title'] ?? 'No Title';

    DocumentSnapshot userDoc =
        await widget.firestore.collection('Users').doc(creatorId).get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    String authorName = generateUniqueName(creatorId) ?? 'Anonymous';
    String userProfilePhoto =
        userData['selectedProfilePhoto'] ?? 'default_profile_photo.png';

    String tempReplyId = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, dynamic> newReply = {
      "id": tempReplyId,
      "author": authorName,
      "content": content,
      "creator": creatorId,
      "userProfilePhoto": userProfilePhoto,
      "threadId": widget.threadId,
      "threadTitle": threadTitle,
      "timestamp": DateTime.now(),
      "isEdited": false,
      "roleType": userData['roleType'],
    };

    setState(() => localReplies.add(newReply));
    //localReplies.add(newReply);

    widget.firestore.collection("replies").add(newReply).then((docRef) {
      int index = localReplies.indexWhere((r) => r["id"] == tempReplyId);
      if (index != -1) {
        setState(() {
          localReplies[index]['id'] = docRef.id;
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
                    const Text("Please fill out the form"),
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
                      String docId = widget.auth.currentUser!.uid;
                      String authorName = generateUniqueName(docId);
                      _addReplyToLocalList(contentInputController.text, docId);
                      //contentInputController.clear();
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
        child: Icon(FontAwesomeIcons.reply),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: threadFuture,
        builder: (context, AsyncSnapshot<DocumentSnapshot> threadSnapshot) {
          if (!threadSnapshot.hasData) return CircularProgressIndicator();
          var threadData = threadSnapshot.data!.data() as Map<String, dynamic>;
          var threadTitle = threadData['title'] ?? 'No Title';
          var threadDescription = threadData['description'] ?? 'No Description';
          var threadAuthor = threadData['author'] ?? 'Anonymous';
          var threadTimestamp = threadData['timestamp']?.toDate();
          var formattedDate = threadTimestamp != null
              ? DateFormat("dd-MMM-yyyy 'at' HH:mm").format(threadTimestamp)
              : 'Date Unknown';

          return Column(
            children: [
              Card(
                margin: EdgeInsets.all(8.0),
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        6.0), // Adjust border radius if needed
                    side: BorderSide(color: Colors.grey, width: 1.0)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              threadTitle,
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(threadDescription, style: TextStyle(fontSize: 16.0)),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("By $threadAuthor",
                              style: TextStyle(
                                  fontSize: 14.0, fontStyle: FontStyle.italic)),
                          Text(formattedDate, style: TextStyle(fontSize: 14.0)),
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
                      firestore: widget.firestore,
                      auth: widget.auth,
                      userProfilePhoto: reply['userProfilePhoto'] ??
                          'default_profile_photo.png',
                      authorName: reply['author'] ?? 'Anonymous',
                      roleType: reply['roleType'] ?? 'Missing Role Type',
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
