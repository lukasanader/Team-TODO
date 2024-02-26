import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/change_profile/change_profile.dart'; // Import ChangeProfile screen

class MainPage extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const MainPage({Key? key, required this.firestore, required this.auth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Main Page!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeProfile(firestore: firestore, auth: auth,),
                  ),
                );
              },
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

