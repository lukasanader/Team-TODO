import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/models/notification.dart' as custom;
import 'package:info_hub_app/models/user_model.dart';
import 'package:info_hub_app/models/preferences.dart';

class DatabaseService {
  final String uid;
  final FirebaseFirestore firestore;

  DatabaseService({required this.uid, required this.firestore});

  Future<String> createNotification(
      String title, String body, DateTime timestamp) async {
    CollectionReference notificationsCollection =
        firestore.collection('notifications');
    var docRef = await notificationsCollection.add({
      'uid': uid,
      'title': title,
      'body': body,
      'timestamp': timestamp,
    });
    return docRef.id;
  }

  Future<void> deleteNotification(String id) async {
    CollectionReference notificationsCollection =
        firestore.collection('notifications');
    await notificationsCollection.doc(id).delete();
  }

  List<custom.Notification> notificationListFromSnapshot(
      QuerySnapshot snapshot) {
    final notifications = snapshot.docs.map((doc) {
      return custom.Notification(
        id: doc.id,
        uid: doc.get('uid') ?? '',
        title: doc.get('title') ?? '',
        body: doc.get('body') ?? '',
        timestamp: doc.get('timestamp').toDate() ?? DateTime.now(),
      );
    }).toList();

    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return notifications;
  }

  Stream<List<custom.Notification>> get notifications {
    CollectionReference notificationsCollection =
        firestore.collection('notifications');
    return notificationsCollection
        .snapshots()
        .map(notificationListFromSnapshot);
  }

  Future<void> addUserData(
      String firstName, String lastName, String email, String roleType) async {
    CollectionReference usersCollectionRef = firestore.collection('Users');
    await usersCollectionRef.doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'roleType': roleType,
    });
  }

  List<UserModel> userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserModel(
        uid: doc.id,
        firstName: doc.get('firstName') ?? '',
        lastName: doc.get('lastName') ?? '',
        email: doc.get('email') ?? '',
        roleType: doc.get('roleType') ?? '',
      );
    }).toList();
  }

  Stream<List<UserModel>> get users {
    CollectionReference usersCollectionRef = firestore.collection('Users');
    return usersCollectionRef.snapshots().map(userListFromSnapshot);
  }

  Future<void> createPreferences() async {
    CollectionReference prefCollection = firestore.collection('preferences');
    await prefCollection.add({
      'uid': uid,
      'push_notifications': true,
    });
  }

  List<Preferences> prefListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Preferences(
        uid: uid,
        push_notifications: doc.get('push_notifications') ?? true,
      );
    }).toList();
  }

  Stream<List<Preferences>> get preferences {
    CollectionReference prefCollectionRef = firestore.collection('preferences');
    return prefCollectionRef.snapshots().map(prefListFromSnapshot);
  }
}
