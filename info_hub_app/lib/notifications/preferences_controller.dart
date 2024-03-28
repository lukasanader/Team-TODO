import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/notifications/preferences_model.dart';

class PreferencesController {
  final FirebaseAuth auth;
  final String uid;
  final FirebaseFirestore firestore;

  PreferencesController(
      {required this.auth, required this.uid, required this.firestore});

// Fetches the notification preferences from Firestore
// and return the value of the push_notifications field
// as a boolean value

  Future<bool> getNotificationPreferences() async {
    final currentUser = auth.currentUser;

    final querySnapshot = await firestore
        .collection('preferences')
        .where('uid', isEqualTo: currentUser?.uid)
        .get();

    return querySnapshot.docs.first.get('push_notifications');
  }

// Updates the notification preferences in Firestore
// type: the type of notification preference to update
// newValue: the new value of the notification preference

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

// Creates the default preferences document for the user in the database
// Called when the user signs up for the first time
  Future<void> createPreferences() async {
    CollectionReference prefCollection = firestore.collection('preferences');
    await prefCollection.add({
      'uid': auth.currentUser!.uid,
      'push_notifications': true,
    });
  }

// Converts a QuerySnapshot of preferences documents to a List of Preferences objects
  List<Preferences> prefListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Preferences(
        uid: auth.currentUser!.uid,
        pushNotifications: doc.get('push_notifications') ?? true,
      );
    }).toList();
  }

// Stream of user preferences from Firestore
// Access this stream to get the user's preferences in real-time
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
