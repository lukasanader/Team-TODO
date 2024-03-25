import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:info_hub_app/main.dart';

class PushNotifications {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin localnotificationsplugin;
  final nav;
  final http;

  PushNotifications(
      {required this.auth,
      required this.firestore,
      required this.messaging,
      required this.localnotificationsplugin,
      this.nav,
      this.http});

  // Initialize Firebase Messaging
  Future<void> init() async {
    messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // Initialize local notifications
  Future<void> localNotiInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);
    localnotificationsplugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  // Handle tap on local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    navigatorKey.currentState!
      ..popUntil((route) => false)
      ..pushNamed('/base')
      ..pushNamed('/notifications');
  }

  // Show a simple notification
  Future<void> showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await localnotificationsplugin.show(0, title, body, notificationDetails,
        payload: payload);
  }

  // Send notification to a specific device
  Future<void> sendNotificationToDevice(
      String deviceToken, String title, String body) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    const serverKey =
        'AAAACxHw_LY:APA91bH8JoD5auNiTLZ0apLI5G6Rj77i0t_g6NAzZIRX2rqO5rL4R5u6YCv1Osw9-T4pJoS8bp-UBRck3KAIo_xMoocGj-2QMT27QuqKuH81udKbfgHbCRzaLZBCH8uEmWlTOIXxNDf0';
    final Map<String, dynamic> data = {
      'notification': {
        'title': title,
        'body': body,
      },
      'to': deviceToken,
    };

    await http.post(
      url,
      body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
    );
  }

  // Store device token in Firestore if it doesn't exist already
  Future<void> storeDeviceToken() async {
    final String? deviceToken = await messaging.getToken();
    if (kDebugMode) {
      print('Token: $deviceToken');
    }
    if (deviceToken != null) {
      final tokenSnapshot = await firestore
          .collection('Users')
          .doc(auth.currentUser!.uid)
          .collection('deviceTokens')
          .where('token', isEqualTo: deviceToken)
          .get();

      if (tokenSnapshot.docs.isEmpty) {
        await firestore
            .collection('Users')
            .doc(auth.currentUser!.uid)
            .collection('deviceTokens')
            .add({
          'token': deviceToken,
        });
      }
    }
  }
}
