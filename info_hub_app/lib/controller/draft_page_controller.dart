import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/model/topic_model.dart';
import '../view/drafts_view.dart';

/// Controller class responsible for managing the Page where admins view list of drafts
class DraftPageController {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  DraftsPageState screen;

  DraftPageController(
    this.auth,
    this.firestore,
    this.screen,
  );

  List<Topic> draftsList = [];

  /// Initializes form data based on whether the form is for editing an existing topic or creating a new one.
  void initializeData() {
    final user = auth.currentUser;
    if (user != null) {
      // Listen to changes in the user's drafted topics document
      firestore
          .collection('Users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        getDraftsList();
      });
    }
  }

  Future<void> getDraftsList() async {
    String uid = auth.currentUser!.uid;

    // Get the user document
    DocumentSnapshot userDoc =
        await firestore.collection('Users').doc(uid).get();

    // Check if the user document exists and contains the "draftedTopics" field
    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      if (userData.containsKey('draftedTopics') &&
          userData['draftedTopics'] != null) {
        // Get the list of drafted topics
        List<String> draftedTopics =
            List<String>.from(userData['draftedTopics']);

        // Check if draftedTopics is not empty
        if (draftedTopics.isNotEmpty) {
          // Query topics using draftedTopics
          QuerySnapshot data = await firestore
              .collection('topicDrafts')
              .where(FieldPath.documentId, whereIn: draftedTopics)
              .get();

          draftsList = data.docs.map((doc) => Topic.fromSnapshot(doc)).toList();
          screen.updateState();
        } else {
          // If draftedTopics is empty, set _draftsList to an empty list

          draftsList = [];
          screen.updateState();
        }
      } else {
        // If "draftedTopics" field is null or not found, set _draftsList to an empty list
        draftsList = [];
        screen.updateState();
      }
    } else {
      // If user document doesn't exist, set _draftsList to an empty list
      draftsList = [];
      screen.updateState();
    }
  }
}
