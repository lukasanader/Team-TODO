

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/user_model.dart';

class UserController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserController(
    this._auth,
    this._firestore
  );



  Future<UserModel> getUser(String uid) async {
    DocumentSnapshot documentSnapshot = await _firestore.collection('Users').doc(uid).get();
    UserModel user = UserModel.fromSnapshot(documentSnapshot);

    return user;
  }

  Future<String> getUserRoleType() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot user = await _firestore.collection('Users').doc(uid).get();

    return user['roleType'];
  }



  Future<List<UserModel>> getUserListBasedOnRoleType(String roleType) async {
    QuerySnapshot data = await _firestore
        .collection('Users')
        .where('roleType', isEqualTo: roleType)
        .get();

    List<UserModel> userList = List.from(data.docs.map((doc) => UserModel.fromSnapshot(doc)));

    return userList;
  }

  Future<void> addAdmins(List<UserModel> selectedUsers) async {
     for (int i = 0; i < selectedUsers.length; i++) {
      await _firestore
          .collection('Users')
          .doc(selectedUsers[i].uid)
          .update({'roleType': 'admin'});
    }
  }

}