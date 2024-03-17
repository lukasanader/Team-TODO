import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/models/livestream.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/webinar-screens/webinar_details_screen.dart';

class WebinarCard extends StatelessWidget {
  final FirebaseFirestore firestore;
  final Livestream post;
  final UserModel user;

  const WebinarCard({super.key,
    required this.post,
    required this.firestore,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = user.roleType == 'admin'; // Check if user is admin

    // builds a webinar card, displaying each webinar currently stored in the database
    return GestureDetector(
      onTap: () async {
        await WebinarService(firestore: firestore).updateViewCount(post.webinarID, true);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BroadcastScreen(
              webinarID: post.webinarID,
              youtubeURL: post.youtubeURL,
              currentUser: user,
              firestore: firestore,
              title: post.title,
            ),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                post.image,
                height: 100,
                width: 100,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      post.startedBy,
                      style: const TextStyle(fontWeight: FontWeight.normal),
                    ),
                    Text(
                      '${post.viewers} watching',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      post.startTime,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (isAdmin)
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Move to Archive'),
                      onTap: () {
                        _showArchiveDialog(context);
                      },
                    ),
                    if (post.status == "Upcoming")
                      PopupMenuItem(
                        child: const Text('Move to Live'),
                        onTap: () {
                          _showLiveDialog(context);
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

void _showArchiveDialog(BuildContext context) {
  TextEditingController urlController = TextEditingController();
  bool isValidURL = true; // Track if the URL is valid
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, setState) {
          return AlertDialog(
            title: const Text('Move to Archived'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you sure you want to move this webinar to archived?'),
                const SizedBox(height: 20),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: 'Enter new YouTube video URL',
                    // Set error text and style based on isValidURL
                    errorText: isValidURL ? null : 'Invalid URL format',
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String newURL = urlController.text;
                  if (newURL.isNotEmpty) {
                    final RegExp regex = RegExp(r'https:\/\/(?:www\.)?youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)|https:\/\/youtu\.be\/([a-zA-Z0-9_-]+)');
                    if (regex.hasMatch(newURL)) {
                      await WebinarService(firestore: firestore).setWebinarStatus(post.webinarID, newURL, changeToArchived: true);
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        isValidURL = false; // Set isValidURL to false to trigger error
                      });
                    }
                  } else {
                    setState(() {
                      isValidURL = true; // Reset isValidURL when the text field is empty
                    });
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    },
  );
}


  void _showLiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Move to Live'),
          content: const Text('Are you sure you want to move this webinar to live?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await WebinarService(firestore: firestore).setWebinarStatus(post.webinarID,post.youtubeURL,changeToLive: true);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
