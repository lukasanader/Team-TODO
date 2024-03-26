import 'package:flutter/material.dart';

void showAdminExperienceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Admin Experience View'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Overview:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'This section allows for the management of patient experiences, classified into Verified and Unverified categories.',
                ),
                SizedBox(height: 10),
                Text(
                  'Verified Experiences:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'These are visible in the patient experience view.',
                ),
                SizedBox(height: 10),
                Text(
                  'Unverified Experiences:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'These are not visible in the patient experience view.',
                ),
                SizedBox(height: 10),
                Text(
                  'Interactions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '• Trash icon: Deletes an experience permanently.\n'
                  '• Cross icon: Unverifies a verified experience.\n'
                  '• Tick icon: Verifies an unverified experience.',
                ),
                SizedBox(height: 10),
                Text(
                  'Confidential Information:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Each experience displays the author’s email and account type (Patient or Parent), which are not visible to patients or parents.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }