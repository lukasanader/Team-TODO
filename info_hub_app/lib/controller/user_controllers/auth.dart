import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/controller/notification_controllers/preferences_controller.dart';
import 'package:info_hub_app/controller/notification_controllers/push_notifications_controller.dart';
import 'package:info_hub_app/model/user_models/user_model.dart';
import 'package:http/http.dart' as http;

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

  /// Creates User Model
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

  /// Registers user onto the database
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
        addUserData(
          user.uid,
          firstName,
          lastName,
          email,
          roleType,
          likedTopics,
          dislikedTopics,
          hasOptedOutOfExperienceExpectations,
        );
        // Sets Preferences
        await PreferencesController(
                firestore: firestore, auth: auth, uid: user.uid)
            .createPreferences();

        // Enables push notifications
        await PushNotifications(
                auth: auth,
                firestore: firestore,
                messaging: messaging,
                http: http.Client(),
                localnotificationsplugin: localnotificationsplugin)
            .storeDeviceToken();

        // returns user model
        return _userFromFirebaseUser(user, firstName, lastName, email, roleType,
            likedTopics, dislikedTopics, hasOptedOutOfExperienceExpectations);
      }
    } catch (e) {
      return null;
    }
  }

  /// Signs in existing users and checks if users do not exist
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
                http: http.Client(),
                localnotificationsplugin: localnotificationsplugin)
            .storeDeviceToken();
        return user;
      }
    } catch (e) {
      return null;
    }
  }

  /// Adds user data into the database
  Future addUserData(
      String uid,
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
