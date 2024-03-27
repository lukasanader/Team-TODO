import 'package:cloud_firestore/cloud_firestore.dart';

class Thread {
  String id;
  String title;
  String description;
  String creator;
  String authorName;
  DateTime timestamp;
  bool isEdited;
  String roleType;
  String topicId;
  String topicTitle;

  Thread({
    required this.id,
    required this.title,
    required this.description,
    required this.creator,
    required this.authorName,
    required this.timestamp,
    required this.isEdited,
    required this.roleType,
    required this.topicId,
    required this.topicTitle,
  });

  factory Thread.fromMap(Map<String, dynamic> map, String id) {
    return Thread(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      creator: map['creator'] ?? '',
      authorName: map['authorName'] ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isEdited: map['isEdited'] ?? false,
      roleType: map['roleType'] ?? '',
      topicId: map['topicId'] ?? '',
      topicTitle: map['topicTitle'] ?? '',
    );
  }
}
