import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/notifications/notification_model.dart' as custom;
import 'package:info_hub_app/push_notifications/push_notifications.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/notifications/preferences_model.dart';
import 'package:http/http.dart' as http;
import 'package:info_hub_app/topics/create_topic/model/topic_model.dart';

class DatabaseService {
  final FirebaseAuth auth;
  final String uid;
  final FirebaseFirestore firestore;

  DatabaseService(
      {required this.auth, required this.uid, required this.firestore});

  Future<String> createNotification(
      String title, String body, DateTime timestamp, String route) async {
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
    final preferences = await getPreferences();
    if (preferences.isNotEmpty && preferences.first.push_notifications) {
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
              nav: navigatorKey,
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
      List<String> dislikedTopics,
      bool hasOptedOutOfExperienceExpectations) async {
    CollectionReference usersCollectionRef = firestore.collection('Users');
    if (roleType == 'Patient') {
      // If you are a patient, you have access to the story expectations
      return await usersCollectionRef.doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'roleType': roleType,
        'likedTopics': likedTopics,
        'dislikedTopics': dislikedTopics,
        'hasOptedOutOfExperienceExpectations':
            hasOptedOutOfExperienceExpectations,
      });
    }
    return await usersCollectionRef.doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'roleType': roleType,
      'likedTopics': likedTopics,
      'dislikedTopics': dislikedTopics,
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
        hasOptedOutOfExperienceExpectations:
            doc.get('hasOptedOutOfExperienceExpectations') ?? false,
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

  Future<void> incrementView(Topic topic) async {
    DocumentReference docRef = firestore.collection('topics').doc(topic.id);
    // Run the transaction
    await firestore.runTransaction((transaction) async {
      // Get the latest snapshot of the document
      DocumentSnapshot snapshot = await transaction.get(docRef);
      int currentViews =
          (snapshot.data() as Map<String, dynamic>)['views'] ?? 0;
      // Increment the views by one
      int newViews = currentViews + 1;
      // Update the 'views' field in Firestore
      transaction.update(docRef, {'views': newViews});
    });
  }
}
