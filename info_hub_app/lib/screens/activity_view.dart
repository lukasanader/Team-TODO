import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/controller/activity_controller.dart';
import 'package:info_hub_app/helpers/activity_card.dart';
import 'package:info_hub_app/topics/view_topic/helpers/topics_card.dart';

class ActivityView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  const ActivityView({
    super.key,
    required this.firestore,
    required this.auth,
    required this.storage,
  });

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  List<dynamic> _topicsList = [];
  List<dynamic> _likedTopics = [];
  List<dynamic> _threadList = [];

  @override
  void initState() {
    super.initState();
    _getActivityList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              textAlign: TextAlign.left,
              'Viewed Topics',
            ),
            SizedBox(
              height: 250,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _topicsList.length,
                itemBuilder: (context, index) {
                  return TopicCard(widget.firestore, widget.auth,
                      widget.storage, _topicsList[index], "topic");
                },
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Text(
              textAlign: TextAlign.left,
              'Liked Topics',
            ),
            SizedBox(
              height: 250,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _likedTopics.length,
                itemBuilder: (context, index) {
                  return TopicCard(widget.firestore, widget.auth,
                      widget.storage, _likedTopics[index], "topic");
                },
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Text(
              textAlign: TextAlign.left,
              'Replied threads',
            ),
            SizedBox(
              height: 250,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _threadList.length,
                itemBuilder: (context, index) {
                  return ActivityCard(
                    _threadList[index],
                    widget.firestore,
                    widget.auth,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch activity lists from the database
  Future<void> _getActivityList() async {
    ActivityController controller =
        ActivityController(firestore: widget.firestore, auth: widget.auth);

    final List<dynamic> topicTemp = await controller.getActivityList('topics');
    final List<dynamic> threadTemp = await controller.getActivityList('thread');
    final List<dynamic> likedTemp = await controller.getLikedTopics();

    setState(() {
      _topicsList = topicTemp;
      _topicsList.sort((a, b) {
        final DateTime dateA = a.viewDate.toDate();
        final DateTime dateB = b.viewDate.toDate();
        return dateB.compareTo(dateA);
      });

      _threadList = threadTemp;
      _threadList.sort((a, b) {
        final DateTime dateA = a['viewDate'].toDate();
        final DateTime dateB = b['viewDate'].toDate();
        return dateB.compareTo(dateA);
      });

      _likedTopics = likedTemp;
    });
  }
}
