import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/notifications/preferences_model.dart';

class PreferencesController {
  final FirebaseAuth auth;
  final String uid;
  final FirebaseFirestore firestore;

  PreferencesController(
      {required this.auth, required this.uid, required this.firestore});

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

  Future<void> createPreferences() async {
    CollectionReference prefCollection = firestore.collection('preferences');
    await prefCollection.add({
      'uid': auth.currentUser!.uid,
      'push_notifications': false,
    });
  }

  List<Preferences> prefListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Preferences(
        uid: auth.currentUser!.uid,
        pushNotifications: doc.get('push_notifications') ?? false,
      );
    }).toList();
  }

  Stream<List<Preferences>> get preferences {
    CollectionReference prefCollectionRef = firestore.collection('preferences');
    return prefCollectionRef.snapshots().map(prefListFromSnapshot);
  }

  Future<List<Preferences>> getPreferences() async {
    // Fetch user preferences from Firestore
    final snapshot = await firestore
        .collection('preferences')
        .where('uid', isEqualTo: uid)
        .get();

    // Convert preferences snapshot to a list of Preferences objects
    final preferences = snapshot.docs
        .map((doc) => Preferences(
              uid: doc.get('uid'),
              pushNotifications: doc.get('push_notifications'),
            ))
        .toList();

    return preferences;
  }
}
