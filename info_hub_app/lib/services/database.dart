import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/notifications/notification_model.dart' as custom;
import 'package:info_hub_app/push_notifications/push_notifications_controller.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/notifications/manage_notifications_model.dart';
import 'package:http/http.dart' as http;
import 'package:info_hub_app/topics/create_topic/model/topic_model.dart';

class DatabaseService {
  final FirebaseAuth auth;
  final String uid;
  final FirebaseFirestore firestore;

  DatabaseService(
      {required this.auth, required this.uid, required this.firestore});

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
}
