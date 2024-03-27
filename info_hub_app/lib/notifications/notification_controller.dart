import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/notifications/notification_model.dart' as custom;
import 'package:info_hub_app/notifications/preferences_controller.dart';
import 'package:info_hub_app/push_notifications/push_notifications_controller.dart';

class NotificationController {
  final FirebaseAuth auth;
  final String uid;
  final FirebaseFirestore firestore;

  NotificationController(
      {required this.auth, required this.uid, required this.firestore});

  Future<String> createNotification(String title, String body,
      DateTime timestamp, String route, String? dataId) async {
    CollectionReference notificationsCollection =
        firestore.collection('notifications');
    var docRef = await notificationsCollection.add({
      'uid': uid,
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'route': route,
      'payload': dataId,
    });

    // Send push notification to all device tokens
    // Send push notification only if push notifications preference is enabled
    final preferences =
        await PreferencesController(auth: auth, uid: uid, firestore: firestore)
            .getPreferences();
    if (preferences.isNotEmpty && preferences.first.pushNotifications) {
      await sendNotificationToDevices(
          title, body, http.Client(), FlutterLocalNotificationsPlugin());
    }
    return docRef.id;
  }

  Future<void> sendNotificationToDevices(String title, String body,
      http.Client client, FlutterLocalNotificationsPlugin plugin) async {
    final tokens = await getUserDeviceTokens();

    // Send the notification to each device token
    for (final token in tokens) {
      await PushNotifications(
              auth: auth,
              firestore: firestore,
              messaging: FirebaseMessaging.instance,
              http: client,
              localnotificationsplugin: plugin)
          .sendNotificationToDevice(token, title, body);
    }
  }

  Future<List> getUserDeviceTokens() async {
    // Query Firestore to get the device tokens for the user
    final snapshot = await firestore
        .collection('Users')
        .doc(uid)
        .collection('deviceTokens')
        .get();

    // Extract the device tokens from the snapshot
    final tokens = snapshot.docs.map((doc) => doc.get('token')).toList();

    return tokens;
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
        route: doc.get('route') ?? '',
        payload: doc.get('payload') ?? '',
        deleted: false,
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

  Future<List<String>> getNotificationIdFromPayload(String? payload) async {
    QuerySnapshot snapshot = await firestore
        .collection('notifications')
        .where('payload', isEqualTo: payload)
        .get();

    if (snapshot.docs.isEmpty) {
      return [];
    } else {
      return snapshot.docs.map((doc) => doc.id).toList();
    }
  }
}
