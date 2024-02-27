import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:info_hub_app/notifications/notification.dart' as custom;

class DatabaseService {
  final String uid;
  final FirebaseFirestore firestore;

  // Constructor
  DatabaseService({required this.uid, required this.firestore});

  // Create a notification
  Future<String> createNotification(
      String title, String body, DateTime timestamp) async {
        CollectionReference notificationsCollection = firestore.collection('notifications');
    try {
      if (kDebugMode) {
        print('Creating notification');
      }
      var docRef = await notificationsCollection.add({
        'user': uid,
        'title': title,
        'body': body,
        'timestamp': timestamp,
      });
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating notification: $e');
      }
      rethrow;
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String id) async {
    CollectionReference notificationsCollection = firestore.collection('notifications');
    try {
      if (kDebugMode) {
        print('Deleting notification');
      }
      await notificationsCollection.doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notification: $e');
      }
      rethrow;
    }
  }

  // Convert a Firestore snapshot to a list of custom notifications
  List<custom.Notification> notificationListFromSnapshot(
      QuerySnapshot snapshot) {
    if (kDebugMode) {
      print('Converting notification list from snapshot');
    }
    final notifications = snapshot.docs.map((doc) {
      if (kDebugMode) {
        print('Converting notification');
      }
      return custom.Notification(
        id: doc.id,
        user: doc.get('user') ?? '',
        title: doc.get('title') ?? '',
        body: doc.get('body') ?? '',
        timestamp: doc.get('timestamp').toDate() ?? DateTime.now(),
      );
    }).toList();

    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return notifications;
  }

  // Get notifications stream
  Stream<List<custom.Notification>> get notifications {
    CollectionReference notificationsCollection = firestore.collection('notifications');
    if (kDebugMode) {
      print('Getting notifications');
    }
    if (kDebugMode) {
      print(notificationsCollection.snapshots().toString());
    }
    return notificationsCollection
        .snapshots()
        .map(notificationListFromSnapshot);
  }
   Future addUserData(String firstName, String lastName,String email,String roleType) async {
    CollectionReference usersCollectionRef = firestore.collection('Users');
    return await usersCollectionRef.doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'roleType': roleType,
    });
  }
}
