import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/message_feature/message_service.dart';
import 'package:info_hub_app/message_feature/messaging_room_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MessageRoomCard extends StatelessWidget {
  final dynamic _chat;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const MessageRoomCard(this.firestore, this.auth, this._chat,
      {super.key});

  @override
  Widget build(BuildContext context) {
    String senderId;
    String receiverId;

    if (_chat['patientId'] == auth.currentUser!.uid) {
      senderId = _chat['patientId'];
      receiverId = _chat['adminId']; 
    }
    else {
      senderId = _chat['adminId'];
      receiverId = _chat['patientId']; 
    }


    return GestureDetector(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: MessageRoomView(
              firestore: firestore,
              auth: auth, 
              senderId: senderId, 
              receiverId: receiverId,),
            withNavBar: false,
          );
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(_chat['adminId'] + _chat['patientId']),
          ),
        ));
  }
}
