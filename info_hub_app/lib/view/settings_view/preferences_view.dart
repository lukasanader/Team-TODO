import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../controller/notification_controllers/preferences_controller.dart';

class PreferencesPage extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  const PreferencesPage(
      {super.key, required this.auth, required this.firestore});
  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late bool _pushNotificationsEnabled;
  bool _isLoading = true;
  late PreferencesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PreferencesController(
        auth: widget.auth,
        uid: widget.auth.currentUser!.uid,
        firestore: widget.firestore);
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
      // Display a loading spinner while fetching the notification preferences
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
                              // Update the state of the switch
                              _pushNotificationsEnabled = value;
                            });
                            // Update the value in Firestore
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
