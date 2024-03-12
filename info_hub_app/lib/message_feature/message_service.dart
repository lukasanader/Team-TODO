import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/message_feature/message_model.dart';

class MessageService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  MessageService(
    this._firebaseAuth,
    this._firestore,
  );


  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      receiverId: receiverId,
      timestamp: timestamp,
      message: message,
    );


    List<String> ids = [currentUserId, receiverId];
    ids.sort();

    String chatRoomId = ids.join('_');

    DocumentSnapshot chatRoomDocument = await _firestore.collection('message_rooms_members').doc(chatRoomId).get();
  

    if (!chatRoomDocument.exists) {
      await _firestore.collection('message_rooms_members').doc(chatRoomId).set({
        'adminId': currentUserId,
        'patientId': receiverId,
      });
    }


    await _firestore
      .collection('message_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .add(newMessage.toMap());
  }


  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
      .collection('message_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots();

  }

}