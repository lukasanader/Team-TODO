import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/profile_view/profile_view.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/notifications/manage_notifications.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:info_hub_app/settings/general_settings.dart';
import 'package:info_hub_app/settings/help_page/help_page.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:info_hub_app/settings/privacy_base.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:info_hub_app/registration/start_page.dart';

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
              ListTile(
                title: const Text("Account"),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ProfileView(
                              firestore: widget.firestore,
                              auth: widget.auth,
                            )),
                  );
                },
              ),
              ListTile(
                title: const Text("General"),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => GeneralSettingsView(
                        themeManager: widget.themeManager,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text("Notifications"),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ManageNotifications(
                          firestore: widget.firestore, auth: widget.auth),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text("History"),
                // onTap: () {
                // },
              ),
              ListTile(
                title: const Text("Privacy"),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const PrivacyPage(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text("Help"),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const HelpView(),
                    ),
                  );
                },
              ),
              const AboutListTile(
                applicationLegalese: 'Legalese',
                applicationName: 'TEAM TODO',
                applicationVersion: '1.0.0',
                aboutBoxChildren: [
                  Text('Liver information hub for young people')
                ],
              ),
              ListTile(
                title: const Text("Log Out"),
                onTap: () {
                  widget.auth.signOut();
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return StartPage(
                            firestore: widget.firestore,
                            auth: widget.auth,
                            storage: widget.storage,
                            themeManager: widget.themeManager);
                      },
                    ),
                    (_) => false,
                  );
                },
              )
            ],
          )),
    );
  }
}
