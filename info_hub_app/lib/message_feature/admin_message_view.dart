import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/message_feature/message_rooms_card.dart';
import 'package:info_hub_app/message_feature/message_service.dart';
import 'package:info_hub_app/message_feature/messaging_room_view.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class MessageView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const MessageView({super.key, required this.firestore, required this.auth});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final TextEditingController _searchController = TextEditingController();
  List<Object> _userList = [];
  List<Object> _chatList = [];


  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getChatList();
    getUserList();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Message a user"),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          selectUserDialog();
        }, 
        child: const Text('Message new patient')
      ),
    
      
      body: SingleChildScrollView(
        child: Center(
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
              ],
            )
          )
      ) 
      

    );
  }

  void selectUserDialog() {
    showDialog(
        context: context,
        builder: (
          BuildContext context,
        ) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: TextField(
                controller: _searchController,
                onChanged: (query) async {
                  await getUserList();
                  setState(() {});
                },
              ),
              content: SizedBox(
                  height: 300,
                  width: 200,
                  child: ListView.builder(
                      itemCount: _userList.isEmpty ? 1 : _userList.length,
                      itemBuilder: (context, index) {
                        if (_userList.isEmpty) {
                          return const ListTile(
                            title: Text(
                                "Sorry there are no patients matching this email."),
                          );
                        } else {
                          return ListTile(
                            title: Text(getEmail(
                                _userList[index] as QueryDocumentSnapshot)),
                            onTap: () {
                              dynamic receiverUser = _userList[index];
          

                              Navigator.pop(context);
                              Navigator.pop(context);


                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (BuildContext context) {
                                    return MessageRoomView(
                                      auth: widget.auth,
                                      senderId: widget.auth.currentUser!.uid,
                                      receiverId: receiverUser.id,
                                      messageService: MessageService(widget.auth, widget.firestore),
                                    );
                                  }
                                )
                              );


                            },
                          );
                        }
                      })),
            );
          });
        });
  }

  String getEmail(QueryDocumentSnapshot user) {
    return user['email'];
  }

  Future getUserList() async {
    QuerySnapshot data = await widget.firestore
        .collection('Users')
        .where('roleType', isEqualTo: 'Patient')
        .get();
    List<Object> tempList = List.from(data.docs);
    String search = _searchController.text;
    if (search.isNotEmpty) {
      for (int i = 0; i < tempList.length; i++) {
        QueryDocumentSnapshot user = tempList[i] as QueryDocumentSnapshot;
        String email = user['email'].toString().toLowerCase();
        if (!email.contains(search.toLowerCase())) {
          tempList.removeAt(i);
          i = i - 1;
        }
      }
    }
    setState(() {
      _userList = tempList;
    });
  }

  Future getChatList() async {
    QuerySnapshot data = await widget.firestore
        .collection('message_rooms_members')
        .where('adminId', isEqualTo: widget.auth.currentUser!.uid)
        .get();
    List<Object> tempList = List.from(data.docs);
    
    setState(() {
      _chatList = tempList;
    });
  }
}
