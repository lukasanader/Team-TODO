import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/notifications/manage_notifications.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:info_hub_app/settings/help_page/help_page.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/settings/privacy_base.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:info_hub_app/registration/start_page.dart';

class SettingsView extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  const SettingsView(
      {super.key,
      required this.auth,
      required this.firestore,
      required this.storage});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<UserModel>>(
          create: (_) => DatabaseService(
                  uid: FirebaseAuth.instance.currentUser!.uid,
                  firestore: FirebaseFirestore.instance)
              .users,
          initialData: [], // Initial data while waiting for Firebase data
        ),
      ],
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Settings"),
          ),
          body: ListView(
            children: [
              Container(
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.black)
                // ),
                child: const ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    foregroundColor: Color.fromRGBO(226, 4, 4, 0.612),
                    backgroundImage: AssetImage('assets/blank_pfp.png'),
                  ),
                  title: Text("Username"),
                  subtitle: Text("Role"),
                ),
              ),
              GestureDetector(
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: ManageNotifications(
                      firestore: widget.firestore,
                      auth: widget.auth,
                    ),
                    withNavBar: false,
                  );
                },
                child: Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(color: Colors.black)
                  // ),
                  child: const ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Manage Notifications'),
                  ),
                ),
              ),
              Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(color: Colors.black)
                  // ),
                  child: ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Manage Privacy Settings'),
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const PrivacyPage(),
                    withNavBar: false,
                  );
                },
              )),
              Container(
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.black)
                // ),
                child: const ListTile(
                  leading: Icon(Icons.history_outlined),
                  title: Text('History'),
                ),
              ),
              GestureDetector(
                key: const Key('Help Option'),
                onTap: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const HelpView(),
                    withNavBar: false, 
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                } ,
                child: Container(
                  child: const ListTile(
                    leading: Icon(Icons.help),
                    title: Text('Help'),
                  ),              
                )
              ),
              Container(
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.black)
                // ),
                child: const AboutListTile(
                  icon: Icon(Icons.info),
                  applicationLegalese: 'Legalese',
                  applicationName: 'TEAM TODO',
                  applicationVersion: '1.0.0',
                  aboutBoxChildren: [
                    Text('Liver information hub for young people')
                  ],
                ),
              ),
              Container(
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.black)
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log Out'),
                  onTap: () {
                    widget.auth.signOut();
                    Navigator.of(context, rootNavigator: true)
                      .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return StartPage(
                              firestore: widget.firestore ,
                              auth: widget.auth, 
                              storage: widget.storage);
                          },
                        ),
                        (_) => false,
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}
