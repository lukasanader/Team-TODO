import 'dart:core';

class Experience {
  String? title;
  String? description;
  String? uid;

  Experience();

  Map<String, dynamic> toJson() => {'title': title, 'description': description, 'uid': uid};
}