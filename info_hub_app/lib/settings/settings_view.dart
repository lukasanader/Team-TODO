import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/notifications/manage_notifications.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/screens/privacy_base.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:info_hub_app/registration/start_page.dart';
import 'package:info_hub_app/settings/help_page.dart'; // Import the help page widget

class SettingsView extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  const SettingsView({super.key, required this.auth, required this.firestore, required this.storage});

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
              leading: Icon(Icons.privacy_tip),
              title: Text('Manage Privacy Settings'),
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: PrivacyPage(),
                  withNavBar: false,
                );
              },
            ),
            const ListTile(
              leading: Icon(Icons.history_outlined),
              title: Text('History'),
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
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
}

