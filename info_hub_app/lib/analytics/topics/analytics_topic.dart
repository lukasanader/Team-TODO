/*
 * This file contains the code for the AnalyticsTopicView class. 
 * This shows the Topic Analytics page, which displays the topics in the database in a list format. 
 * The topics can be ordered by name, popularity, trending, likes, and dislikes.
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:info_hub_app/controller/create_topic_controllers/topic_controller.dart';
import 'package:info_hub_app/topics/view_topic/helpers/topics_card.dart';
import 'package:info_hub_app/helpers/helper.dart' show getTrending;
import 'package:info_hub_app/model/topic_model.dart';

class AnalyticsTopicView extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  const AnalyticsTopicView(
      {super.key,
      required this.auth,
      required this.firestore,
      required this.storage});

  @override
  State<AnalyticsTopicView> createState() => _AnalyticsTopicView();
}

class _AnalyticsTopicView extends State<AnalyticsTopicView> {
  // Default/Starting Variables
  List<Topic> _topicsList = [];
  int topicLength = 0;
  String dropdownvalue = "Name A-Z";

  // Retrieves topic data from database as a String/Int
  String _getTopicTitle(Topic topic) {
    return topic.title!;
  }

  int _getTopicViews(Topic topic) {
    return topic.views!;
  }

  int _getTopicLikes(Topic topic) {
    return topic.likes!;
  }

  int _getTopicDislikes(Topic topic) {
    return topic.dislikes!;
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
            // Dropdown for ordering topics
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
                  value: "Most Dislikes",
                  child: Text("Most Dislikes"),
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
                        return TopicCard(
                          widget.firestore,
                          widget.auth,
                          widget.storage,
                          _topicsList[index],
                          "adminTopic",
                        );
                      }),
                ),
        ],
      ),
    );
  }

  Future getTopicsList() async {
    // Retrieves topic data from database.
    List<Topic> topics =
        await TopicController(auth: widget.auth, firestore: widget.firestore)
            .getTopicList();

    // Amends ordering of topics on the screen when new dropdown is selected
    // or when the page is initialised for the first time.
    setState(() {
      _topicsList = topics;
      topicLength = _topicsList.length;
      if (dropdownvalue == "Name A-Z") {
        _topicsList.sort((a, b) =>
            _getTopicTitle(a as Topic).compareTo(_getTopicTitle(b as Topic)));
      } else if (dropdownvalue == "Name Z-A") {
        _topicsList.sort((b, a) =>
            _getTopicTitle(a as Topic).compareTo(_getTopicTitle(b as Topic)));
      } else if (dropdownvalue == "Most Popular") {
        _topicsList.sort((b, a) =>
            _getTopicViews(a as Topic).compareTo(_getTopicViews(b as Topic)));
      } else if (dropdownvalue == "Trending") {
        _topicsList.sort((b, a) =>
            getTrending(a as Topic).compareTo(getTrending(b as Topic)));
      } else if (dropdownvalue == "Most Likes") {
        _topicsList.sort((b, a) =>
            _getTopicLikes(a as Topic).compareTo(_getTopicLikes(b as Topic)));
      } else if (dropdownvalue == "Most Dislikes") {
        _topicsList.sort((b, a) => _getTopicDislikes(a as Topic)
            .compareTo(_getTopicDislikes(b as Topic)));
      }
    });
  }
}
