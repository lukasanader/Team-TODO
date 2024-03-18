import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/topics/topics_card.dart';

class DraftsPage extends StatefulWidget {
  FirebaseFirestore firestore;
  FirebaseAuth auth;
  FirebaseStorage storage;

  //User? user = FirebaseAuth.instance.currentUser;
  DraftsPage(
      {super.key,
      required this.auth,
      required this.firestore,
      required this.storage});
  @override
  State<DraftsPage> createState() => _DraftsPageState();
}

class _DraftsPageState extends State<DraftsPage> {
  List<Object> _draftsList = [];

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
        getDraftsList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Drafts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: _buildDraftsList(),
      ),
    );
  }

  Widget _buildDraftsList() {
    if (_draftsList.isEmpty) {
      return const Center(
        child: Text('No drafts'),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: _draftsList.length,
        itemBuilder: (context, index) {
          return TopicDraftCard(
            widget.firestore,
            widget.auth,
            widget.storage,
            _draftsList[index] as QueryDocumentSnapshot<Object>,
          );
        },
      );
    }
  }

  Future<void> getDraftsList() async {
    String uid = widget.auth.currentUser!.uid;

    // Get the user document
    DocumentSnapshot userDoc =
        await widget.firestore.collection('Users').doc(uid).get();

    // Check if the user document exists and contains the "draftedTopics" field
    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      if (userData.containsKey('draftedTopics') &&
          userData['draftedTopics'] != null) {
        // Get the list of drafted topics
        List<String> draftedTopics =
            List<String>.from(userData['draftedTopics']);

        // Check if savedTopics is not empty
        if (draftedTopics.isNotEmpty) {
          // Query topics using savedTopics
          QuerySnapshot data = await widget.firestore
              .collection('topicDrafts')
              .where(FieldPath.documentId, whereIn: draftedTopics)
              .get();
          setState(() {
            _draftsList = List.from(data.docs);
          });
        } else {
          // If savedTopics is empty, set _topicsList to an empty list
          setState(() {
            _draftsList = [];
          });
        }
      } else {
        // If "savedTopics" field is null or not found, set _topicsList to an empty list
        setState(() {
          _draftsList = [];
        });
      }
    } else {
      // If user document doesn't exist, set _topicsList to an empty list
      setState(() {
        _draftsList = [];
      });
    }
  }
}
