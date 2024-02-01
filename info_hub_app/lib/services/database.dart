import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/models/notification.dart' as custom;

class DatabaseService {
  final String uid;

  // Constructor
  DatabaseService({required this.uid});

  // Collection reference
  final CollectionReference notificationsCollection =
      FirebaseFirestore.instance.collection('notifications');

  // Update user data
  Future<void> updateUserData(
      String title, String body, DateTime timestamp) async {
    try {
      await notificationsCollection.doc(uid).set({
        'title': title,
        'body': body,
        'timestamp': timestamp,
      });
    } catch (e) {
      print('Error updating user data: $e');
      throw e;
    }
  }

  // Create a notification
  Future<void> createNotification(
      String title, String body, DateTime timestamp) async {
    try {
      await notificationsCollection.doc(uid).set({
        'id': uid,
        'title': title,
        'body': body,
        'timestamp': timestamp,
      });
    } catch (e) {
      print('Error creating notification: $e');
      throw e;
    }
  }

  // Convert a Firestore snapshot to a list of custom notifications
  List<custom.Notification> notificationListFromSnapshot(
      QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return custom.Notification(
        id: doc.id,
        title: doc.get('title') ?? '',
        message: doc.get('message') ?? '',
        timestamp: doc.get('timestamp').toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  // Get notifications stream
  Stream<List<custom.Notification>> get notifications {
    return notificationsCollection
        .snapshots()
        .map(notificationListFromSnapshot);
  }
}
