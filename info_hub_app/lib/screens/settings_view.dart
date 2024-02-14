import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          onPressed: () {}, 
          icon: const Icon(Icons.arrow_back))
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
            Container(
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.black)
              // ),
              child: const ListTile(
                leading: Icon(Icons.help),
                title: Text('Help'),
              ),
            ),

        ],)
    );
  }
}