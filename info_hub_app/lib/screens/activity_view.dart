import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/helpers/activity_card.dart';
import 'package:info_hub_app/services/database.dart';

class ActivityView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const ActivityView({super.key, required this.firestore, required this.auth});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  List<dynamic> _topicsList = [];
  List<dynamic> _likedTopics = [];
  List<dynamic> _threadList = [];

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    getActivityList();
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
              Container(
                height: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _topicsList.isEmpty
                      ? 0
                      : _topicsList
                          .length, // Replace with the actual number of items
                  itemBuilder: (context, index) {
                    return ActivityCard(
                        _topicsList[index], widget.firestore, widget.auth);
                  },
                ),
              ),
              const Text(
                textAlign: TextAlign.left,
                'Liked Topics',
              ),
              Container(
                height: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _likedTopics.isEmpty
                      ? 0
                      : _likedTopics
                          .length, // Replace with the actual number of items
                  itemBuilder: (context, index) {
                    return ActivityCard(
                        _likedTopics[index], widget.firestore, widget.auth);
                  },
                ),
              ),
              SizedBox(
                height: 40,
              ),
              const Text(
                textAlign: TextAlign.left,
                'Replied threads',
              ),
              Container(
                height: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _threadList.isEmpty
                      ? 0
                      : _threadList
                          .length, // Replace with the actual number of items
                  itemBuilder: (context, index) {
                    return ActivityCard(
                        _threadList[index], widget.firestore, widget.auth);
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Future getActivityList() async {
    List<dynamic> topicTemp = await DatabaseService(
            uid: widget.auth.currentUser!.uid, firestore: widget.firestore)
        .getActivityList('topics');
    List<dynamic> threadTemp = await DatabaseService(
            uid: widget.auth.currentUser!.uid, firestore: widget.firestore)
        .getActivityList('thread');
    List<dynamic>? likedTemp = await DatabaseService(
            uid: widget.auth.currentUser!.uid, firestore: widget.firestore)
        .getLikedTopics();

    setState(() {
      _topicsList = topicTemp;
      _topicsList.sort(((a, b) {
        DateTime dateA = a['viewDate'].toDate();
        DateTime dateB = b['viewDate'].toDate();
        return dateB.compareTo(dateA);
      }));
      _threadList = threadTemp;
      _threadList.sort(((a, b) {
        DateTime dateA = a['viewDate'].toDate();
        DateTime dateB = b['viewDate'].toDate();
        return dateB.compareTo(dateA);
      }));
      _likedTopics = likedTemp;
    });
  }
}
