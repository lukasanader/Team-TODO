import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'custom_card.dart';

class ThreadApp extends StatefulWidget {
  const ThreadApp({Key? key}) : super(key: key);

  @override
  _ThreadAppState createState() => _ThreadAppState();
}

class _ThreadAppState extends State<ThreadApp> {
  var firestoreDb = FirebaseFirestore.instance.collection("thread").snapshots();
  late TextEditingController nameInputController;
  late TextEditingController titleInputController;
  late TextEditingController descriptionInputController;

  @override
  void initState() {
    super.initState();
    nameInputController = TextEditingController();
    titleInputController = TextEditingController();
    descriptionInputController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Threads in Developement"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog(context);
        },
        child: const Icon(FontAwesomeIcons.solidQuestionCircle),
      ),
      body: StreamBuilder(
        stream: firestoreDb,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, int index) {
              //return Text(snapshot.data!.docs[index]['title']);
              return CustomCard(snapshot: snapshot.data, index: index);
            },
          );
        },
      ),
    );
  }

  _showDialog(BuildContext context) async {
    // Initialize error state variables
    bool showErrorName = false;
    bool showErrorTitle = false;
    bool showErrorDescription = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Added StatefulBuilder here
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(12.0),
              content: SingleChildScrollView(
                // Changed to SingleChildScrollView to accommodate keyboard
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Changed to min to avoid overflow
                  children: <Widget>[
                    const Text("Please fill out the form"),
                    TextField(
                      autofocus: true,
                      autocorrect: true,
                      decoration: InputDecoration(
                        labelText: "Author",
                        errorText:
                            showErrorName ? "Please enter your name" : null,
                      ),
                      controller: nameInputController,
                    ),
                    TextField(
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
                    nameInputController.clear();
                    titleInputController.clear();
                    descriptionInputController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    // Update the error state based on the text field inputs
                    setState(() {
                      showErrorName = nameInputController.text.isEmpty;
                      showErrorTitle = titleInputController.text.isEmpty;
                      showErrorDescription =
                          descriptionInputController.text.isEmpty;
                    });

                    // Check if all fields are filled
                    if (!showErrorName &&
                        !showErrorTitle &&
                        !showErrorDescription) {
                      FirebaseFirestore.instance.collection("thread").add({
                        "name": nameInputController.text,
                        "title": titleInputController.text,
                        "description": descriptionInputController.text,
                        "timestamp": FieldValue.serverTimestamp(),
                      }).then((response) {
                        print(response.id);
                        nameInputController.clear();
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
