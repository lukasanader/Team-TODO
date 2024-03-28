import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/controller/user_controller.dart';
import 'package:info_hub_app/profile_view/profile_view.dart';
import 'package:info_hub_app/profile_view/profile_view_controller.dart';
import 'package:info_hub_app/notifications/preferences_view.dart';
import 'package:info_hub_app/screens/activity_view.dart';
import 'package:info_hub_app/settings/general_settings.dart';
import 'package:info_hub_app/settings/help_page_view.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/settings/saved/view/saved_view.dart';
import 'package:info_hub_app/settings/drafts/view/drafts_view.dart';
import 'package:info_hub_app/settings/privacy_base.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:info_hub_app/registration/start_page.dart';

class SettingsView extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final ThemeManager themeManager;
  final FirebaseMessaging messaging;
  const SettingsView(
      {super.key,
      required this.auth,
      required this.firestore,
      required this.storage,
      required this.themeManager,
      required this.messaging});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isAdmin = false;
  late UserController userController;

  @override
  void initState() {
    super.initState();
    userController = UserController(widget.auth, widget.firestore);
    initializeAdminStatus();
  }

  Future<void> initializeAdminStatus() async {
    bool isAdminUser = await userController.isAdmin();
    setState(() {
      isAdmin = isAdminUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Account"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: ProfileView(
                  controller: ProfileViewController(
                    firestore: widget.firestore,
                    auth: widget.auth,
                  ),
                ),
                withNavBar: false,
              );
            },
          ),
          ListTile(
            title: const Text("General"),
            trailing: const Icon(Icons.keyboard_arrow_right),
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
            title: const Text("Privacy"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const PrivacyPage(),
                withNavBar: false,
              );
            },
          ),
          const SizedBox(height: 30),
          ListTile(
            title: const Text("Notifications"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: PreferencesPage(
                  firestore: widget.firestore,
                  auth: widget.auth,
                ),
                withNavBar: false,
              );
            },
          ),
          ListTile(
            title: const Text('History'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: ActivityView(
                  firestore: widget.firestore,
                  auth: widget.auth,
                  storage: widget.storage,
                ),
                withNavBar: false,
              );
            },
          ),
          ListTile(
            title: const Text('Saved Topics'),
            trailing: const Icon(Icons.keyboard_arrow_right),
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
              trailing: const Icon(Icons.keyboard_arrow_right),
              title: const Text('Topic Drafts'),
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
          const SizedBox(height: 30),
          ListTile(
            title: const Text('Help'),
            trailing: const Icon(Icons.keyboard_arrow_right),
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
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () async {
              final String? deviceToken = await widget.messaging.getToken();
              if (deviceToken != null) {
                final tokenSnapshot = await widget.firestore
                    .collection('Users')
                    .doc(widget.auth.currentUser!.uid)
                    .collection('deviceTokens')
                    .where('token', isEqualTo: deviceToken)
                    .get();

                if (tokenSnapshot.docs.isNotEmpty) {
                  await tokenSnapshot.docs.first.reference.delete();
                }
              }
              widget.auth.signOut();
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return StartPage(
                      firestore: widget.firestore,
                      auth: widget.auth,
                      storage: widget.storage,
                      themeManager: widget.themeManager,
                      messaging: FirebaseMessaging.instance,
                      localnotificationsplugin:
                          FlutterLocalNotificationsPlugin(),
                    );
                  },
                ),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
