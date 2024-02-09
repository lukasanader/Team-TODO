import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  final FirebaseFirestore firestore;

  DatabaseService({required this.uid, required this.firestore});

  // adds user data to database
  Future addUserData(String firstName, String lastName,String email,String roleType) async {
    CollectionReference usersCollectionRef = firestore.collection('Users');
    return await usersCollectionRef.add({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'roleType': roleType,
    });
  }
}
