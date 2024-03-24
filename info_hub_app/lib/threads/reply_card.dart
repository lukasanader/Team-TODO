/*

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

  const ReplyCard({
    Key? key,
    required this.snapshot,
    required this.index,
    required this.firestore,
    required this.auth,
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
                child: Text(authorName[0].toUpperCase()),
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

  void _showDialog(BuildContext context, String docId) async {
    //bool showErrorAuthor = false;
    bool showErrorContent = false;

    var docSnapshot =
        await widget.firestore.collection('replies').doc(docId).get();
    var docData = docSnapshot.data() as Map<String, dynamic>;

    if (!mounted) return;

    //authorController.text = docData['author'] ?? '';
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
                /*TextField(
                  autofocus: true,
                  autocorrect: true,
                  decoration: InputDecoration(
                    labelText: "Author",
                    errorText:
                        showErrorAuthor ? "Please enter your name" : null,
                  ),
                  controller: authorController,
                ),*/
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
              key: Key('cancelButton'),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  await widget.firestore
                      .collection('replies')
                      .doc(docId)
                      .update({
                    //'author': authorController.text,
                    'content': contentController.text,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                } else {
                  //showErrorAuthor = authorController.text.isEmpty;
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

import 'package:chewie/chewie.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/name_generator.dart';

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
    Key? key,
    //required this.snapshot,
    //required this.index,
    required this.reply,
    required this.firestore,
    required this.auth,
    required this.userProfilePhoto,
    required this.authorName,
    required this.roleType,
  }) : super(key: key);

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
    /*
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
*/
    var docId = widget.reply['id'];
    var content = widget.reply['content'] ?? 'No content provided';
    var isEdited = widget.reply['isEdited'] ?? false;
    var creator = widget.reply['creator'] ?? ' ';
    var currentUserId = widget.auth.currentUser!.uid;
    var timestamp = (widget.reply['timestamp'] as Timestamp?)?.toDate();
    var formatter = timestamp != null
        ? DateFormat("dd-MMM-yyyy 'at' HH:mm").format(timestamp)
        : 'Timestamp not available';

    /*
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
                /*
                backgroundImage: widget.userProfilePhoto.startsWith('http')
                    ? NetworkImage(widget.userProfilePhoto)
                        as ImageProvider<Object>
                    : AssetImage('assets/${widget.userProfilePhoto}')
                        as ImageProvider<Object>, */
                backgroundImage: widget.userProfilePhoto.startsWith('http')
                    ? NetworkImage(widget.userProfilePhoto)
                        as ImageProvider<Object>
                    : AssetImage('assets/${widget.userProfilePhoto}')
                        as ImageProvider<Object>,
              ),
              title: Text(
                widget.authorName,
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
                  if (isEdited) // Display " (edited)" if the reply is edited
                    Text(
                      " (edited)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 255, 0, 0),
                        fontStyle: FontStyle.italic,
                      ),
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
    ); */

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );

    IconData _getRoleIcon(String roleType) {
      switch (roleType) {
        case 'Patient':
          return Icons.local_hospital; // Example icon for Patient
        case 'Healthcare Professional':
          return Icons
              .medical_services; // Example icon for Healthcare Professional
        case 'Parent':
          return Icons.family_restroom; // Example icon for Parent
        case 'Admin':
          return Icons.admin_panel_settings; // Example icon for Admin
        default:
          return Icons.help_outline; // Example icon for Unknown or other roles
      }
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ExpansionTileCard(
            //baseColor: Colors.white, // You can adjust the base color
            //expandedColor: Colors.white, // And the expanded color
            elevation: 5,
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: widget.userProfilePhoto.startsWith('http')
                  ? NetworkImage(widget.userProfilePhoto)
                      as ImageProvider<Object>
                  : AssetImage('assets/${widget.userProfilePhoto}')
                      as ImageProvider<Object>,
            ),
            title: Text(
              widget.authorName,
              style: TextStyle(
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
                  style: const TextStyle(fontSize: 18),
                  //overflow: TextOverflow.ellipsis,
                  //maxLines: 3,
                ),
                SizedBox(height: 4),
                Text(
                  formatter,
                  style: const TextStyle(fontSize: 12),
                ),
                if (isEdited)
                  Text(
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
                      style: flatButtonStyle,
                      onPressed: () {
                        _showDialog(context, docId);
                      },
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.edit),
                          Padding(
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
                        _getRoleIcon(widget
                            .roleType), // Determines the icon based on the roleType
                        //size: 24.0, // Adjust the size as needed
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Text(
                        widget.roleType,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium, // Display the roleType text
                        // Adjust the text style as needed
                      ),
                    ],
                  ),

                  if (currentUserId == creator)
                    TextButton(
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
                          Icon(Icons.delete),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.0),
                          ),
                          Text(
                            'Delete Reply',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  // Add more buttons or logic for user role as needed
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 50.0, right: 50.0), // Adjust the padding as needed
          child: Divider(
            color: Colors.grey, // Change color as needed
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
