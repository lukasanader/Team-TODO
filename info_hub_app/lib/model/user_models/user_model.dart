// UserModel is mainly used for local work- it can be used to avoid having to constantly query the database in order to retrieve information
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String roleType;
  final List<String> likedTopics;
  final List<String> dislikedTopics;
  List<String>? draftedTopics;
  bool hasOptedOutOfExperienceExpectations;
  String?
      selectedProfilePhoto; // This is a nullable variable, as the user may not have a profile photo

  UserModel(
      {required this.uid,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.roleType,
      required this.likedTopics,
      required this.dislikedTopics,
      this.hasOptedOutOfExperienceExpectations = false,
      this.draftedTopics,
      this.selectedProfilePhoto});

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      uid: snapshot.id,
      firstName: data['firstName'], 
      lastName: data['lastName'],
      email: data['email'],
      roleType: data['roleType'],
      likedTopics: List<String>.from(data['likedTopics'] ?? []),
      dislikedTopics: List<String>.from(data['dislikedTopics'] ?? []),
    );
  }


}
