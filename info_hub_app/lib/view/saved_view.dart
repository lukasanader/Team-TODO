import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/helpers/topics_card.dart';
import '../controller/saved_page_controller.dart';

class SavedPage extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  const SavedPage(
      {super.key,
      required this.auth,
      required this.firestore,
      required this.storage});
  @override
  State<SavedPage> createState() => SavedPageState();
}

class SavedPageState extends State<SavedPage> {
  late SavedPageController savedController;

  @override
  void initState() {
    super.initState();
    savedController = SavedPageController(widget.auth, widget.firestore, this);
    savedController.initializeData();
  }

  void updateState() {
    if (mounted) {
      setState(() {});
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
        child: _buildSavedTopicsList(),
      ),
    );
  }

  Widget _buildSavedTopicsList() {
    if (savedController.savedList.isEmpty) {
      return const Center(
        child: Text('No saved topics'),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: savedController.savedList.isEmpty
            ? 0
            : savedController.savedList.length * 2 - 1,
        itemBuilder: (context, index) {
          if (index.isOdd) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 1,
                color: Colors.grey,
              ),
            );
          } else {
            final topicIndex = index ~/ 2;
            return TopicCard(widget.firestore, widget.auth, widget.storage,
                savedController.savedList[topicIndex], "topic");
          }
        },
      );
    }
  }
}
