import 'package:flutter/material.dart';

class ManageNotifications extends StatefulWidget {
  @override
  _ManageNotificationsState createState() => _ManageNotificationsState();
}

class _ManageNotificationsState extends State<ManageNotifications> {
  bool _pushNotificationsEnabled = true;
  bool _notificationType1Enabled = true;
  bool _notificationType2Enabled = true;
  bool _notificationType3Enabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Notifications'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Push Notifications'),
            value: _pushNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _pushNotificationsEnabled = value;
              });
            },
          ),
          ListTile(
            title: Text('Notification Types'),
          ),
          SwitchListTile(
            title: Text('Notification Type 1'),
            value: _notificationType1Enabled,
            onChanged: (value) {
              setState(() {
                _notificationType1Enabled = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('Notification Type 2'),
            value: _notificationType2Enabled,
            onChanged: (value) {
              setState(() {
                _notificationType2Enabled = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('Notification Type 3'),
            value: _notificationType3Enabled,
            onChanged: (value) {
              setState(() {
                _notificationType3Enabled = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
