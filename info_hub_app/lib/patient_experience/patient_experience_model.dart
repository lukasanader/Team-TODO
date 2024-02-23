import 'dart:core';

class Experience {
  String? title;
  String? description;
  String? uid;
  bool? verified;

  Experience();

  Map<String, dynamic> toJson() => {'title': title, 'description': description, 'uid': uid, 'verified' : verified};

  Experience.fromSnapshot(snapshot)
    : title = snapshot.data()['title'],
      description = snapshot.data()['description'],
      uid = snapshot.data()['uid'];
}