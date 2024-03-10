import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/services/database.dart';

class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthService({required this.firestore, required this.auth});

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

  Stream<User?> get user {
    return auth.authStateChanges();
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
        await DatabaseService(firestore: firestore, uid: user.uid).addUserData(
            firstName,
            lastName,
            email,
            roleType,
            likedTopics,
            dislikedTopics,
            hasOptedOutOfExperienceExpectations);
        await DatabaseService(firestore: firestore, uid: user.uid)
            .createPreferences();
        // create user model
        return _userFromFirebaseUser(user, firstName, lastName, email, roleType,
            likedTopics, dislikedTopics, hasOptedOutOfExperienceExpectations);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }

  Future signInUser(String email, String password) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        return user;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return null;
    }
  }
}
