import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageNotifications extends StatefulWidget {
  final FirebaseAuth auth;
  FirebaseFirestore firestore;
  ManageNotifications({Key? key, required this.auth, required this.firestore})
      : super(key: key);
  @override
  _ManageNotificationsState createState() => _ManageNotificationsState();
}

class _ManageNotificationsState extends State<ManageNotifications> {
  late bool _pushNotificationsEnabled;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getNotificationPreferences();
  }

  Future<void> _getNotificationPreferences() async {
    final currentUser = widget.auth.currentUser;

    final querySnapshot = await widget.firestore
        .collection('preferences')
        .where('uid', isEqualTo: currentUser?.uid)
        .get();

    setState(() {
      _pushNotificationsEnabled =
          querySnapshot.docs.first.get('push_notifications');
      _isLoading = false;
    });
  }

  Future<void> _updateNotificationPreferences(
      String type, bool newValue) async {
    final currentUser = widget.auth.currentUser;

    await widget.firestore
        .collection('preferences')
        .where('uid', isEqualTo: currentUser?.uid)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.first.reference.update({type: newValue});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Notifications'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  title: Text('Push Notifications'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _pushNotificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _pushNotificationsEnabled = value;
                            });
                            _updateNotificationPreferences(
                                'push_notifications', value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
