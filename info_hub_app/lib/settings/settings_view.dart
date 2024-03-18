import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/notifications/manage_notifications.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:info_hub_app/settings/help_page.dart';
import 'package:info_hub_app/settings/saved/saved_page.dart';
import 'package:info_hub_app/settings/drafts/drafts_page.dart';
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
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    initializeAdminStatus();
  }

  Future<void> initializeAdminStatus() async {
    await isAdminUser();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<UserModel>>(
          create: (_) => DatabaseService(
            uid: FirebaseAuth.instance.currentUser!.uid,
            firestore: FirebaseFirestore.instance,
          ).users,
          initialData: [], // Initial data while waiting for Firebase data
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: ListView(
          children: [
            const ListTile(
              leading: CircleAvatar(
                radius: 30,
                foregroundColor: Color.fromRGBO(226, 4, 4, 0.612),
                backgroundImage: AssetImage('assets/blank_pfp.png'),
              ),
              title: Text("Username"),
              subtitle: Text("Role"),
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
              child: const ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Manage Notifications'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Manage Privacy Settings'),
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: const PrivacyPage(),
                  withNavBar: false,
                );
              },
            ),
            const ListTile(
              leading: Icon(Icons.history_outlined),
              title: Text('History'),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_added_outlined),
              title: const Text('Saved Topics'),
              onTap: () {
                // Navigate to the saved topics page when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SavedPage(
                            auth: widget.auth,
                            firestore: widget.firestore,
                            storage: widget.storage,
                          )),
                );
              },
            ),
            if (isAdmin)
              ListTile(
                key: Key("drafts_tile"),
                leading: const Icon(Icons.difference_outlined),
                title: const Text('Topic Drafts'),
                onTap: () {
                  // Navigate to the saved topics page when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DraftsPage(
                              auth: widget.auth,
                              firestore: widget.firestore,
                              storage: widget.storage,
                            )),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                // Navigate to the HelpPage when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpPage()),
                );
              },
            ),
            const AboutListTile(
              icon: Icon(Icons.info),
              applicationLegalese: 'Legalese',
              applicationName: 'TEAM TODO',
              applicationVersion: '1.0.0',
              aboutBoxChildren: [
                Text('Liver information hub for young people'),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () {
                widget.auth.signOut();
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: StartPage(
                    firestore: widget.firestore,
                    auth: widget.auth,
                    storage: widget.storage,
                  ),
                  withNavBar: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> isAdminUser() async {
    User? user = widget.auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
          await widget.firestore.collection('Users').doc(user.uid).get();
      setState(() {
        isAdmin = snapshot['roleType'] == 'admin';
      });
    }
  }
}
