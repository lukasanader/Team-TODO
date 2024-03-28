import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/model/thread_models/thread_replies_model.dart';
import 'package:info_hub_app/model/thread_models/thread_model.dart';
import 'package:intl/intl.dart';

class ThreadController {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ThreadController({required this.firestore, required this.auth});

  IconData getRoleIcon(String roleType) {
    switch (roleType) {
      case 'Patient':
        return Icons.local_hospital;
      case 'Healthcare Professional':
        return Icons.medical_services;
      case 'Parent':
        return Icons.family_restroom;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.help_outline;
    }
  }

  String formatDate(DateTime? timestamp) {
    if (timestamp == null) return 'Timestamp not available';
    return DateFormat("dd-MMM-yyyy 'at' HH:mm").format(timestamp);
  }

  String getCurrentUserId() {
    return auth.currentUser?.uid ?? '';
  }

  bool isUserCreator(String creatorId) {
    return auth.currentUser?.uid == creatorId;
  }

  Future<ImageProvider<Object>> getUserProfileImage(String userId) async {
    String profilePhotoFileName = await getUserProfilePhotoFilename(userId);
    return AssetImage('assets/$profilePhotoFileName');
  }

  Future<String> getUserProfilePhotoFilename(String userId) async {
    DocumentSnapshot userDoc =
        await firestore.collection('Users').doc(userId).get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return userData['selectedProfilePhoto'] ?? 'default_profile_photo.png';
    }
    return 'default_profile_photo.png';
  }

  Stream<List<Reply>> getRepliesStream(String threadId) {
    return firestore
        .collection("replies")
        .where('threadId', isEqualTo: threadId)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((DocumentSnapshot document) {
        return Reply.fromMap(
            document.data() as Map<String, dynamic>, document.id);
      }).toList();
    });
  }

  Stream<List<Thread>> getThreadListStream(String topicId) {
    return firestore
        .collection("thread")
        .where('topicId', isEqualTo: topicId)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs
          .map((doc) =>
              Thread.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Stream<List<Thread>> getAllThreadsStream() {
    return firestore
        .collection("thread")
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((DocumentSnapshot document) {
        return Thread.fromMap(
            document.data() as Map<String, dynamic>, document.id);
      }).toList();
    });
  }

  Stream<List<Reply>> getAllRepliesStream() {
    return firestore
        .collection("replies")
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((DocumentSnapshot document) {
        return Reply.fromMap(
            document.data() as Map<String, dynamic>, document.id);
      }).toList();
    });
  }

  Future<Map<String, dynamic>?> getThreadData(String threadId) async {
    DocumentSnapshot threadDoc =
        await firestore.collection("thread").doc(threadId).get();
    return threadDoc.data() as Map<String, dynamic>?;
  }

  Future<Thread> getThreadDocument(String threadId) async {
    DocumentSnapshot snapshot =
        await firestore.collection("thread").doc(threadId).get();
    if (snapshot.exists) {
      return Thread.fromMap(
          snapshot.data() as Map<String, dynamic>, snapshot.id);
    } else {
      // Cases where the document is not found
      return Thread(
        id: 'Missing ID',
        title: 'No Title',
        description: 'No Description',
        creator: 'Missing Creator',
        authorName: 'Missing Author',
        timestamp: DateTime.now(),
        isEdited: false,
        roleType: 'Missing Role',
        topicId: '',
        topicTitle: 'Missing Topic Title',
      );
    }
  }

  Future<void> addThread(Thread thread) async {
    await firestore.collection("thread").add({
      "id": thread.id,
      "title": thread.title,
      "description": thread.description,
      "creator": thread.creator,
      "authorName": thread.authorName,
      "timestamp": FieldValue.serverTimestamp(),
      "isEdited": thread.isEdited,
      "roleType": thread.roleType,
      "topicId": thread.topicId,
      "topicTitle": thread.topicTitle,
    });
  }

  Stream<QuerySnapshot> getThreads(String topicId) {
    return firestore
        .collection("thread")
        .where('topicId', isEqualTo: topicId)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    DocumentSnapshot userDoc =
        await firestore.collection('Users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>?;
  }

  Future<void> updateThread(
      String threadId, String title, String description) async {
    await firestore.collection("thread").doc(threadId).update({
      "title": title,
      "description": description,
      "timestamp": FieldValue.serverTimestamp(),
      "isEdited": true,
    });
  }

  Future<void> deleteThread(String threadId) async {
    final replyQuerySnapshot = await firestore
        .collection("replies")
        .where('threadId', isEqualTo: threadId)
        .get();
    final WriteBatch batch = firestore.batch();

    for (DocumentSnapshot replyDoc in replyQuerySnapshot.docs) {
      batch.delete(replyDoc.reference);
    }

    await batch.commit();

    await firestore.collection("thread").doc(threadId).delete();
  }

  Future<DocumentReference> addReply(Reply reply) async {
    return await firestore.collection("replies").add(reply.toMap());
  }

  Stream<QuerySnapshot> getReplies(String threadId) {
    return firestore
        .collection("replies")
        .where('threadId', isEqualTo: threadId)
        .snapshots();
  }

  Future<void> updateReply(String replyId, String content) async {
    await firestore.collection("replies").doc(replyId).update({
      "content": content,
      "timestamp": FieldValue.serverTimestamp(),
      "isEdited": true,
    });
  }

  Future<void> deleteReply(String replyId) async {
    await firestore.collection("replies").doc(replyId).delete();
  }

  Future<String> getUserRoleType(String userId) async {
    DocumentSnapshot userDoc =
        await firestore.collection('Users').doc(userId).get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return userData['roleType'] ?? 'Missing Role';
    }
    return 'Missing Role';
  }

  Future<Map<String, dynamic>?> getReplyData(String replyId) async {
    DocumentSnapshot replyDoc =
        await firestore.collection('replies').doc(replyId).get();
    return replyDoc.data() as Map<String, dynamic>?;
  }
}
