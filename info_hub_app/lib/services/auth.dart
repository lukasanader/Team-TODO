import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/notifications/preferences_service.dart';
import 'package:info_hub_app/push_notifications/push_notifications_controller.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/services/database.dart';

class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin localnotificationsplugin;

  AuthService(
      {required this.firestore,
      required this.auth,
      required this.messaging,
      required this.localnotificationsplugin});

  // create user model
  UserModel? _userFromFirebaseUser(
      User user,
      String firstName,
      String lastName,
      String email,
      String roleType,
      List<String> likedTopics,
      List<String> dislikedTopics,
      bool hasOptedOutOfExperienceExpectations) {
    return UserModel(
        uid: user.uid,
        firstName: firstName,
        email: email,
        lastName: lastName,
        roleType: roleType,
        likedTopics: likedTopics,
        dislikedTopics: dislikedTopics,
        hasOptedOutOfExperienceExpectations: false);
  }

  // register user
  Future registerUser(
    String firstName,
    String lastName,
    String email,
    String password,
    String roleType,
    List<String> likedTopics,
    List<String> dislikedTopics,
    bool hasOptedOutOfExperienceExpectations,
  ) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await DatabaseService(firestore: firestore, auth: auth, uid: user.uid)
            .addUserData(
          firstName,
          lastName,
          email,
          roleType,
          likedTopics,
          dislikedTopics,
          hasOptedOutOfExperienceExpectations,
        );
        await PreferencesService(
                firestore: firestore, auth: auth, uid: user.uid)
            .createPreferences();

        await PushNotifications(
                auth: auth,
                firestore: firestore,
                messaging: messaging,
                localnotificationsplugin: localnotificationsplugin)
            .storeDeviceToken();

        // create user model
        return _userFromFirebaseUser(user, firstName, lastName, email, roleType,
            likedTopics, dislikedTopics, hasOptedOutOfExperienceExpectations);
      }
    } catch (e) {
      return null;
    }
  }

  Future signInUser(String email, String password) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await PushNotifications(
                auth: auth,
                firestore: firestore,
                messaging: messaging,
                localnotificationsplugin: localnotificationsplugin)
            .storeDeviceToken();
        return user;
      }
    } catch (e) {
      return null;
    }
  }
}
