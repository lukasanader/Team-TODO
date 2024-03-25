// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/analytics/analytics_base.dart';
import 'package:info_hub_app/controller/user_controller.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/message_feature/admin_message_view.dart';
import 'package:info_hub_app/patient_experience/admin_experience_view.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/theme/theme_constants.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/topics/create_topic/view/topic_creation_view.dart';
import 'package:info_hub_app/ask_question/question_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:info_hub_app/webinar/views/admin-webinar-screens/admin_webinar_dashboard.dart';
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
  late UserController _userController;
  List<UserModel> _userList = [];
  List<bool> selected = [];

  @override
  void initState() {
    super.initState();
    _userController = UserController(widget.auth, widget.firestore);
  }

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
                    screen: TopicCreationView(
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
                    auth: widget.auth,
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
                UserModel currentAdmin = await _userController
                    .getUser(widget.auth.currentUser!.uid.toString());
                WebinarService webService = WebinarService(
                    firestore: widget.firestore, storage: widget.storage);
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: WebinarDashboard(
                    firestore: widget.firestore,
                    user: currentAdmin,
                    webinarService: webService,
                  ),
                  withNavBar: false,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera),
                  addVerticalSpace(5),
                  const Text(
                    'Manage Webinars',
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
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search',
                ),
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
                            title: Text(_userList[index].email),
                            onTap: () {
                              setState(() {
                                selected[index] = !selected[index];
                              });
                            },
                            tileColor: selected[index]
                                ? COLOR_PRIMARY_LIGHT.withOpacity(0.2)
                                : Colors.transparent,
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

  Future getUserList() async {
    List<UserModel> tempList;
    List<UserModel> allHealthcareProfessionalsList = await _userController
        .getUserListBasedOnRoleType('Healthcare Professional');

    String search = _searchController.text.toLowerCase();

    if (search.isNotEmpty) {
      tempList = allHealthcareProfessionalsList.where((user) {
        return user.email.toLowerCase().contains(search);
      }).toList();
    } else {
      tempList = allHealthcareProfessionalsList;
    }

    setState(() {
      _userList = tempList;
      selected = List<bool>.filled(_userList.length, false);
    });
  }

  void addAdmins() async {
    List<int> indicesToRemove = [];
    List<UserModel> selectedUsers = [];
    for (int i = 0; i < selected.length; i++) {
      if (selected[i]) {
        selectedUsers.add(_userList[i]);
        indicesToRemove.add(i); // Add the selected item to the list
      }
    }
    await _userController.addAdmins(selectedUsers);

    getUserList(); //refreshes the list
  }
}
