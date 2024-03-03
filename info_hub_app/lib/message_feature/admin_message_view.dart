import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/message_feature/messaging_room_view.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/services/database.dart';
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
  List<bool> selected = [];


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUserList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Message a user"),
        ),
        body: SingleChildScrollView(
          child : Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    selectUserDialog();
                  }, 
                  child: const Text('Message new patient'))
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
                              User? currentUser = widget.auth.currentUser;
                              String currentUserId = '';

                              if (currentUser != null) {
                                currentUserId = currentUser.uid;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MessageRoomView(
                                          firestore: widget.firestore,
                                          auth: widget.auth,
                                          senderId: currentUserId,
                                          receiverId: receiverUser.id,
                                        )),
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
      selected = List<bool>.filled(_userList.length, false);
    });
  }

}
