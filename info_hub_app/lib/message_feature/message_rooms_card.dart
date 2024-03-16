import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/message_feature/message_service.dart';
import 'package:info_hub_app/message_feature/messaging_room_view.dart';
import 'package:info_hub_app/threads/name_generator.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MessageRoomCard extends StatefulWidget {
  final dynamic _chat;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const MessageRoomCard(this.firestore, this.auth, this._chat,
      {super.key});

  @override
  State<MessageRoomCard> createState() => _MessageRoomCardState();
}

class _MessageRoomCardState extends State<MessageRoomCard> {
  late String senderId;
  late String receiverId;
  late Widget displayName = const CircularProgressIndicator();

  @override
  void initState() {
    super.initState();
    if (isAdmin()) {
      senderId = widget._chat['adminId'];
      receiverId = widget._chat['patientId']; 
    }
    else {
      senderId = widget._chat['patientId'];
      receiverId = widget._chat['adminId']; 
    }
    getDisplayName();
  }


  Future<void> getDisplayName() async {
    if (isAdmin()) {
      DocumentSnapshot user = await widget.firestore
        .collection('Users')
        .doc(receiverId)
        .get();

      setState(() {
        displayName = Text(user['email']);
      });
    }
    else {
      displayName = Text(generateUniqueName(senderId));
    }
  }

  bool isAdmin() {
    return widget._chat['adminId'] == widget.auth.currentUser!.uid;
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: MessageRoomView(
              firestore: widget.firestore,
              auth: widget.auth, 
              senderId: senderId, 
              receiverId: receiverId,),
            withNavBar: false,
          );
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: displayName,
          ),
        ));
  }
}
