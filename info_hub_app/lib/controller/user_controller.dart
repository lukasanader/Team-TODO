

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserController(
    this._auth,
    this._firestore
  );

  Future<DocumentSnapshot> getCurrentUser() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot user = await _firestore.collection('Users').doc(uid).get();

    return user;
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    DocumentSnapshot user = await _firestore.collection('Users').doc(uid).get();
    return user;
  }

  Future<String> getUserRoleType() async {
    DocumentSnapshot user = await getCurrentUser();

    return user['roleType'];
  }

  Future<String> getCurrentUserEmail() async {
    DocumentSnapshot user = await getCurrentUser();
    return user['email'];
  }

  String getEmail(QueryDocumentSnapshot user) {
    return user['email'];
  }

  Future<List<Object>> getUserListBasedOnRoleType(String roleType) async {
    QuerySnapshot data = await _firestore
        .collection('Users')
        .where('roleType', isEqualTo: roleType)
        .get();
    List<Object> userList = List.from(data.docs);

    return userList;
  }

}