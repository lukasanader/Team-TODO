import 'package:flutter/material.dart';
import 'package:info_hub_app/help_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

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

        ],)
    );
  }
}