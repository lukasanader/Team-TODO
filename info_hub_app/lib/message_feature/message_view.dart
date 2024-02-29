import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:provider/provider.dart';

class MessageView extends StatefulWidget {
  final FirebaseFirestore firestore;
  const MessageView({super.key, required this.firestore});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final TextEditingController _searchController = TextEditingController();
  List<Object> _userList = [];
  List<bool> selected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Message a user"),
        ),
        body: ElevatedButton(
          onPressed: () {
            selectUserDialog();
          },
          child: const Text("hello"),)
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
                                "Sorry there are no healthcare professionals matching this email."),
                          );
                        } else {
                          return ListTile(
                            title: Text(getEmail(
                                _userList[index] as QueryDocumentSnapshot)),
                            onTap: () {
                              setState(() {
                                selected[index] = !selected[index];
                              });
                            },
                            tileColor: selected[index]
                                ? Colors.blue.withOpacity(0.5)
                                : null,
                          );
                        }
                      })),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    print("hello");
                  },
                  child: const Text("OK"),
                ),
              ],
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
