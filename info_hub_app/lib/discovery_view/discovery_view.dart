import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/topics/topics_card.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<Object> _searchedTopicsList = [];
  int topicLength = 0;

  late List<bool> isSelected = [];
  List<Widget> _categoriesWidget = [];
  List<String> _categories = [];
  List<String> categoriesSelected = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCategoryList();
    updateTopicsList();
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
      body: SingleChildScrollView(
          child: Column(
        children: [
          addVerticalSpace(10),
          ToggleButtons(
            isSelected: isSelected,
            onPressed: (int index) {
              setState(() {
                isSelected[index] = !isSelected[index];
                if (!categoriesSelected.contains(_categories[index])) {
                  categoriesSelected.add(_categories[index]);
                } else {
                  categoriesSelected.remove(_categories[index]);
                }
                updateTopicListBasedOnCategory(categoriesSelected);
              });
            },
            children: List.generate(
              _categoriesWidget.length,
              (index) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0), // Adjust the horizontal spacing here
                child: _categoriesWidget[index],
              ),
            ),
          ),
          addVerticalSpace(10),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: topicLength == 0 ? 1 : topicLength * 2 - 1,
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
                if (_topicsList.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (_searchController.text.isEmpty) {
                    return TopicCard(
                      widget.firestore,
                      widget.auth,
                      widget.storage,
                      _topicsList[topicIndex] as QueryDocumentSnapshot<Object>,
                    );
                  } else if (_searchedTopicsList.isEmpty) {
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
                      _searchedTopicsList[topicIndex]
                          as QueryDocumentSnapshot<Object>,
                    );
                  }
                }
              }
            },
          ),
          ElevatedButton(
              onPressed: () {
                _showPostDialog();
              },
              child: const Text("Ask a question!")),
          addVerticalSpace(20),
        ],
      )),
    );
  }

  void _searchData(String query) {
    List<QueryDocumentSnapshot<Object?>> tempList = [];

    for (int i = 0; i < _topicsList.length; i++) {
      QueryDocumentSnapshot topic =
          _topicsList[i] as QueryDocumentSnapshot<Object?>;
      if (topic['title'] != null) {
        String title = topic['title'].toString().toLowerCase();
        if (title.contains(query.toLowerCase())) {
          tempList.add(topic);
        }
      }
    }

    setState(() {
      _searchedTopicsList = tempList;
      topicLength = _searchedTopicsList.length;
    });
  }

  Future<List<Object>> getTopicsList() async {
    String uid = widget.auth.currentUser!.uid;
    DocumentSnapshot user =
        await widget.firestore.collection('Users').doc(uid).get();
    String role = user['roleType'];
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

    return List.from(data.docs);
  }

  Future updateTopicsList() async {
    List<Object> tempTopicList = await getTopicsList();

    setState(() {
      _topicsList = tempTopicList;
      topicLength = _topicsList.length;
    });
  }

  Future updateTopicListBasedOnCategory(List<String> categories) async {
    if (categories.isEmpty) {
      updateTopicsList();
    } else {
      List<Object> allTopics = await getTopicsList();

      List<Object> categoryTopicList = [];

      for (dynamic topic in allTopics) {
        var data = topic.data();
        if (data != null && data.containsKey('categories')) {
          if (categories.every((item) => data['categories'].contains(item))) {
            categoryTopicList.add(topic);
          }
        }
      }

      setState(() {
        _topicsList = categoryTopicList;
        topicLength = _topicsList.length;
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

  void _showPostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _questionController,
                decoration:
                    const InputDecoration(labelText: 'Ask a question...'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Access the entered text using _textFieldController.text
                  //call method to add question to database
                  DateTime currentDate = DateTime.now();
                  final postData = {
                    'question': _questionController.text,
                    'uid': 1,
                    'date': currentDate.toString(),
                  };
                  CollectionReference db =
                      widget.firestore.collection('questions');
                  await db.add(postData);
                  _questionController.clear();
                  // Close the dialog
                  Navigator.of(context).pop();

                  // Show the message dialog
                  // ignore: use_build_context_synchronously
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
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }
}
