import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/model/model.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/registration/user_controller.dart';
import 'package:info_hub_app/topics/topics_card.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controller/topic_question_controller.dart';

class DiscoveryView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  const DiscoveryView(
      {super.key,
      required this.auth,
      required this.storage,
      required this.firestore});
  @override
  _DiscoveryViewState createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Object> _topicsList = [];
  int topicLength = 0;

  late List<bool> isSelected = [];
  List<Widget> _categoriesWidget = [];
  List<String> _categories = [];
  List<String> categoriesSelected = [];

  List<Object> _displayedTopicsList = [];

  @override
  void initState() {
    super.initState();
    getCategoryList();
    getAllTopicsList().then((_) {
      setState(() {
        _displayedTopicsList = _topicsList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search',
          ),
          onChanged: (query) {
            _searchData(query);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  addVerticalSpace(10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ToggleButtons(
                      isSelected: isSelected,
                      onPressed: (int index) {
                        setState(() {
                          isSelected[index] = !isSelected[index];
                          if (!categoriesSelected
                              .contains(_categories[index])) {
                            categoriesSelected.add(_categories[index]);
                          } else {
                            categoriesSelected.remove(_categories[index]);
                          }
                          _searchData(_searchController.text);
                        });
                      },
                      children: List.generate(
                        _categoriesWidget.length,
                        (index) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal:
                                  15.0), // Adjust the horizontal spacing here
                          child: _categoriesWidget[index],
                        ),
                      ),
                    ),
                  ),
                  addVerticalSpace(10),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _displayedTopicsList.isEmpty
                        ? 1
                        : _displayedTopicsList.length * 2 - 1,
                    itemBuilder: (context, index) {
                      if (index.isOdd) {
                        // Add Padding and Container between TopicCards
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                        );
                      } else {
                        final topicIndex = index ~/ 2;
                        if (_displayedTopicsList.isEmpty &&
                            _topicsList.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          if (_displayedTopicsList.isEmpty) {
                            return const ListTile(
                              title: Text(
                                "Sorry there are no topics for this!",
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else {
                            return TopicCard(
                              widget.firestore,
                              widget.auth,
                              widget.storage,
                              _displayedTopicsList[topicIndex]
                                  as QueryDocumentSnapshot<Object>,
                            );
                          }
                        }
                      }
                    },
                  ),
                  addVerticalSpace(20),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              addQuestionDialog();
            },
            child: const Text("Ask a question!"),
          ),
          addVerticalSpace(20),
        ],
      ),
    );
  }

  Future<void> addQuestionDialog() async {
    // Show dialog to get user input
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ask a question'),
          content: TextField(
            controller: _questionController,
            decoration: const InputDecoration(
              labelText: 'Enter your question...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Get the entered question text
                String questionText = _questionController.text.trim();

                // Validate question text
                if (questionText.isNotEmpty) {
                  TopicQuestionController(
                          firestore: widget.firestore, auth: widget.auth)
                      .handleQuestion(questionText);
                  // Clear the text field
                  _questionController.clear();
                  // Close the dialog
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Message'),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 50,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Thank you!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Your question has been submitted.\n'
                              'An admin will get back to you shortly.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Question submitted successfully!'),
                    ),
                  );
                } else {
                  // Show error message if question is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a question.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _searchData(String query) {
    updateTopicListBasedOnCategory(categoriesSelected);

    if (query.isNotEmpty) {
      List<QueryDocumentSnapshot<Object?>> tempList = [];

      for (int i = 0; i < _displayedTopicsList.length; i++) {
        QueryDocumentSnapshot topic =
            _displayedTopicsList[i] as QueryDocumentSnapshot<Object?>;
        if (topic['title'] != null) {
          String title = topic['title'].toString().toLowerCase();
          if (title.contains(query.toLowerCase())) {
            tempList.add(topic);
          }
        }
      }

      setState(() {
        _displayedTopicsList = tempList;
      });
    }
  }

  Future getAllTopicsList() async {
    String role =
        await UserController(widget.auth, widget.firestore).getUserRoleType();
    late QuerySnapshot data;

    if (role == 'admin') {
      data = await widget.firestore.collection('topics').orderBy('title').get();
    } else {
      data = await widget.firestore
          .collection('topics')
          .where('tags', arrayContains: role)
          .orderBy('title')
          .get();
    }

    List<Object> tempList = List.from(data.docs);

    setState(() {
      _topicsList = tempList;
    });
  }

  Future updateTopicListBasedOnCategory(List<String> categories) async {
    if (categories.isNotEmpty) {
      List<Object> categoryTopicList = [];

      for (dynamic topic in _topicsList) {
        var data = topic.data();
        if (data != null && data.containsKey('categories')) {
          if (categories.every((item) => data['categories'].contains(item))) {
            categoryTopicList.add(topic);
          }
        }
      }

      setState(() {
        _displayedTopicsList = categoryTopicList;
      });
    } else {
      setState(() {
        _displayedTopicsList = _topicsList;
      });
    }
  }

  Future getCategoryList() async {
    QuerySnapshot data =
        await widget.firestore.collection('categories').orderBy('name').get();

    List<Object> dataList = List.from(data.docs);
    List<String> tempStringList = [];
    List<Widget> tempWidgetList = [];

    for (dynamic category in dataList) {
      tempStringList.add(category['name']);
      tempWidgetList.add(Text(category['name']));
    }

    setState(() {
      _categories = tempStringList;
      _categoriesWidget = tempWidgetList;
      isSelected = List<bool>.filled(_categoriesWidget.length, false);
    });
  }
}
