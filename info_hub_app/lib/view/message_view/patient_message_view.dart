import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/controller/message_controllers/message_room_controller.dart';
import 'package:info_hub_app/model/message_models/message_room_model.dart';
import 'package:info_hub_app/view/message_view/message_rooms_card.dart';

class PatientMessageView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const PatientMessageView({super.key, required this.firestore, required this.auth});

  @override
  State<PatientMessageView> createState() => _PatientMessageViewState();
}

class _PatientMessageViewState extends State<PatientMessageView> {
  List<MessageRoom> _chatList = [];
  bool pageLoaded = false;



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
    
      body: !pageLoaded
      ? const Center(child: CircularProgressIndicator(),) 
      : Center(
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
      pageLoaded = true;
    });
  }
}
