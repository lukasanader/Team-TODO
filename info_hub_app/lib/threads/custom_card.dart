import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:info_hub_app/threads/thread_replies.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/name_generator.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';

class CustomCard extends StatefulWidget {
  final QuerySnapshot? snapshot;
  final int index;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final String userProfilePhoto;
  final Function onEditCompleted;
  final String roleType;

  const CustomCard({
    Key? key,
    this.snapshot,
    required this.index,
    required this.firestore,
    required this.auth,
    required this.userProfilePhoto,
    required this.onEditCompleted,
    required this.roleType,
  }) : super(key: key);

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  late TextEditingController titleInputController;
  late TextEditingController descriptionInputController;
  late String _userProfilePhoto = 'assets/default_profile_photo.png';
  late bool isEdited;

  @override
  void initState() {
    super.initState();

    titleInputController = TextEditingController();
    descriptionInputController = TextEditingController();
    var docData =
        widget.snapshot!.docs[widget.index].data() as Map<String, dynamic>;
    isEdited = docData['isEdited'] ?? false;
  }

  @override
  void dispose() {
    titleInputController.dispose();
    descriptionInputController.dispose();
    //nameInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var docData =
        widget.snapshot!.docs[widget.index].data() as Map<String, dynamic>;
    var docId = widget.snapshot!.docs[widget.index].id;

    // print('Selected Profile Photo: ${docData['selectedProfilePhoto']}');

    var title = docData['title'] ?? 'No title';
    var description = docData['description'] ?? 'No description';
    var creator = docData['creator'] ?? 'Unknown';
    var currentUserId = widget.auth.currentUser!.uid;
    //var name = docData[''] ?? 'Unknown';
    var timestamp = docData['timestamp']?.toDate();
    var formatter = timestamp != null
        ? DateFormat("dd-MMM-yyyy 'at' HH:mm").format(timestamp)
        : 'Timestamp not available';
    var authorName = generateUniqueName(creator);

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
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: widget.userProfilePhoto.startsWith('http')
                  ? NetworkImage(widget.userProfilePhoto)
                      as ImageProvider<Object>
                  : AssetImage('assets/${widget.userProfilePhoto}')
                      as ImageProvider<Object>,
            ),
            title: Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    key: Key('navigateToThreadReplies_${widget.index}'),
                    onTap: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                        builder: (BuildContext context) => ThreadReplies(
                          threadId: docId,
                          firestore: widget.firestore,
                          auth: widget.auth,
                        ),
                      ));
                    },
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    authorName,
                    style: const TextStyle(fontSize: 14),
                    //overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatter,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            children: <Widget>[
              const Divider(
                thickness: 1.0,
                height: 1.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 16),
                      //maxLines: 2,
                      //overflow: TextOverflow.ellipsis,
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
                                  'Edit Post',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
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
                              // batch delete removes up to 500 replies at a time from the replies collection due to firestore limitations
                              final replyQuerySnapshot = await widget.firestore
                                  .collection("replies")
                                  .where('threadId', isEqualTo: docId)
                                  .get();

                              final WriteBatch batch = widget.firestore.batch();
                              for (DocumentSnapshot replyDoc
                                  in replyQuerySnapshot.docs) {
                                batch.delete(replyDoc.reference);
                              }

                              await batch.commit();

                              await widget.firestore
                                  .collection("thread")
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
                                  'Delete Post',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        // Additional buttons or logic for user role can be added here
                      ],
                    ),
                  ],
                ),
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

  _showDialog(BuildContext context, String docId) async {
    bool showErrorTitle = false;
    bool showErrorDescription = false;

    var docSnapshot =
        await widget.firestore.collection("thread").doc(docId).get();
    var docData = docSnapshot.data() as Map<String, dynamic>;

    if (!mounted) return;

    titleInputController.text = docData['title'] ?? '';
    descriptionInputController.text = docData['description'] ?? '';

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
                            showErrorTitle ? "Please enter a title" : null,
                      ),
                      controller: titleInputController,
                    ),
                    TextField(
                      key: const Key('Description'),
                      autofocus: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: "Description",
                        errorText: showErrorDescription
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
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showErrorTitle = titleInputController.text.isEmpty;
                      showErrorDescription =
                          descriptionInputController.text.isEmpty;
                    });

                    if (!showErrorTitle && !showErrorDescription) {
                      setState(() {
                        docData['title'] = titleInputController.text;
                        docData['description'] =
                            descriptionInputController.text;
                        isEdited = true;
                      });

                      widget.firestore.collection("thread").doc(docId).update({
                        "title": titleInputController.text,
                        "description": descriptionInputController.text,
                        "timestamp": FieldValue.serverTimestamp(),
                        "isEdited": true,
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
