import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/notifications/notification.dart' as custom;
import 'package:info_hub_app/push_notifications/push_notifications.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/notifications/preferences.dart';

class DatabaseService {
  final FirebaseAuth auth;
  final String uid;
  final FirebaseFirestore firestore;

  DatabaseService(
      {required this.auth, required this.uid, required this.firestore});

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

    // Send push notification to all device tokens
    // Send push notification only if push notifications preference is enabled
    final preferences = await getPreferences();
    if (preferences.isNotEmpty && preferences.first.push_notifications) {
      await sendNotificationToDevices(title, body);
    }
    return docRef.id;
  }

  Future<void> sendNotificationToDevices(String title, String body) async {
    // Get the device tokens for the user
    final tokens = await getUserDeviceTokens();

    // Send the notification to each device token
    for (final token in tokens) {
      await PushNotifications(
              uid: uid,
              firestore: firestore,
              messaging: FirebaseMessaging.instance,
              localnotificationsplugin: FlutterLocalNotificationsPlugin())
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

  Future addUserData(
      String firstName,
      String lastName,
      String email,
      String roleType,
      List<String> likedTopics,
      List<String> dislikedTopics) async {
    CollectionReference usersCollectionRef = firestore.collection('Users');
    return await usersCollectionRef.doc(auth.currentUser!.uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'roleType': roleType,
      'likedTopics': likedTopics,
      'dislikedTopics': dislikedTopics
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
        likedTopics: doc.get('likedTopics') ?? [],
        dislikedTopics: doc.get('dislikedTopics') ?? [],
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
      'uid': auth.currentUser!.uid,
      'push_notifications': true,
    });
  }

  List<Preferences> prefListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Preferences(
        uid: auth.currentUser!.uid,
        push_notifications: doc.get('push_notifications') ?? true,
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
              push_notifications: doc.get('push_notifications'),
            ))
        .toList();

    return preferences;
  }
}
