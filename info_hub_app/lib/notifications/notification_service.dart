import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/notifications/preferences_service.dart';
import 'package:info_hub_app/push_notifications/push_notifications_controller.dart';

class NotificationService {
  final FirebaseAuth auth;
  final String uid;
  final FirebaseFirestore firestore;

  NotificationService(
      {required this.auth, required this.uid, required this.firestore});

  static Future<String> createNotification(
      String uid,
      String title,
      String body,
      DateTime timestamp,
      String route,
      FirebaseFirestore firestore,
      FirebaseAuth auth,
      http.Client client,
      FlutterLocalNotificationsPlugin plugin) async {
    CollectionReference notificationsCollection =
        firestore.collection('notifications');
    var docRef = await notificationsCollection.add({
      'uid': uid,
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'route': route,
    });

    // Send push notification to all device tokens
    // Send push notification only if push notifications preference is enabled
    final preferences =
        await PreferencesService(auth: auth, uid: uid, firestore: firestore)
            .getPreferences();
    if (preferences.isNotEmpty && preferences.first.push_notifications) {
      final tokens = await getUserDeviceTokens(uid, firestore);
      await sendNotificationToDevices(
          uid, tokens, title, body, client, plugin, auth, firestore);
    }
    return docRef.id;
  }

  static Future<void> deleteNotification(
      String id, FirebaseFirestore firestore) async {
    CollectionReference notificationsCollection =
        firestore.collection('notifications');
    await notificationsCollection.doc(id).delete();
  }

  static Future<List> getUserDeviceTokens(
      String uid, FirebaseFirestore firestore) async {
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

  static Future<void> sendNotificationToDevices(
      String uid,
      List tokens,
      String title,
      String body,
      http.Client client,
      FlutterLocalNotificationsPlugin plugin,
      FirebaseAuth auth,
      FirebaseFirestore firestore) async {
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
}
