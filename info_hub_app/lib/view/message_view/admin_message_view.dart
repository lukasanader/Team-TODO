import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/controller/user_controllers/user_controller.dart';
import 'package:info_hub_app/view/message_view/message_card_helper.dart';
import 'package:info_hub_app/controller/message_controllers/message_room_controller.dart';
import 'package:info_hub_app/model/message_models/message_room_model.dart';
import 'package:info_hub_app/view/message_view/message_rooms_card.dart';
import 'package:info_hub_app/view/message_view/messaging_room_view.dart';
import 'package:info_hub_app/model/user_models/user_model.dart';
import 'package:info_hub_app/controller/notification_controllers/notification_controller.dart';

class MessageView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const MessageView({super.key, required this.firestore, required this.auth});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _userList = [];
  List<MessageRoom> _chatList = [];
  late MessageRoomController messageRoomController;
  late UserController userController;
  bool pageLoaded = false;

  @override
  void initState() {
    super.initState();
    messageRoomController =
        MessageRoomController(widget.auth, widget.firestore);
    userController = UserController(widget.auth, widget.firestore);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateChatList();
    getUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Users"),
      ),
      body: !pageLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Messages',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: _chatList.length,
                          itemBuilder: (context, index) {
                            MessageRoom chat = _chatList[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: MessageRoomCard(
                                      widget.firestore, widget.auth, chat),
                                ),
                                IconButton(
                                  onPressed: () {
                                    deleteMessageRoomConfirmation(chat.id!);
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  addVerticalSpace(15),
                  ElevatedButton(
                    onPressed: () {
                      selectUserDialog();
                    },
                    child: const Text('Message new patient'),
                  ),
                ],
              ),
            ),
    );
  }

  ///dialog that displays the search for patients to message
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
                            title: Text(_userList[index].email),
                            onTap: () {
                              UserModel receiverUser = _userList[index];

                              Navigator.pop(context);
                              Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (BuildContext context) {
                                return MessageRoomView(
                                  firestore: widget.firestore,
                                  auth: widget.auth,
                                  senderId: widget.auth.currentUser!.uid,
                                  receiverId: receiverUser.uid,
                                  onNewMessageRoomCreated: updateChatList,
                                );
                              }));
                            },
                          );
                        }
                      })),
            );
          });
        });
  }

  ///delete confirmation dialog
  Future<void> deleteMessageRoomConfirmation(String chatId) async {
    MessageRoom chat =
        await MessageRoomController(widget.auth, widget.firestore)
            .getMessageRoom(chatId);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning!'),
          content: const Text("Are you sure you want to delete?"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                NotificationController notificationController =
                    NotificationController(
                        auth: widget.auth,
                        firestore: widget.firestore,
                        uid: chat.patientId.toString());
                List<String> notificationId = await notificationController
                    .getNotificationIdFromPayload(chatId);
                if (notificationId.isNotEmpty) {
                  for (String id in notificationId) {
                    notificationController.deleteNotification(id);
                  }
                }
                messageRoomController.deleteMessageRoom(chatId);
                Navigator.pop(context);
                updateChatList();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  ///implements search logic for getting the users in the dialog
  Future getUserList() async {
    List<UserModel> tempList;
    List<UserModel> allPatientsList =
        await userController.getUserListBasedOnRoleType('Patient');

    String search = _searchController.text.toLowerCase();

    if (search.isNotEmpty) {
      tempList = allPatientsList.where((user) {
        return user.email.toLowerCase().contains(search);
      }).toList();
    } else {
      tempList = allPatientsList;
    }

    setState(() {
      _userList = tempList;
    });
  }

  Future updateChatList() async {
    List<MessageRoom> tempList =
        await messageRoomController.getMessageRoomsList();

    setState(() {
      _chatList = tempList;
      pageLoaded = true;
    });
  }
}
