import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/topics/view_topic/helpers/topics_card.dart';
import 'package:info_hub_app/topics/create_topic/model/topic_model.dart';

class SavedPage extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  //User? user = FirebaseAuth.instance.currentUser;
  const SavedPage(
      {super.key,
      required this.auth,
      required this.firestore,
      required this.storage});
  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<Topic> _topicsList = [];

  @override
  void initState() {
    super.initState();
    // Get the current user
    final user = widget.auth.currentUser;
    if (user != null) {
      // Listen to changes in the user's saved topics document
      widget.firestore
          .collection('Users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        getTopicsList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Topics',
        ),
      ),
      body: SingleChildScrollView(
        child: _buildTopicsList(),
      ),
    );
  }

  Widget _buildTopicsList() {
    if (_topicsList.isEmpty) {
      return const Center(
        child: Text('No saved topics'),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: _topicsList.isEmpty ? 0 : _topicsList.length * 2 - 1,
        itemBuilder: (context, index) {
          if (index.isOdd) {
            // Add Padding and Container between TopicCards
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 1,
                color: Colors.grey,
              ),
            );
          } else {
            final topicIndex = index ~/ 2;
            return TopicCard(
              widget.firestore,
              widget.auth,
              widget.storage,
              _topicsList[topicIndex],
            );
          }
        },
      );
    }
  }

  Future<void> getTopicsList() async {
    String uid = widget.auth.currentUser!.uid;

    // Get the user document
    DocumentSnapshot userDoc =
        await widget.firestore.collection('Users').doc(uid).get();

    // Check if the user document exists and contains the "savedTopics" field
    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      // Check if "savedTopics" field exists and is not null
      if (userData.containsKey('savedTopics') &&
          userData['savedTopics'] != null) {
        // Get the list of saved topics
        List<String> savedTopics = List<String>.from(userData['savedTopics']);

        // Check if savedTopics is not empty
        if (savedTopics.isNotEmpty) {
          // Query topics using savedTopics
          QuerySnapshot data = await widget.firestore
              .collection('topics')
              .where(FieldPath.documentId, whereIn: savedTopics)
              .get();
          if (mounted) {
            setState(() {
              _topicsList =
                  data.docs.map((doc) => Topic.fromSnapshot(doc)).toList();
            });
          }
        } else {
          // If savedTopics is empty, set _topicsList to an empty list
          if (mounted) {
            setState(() {
              _topicsList = [];
            });
          }
        }
      } else {
        // If "savedTopics" field is null or not found, set _topicsList to an empty list
        if (mounted) {
          setState(() {
            _topicsList = [];
          });
        }
      }
    } else {
      // If user document doesn't exist, set _topicsList to an empty list
      if (mounted) {
        setState(() {
          _topicsList = [];
        });
      }
    }
  }
}
