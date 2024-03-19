import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/message_feature/message_bubble.dart';
import 'package:info_hub_app/message_feature/message_room/message_room_model.dart';
import 'package:info_hub_app/message_feature/message_service.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/notifications/manage_notifications.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:info_hub_app/threads/name_generator.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/settings/privacy_base.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class MessageRoomView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final String senderId;
  final String receiverId;
  final Function() onNewMessageRoomCreated;

  const MessageRoomView(
      {super.key,
      required this.firestore,
      required this.auth,
      required this.senderId,
      required this.receiverId,
      required this.onNewMessageRoomCreated
      });

  @override
  State<MessageRoomView> createState() => _MessageRoomViewState();
}

class _MessageRoomViewState extends State<MessageRoomView> {
  final TextEditingController _messageController = TextEditingController();
  late MessageService messageService;
  late Widget displayName = const Text('Loading');

  @override
  void initState() {
    super.initState();
    messageService = MessageService(widget.auth, widget.firestore);
    getDisplayName();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await messageService
          .sendMessage(widget.receiverId, _messageController.text);
      _messageController.clear();
    }
    widget.onNewMessageRoomCreated();
  }

  Future<void> getDisplayName() async {
    displayName = Text(generateUniqueName(widget.receiverId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: displayName,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: messageService
            .getMessages(widget.receiverId, widget.auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }

          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        });
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
              border: OutlineInputBorder(), hintText: 'Type here'),
        )),
        IconButton(onPressed: sendMessage, icon: const Icon(Icons.arrow_upward))
      ],
    );
  }
}
