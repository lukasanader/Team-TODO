import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReplyCard extends StatefulWidget {
  //final QuerySnapshot snapshot;
  //final int index;
  final Map<String, dynamic> reply;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final String userProfilePhoto;
  final String authorName;
  final String roleType;

  const ReplyCard({
    super.key,
    //required this.snapshot,
    //required this.index,
    required this.reply,
    required this.firestore,
    required this.auth,
    required this.userProfilePhoto,
    required this.authorName,
    required this.roleType,
  });

  @override
  _ReplyCardState createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  //late DocumentSnapshot replyDoc;
  //late TextEditingController authorController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    //replyDoc = widget.snapshot.docs[widget.index];
    //authorController = TextEditingController();
    contentController = TextEditingController(text: widget.reply['content']);
  }

  @override
  void dispose() {
    //authorController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var docId = widget.reply['id'];
    var content = widget.reply['content'] ?? 'No content provided';
    var isEdited = widget.reply['isEdited'] ?? false;
    var creator = widget.reply['creator'] ?? ' ';
    var currentUserId = widget.auth.currentUser!.uid;
    var timestamp = (widget.reply['timestamp'] as Timestamp?)?.toDate();
    var formatter = timestamp != null
        ? DateFormat("dd-MMM-yyyy 'at' HH:mm").format(timestamp)
        : 'Timestamp not available';

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );

    IconData getRoleIcon(String roleType) {
      switch (roleType) {
        case 'Patient':
          return Icons.local_hospital;
        case 'Healthcare Professional':
          return Icons.medical_services;
        case 'Parent':
          return Icons.family_restroom;
        case 'admin':
          return Icons.admin_panel_settings;
        default:
          return Icons.help_outline;
      }
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ExpansionTileCard(
            //baseColor: Colors.white,
            //expandedColor: Colors.white,
            elevation: 5,
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/${widget.userProfilePhoto}')
                  as ImageProvider<Object>,
            ),
            title: Text(
              widget.authorName,
              key: const Key('authorText_0'),
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              //overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  content,
                  key: const Key('Content'),
                  style: const TextStyle(fontSize: 18),
                  //overflow: TextOverflow.ellipsis,
                  //maxLines: 3,
                ),
                const SizedBox(height: 4),
                Text(
                  formatter,
                  style: const TextStyle(fontSize: 12),
                ),
                if (isEdited)
                  const Text(
                    " (edited)",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 255, 0, 0),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            children: <Widget>[
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                buttonHeight: 52.0,
                buttonMinWidth: 90.0,
                children: <Widget>[
                  if (currentUserId == creator)
                    TextButton(
                      key: const Key('editButton_0'),
                      style: flatButtonStyle,
                      onPressed: () {
                        _showDialog(context, docId);
                      },
                      child: Column(
                        children: <Widget>[
                          const Icon(Icons.edit),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.0),
                          ),
                          Text(
                            'Edit Reply',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        getRoleIcon(widget
                            .roleType), // Determines the icon based on the roleType
                        //size: 24.0,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      widget.roleType == 'Healthcare Professional'
                          ? Column(
                              children: <Widget>[
                                Text(
                                  'Healthcare',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  'Professional',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            )
                          : Text(
                              widget.roleType,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                    ],
                  ),
                  if (currentUserId == creator)
                    TextButton(
                      key: const Key('deleteButton_0'),
                      style: flatButtonStyle,
                      onPressed: () async {
                        if (!mounted) return;
                        await widget.firestore
                            .collection('replies')
                            .doc(docId)
                            .delete();
                      },
                      child: Column(
                        children: <Widget>[
                          const Icon(
                            Icons.delete,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.0),
                          ),
                          Text(
                            'Delete Reply',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 50.0, right: 50.0),
          child: Divider(
            color: Colors.grey,
            height: 1,
          ),
        )
      ],
    );
  }

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
              key: const Key('updateButtonText'),
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  String updatedContent = contentController.text;

                  await widget.firestore
                      .collection('replies')
                      .doc(docId)
                      .update({
                    'content': updatedContent,
                    'timestamp': FieldValue.serverTimestamp(),
                    'isEdited': true,
                  });

                  if (mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  setState(() {
                    showErrorContent = true;
                  });
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
