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
  List<Object> _categoryTopicsList = [];
  int topicLength = 0;

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
          ElevatedButton(
              onPressed: () {
                print(_categoryTopicsList.length);
                // dynamic topic1 = _categoryTopicsList[0];
                // print(topic1['title']);
              },
              child: const Text("List test button")
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

  Future getCategoryList() async {
    
    // QuerySnapshot data =
    //     await widget.firestore.collection('topics')
    //     // .orderBy('title')
    //     .where('tags', arrayContainsAny: ['Parent'])
    //     .get()
    //     .then((querySnapshot) {
    //       querySnapshot.docs.forEach((doc) { 
    //         print(doc.data());
    //       });
    //     })
    //     .catchError((error) {
    //       print("erorr");
    //     })

    QuerySnapshot data = await widget.firestore
        .collection('topics')
        .where('tags', arrayContainsAny: ['Parent'])
        .orderBy('title')
        .get();
         
        

    setState(() {
      _categoryTopicsList = List.from(data.docs);
      // topicLength = _topicsList.length;
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
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(); // Close the dialog
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
