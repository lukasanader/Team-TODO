import 'package:cloud_firestore/cloud_firestore.dart';

class Experience {
  String? id; // Document ID
  String? title;
  String? description;
  String? userEmail;
  bool? verified;

  Experience({this.id, this.title, this.description, this.userEmail, this.verified});

  factory Experience.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Experience(
      id: snapshot.id, // Set the document ID
      title: data['title'],
      description: data['description'],
      userEmail: data['userEmail'],
      verified: data['verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'userEmail': userEmail,
      'verified': verified,
    };
  }
}