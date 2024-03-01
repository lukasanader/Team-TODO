import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/notifications/manage_notifications.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/screens/privacy_base.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';


class MessageRoomView extends StatefulWidget {
  final String senderId;
  final String receiverId;

  const MessageRoomView({super.key, required this.senderId, required this.receiverId});
  

  @override
  State<MessageRoomView> createState() => _MessageRoomViewState();
}

class _MessageRoomViewState extends State<MessageRoomView> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(widget.receiverId),
    );
  }
}
