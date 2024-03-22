import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/message_feature/messaging_room_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageRoomCard extends StatelessWidget {
  final dynamic _chat;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const MessageRoomCard(this.firestore, this.auth, this._chat, {super.key});

  bool isAdmin() {
    return _chat['adminId'] == auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    String senderId;
    String receiverId;

    if (isAdmin()) {
      senderId = _chat['adminId'];
      receiverId = _chat['patientId'];
    } else {
      senderId = _chat['patientId'];
      receiverId = _chat['adminId'];
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
              onNewMessageRoomCreated: () {},
            ),
            withNavBar: false,
          );
        },
        child: Card(
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: isAdmin()
                  ? Text(_chat['adminDisplayName'])
                  : Text(_chat['patientDisplayName'])),
        ));
  }
}
