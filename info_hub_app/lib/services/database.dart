import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/models/notification.dart' as custom;

class DatabaseService {
  final String uid;
  final CollectionReference notificationsCollection;

  // Constructor
  DatabaseService({required this.uid, FirebaseFirestore? firestore})
      : notificationsCollection = (firestore ?? FirebaseFirestore.instance)
            .collection('notifications');

  // Create a notification
  Future<void> createNotification(
      String title, String body, DateTime timestamp) async {
    try {
      print('Creating notification');
      await notificationsCollection.add({
        'user': uid,
        'title': title,
        'body': body,
        'timestamp': timestamp,
      });
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      print('Deleting notification');
      await notificationsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Convert a Firestore snapshot to a list of custom notifications
  List<custom.Notification> notificationListFromSnapshot(
      QuerySnapshot snapshot) {
    print('Converting notification list from snapshot');
    final notifications = snapshot.docs.map((doc) {
      print('Converting notification');
      return custom.Notification(
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
    print('Getting notifications');
    print(notificationsCollection.snapshots().toString());
    return notificationsCollection
        .snapshots()
        .map(notificationListFromSnapshot);
  }
}
