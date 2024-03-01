// UserModel is mainly used for local work- it can be used to avoid having to constantly query the database in order to retrieve information
class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String roleType;
  final List<String> likedTopics;
  final List<String> dislikedTopics;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roleType,
    required this.likedTopics,
    required this.dislikedTopics,
  });
}
