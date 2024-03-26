import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseAuth auth;
  final String uid;
  final FirebaseFirestore firestore;

  DatabaseService(
      {required this.auth, required this.uid, required this.firestore});

  Future addUserData(
      String firstName,
      String lastName,
      String email,
      String roleType,
      List<String> likedTopics,
      List<String> dislikedTopics,
      bool hasOptedOutOfExperienceExpectations) async {
    CollectionReference usersCollectionRef = firestore.collection('Users');
    if (roleType == 'Patient') {
      // If you are a patient, you have access to the story expectations
      return await usersCollectionRef.doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'roleType': roleType,
        'likedTopics': likedTopics,
        'dislikedTopics': dislikedTopics,
        'hasOptedOutOfExperienceExpectations':
            hasOptedOutOfExperienceExpectations,
      });
    }
    return await usersCollectionRef.doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'roleType': roleType,
      'likedTopics': likedTopics,
      'dislikedTopics': dislikedTopics,
    });
  }
}
