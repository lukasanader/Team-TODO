import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'thread_replies.dart';
import 'package:flutter/cupertino.dart';

class CustomCard extends StatefulWidget {
  final QuerySnapshot? snapshot;
  final int index;
  final FirebaseFirestore firestore;

  const CustomCard({
    Key? key,
    this.snapshot,
    required this.index,
    required this.firestore,
  }) : super(key: key);

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  late TextEditingController titleInputController;
  late TextEditingController descriptionInputController;
  late TextEditingController nameInputController;

  @override
  void initState() {
    super.initState();
    final docData =
        widget.snapshot!.docs[widget.index].data() as Map<String, dynamic>;
    /* titleInputController = TextEditingController(text: docData['title']);
    descriptionInputController =
        TextEditingController(text: docData['description']);
    nameInputController = TextEditingController(text: docData['name']); */
    titleInputController = TextEditingController();
    descriptionInputController = TextEditingController();
    nameInputController = TextEditingController();
  }

  @override
  void dispose() {
    titleInputController.dispose();
    descriptionInputController.dispose();
    nameInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var docData =
        widget.snapshot!.docs[widget.index].data() as Map<String, dynamic>;
    var docId = widget.snapshot!.docs[widget.index].id;

    var title = docData['title'] ?? 'No title';
    var description = docData['description'] ?? 'No description';
    var name = docData['name'] ?? 'Unknown';
    var timestamp = docData['timestamp']?.toDate();
    var formatter = timestamp != null
        ? DateFormat("dd-MMM-yyyy 'at' HH:mm").format(timestamp)
        : 'Timestamp not available';

    return Column(
      children: <Widget>[
        Container(
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
                        onTap: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (BuildContext context) =>
                                  ThreadReplies()));
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
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.edit, size: 15),
                    onPressed: () {
                      _showDialog(context, docId);
                    },
                  ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.trashAlt, size: 15),
                    onPressed: () async {
                      if (!mounted) return;
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
                  const Padding(padding: EdgeInsets.all(2)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "$name: ",
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
                child: Text(title[0]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _showDialog(BuildContext context, String docId) async {
    bool showErrorName = false;
    bool showErrorTitle = false;
    bool showErrorDescription = false;

    var docSnapshot =
        await widget.firestore.collection("thread").doc(docId).get();
    var docData = docSnapshot.data() as Map<String, dynamic>;

    if (!mounted) return;

    // Reinitialize the TextEditingController instances with the latest document data
    titleInputController.text = docData['title'] ?? '';
    descriptionInputController.text = docData['description'] ?? '';
    nameInputController.text = docData['name'] ?? '';

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
                    /*nameInputController.clear();
                    titleInputController.clear();
                    descriptionInputController.clear();*/
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showErrorName = nameInputController.text.isEmpty;
                      showErrorTitle = titleInputController.text.isEmpty;
                      showErrorDescription =
                          descriptionInputController.text.isEmpty;
                    });

                    if (!showErrorName &&
                        !showErrorTitle &&
                        !showErrorDescription) {
                      widget.firestore.collection("thread").doc(docId).update({
                        "name": nameInputController.text,
                        "title": titleInputController.text,
                        "description": descriptionInputController.text,
                        "timestamp": FieldValue.serverTimestamp(),
                      }).then((response) {
                        //print(response.id);
                        /* nameInputController.clear();
                        titleInputController.clear();
                        descriptionInputController.clear(); */
                        Navigator.pop(context);
                      });
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
