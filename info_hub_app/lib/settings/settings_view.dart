import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:info_hub_app/profile_view/profile_view.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/notifications/manage_notifications.dart';
import 'package:info_hub_app/screens/activity_view.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:info_hub_app/settings/general_settings.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/settings/saved/saved_page.dart';
import 'package:info_hub_app/settings/drafts/drafts_page.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/settings/privacy_base.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:info_hub_app/registration/start_page.dart';
import 'package:info_hub_app/settings/help_page.dart'; // Import the help page widget

class SettingsView extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final ThemeManager themeManager;
  const SettingsView(
      {super.key,
      required this.auth,
      required this.firestore,
      required this.storage,
      required this.themeManager});

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
            ListTile(
              title: const Text("Account"),
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //         builder: (context) => ProfileView(
              //               firestore: widget.firestore,
              //               auth: widget.auth,
              //             )),
              //   );
              // },
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: ProfileView(
                    firestore: widget.firestore,
                    auth: widget.auth,
                  ),
                  withNavBar: false,
                );
              },
            ),
            ListTile(
              title: const Text("General"),
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //       builder: (context) => GeneralSettings(
              //         themeManager: widget.themeManager,
              //       ),
              //     ),
              //   );
              // },
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: GeneralSettings(
                    themeManager: widget.themeManager,
                  ),
                  withNavBar: false,
                );
              },
            ),
            ListTile(
              title: const Text("Notifications"),
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //       builder: (context) => ManageNotifications(
              //           firestore: widget.firestore, auth: widget.auth),
              //     ),
              //   );
              // },
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
            ),
            ListTile(
              title: const Text('History'),
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //       builder: (context) => ActivityView(
              //           firestore: widget.firestore, auth: widget.auth),
              //     ),
              //   );
              // }
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: ActivityView(
                    firestore: widget.firestore,
                    auth: widget.auth,
                  ),
                  withNavBar: false,
                );
              },
            ),
            ListTile(
              title: const Text("Privacy"),
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //       builder: (context) => const PrivacyPage(),
              //     ),
              //   );
              // },
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: const PrivacyPage(),
                  withNavBar: false,
                );
              },
            ),
            ListTile(
              title: const Text('Saved Topics'),
              // onTap: () {
              //   // Navigate to the saved topics page when tapped
              //   Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //         builder: (context) => SavedPage(
              //               auth: widget.auth,
              //               firestore: widget.firestore,
              //               storage: widget.storage,
              //             )),
              //   );
              // },
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: SavedPage(
                    firestore: widget.firestore,
                    auth: widget.auth,
                    storage: widget.storage,
                  ),
                  withNavBar: false,
                );
              },
            ),
            if (isAdmin)
              ListTile(
                key: const Key("drafts_tile"),
                title: const Text('Topic Drafts'),
                // onTap: () {
                //   // Navigate to the saved topics page when tapped
                //   Navigator.push(
                //     context,
                //     CupertinoPageRoute(
                //         builder: (context) => DraftsPage(
                //               auth: widget.auth,
                //               firestore: widget.firestore,
                //               storage: widget.storage,
                //             )),
                //   );
                // },
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: DraftsPage(
                    firestore: widget.firestore,
                    auth: widget.auth,
                    storage: widget.storage,
                  ),
                  withNavBar: false,
                );
              },
              ),
            ListTile(
              title: const Text('Help'),
              onTap: () {
                // Navigate to the HelpPage when tapped
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const HelpPage()),
                );
              },
            ),
            const AboutListTile(
              applicationLegalese: 'Legalese',
              applicationName: 'TEAM TODO',
              applicationVersion: '1.0.0',
              aboutBoxChildren: [
                Text('Liver information hub for young people'),
              ],
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: () {
                widget.auth.signOut();
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: StartPage(
                    firestore: widget.firestore,
                    auth: widget.auth,
                    storage: widget.storage,
                    themeManager: widget.themeManager,
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
