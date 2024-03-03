import 'package:flutter/material.dart';
import 'package:info_hub_app/analytics/analytics_topic_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AnalyticsTopicView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  const AnalyticsTopicView(
      {super.key, required this.firestore, required this.storage});

  @override
  State<AnalyticsTopicView> createState() => _AnalyticsTopicView();
}

class _AnalyticsTopicView extends State<AnalyticsTopicView> {
  List<Object> _topicsList = [];
  int topicLength = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getTopicsList();
  }

  @override
  void initState() {
    super.initState();
    widget.firestore.collection('topics').snapshots().listen((snapshot) {
      getTopicsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Topic Analytics"),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: topicLength == 0 ? 0 : topicLength,
          itemBuilder: (context, index) {
            return AdminTopicCard(widget.firestore, widget.storage,
                _topicsList[index] as QueryDocumentSnapshot<Object>);
          }),
    );
  }

  Future getTopicsList() async {
    QuerySnapshot data = await widget.firestore.collection('topics').get();

    double getTrending(QueryDocumentSnapshot topic) {
      Timestamp timestamp = topic['date'];
      DateTime date = timestamp.toDate();
      int difference = DateTime.now().difference(date).inDays;
      if (difference == 0) {
        difference = 1;
      }
      return topic['views'] / difference;
    }

    setState(() {
      _topicsList = List.from(data.docs);
      _topicsList.sort((b, a) =>
          getTrending(a as QueryDocumentSnapshot<Object?>)
              .compareTo(getTrending(b as QueryDocumentSnapshot<Object?>)));
      topicLength = _topicsList.length;
    });
  }
}
