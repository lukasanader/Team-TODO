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
  //late TextEditingController authorInputController;

  @override
  void initState() {
    super.initState();
    threadFuture =
        widget.firestore.collection("thread").doc(widget.threadId).get();
    replyStream = widget.firestore
        .collection("replies")
        .where('threadId', isEqualTo: widget.threadId)
        //.orderBy('timestamp', descending: false)
        .snapshots();
    contentInputController = TextEditingController();
    //authorInputController = TextEditingController();
  }

  @override
  void dispose() {
    contentInputController.dispose();
    //authorInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(context),
        child: Icon(FontAwesomeIcons.reply),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: widget.firestore
            .collection("thread")
            .doc(widget.threadId)
            .snapshots(),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: replyStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return ReplyCard(
                          snapshot: snapshot.data!,
                          index: index,
                          firestore: widget
                              .firestore, // Use the passed firestore instance
                          auth: widget.auth,
                        );
                      },
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

  void _showDialog(BuildContext context) async {
    //bool showErrorAuthor = false;
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
                    /*TextField(
                      key: const Key('Author'),
                      autofocus: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: "Author",
                        errorText:
                            showErrorAuthor ? "Please enter your name" : null,
                      ),
                      controller: authorInputController,
                    ),*/
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
                    //authorInputController.clear();
                    contentInputController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      //showErrorAuthor = authorInputController.text.isEmpty;
                      showErrorContent = contentInputController.text.isEmpty;
                    });

                    if ( //!showErrorAuthor &&
                        !showErrorContent) {
                      String docId = widget.auth.currentUser!
                          .uid; // Use the passed auth instance
                      String authorName = generateUniqueName(docId);

                      widget.firestore.collection("replies").add({
                        // Use the passed firestore instance
                        "author": authorName,
                        "content": contentInputController.text,
                        "threadId": widget.threadId,
                        "timestamp": FieldValue.serverTimestamp(),
                        "creator": docId,
                      }).then((response) {
                        //authorInputController.clear();
                        contentInputController.clear();
                        Navigator.pop(context);
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
    );
  }
}
