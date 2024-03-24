import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:info_hub_app/threads/custom_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/threads/name_generator.dart';

class ThreadApp extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final String topicId;
  final String topicTitle;

  const ThreadApp(
      {Key? key,
      required this.firestore,
      required this.auth,
      required this.topicId,
      required this.topicTitle})
      : super(key: key);

  @override
  _ThreadAppState createState() => _ThreadAppState();
}

class _ThreadAppState extends State<ThreadApp> {
  late Stream<QuerySnapshot> firestoreDb;
  //late TextEditingController nameInputController;
  late TextEditingController titleInputController;
  late TextEditingController descriptionInputController;

  @override
  void initState() {
    super.initState();
    firestoreDb = widget.firestore
        .collection("thread")
        .where('topicId', isEqualTo: widget.topicId)
        .snapshots();
    titleInputController = TextEditingController();
    descriptionInputController = TextEditingController();
  }

  void _refreshData() {
    setState(() {
      firestoreDb = widget.firestore
          .collection("thread")
          .where('topicId', isEqualTo: widget.topicId)
          .snapshots();
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
            //color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        //backgroundColor: Colors.red[900],
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

// modify above appbar as needed to match rest of app

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Check if user is logged in before showing the dialog
          // if (widget.auth.currentUser != null) {
          _showDialog(context);
        },
        /* else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Please log in to post a thread.")) // login error message
                );
          } */

        child: const Icon(FontAwesomeIcons.questionCircle),
      ),
      body: StreamBuilder(
        stream: firestoreDb,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, int index) {
              var threadDoc = snapshot.data!.docs[index];
              var roleType = threadDoc['roleType'] ?? 'Unknown';
              var creatorId = threadDoc['creator'];

              return FutureBuilder<DocumentSnapshot>(
                future:
                    widget.firestore.collection('Users').doc(creatorId).get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return CircularProgressIndicator(); // Or some placeholder widget
                  }

                  var userDocData =
                      userSnapshot.data?.data() as Map<String, dynamic>?;
                  var profilePhoto = userDocData?['selectedProfilePhoto'] ??
                      'default_profile_photo.png';
                  //var roleType = userDocData?['roleType'] ?? 'Missing Role';

                  return CustomCard(
                    key: ObjectKey(threadDoc.id),
                    snapshot: snapshot.data,
                    index: index,
                    firestore: widget.firestore,
                    auth: widget.auth,
                    userProfilePhoto: profilePhoto,
                    onEditCompleted: _refreshData,
                    roleType: roleType,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  _showDialog(BuildContext context) async {
    //bool showErrorName = false;
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
                    //nameInputController.clear();
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
                      String docId = widget.auth.currentUser!.uid;
                      String authorName = generateUniqueName(docId);

                      DocumentSnapshot userDoc = await widget.firestore
                          .collection('Users')
                          .doc(docId)
                          .get();
                      var userDocData = userDoc.data() as Map<String, dynamic>?;
                      var roleType = userDocData?['roleType'] ?? 'Missing Role';
                      widget.firestore.collection("thread").add({
                        "author": authorName, // Using logged in user details
                        "title": titleInputController.text,
                        "description": descriptionInputController.text,
                        "timestamp": FieldValue.serverTimestamp(),
                        "creator": docId,
                        "topicId": widget.topicId,
                        "topicTitle": widget.topicTitle,
                        "isEdited": false,
                        "roleType": roleType,
                      }).then((response) {
                        titleInputController.clear();
                        descriptionInputController.clear();
                        _refreshData();
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
