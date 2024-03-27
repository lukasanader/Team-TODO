import 'package:cloud_firestore/cloud_firestore.dart';

class Experience {
  String? id; // Document ID
  String? title;
  String? description;
  String? userEmail;
  String? userRoleType;
  Timestamp? timestamp;
  bool? verified;

  Experience({this.id, this.title, this.description, this.userEmail, this.userRoleType, this.timestamp,this.verified});

  factory Experience.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Experience(
      id: snapshot.id, // Set the document ID
      title: data['title'],
      description: data['description'],
      userEmail: data['userEmail'],
      userRoleType: data['userRoleType'],
      timestamp: data['timestamp'],
      verified: data['verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'userEmail': userEmail,
      'userRoleType': userRoleType,
      'timestamp': timestamp,
      'verified': verified,
    };
  }
}