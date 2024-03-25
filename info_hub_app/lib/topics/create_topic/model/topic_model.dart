import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a Topic
class Topic {
  String? id; // Document ID
  String? title;
  String? description;
  String? articleLink;
  DateTime? date;
  int? views;
  int? likes;
  int? dislikes;
  String? quizID;
  List<dynamic>? tags;
  List<dynamic>? categories;
  List<Map<String, dynamic>>? media;
  String? userID;
  Timestamp? viewDate;

  Topic({
    this.id,
    this.title,
    this.description,
    this.articleLink,
    this.views,
    this.likes,
    this.dislikes,
    this.quizID,
    this.date,
    this.tags,
    this.categories,
    this.media,
    this.userID,
    this.viewDate
  });

  factory Topic.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Topic(
      id: snapshot.id,
      title: data['title'],
      description: data['description'],
      articleLink: data['articleLink'],
      views: data['views'],
      likes: data['likes'],
      dislikes: data['dislikes'],
      quizID: data['quizID'],
      date: (data['date'] as Timestamp).toDate(),
      tags: List<dynamic>.from(data['tags']),
      categories: List<dynamic>.from(data['categories']),
      media: List<Map<String, dynamic>>.from(data['media']),
      userID: data['userID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'articleLink': articleLink,
      'views': views,
      'likes': likes,
      'dislikes': dislikes,
      'quizID': quizID,
      'date': date,
      'tags': tags,
      'categories': categories,
      'media': media,
      'userID': userID,
    };
  }
}
