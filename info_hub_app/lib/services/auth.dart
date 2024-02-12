import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/models/user_model.dart';
import 'package:info_hub_app/services/database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user model
  UserModel? _userFromFirebaseUser(User user, String firstName, String lastName,String email, String roleType) {
    return UserModel(uid: user.uid,firstName: firstName, email: email, lastName: lastName,roleType: roleType);
  }
  // register user

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future registerUser(String firstName, String lastName, String email, String password,String roleType) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await DatabaseService(uid:user.uid).addUserData(firstName, lastName, email, roleType);
        // create user model
        return _userFromFirebaseUser(user,firstName, lastName, email, roleType);
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

}