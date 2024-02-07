import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/holder/topics_card.dart';
import '../screens/create_topic.dart';


class trendingTopic extends StatefulWidget {
  final FirebaseFirestore firestore;
  const trendingTopic({Key? key, required this.firestore});
  @override
  _trendingTopicState createState() => _trendingTopicState();
}

class _trendingTopicState extends State<trendingTopic>{
List<Object> _topicsList = [];
int topicLength = 0;

@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getTopicsList();
  }

Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color.fromRGBO(255, 255, 255, 1),
    body: SafeArea(
      child: Column(children: [
        Expanded(child: ListView.builder(
          itemCount:  topicLength == 0 ? 0: topicLength,
          itemBuilder: (context, index){
          return TopicCard(_topicsList[index] as QueryDocumentSnapshot<Object>);
          }),)
      ]),
    ),
    );
}

Future getTopicsList() async {
    QuerySnapshot data = await widget.firestore.collection('topics').get();
    
    double getTrending(QueryDocumentSnapshot topic){
      Timestamp timestamp = topic['date'];
      DateTime date = timestamp.toDate();
      int difference = DateTime.now().difference(date).inDays;
      if (difference==0) {
        difference=1;
      }
      return topic['views']/difference;
    }
    setState(() {
      _topicsList = List.from(data.docs);
      
      _topicsList.sort((b,a) => getTrending(a as QueryDocumentSnapshot<Object?>).compareTo(getTrending(b as QueryDocumentSnapshot<Object?>)));
      topicLength = _topicsList.length;
    });
  }
}