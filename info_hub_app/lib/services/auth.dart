import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/models/user_model.dart';
import 'package:info_hub_app/services/database.dart';

class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthService({required this.firestore,required this.auth});

  // create user model
  UserModel? _userFromFirebaseUser(User user, String firstName, String lastName,String email, String roleType) {
    return UserModel(uid: user.uid,firstName: firstName, email: email, lastName: lastName,roleType: roleType);
  }

  Stream<User?> get user {
    return auth.authStateChanges();
  }
  // register user
  Future registerUser(String firstName, String lastName, String email, String password,String roleType) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await DatabaseService(firestore: firestore, uid: user.uid).addUserData(firstName, lastName, email, roleType);
        // create user model
        return _userFromFirebaseUser(user,firstName, lastName, email, roleType);
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

}