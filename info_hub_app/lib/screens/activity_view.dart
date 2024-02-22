
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/helpers/activity_card.dart';
import 'package:info_hub_app/services/database.dart';

class ActivityView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const ActivityView({super.key,required this.firestore,required this.auth});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  List<dynamic> _topicsList = [];


  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    getTopicsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity"),
      ),
      body: Column(
        children: [
          const Text(textAlign: TextAlign.left,
          
          'Topics',
          ),
          Container(
            height: 250,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount:_topicsList.isEmpty ? 0 : _topicsList.length, // Replace with the actual number of items
              itemBuilder: (context, index) {
                return ActivityCard(_topicsList[index], widget.firestore, widget.auth);
              },
            ),
          ),
          SizedBox(height: 40,),
          Container(
            height: 250,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5, // Replace with the actual number of items
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('comment $index'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Future getTopicsList() async {
    List<dynamic> temp = await DatabaseService(uid: widget.auth.currentUser!.uid,firestore: widget.firestore).getActivityList('topics');
    setState(() {
      _topicsList = temp;
      _topicsList.sort(((a, b) {
        DateTime dateA = a['viewDate'].toDate();
        DateTime dateB = b['viewDate'].toDate();
        return dateB.compareTo(dateA);
    }));
  });
}
}