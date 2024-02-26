import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:info_hub_app/helpers/reply_card.dart';

class ThreadReplies extends StatefulWidget {
  final String threadId;

  const ThreadReplies({Key? key, required this.threadId}) : super(key: key);

  @override
  State<ThreadReplies> createState() => _ThreadRepliesState();
}

class _ThreadRepliesState extends State<ThreadReplies> {
  late Stream<QuerySnapshot> replyStream;
  late Future<DocumentSnapshot> threadFuture;
  late TextEditingController contentInputController;
  late TextEditingController authorInputController;

  @override
  void initState() {
    super.initState();
    threadFuture = FirebaseFirestore.instance
        .collection("thread")
        .doc(widget.threadId)
        .get();
    replyStream = FirebaseFirestore.instance
        .collection("replies")
        .where('threadId', isEqualTo: widget.threadId)
        .snapshots();
    contentInputController = TextEditingController();
    authorInputController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thread Replies"),
        backgroundColor: Color.fromARGB(255, 0, 48, 194),
        elevation: 4.0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(context),
        child: Icon(FontAwesomeIcons.reply),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: threadFuture,
        builder: (context, threadSnapshot) {
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
                      Text(threadTitle,
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.0),
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
                          firestore: FirebaseFirestore.instance,
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
    bool showErrorAuthor = false;
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
                      key: const Key('Author'),
                      autofocus: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: "Author",
                        errorText:
                            showErrorAuthor ? "Please enter your name" : null,
                      ),
                      controller: authorInputController,
                    ),
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
                    authorInputController.clear();
                    contentInputController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showErrorAuthor = authorInputController.text.isEmpty;
                      showErrorContent = contentInputController.text.isEmpty;
                    });

                    if (!showErrorAuthor && !showErrorContent) {
                      FirebaseFirestore.instance.collection("replies").add({
                        "author": authorInputController.text,
                        "content": contentInputController.text,
                        "threadId": widget.threadId,
                        "timestamp": FieldValue.serverTimestamp(),
                      }).then((response) {
                        authorInputController.clear();
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
