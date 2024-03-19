

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserController(
    this._auth,
    this._firestore
  );

  Future<DocumentSnapshot> getUser() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot user = await _firestore.collection('Users').doc(uid).get();

    return user;
  }

  Future<String> getUserRoleType() async {
    DocumentSnapshot user = await getUser();

    return user['roleType'];
  }

  Future<String> getEmail() async {
    DocumentSnapshot user = await getUser();
    return user['email'];
  }


}