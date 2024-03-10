import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/message_feature/message_bubble.dart';
import 'package:info_hub_app/message_feature/message_service.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/notifications/manage_notifications.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/screens/privacy_base.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';


class MessageRoomView extends StatefulWidget {
  final FirebaseAuth auth;
  final String senderId;
  final String receiverId;
  final MessageService messageService;

  const MessageRoomView({
    super.key,
    required this.auth, 
    required this.senderId, 
    required this.receiverId,
    required this.messageService});
  

  @override
  State<MessageRoomView> createState() => _MessageRoomViewState();
}

class _MessageRoomViewState extends State<MessageRoomView> {
  final TextEditingController _messageController = TextEditingController();


  

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await widget.messageService.sendMessage(widget.receiverId, _messageController.text);

      _messageController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(widget.receiverId),


      ),

      body: Column(
        children: [
          Expanded(
            child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }
  
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: widget.messageService.getMessages(
        widget.receiverId, 
        widget.auth.currentUser!.uid),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        return ListView(
          children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );

      }
    );

  }




  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == widget.auth.currentUser!.uid) 
      ? Alignment.centerRight 
      : Alignment.centerLeft;


    return Container(
      alignment: alignment,
      child: Column(
        children: [
          const SizedBox(height: 10),
          MessageBubble(message: data['message'])
        ],
      ),
    );

  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Type here' 
            ),
          )
        ),
        IconButton(onPressed: sendMessage, icon: const Icon(Icons.arrow_upward))

      ],
    );
  }


}
