import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/holder/topics_card.dart';
import '../screens/create_topic.dart';




class DiscoveryView extends StatefulWidget {
  @override
  _DiscoveryViewState createState() => _DiscoveryViewState();
}



class _DiscoveryViewState extends State<DiscoveryView> {
  TextEditingController _searchController = TextEditingController();
  List<Object> _topicsList = [];
  List<Object> _searchedTopicsList = [];
  int topicLength = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getTopicsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              print(_searchedTopicsList);
            },
          ),
          title: TextField(
            controller: _searchController,
            onChanged: (query) {
              _searchData(query);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
              },
            )
          ],
        ),
        body: SafeArea(
          child: Column (children: [
            Expanded(child: ListView.builder(
              itemCount: topicLength == 0 ? 1: topicLength,
              itemBuilder: (context, index) {
                if (_searchController.text.isEmpty) {
                  return TopicCard(_topicsList[index] as QueryDocumentSnapshot<Object>);
                }
                if (_searchedTopicsList.isEmpty) {
                  return ListTile(
                    title: Text("Sorry there are no topics for this!"),
                  );
                }
                return TopicCard(_searchedTopicsList[index] as QueryDocumentSnapshot<Object>);
                },
              ) 
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text("Ask a question!")
            )
          ],)
        ),
    );
  }


  void _searchData(String query) {
    List<QueryDocumentSnapshot<Object?>> _tempList = [];

    for (int i = 0; i < _topicsList.length; i++) {
      QueryDocumentSnapshot topic = _topicsList[i] as QueryDocumentSnapshot<Object?>;
      if (topic['title'] != null) {
        String title = topic['title'].toString().toLowerCase();
        if (title.contains(query.toLowerCase())) {
          _tempList.add(topic);
        }
      }
    }
    
    setState(() {
      _searchedTopicsList = _tempList;
      topicLength = _searchedTopicsList.length;
    });
  }


  Future getTopicsList() async {
    QuerySnapshot data = await FirebaseFirestore.instance.collection('topics').get();

    setState(() {
      _topicsList = List.from(data.docs);
      topicLength = _topicsList.length;
    });
  }

}