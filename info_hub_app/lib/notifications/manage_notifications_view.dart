import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'manage_notifications_controller.dart';

class ManageNotifications extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  const ManageNotifications({super.key, required this.auth, required this.firestore});
  @override
  _ManageNotificationsState createState() => _ManageNotificationsState();
}

class _ManageNotificationsState extends State<ManageNotifications> {
  late bool _pushNotificationsEnabled;
  bool _isLoading = true;
  late ManageNotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ManageNotificationsController(
        auth: widget.auth, firestore: widget.firestore);
    _getNotificationPreferences();
  }

  Future<void> _getNotificationPreferences() async {
    final result = await _controller.getNotificationPreferences();

    setState(() {
      _pushNotificationsEnabled = result;
      _isLoading = false;
    });
  }

  Future<void> _updateNotificationPreferences(
      String type, bool newValue) async {
    await _controller.updateNotificationPreferences(type, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Notifications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  title: const Text('Push Notifications'),
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
