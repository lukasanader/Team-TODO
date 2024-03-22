// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/analytics/analytics_base.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/message_feature/admin_message_view.dart';
import 'package:info_hub_app/patient_experience/admin_experience_view.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/topics/create_topic/create_topic.dart';
import 'package:info_hub_app/ask_question/question_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:info_hub_app/webinar/admin-webinar-screens/admin_webinar_dashboard.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';

class AdminHomepage extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;
  final ThemeManager themeManager;
  const AdminHomepage(
      {super.key,
      required this.firestore,
      required this.auth,
      required this.storage,
      required this.themeManager});
  @override
  _AdminHomepageState createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
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
      body: Center(
          child: GridView.extent(
              shrinkWrap: true,
              maxCrossAxisExtent: 150,
              crossAxisSpacing: 50.0,
              mainAxisSpacing: 50.0,
              padding: const EdgeInsets.all(20.0),
              children: <Widget>[
            ElevatedButton(
              onPressed: () {
                selectUserDialog();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add),
                  addVerticalSpace(5),
                  const Text(
                    'Add Admin',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: CreateTopicScreen(
                      firestore: widget.firestore,
                      auth: widget.auth,
                      storage: widget.storage,
                      themeManager: widget.themeManager,
                    ),
                    withNavBar: false,
                  );
                },
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.note_add_sharp),
                  addVerticalSpace(5),
                  const Text(
                    'Create Topic',
                    textAlign: TextAlign.center,
                  ),
                ])),
            ElevatedButton(
              onPressed: () {
                //PLACE VIEW THREAD METHOD HERE
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.question_answer),
                  addVerticalSpace(5),
                  const Text(
                    'View Thread',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              // onPressed: () => Navigator.of(context).push(
              //   CupertinoPageRoute(
              //     builder: (BuildContext context) {
              //       return ViewQuestionPage(
              //         firestore: widget.firestore,
              //         auth: widget.auth,
              //       );
              //     },
              //   ),
              // ),
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: ViewQuestionPage(
                    firestore: widget.firestore,
                    auth: widget.auth,
                  ),
                  withNavBar: false,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.question_mark),
                  addVerticalSpace(5),
                  const Text(
                    'View Questions',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              // onPressed: () => Navigator.of(context).push(
              //   CupertinoPageRoute(
              //     builder: (BuildContext context) {
              //       return AdminExperienceView(
              //         firestore: widget.firestore,
              //         auth: widget.auth,
              //       );
              //     },
              //   ),
              // ),
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AdminExperienceView(
                    firestore: widget.firestore,
                    auth: widget.auth,
                  ),
                  withNavBar: false,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.book),
                  addVerticalSpace(5),
                  const Text(
                    'View Experiences',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              // onPressed: () => Navigator.of(context).push(
              //   CupertinoPageRoute(
              //     builder: (BuildContext context) {
              //       return AnalyticsBase(
              //         firestore: widget.firestore,
              //         storage: widget.storage,
              //       );
              //     },
              //   ),
              // ),
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AnalyticsBase(
                    firestore: widget.firestore,
                    storage: widget.storage,
                  ),
                  withNavBar: false,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.analytics),
                  addVerticalSpace(5),
                  const Text(
                    'View Analytics',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              // onPressed: () => Navigator.of(context).push(
              //   CupertinoPageRoute(
              //     builder: (BuildContext context) {
              //       return MessageView(
              //         firestore: widget.firestore,
              //         auth: widget.auth,
              //       );
              //     },
              //   ),
              // ),
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: MessageView(
                    firestore: widget.firestore,
                    auth: widget.auth,
                  ),
                  withNavBar: false,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.message),
                  addVerticalSpace(5),
                  const Text(
                    'Message Users',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                UserModel currentAdmin = await generateCurrentUser();
                WebinarService webService = WebinarService(
                    firestore: widget.firestore, storage: widget.storage);
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (BuildContext context) {
                      return WebinarDashboard(
                        firestore: widget.firestore,
                        user: currentAdmin,
                        webinarService: webService,
                      );
                    },
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera),
                  addVerticalSpace(5),
                  const Text(
                    'Add/View Webinar',
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ])),
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
                    addAdmins();
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          });
        });
  }

  Future<UserModel> generateCurrentUser() async {
    String uid = widget.auth.currentUser!.uid;
    DocumentSnapshot userDoc =
        await widget.firestore.collection('Users').doc(uid).get();
    List<String> likedTopics = List<String>.from(userDoc['likedTopics']);
    List<String> dislikedTopics = List<String>.from(userDoc['dislikedTopics']);
    UserModel user = UserModel(
      uid: uid,
      firstName: userDoc['firstName'],
      lastName: userDoc['lastName'],
      email: userDoc['email'],
      roleType: userDoc['roleType'],
      likedTopics: likedTopics,
      dislikedTopics: dislikedTopics,
    );
    return user;
  }

  Future getUserList() async {
    QuerySnapshot data = await widget.firestore
        .collection('Users')
        .where('roleType', isEqualTo: 'Healthcare Professional')
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

  String getEmail(QueryDocumentSnapshot user) {
    return user['email'];
  }

  void addAdmins() async {
    List<int> indicesToRemove = [];
    List<dynamic> selectedUsers = [];
    for (int i = 0; i < selected.length; i++) {
      if (selected[i]) {
        selectedUsers.add(_userList[i]);
        indicesToRemove.add(i); // Add the selected item to the list
      }
    }
    for (int i = 0; i < selectedUsers.length; i++) {
      await widget.firestore
          .collection('Users')
          .doc(selectedUsers[i].id)
          .update({'roleType': 'admin'});
    }
    getUserList(); //refreshes the list
  }
}
