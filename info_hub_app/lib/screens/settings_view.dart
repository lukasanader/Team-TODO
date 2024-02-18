import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/screens/activity_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class SettingsView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const SettingsView({super.key, required this.firestore, required this.auth});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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


            Container(
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.black)
              // ),
              child: const ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Manage Notifications'),
              ),
            ),
            Container(
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.black)
              // ),
              child: const ListTile(
                leading: Icon(Icons.privacy_tip),
                title: Text('Manage Privacy Settings'),
              ),
            ),
            GestureDetector(
              key: const Key('Activity Option'),
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: ActivityView(firestore: widget.firestore,auth: widget.auth,),
                  withNavBar: false, 
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
            child:
            Container(
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.black)
              // ),
              child: const ListTile(
                leading: Icon(Icons.history_outlined),
                title: Text('History'),
              ),
            ),
            ),
            Container(
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.black)
              // ),
              child: const ListTile(
                leading: Icon(Icons.help),
                title: Text('Help'),
              ),
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

        ],)
    );
  }
}