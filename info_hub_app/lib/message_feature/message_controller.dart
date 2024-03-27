import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/message_feature/message_model.dart';
import 'package:info_hub_app/message_feature/message_room/message_room_controller.dart';
import 'package:info_hub_app/controller/user_controller.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/threads/controllers/name_generator_controller.dart';

class MessageController extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  MessageController(
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

    MessageRoomController messageRoomController =
        MessageRoomController(_firebaseAuth, _firestore);

    //checks if room is initialised, if not creates it
    DocumentSnapshot chatRoomDocument =
        await _firestore.collection('message_rooms').doc(chatRoomId).get();
    if (!chatRoomDocument.exists) {
      UserModel receiverUser =
          await UserController(_firebaseAuth, _firestore).getUser(receiverId);

      //will display the patients email as the card name
      String adminDisplayName = receiverUser.email;

      //will display the admins username as the card name
      String patientDisplayName = generateUniqueName(currentUserId);

      messageRoomController.addMessageRoom(chatRoomId, currentUserId,
          receiverId, adminDisplayName, patientDisplayName);
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
