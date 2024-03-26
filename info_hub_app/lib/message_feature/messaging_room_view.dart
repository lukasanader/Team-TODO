import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/message_feature/message_bubble.dart';
import 'package:info_hub_app/message_feature/message_controller.dart';
import 'package:info_hub_app/threads/name_generator.dart';

class MessageRoomView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final String senderId;
  final String receiverId;
  final Function()? onNewMessageRoomCreated;

  const MessageRoomView(
      {super.key,
      required this.firestore,
      required this.auth,
      required this.senderId,
      required this.receiverId,
      this.onNewMessageRoomCreated});

  @override
  State<MessageRoomView> createState() => _MessageRoomViewState();
}

class _MessageRoomViewState extends State<MessageRoomView> {
  final TextEditingController _messageController = TextEditingController();
  late MessageController messageController;
  late Widget displayName = const Text('Loading');

  @override
  void initState() {
    super.initState();
    messageController = MessageController(widget.auth, widget.firestore);
    getDisplayName();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await messageController.sendMessage(
          widget.receiverId, _messageController.text);
      _messageController.clear();
    }
    widget.onNewMessageRoomCreated!();
  }

  Future<void> getDisplayName() async {
    displayName = Text(generateUniqueName(widget.receiverId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: displayName,
      ),
      body: Column(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildMessageList(),
          )),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: messageController.getMessages(
            widget.receiverId, widget.auth.currentUser!.uid),
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
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                  hintText: 'Type here',
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0)),
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
                onPressed: sendMessage, icon: const Icon(Icons.arrow_upward)),
          ),
        ],
      ),
    );
  }
}
