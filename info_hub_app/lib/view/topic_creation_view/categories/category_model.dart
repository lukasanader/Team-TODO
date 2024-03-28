import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String? id;
  String? name; 

  Category({this.id, this.name});

  factory Category.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Category(
      id: snapshot.id,
      name: data['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}