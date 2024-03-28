import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/view/topic_view/topics_card.dart';
import '../../controller/draft_controllers/draft_page_controller.dart';

/// This view is responsible for showing admin their list of drafted topics
class DraftsPage extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  const DraftsPage(
      {super.key,
      required this.auth,
      required this.firestore,
      required this.storage});
  @override
  State<DraftsPage> createState() => DraftsPageState();
}

class DraftsPageState extends State<DraftsPage> {
  late DraftPageController draftController;

  @override
  void initState() {
    super.initState();
    draftController = DraftPageController(widget.auth, widget.firestore, this);
    draftController.initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Drafts',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: _buildDraftsList(),
      ),
    );
  }

  /// Refreshes the screen
  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildDraftsList() {
    if (draftController.draftsList.isEmpty) {
      return const Center(
        child: Text('No drafts'),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: draftController.draftsList.length,
        itemBuilder: (context, index) {
          return TopicCard(widget.firestore, widget.auth, widget.storage,
              draftController.draftsList[index], "draft");
        },
      );
    }
  }
}
