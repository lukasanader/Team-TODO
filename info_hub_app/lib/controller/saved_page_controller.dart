import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/model/topic_model.dart';
import '../view/saved_view.dart';

/// Controller class responsible for managing the page where users view list of saved topics
class SavedPageController {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  SavedPageState screen;

  SavedPageController(
    this.auth,
    this.firestore,
    this.screen,
  );

  List<Topic> savedList = [];

  /// initializes most up-to-date saved topics list
  void initializeData() {
    final user = auth.currentUser;
    if (user != null) {
      // Listen to changes in the user's saved topics document
      firestore
          .collection('Users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        getSavedTopicsList();
      });
    }
  }

  Future<void> getSavedTopicsList() async {
    String uid = auth.currentUser!.uid;

    // Get the user document
    DocumentSnapshot userDoc =
        await firestore.collection('Users').doc(uid).get();

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
          QuerySnapshot data = await firestore
              .collection('topics')
              .where(FieldPath.documentId, whereIn: savedTopics)
              .get();

          savedList = data.docs.map((doc) => Topic.fromSnapshot(doc)).toList();
          screen.updateState();
        } else {
          // If savedTopics is empty, set savedList to an empty list
          savedList = [];
          screen.updateState();
        }
      } else {
        // If "savedTopics" field is null or not found, set savedList to an empty list
        savedList = [];
        screen.updateState();
      }
    } else {
      // If user document doesn't exist, set savedList to an empty list

      savedList = [];
      screen.updateState();
    }
  }
}
