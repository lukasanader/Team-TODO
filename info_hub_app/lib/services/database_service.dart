import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseService({required this.uid});

  // adds user data to database
  Future addUserData(String firstName, String lastName,String email,String roleType) async {
    CollectionReference usersCollectionRef = _firestore.collection('Users');
    return await usersCollectionRef.add({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'roleType': roleType,
    });
  }
}
