import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:info_hub_app/threads/thread_replies.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/name_generator.dart';

class CustomCard extends StatefulWidget {
  final QuerySnapshot? snapshot;
  final int index;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final String userProfilePhoto;
  final Function onEditCompleted;

  const CustomCard({
    Key? key,
    this.snapshot,
    required this.index,
    required this.firestore,
    required this.auth,
    required this.userProfilePhoto,
    required this.onEditCompleted,
  }) : super(key: key);

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  late TextEditingController titleInputController;
  late TextEditingController descriptionInputController;
  late String _userProfilePhoto = 'assets/default_profile_photo.png';
  late bool isEdited;
  //late TextEditingController nameInputController;

  @override
  void initState() {
    super.initState();
    /*final docData =
        widget.snapshot!.docs[widget.index].data() as Map<String, dynamic>;
     titleInputController = TextEditingController(text: docData['title']);
    descriptionInputController =
        TextEditingController(text: docData['description']);
    nameInputController = TextEditingController(text: docData['name']); */
    titleInputController = TextEditingController();
    descriptionInputController = TextEditingController();
    var docData =
        widget.snapshot!.docs[widget.index].data() as Map<String, dynamic>;
    isEdited = docData['isEdited'] ?? false;
    // Initialize isEdited based on the Firestore document
    //_fetchUserProfilePhoto();
    //nameInputController = TextEditingController();
  }
/*
  void _fetchUserProfilePhoto() async {
    var userDoc = await widget.firestore
        .collection('Users')
        .doc(widget.snapshot!.docs[widget.index].get('creator'))
        .get();
    String? profilePhoto = userDoc.data()?['selectedProfilePhoto'];
    if (profilePhoto != null && profilePhoto.isNotEmpty) {
      setState(() {
        _userProfilePhoto = profilePhoto;
      });
    }
  }
  */

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

    return Column(
      children: <Widget>[
        SizedBox(
          height: 140,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 5,
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: Key('navigateToThreadReplies_${widget.index}'),
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (BuildContext context) => ThreadReplies(
                                    threadId: docId,
                                    firestore: widget.firestore,
                                    auth: widget.auth,
                                  )));
                        },
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (currentUserId == creator)
                    IconButton(
                      key: Key('editButton_$docId'),
                      icon: const Icon(FontAwesomeIcons.penToSquare, size: 15),
                      onPressed: () {
                        _showDialog(context, docId);
                      },
                    ),
                  if (currentUserId == creator)
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.trashCan, size: 15),
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
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  if (isEdited) // Check if the post is edited
                    const Text(
                      " (edited)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 255, 0, 0),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const Padding(padding: EdgeInsets.all(2)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "$authorName: ",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 255, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        formatter,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 255, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              leading: CircleAvatar(
                radius: 38,
                backgroundImage: widget.userProfilePhoto.startsWith('http')
                    ? NetworkImage(widget.userProfilePhoto)
                        as ImageProvider<Object>
                    : AssetImage('assets/${widget.userProfilePhoto}')
                        as ImageProvider<Object>,
              ),
            ),
          ),
        ),
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
                      // Update the local UI immediately
                      setState(() {
                        docData['title'] = titleInputController.text;
                        docData['description'] =
                            descriptionInputController.text;
                        isEdited = true;
                      });

                      // Asynchronously update Firestore
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
