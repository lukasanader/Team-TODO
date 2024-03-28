import 'package:cloud_firestore/cloud_firestore.dart';

/// Reply model class
class Reply {
  String id;
  String content;
  String creator;
  String authorName;
  DateTime timestamp;
  bool isEdited;
  String userProfilePhoto;
  String threadId;
  String threadTitle;
  String roleType;

  Reply({
    required this.id,
    required this.content,
    required this.creator,
    required this.authorName,
    required this.timestamp,
    required this.isEdited,
    required this.userProfilePhoto,
    required this.threadId,
    required this.threadTitle,
    required this.roleType,
  });

  /// Converts reply object to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'creator': creator,
      'authorName': authorName,
      'timestamp': timestamp,
      'isEdited': isEdited,
      'userProfilePhoto': userProfilePhoto,
      'threadId': threadId,
      'threadTitle': threadTitle,
      'roleType': roleType,
    };
  }

// Converts map to reply object
  factory Reply.fromMap(Map<String, dynamic> map, String id) {
    return Reply(
      id: id,
      content: map['content'] ?? '',
      creator: map['creator'] ?? '',
      authorName: map['authorName'] ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isEdited: map['isEdited'] ?? false,
      userProfilePhoto: map['userProfilePhoto'] ?? '',
      threadId: map['threadId'] ?? '',
      threadTitle: map['threadTitle'] ?? '',
      roleType: map['roleType'] ?? '',
    );
  }
}
