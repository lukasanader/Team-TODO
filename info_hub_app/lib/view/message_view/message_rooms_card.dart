import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/model/message_models/message_room_model.dart';
import 'package:info_hub_app/view/message_view/messaging_room_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageRoomCard extends StatelessWidget {
  final MessageRoom _chat;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const MessageRoomCard(this.firestore, this.auth, this._chat, {super.key});

  
  bool isAdmin() {
    return _chat.adminId == auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    String senderId;
    String receiverId;

    //determines the receiver and sender of message
    if (isAdmin()) {
      senderId = _chat.adminId.toString();
      receiverId = _chat.patientId.toString();
    } else {
      senderId = _chat.patientId.toString();
      receiverId = _chat.adminId.toString();
    }

    return GestureDetector(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: MessageRoomView(
              auth: auth,
              senderId: senderId,
              receiverId: receiverId,
              firestore: firestore,
            ),
            withNavBar: false,
          );
        },
        child: Card(
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: isAdmin()
                  ? Text(_chat.adminDisplayName.toString())
                  : Text(_chat.patientDisplayName.toString())),
        ));
  }
}
