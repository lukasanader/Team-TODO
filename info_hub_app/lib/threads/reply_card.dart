import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/name_generator.dart';

class ReplyCard extends StatefulWidget {
  final QuerySnapshot snapshot;
  final int index;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final String userProfilePhoto;

  const ReplyCard({
    Key? key,
    required this.snapshot,
    required this.index,
    required this.firestore,
    required this.auth,
    required this.userProfilePhoto,
  }) : super(key: key);

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  late DocumentSnapshot replyDoc;
  //late TextEditingController authorController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    replyDoc = widget.snapshot.docs[widget.index];
    //authorController = TextEditingController();
    contentController = TextEditingController();
  }

  @override
  void dispose() {
    //authorController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var docData = replyDoc.data() as Map<String, dynamic>;
    var docId = replyDoc.id;

    //var author = docData['author'] ?? 'Anonymous';
    var content = docData['content'] ?? 'No content provided';
    var creator = docData['creator'] ?? 'Anonymous';
    var currentUserId = widget.auth.currentUser!.uid;
    var timestamp = docData['timestamp']?.toDate();
    var formatter = timestamp != null
        ? DateFormat("dd-MMM-yyyy 'at' HH:mm").format(timestamp)
        : 'Timestamp not available';
    var authorName = generateUniqueName(creator);

    return Column(
      children: <Widget>[
        SizedBox(
          height: 140,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 5,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: widget.userProfilePhoto.startsWith('http')
                    ? NetworkImage(widget.userProfilePhoto)
                        as ImageProvider<Object>
                    : AssetImage('assets/${widget.userProfilePhoto}')
                        as ImageProvider<Object>,
              ),
              title: Text(
                authorName,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    content,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                  SizedBox(height: 4),
                  Text(
                    formatter,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Color.fromARGB(255, 255, 0, 0),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentUserId == creator)
                    IconButton(
                      key: Key('editButton_$docId'),
                      icon: Icon(FontAwesomeIcons.edit, size: 15),
                      onPressed: () {
                        _showDialog(context, docId);
                      },
                    ),
                  if (currentUserId == creator)
                    IconButton(
                      key: Key('deleteButton_$docId'),
                      icon: Icon(FontAwesomeIcons.trash, size: 15),
                      onPressed: () async {
                        if (!mounted) return;
                        await widget.firestore
                            .collection('replies')
                            .doc(docId)
                            .delete();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

/*
  void _showDialog(BuildContext context, String docId) async {
    //bool showErrorAuthor = false;
    bool showErrorContent = false;

    var docSnapshot =
        await widget.firestore.collection('replies').doc(docId).get();
    var docData = docSnapshot.data() as Map<String, dynamic>;

    if (!mounted) return;

    //authorController.text = docData['author'] ?? '';
    contentController.text = docData['content'] ?? '';

    void _showDialog(BuildContext context, String docId) async {
      bool showErrorContent = false;

      var docSnapshot =
          await widget.firestore.collection('replies').doc(docId).get();
      var docData = docSnapshot.data() as Map<String, dynamic>;

      if (!mounted) return;

      contentController.text = docData['content'] ?? '';

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(12.0),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Edit your reply"),
                  TextField(
                    key: const Key('Content'),
                    autofocus: true,
                    autocorrect: true,
                    decoration: InputDecoration(
                      labelText: "Content",
                      errorText:
                          showErrorContent ? "Please enter content" : null,
                    ),
                    controller: contentController,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                key: Key('cancelButton'),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (contentController.text.isNotEmpty) {
                    String updatedContent = contentController.text;
                    if (!updatedContent.endsWith("(edited)")) {
                      updatedContent += " (edited)";
                    }
                    await widget.firestore
                        .collection('replies')
                        .doc(docId)
                        .update({
                      'content': updatedContent,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                  } else {
                    showErrorContent = contentController.text.isEmpty;
                    setState(() {});
                  }
                },
                child: Text('Save'),
              ),
            ],
          );
          
        },
      );
    }
  }
  */

  void _showDialog(BuildContext context, String docId) async {
    bool showErrorContent = false;

    var docSnapshot =
        await widget.firestore.collection('replies').doc(docId).get();
    var docData = docSnapshot.data() as Map<String, dynamic>;

    if (!mounted) return;

    contentController.text = docData['content'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(12.0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text("Edit your reply"),
                TextField(
                  key: const Key('Content'),
                  autofocus: true,
                  autocorrect: true,
                  decoration: InputDecoration(
                    labelText: "Content",
                    errorText: showErrorContent ? "Please enter content" : null,
                  ),
                  controller: contentController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('cancelButton'),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  String updatedContent = contentController.text;
                  if (!updatedContent.endsWith("(edited)")) {
                    updatedContent += " (edited)";
                  }
                  await widget.firestore
                      .collection('replies')
                      .doc(docId)
                      .update({
                    'content': updatedContent,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                } else {
                  showErrorContent = true;
                  setState(() {});
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
