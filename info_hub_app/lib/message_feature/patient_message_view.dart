import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/message_feature/message_room/message_room_controller.dart';
import 'package:info_hub_app/message_feature/message_room/message_room_model.dart';
import 'package:info_hub_app/message_feature/message_rooms_card.dart';

class PatientMessageView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const PatientMessageView({super.key, required this.firestore, required this.auth});

  @override
  State<PatientMessageView> createState() => _PatientMessageViewState();
}

class _PatientMessageViewState extends State<PatientMessageView> {
  List<MessageRoom> _chatList = [];



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateChatList();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reply to admins"),
      ),
    
      body: Center(
        child: Column(
          children: [
            const Text('Messages'),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _chatList.length,
              itemBuilder: (context, index) {
                MessageRoom chat = _chatList[index]; 
                return MessageRoomCard(widget.firestore, widget.auth, chat);
              }
            ),

          ],
        )
      )
    );
  }


  Future updateChatList() async {
    MessageRoomController messageRoomController = MessageRoomController(
      widget.auth, 
      widget.firestore);

    List<MessageRoom> tempList = await messageRoomController.getMessageRoomsList();
    
    setState(() {
      _chatList = tempList;
    });
  }
}
