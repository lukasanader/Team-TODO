import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/topics/topics_card.dart';

class SavedPage extends StatefulWidget {
  FirebaseFirestore firestore;
  FirebaseAuth auth;
  FirebaseStorage storage;

  //User? user = FirebaseAuth.instance.currentUser;
  SavedPage(
      {super.key,
      required this.auth,
      required this.firestore,
      required this.storage});
  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<Object> _topicsList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getTopicsList();
  }

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
          'Your Saved Topics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
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
        itemCount: _topicsList.length,
        itemBuilder: (context, index) {
          return TopicCard(
            widget.firestore,
            widget.auth,
            widget.storage,
            _topicsList[index] as QueryDocumentSnapshot<Object>,
          );
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
          setState(() {
            _topicsList = List.from(data.docs);
          });
        } else {
          // If savedTopics is empty, set _topicsList to an empty list
          setState(() {
            _topicsList = [];
          });
        }
      } else {
        // If "savedTopics" field is null or not found, set _topicsList to an empty list
        setState(() {
          _topicsList = [];
        });
      }
    } else {
      // If user document doesn't exist, set _topicsList to an empty list
      setState(() {
        _topicsList = [];
      });
    }
  }
}
