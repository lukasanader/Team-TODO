import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/threads/name_generator.dart';

class ProfileViewController {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ProfileViewController({required this.firestore, required this.auth});

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = auth.currentUser;
    if (user != null) {
      final docRef = firestore.collection('Users');
      final querySnapshot = await docRef.get();
      final userDoc =
          querySnapshot.docs.firstWhere((doc) => doc.id == user.uid);
      return userDoc.data();
    }
    return null;
  }

  Future<void> updateSelectedProfilePhoto(String selectedPhoto) async {
    final user = auth.currentUser;
    if (user != null) {
      final docRef = firestore.collection('Users').doc(user.uid);
      await docRef.update({'selectedProfilePhoto': selectedPhoto});
    }
  }

  String getProfileName() {
    return generateUniqueName(auth.currentUser?.uid ?? '');
  }
}
