import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/notifications/manage_notifications_model.dart';

class PreferencesService {
  final FirebaseAuth auth;
  final String uid;
  final FirebaseFirestore firestore;

  PreferencesService(
      {required this.auth, required this.uid, required this.firestore});

  static Future<void> createPreferences(
      FirebaseAuth auth, FirebaseFirestore firestore) async {
    CollectionReference prefCollection = firestore.collection('preferences');
    await prefCollection.add({
      'uid': auth.currentUser!.uid,
      'push_notifications': true,
    });
  }

  static List<Preferences> prefListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Preferences(
        uid: doc.get('uid'),
        push_notifications: doc.get('push_notifications') ?? true,
      );
    }).toList();
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
              push_notifications: doc.get('push_notifications'),
            ))
        .toList();

    return preferences;
  }

  Stream<List<Preferences>> get preferences {
    CollectionReference prefCollectionRef = firestore.collection('preferences');
    return prefCollectionRef.snapshots().map(prefListFromSnapshot);
  }
}
