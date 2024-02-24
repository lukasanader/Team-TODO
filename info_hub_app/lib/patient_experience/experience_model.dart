import 'package:cloud_firestore/cloud_firestore.dart';

class Experience {
  String? id; // Document ID
  String? title;
  String? description;
  String? uid;
  bool? verified;

  Experience({this.id, this.title, this.description, this.uid, this.verified});

  factory Experience.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Experience(
      id: snapshot.id, // Set the document ID
      title: data['title'],
      description: data['description'],
      uid: data['uid'],
      verified: data['verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'uid': uid,
      'verified': verified,
    };
  }
}