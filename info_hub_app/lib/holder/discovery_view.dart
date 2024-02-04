import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/holder/autocomplete.dart';
import 'package:info_hub_app/holder/topics_card.dart';
import '../screens/create_topic.dart';




class DiscoveryView extends StatefulWidget {
  @override
  _DiscoveryViewState createState() => _DiscoveryViewState();
}



class _DiscoveryViewState extends State<DiscoveryView> {
  List<Object> _topicsList = [];

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
                    QueryDocumentSnapshot topic = _topicsList[0] as QueryDocumentSnapshot<Object?>;
                    print(topic['title']);
            },
          ),
          title: Search(),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
              },
            )
          ],
        ),
        body: SafeArea(
          child: ListView.builder(
            itemCount: _topicsList.length,
            itemBuilder: (context, index) {
              return TopicCard(_topicsList[index] as QueryDocumentSnapshot<Object>);
            },
          )
        ),
    );
  }


  Future getTopicsList() async {
    QuerySnapshot data = await FirebaseFirestore.instance.collection('topics').get();

    setState(() {
      _topicsList = List.from(data.docs);
    });
  }

}