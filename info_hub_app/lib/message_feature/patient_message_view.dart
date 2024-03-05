import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/message_feature/message_rooms_card.dart';

class PatientMessageView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const PatientMessageView({super.key, required this.firestore, required this.auth});

  @override
  State<PatientMessageView> createState() => _PatientMessageViewState();
}

class _PatientMessageViewState extends State<PatientMessageView> {
  List<Object> _chatList = [];



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getChatList();
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
                dynamic chat = _chatList[index]; 
                return MessageRoomCard(widget.firestore, widget.auth, chat);
              }
            ),
            ElevatedButton(
              onPressed: () {
                print(_chatList.length);
              }, 
              child: const Text('testing button'))

          ],
        )
      )
    );
  }


  Future getChatList() async {
    QuerySnapshot data = await widget.firestore
        .collection('message_rooms_members')
        .where('patientId', isEqualTo: widget.auth.currentUser!.uid)
        .get();
    List<Object> tempList = List.from(data.docs);
    
    setState(() {
      _chatList = tempList;
    });
  }
}
