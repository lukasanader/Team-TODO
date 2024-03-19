

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/message_feature/message_room/message_room_model.dart';
import 'package:info_hub_app/patient_experience/experience_model.dart';

class MessageRoomController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  MessageRoomController(
    this._auth,
    this._firestore
  );

  void addMessageRoom(String chatRoomId, String adminId, String patientId) async {
    MessageRoom newMessageRoom = MessageRoom();

    newMessageRoom.adminId = adminId;
    newMessageRoom.patientId = patientId;

    CollectionReference db = _firestore.collection('message_rooms');
    await db.doc(chatRoomId).set(newMessageRoom.toJson());
  }

  void deleteMessageRoom(String chatRoomId) async {
    await _firestore
      .collection('message_rooms')
      .doc(chatRoomId)
      .delete();

    QuerySnapshot messages = await _firestore
      .collection('message_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .get();

    for (QueryDocumentSnapshot message in messages.docs) {
      await message.reference.delete();
    }

    await _firestore
      .collection('message_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .doc()
      .delete();
  }

  Future<List<Object>> getMessageRoomsList() async {
    late String receiverType;
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot user = await _firestore.collection('Users').doc(uid).get();
    String role = user['roleType'];

    if (role == 'admin') {
      receiverType = 'adminId';
    }
    else {
      receiverType = 'patientId';
    }

    QuerySnapshot data = await _firestore
        .collection('message_rooms')
        .where(receiverType, isEqualTo: _auth.currentUser!.uid)
        .get();

    List<Object> messageRoomList = List.from(data.docs);
    return messageRoomList;
  }


}