import 'package:flutter/material.dart';
import 'package:info_hub_app/analytics/topics/analytics_topic_card.dart';
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
  // Default/Starting Variables
  List<Object> _topicsList = [];
  int topicLength = 0;
  String dropdownvalue = "Name A-Z";

  // Retrieves topic data from database as a String/Int
  String _getTopicTitle(QueryDocumentSnapshot topic) {
    return topic['title'];
  }

  int _getTopicViews(QueryDocumentSnapshot topic) {
    return topic['views'];
  }

  int _getTopicLikes(QueryDocumentSnapshot topic) {
    return topic['likes'];
  }

  int _getTopicDislikes(QueryDocumentSnapshot topic) {
    return topic['dislikes'];
  }

  double _getTrending(QueryDocumentSnapshot topic) {
    Timestamp timestamp = topic['date'];
    DateTime date = timestamp.toDate();
    int difference = DateTime.now().difference(date).inDays;
    if (difference == 0) {
      difference = 1;
    }
    return topic['views'] / difference;
  }

  @override
  void initState() {
    super.initState();
    widget.firestore.collection('topics').snapshots().listen((snapshot) {
      getTopicsList();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getTopicsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Topic Analytics"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: DropdownButton<String>(
              value: dropdownvalue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                  getTopicsList();
                });
              },
              items: const [
                DropdownMenuItem<String>(
                  value: "Name A-Z",
                  child: Text("Name (A - Z)"),
                ),
                DropdownMenuItem<String>(
                  value: "Name Z-A",
                  child: Text("Name (Z - A)"),
                ),
                DropdownMenuItem<String>(
                  value: "Most Popular",
                  child: Text("Most Popular"),
                ),
                DropdownMenuItem<String>(
                  value: "Trending",
                  child: Text("Trending"),
                ),
                DropdownMenuItem<String>(
                  value: "Most Likes",
                  child: Text("Most Likes"),
                ),
                DropdownMenuItem<String>(
                  value: "Most Disliked",
                  child: Text("Most Disliked"),
                ),
              ],
            ),
          ),
          topicLength == 0
              ? Center(
                  // If there are no topics on the database
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      "Sorry, there are no topics.\nPlease come back later.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Expanded(
                  // If there is at least 1 or more topics on the database
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: topicLength == 0 ? 0 : topicLength,
                      itemBuilder: (context, index) {
                        return AdminTopicCard(
                            widget.firestore,
                            widget.storage,
                            _topicsList[index]
                                as QueryDocumentSnapshot<Object>);
                      }),
                ),
        ],
      ),
    );
  }

  Future getTopicsList() async {
    // Retrieves topic data as QuerySnapshot from database.
    QuerySnapshot data = await widget.firestore.collection('topics').get();
    _topicsList = List.from(data.docs);
    topicLength = _topicsList.length;

    // Amends ordering of topics on the screen when new dropdown is selected
    // or when the page is initialised for the first time.
    setState(() {
      if (dropdownvalue == "Name A-Z") {
        _topicsList.sort((a, b) =>
            _getTopicTitle(a as QueryDocumentSnapshot<Object?>).compareTo(
                _getTopicTitle(b as QueryDocumentSnapshot<Object?>)));
      } else if (dropdownvalue == "Name Z-A") {
        _topicsList.sort((b, a) =>
            _getTopicTitle(a as QueryDocumentSnapshot<Object?>).compareTo(
                _getTopicTitle(b as QueryDocumentSnapshot<Object?>)));
      } else if (dropdownvalue == "Most Popular") {
        _topicsList.sort((b, a) =>
            _getTopicViews(a as QueryDocumentSnapshot<Object?>).compareTo(
                _getTopicViews(b as QueryDocumentSnapshot<Object?>)));
      } else if (dropdownvalue == "Trending") {
        _topicsList.sort((a, b) =>
            _getTrending(a as QueryDocumentSnapshot<Object?>)
                .compareTo(_getTrending(b as QueryDocumentSnapshot<Object?>)));
      } else if (dropdownvalue == "Most Likes") {
        _topicsList.sort((b, a) =>
            _getTopicLikes(a as QueryDocumentSnapshot<Object?>).compareTo(
                _getTopicLikes(b as QueryDocumentSnapshot<Object?>)));
      } else if (dropdownvalue == "Most Disliked") {
        _topicsList.sort((b, a) =>
            _getTopicDislikes(a as QueryDocumentSnapshot<Object?>).compareTo(
                _getTopicDislikes(b as QueryDocumentSnapshot<Object?>)));
      }
    });
  }
}
