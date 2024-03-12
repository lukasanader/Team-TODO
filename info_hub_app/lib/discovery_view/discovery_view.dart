import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    getTopicsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: (query) {
            _searchData(query);
          },
        ),
        actions: const [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: null,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
        children: [
          ToggleButtons(
            isSelected: isSelected,
            onPressed: (int index) {
              setState(() {
                isSelected[index] = !isSelected[index];
                if (!categoriesSelected.contains(_categories[index])) {
                  categoriesSelected.add(_categories[index]);
                }
                else {
                  categoriesSelected.remove(_categories[index]);
                }
                updateTopicListBasedOnCategory(categoriesSelected);
              });
            },
            children: _categoriesWidget
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: topicLength == 0 ? 1 : topicLength,
            itemBuilder: (context, index) {
              if (_topicsList.isEmpty) {
                return const ListTile(
                  title: CircularProgressIndicator(),
                );
              } else {
                if (_searchController.text.isEmpty) {
                  return TopicCard(
                      widget.firestore,
                      widget.auth,
                      widget.storage,
                      _topicsList[index] as QueryDocumentSnapshot<Object>);
                } else if (_searchedTopicsList.isEmpty) {
                  return const ListTile(
                    title: Text("Sorry there are no topics for this!"),
                  );
                } else {
                  return TopicCard(
                      widget.firestore,
                      widget.auth,
                      widget.storage,
                      _searchedTopicsList[index]
                          as QueryDocumentSnapshot<Object>);
                }
              }
            },
          ),

          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                _showPostDialog();
              },
              child: const Text("Ask a question!")
          )
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

  Future getTopicsList() async {
    QuerySnapshot data =
        await widget.firestore.collection('topics').orderBy('title').get();

    setState(() {
      _topicsList = List.from(data.docs);
      topicLength = _topicsList.length;
    });
  }



  Future updateTopicListBasedOnCategory(List<String> categories) async {
    if (categories.isEmpty) {
      getTopicsList();
    } else {
      List<QuerySnapshot> snapshots = [];
      for (String category in categories) {
        QuerySnapshot snapshot = await widget.firestore
            .collection('topics')
            .where('categories', arrayContains: category)
            .orderBy('title')
            .get();
        snapshots.add(snapshot);
      }

      // Find the intersection of documents
      List<QueryDocumentSnapshot> intersection = [];
      if (snapshots.isNotEmpty) {
        intersection = snapshots.first.docs;
        for (int i = 1; i < snapshots.length; i++) {
          intersection = intersection
              .where((doc1) => snapshots[i].docs
                  .any((doc2) => doc1.id == doc2.id))
              .toList();
        }
      }

      setState(() {
        _topicsList = intersection;
        topicLength = _topicsList.length;
      });
    }
  }


  Future getCategoryList() async {
    QuerySnapshot data = await widget.firestore
        .collection('categories')
        .orderBy('name')
        .get();

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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Message'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Thank you!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
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
