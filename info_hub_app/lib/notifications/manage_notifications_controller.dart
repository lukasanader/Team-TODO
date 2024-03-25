import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageNotificationsController {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  ManageNotificationsController({required this.auth, required this.firestore});

  Future<bool> getNotificationPreferences() async {
    final currentUser = auth.currentUser;

    final querySnapshot = await firestore
        .collection('preferences')
        .where('uid', isEqualTo: currentUser?.uid)
        .get();

    return querySnapshot.docs.first.get('push_notifications');
  }

  Future<void> updateNotificationPreferences(String type, bool newValue) async {
    final currentUser = auth.currentUser;

    await firestore
        .collection('preferences')
        .where('uid', isEqualTo: currentUser?.uid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.first.reference.update({type: newValue});
    });
  }
}
