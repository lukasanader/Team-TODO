/*
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
    //nameInputController = TextEditingController();
    titleInputController = TextEditingController();
    descriptionInputController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//current appbar is placeholder, replace with actual appbar or equivalent
      appBar: AppBar(
        title: Text(
          widget.topicTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 48, 194),
        elevation: 4.0,
        /*leading: 
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            tooltip: 'Notifications',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () {},
          ), 
        ],*/
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

        child: const Icon(FontAwesomeIcons.solidQuestionCircle),
      ),
      body: StreamBuilder(
        stream: firestoreDb,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, int index) {
              //return Text(snapshot.data!.docs[index]['title']);
              return CustomCard(
                snapshot: snapshot.data,
                index: index,
                firestore: widget.firestore,
                auth: widget.auth,
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
                    /*
                    TextField(
                      key: const Key('Author'),
                      autofocus: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: "Author",
                        errorText:
                            showErrorName ? "Please enter your name" : null,
                      ),
                      controller: nameInputController,
                    ), */
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

                /*
                TextButton(
                  onPressed: () {
                    setState(() {
                      //showErrorName = nameInputController.text.isEmpty;
                      showErrorTitle = titleInputController.text.isEmpty;
                      showErrorDescription =
                          descriptionInputController.text.isEmpty;
                    });

                    if (//!showErrorName &&
                        !showErrorTitle &&
                        !showErrorDescription) {
                      widget.firestore.collection("thread").add({
                       
                       // "name": nameInputController.text,
                        "title": titleInputController.text,
                        "description": descriptionInputController.text,
                        "timestamp": FieldValue.serverTimestamp(),
                      }).then((response) {
                        //print(response.id);
                        //nameInputController.clear();
                        titleInputController.clear();
                        descriptionInputController.clear();
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: const Text("Submit"),

                  */
                TextButton(
                  onPressed: () {
                    setState(() {
                      showErrorTitle = titleInputController.text.isEmpty;
                      showErrorDescription =
                          descriptionInputController.text.isEmpty;
                    });

                    if (!showErrorTitle && !showErrorDescription) {
                      String docId = widget.auth.currentUser!.uid;
                      String authorName = generateUniqueName(docId);

                      widget.firestore.collection("thread").add({
                        "author": authorName, // Using logged in user details
                        "title": titleInputController.text,
                        "description": descriptionInputController.text,
                        "timestamp": FieldValue.serverTimestamp(),
                        "creator": docId,
                        "topicId": widget.topicId,
                      }).then((response) {
                        titleInputController.clear();
                        descriptionInputController.clear();
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

*/

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
    //nameInputController = TextEditingController();
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
    //nameInputController.dispose();
    titleInputController.dispose();
    descriptionInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//current appbar is placeholder, replace with actual appbar or equivalent
      appBar: AppBar(
        title: Text(
          widget.topicTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 48, 194),
        elevation: 4.0,
        /*leading: 
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            tooltip: 'Notifications',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () {},
          ), 
        ],*/
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

                  return CustomCard(
                    key: ObjectKey(threadDoc.id),
                    snapshot: snapshot.data,
                    index: index,
                    firestore: widget.firestore,
                    auth: widget.auth,
                    userProfilePhoto: profilePhoto,
                    onEditCompleted: _refreshData,
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
                    /*
                    TextField(
                      key: const Key('Author'),
                      autofocus: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: "Author",
                        errorText:
                            showErrorName ? "Please enter your name" : null,
                      ),
                      controller: nameInputController,
                    ), */
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

                /*
                TextButton(
                  onPressed: () {
                    setState(() {
                      //showErrorName = nameInputController.text.isEmpty;
                      showErrorTitle = titleInputController.text.isEmpty;
                      showErrorDescription =
                          descriptionInputController.text.isEmpty;
                    });

                    if (//!showErrorName &&
                        !showErrorTitle &&
                        !showErrorDescription) {
                      widget.firestore.collection("thread").add({
                       
                       // "name": nameInputController.text,
                        "title": titleInputController.text,
                        "description": descriptionInputController.text,
                        "timestamp": FieldValue.serverTimestamp(),
                      }).then((response) {
                        //print(response.id);
                        //nameInputController.clear();
                        titleInputController.clear();
                        descriptionInputController.clear();
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: const Text("Submit"),

                  */
                TextButton(
                  onPressed: () {
                    setState(() {
                      showErrorTitle = titleInputController.text.isEmpty;
                      showErrorDescription =
                          descriptionInputController.text.isEmpty;
                    });

                    if (!showErrorTitle && !showErrorDescription) {
                      String docId = widget.auth.currentUser!.uid;
                      String authorName = generateUniqueName(docId);

                      widget.firestore.collection("thread").add({
                        "author": authorName, // Using logged in user details
                        "title": titleInputController.text,
                        "description": descriptionInputController.text,
                        "timestamp": FieldValue.serverTimestamp(),
                        "creator": docId,
                        "topicId": widget.topicId,
                        "isEdited": false,
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
