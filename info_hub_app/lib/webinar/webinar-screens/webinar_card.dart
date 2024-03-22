import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/models/livestream.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/webinar-screens/display_webinar.dart';

class WebinarCard extends StatelessWidget {
  final FirebaseFirestore firestore;
  final Livestream post;
  final UserModel user;
  final WebinarService webinarService;

  const WebinarCard({
    super.key,
    required this.post,
    required this.firestore,
    required this.user,
    required this.webinarService,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = user.roleType == 'admin'; // Check if user is admin

    return GestureDetector(
      onTap: () async {
        // if user attempts to click on a non-existent webinar, they should be prompted that they can't yet enter
        if (post.status == "Upcoming") {
          _showUpcomingDialog(context, post.startTime);
        } else {
        // if live or archived redirect to watch screen and increment view counter
          await webinarService.updateViewCount(post.webinarID, true);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WebinarScreen(
                webinarID: post.webinarID,
                youtubeURL: post.youtubeURL,
                currentUser: user,
                firestore: firestore,
                title: post.title,
                webinarService: webinarService,
                status: post.status,
              ),
            ),
          );
        }
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
                    Text(
                      post.startTime,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // if user is admin, they're able to modify webinar status using dropdown in the top right of each card
              if (isAdmin)
                PopupMenuButton(
                  itemBuilder: (context) => [
                    if (post.status != "Archived")
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

  // prompts the user with a dialog box to change a webinar from live -> archived
  void _showArchiveDialog(BuildContext context) {
    TextEditingController urlController = TextEditingController();
    bool isValidURL = true; // Track if the URL is valid
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text('Move to Archive'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Are you sure you want to move this webinar to the archive?'),
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
                      // validates url into expected formats and sets these changes into database
                      final RegExp regex = RegExp(r'https:\/\/(?:www\.)?youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)|https:\/\/youtu\.be\/([a-zA-Z0-9_-]+)');
                      if (regex.hasMatch(newURL)) {
                        await webinarService.setWebinarStatus(post.webinarID, newURL, changeToArchived: true);
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

  // allows admin to change webinar card from upcoming to live
void _showLiveDialog(BuildContext context) {
  // Store the context in a variable
  BuildContext dialogContext = context;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Move to Live'),
        content: const Text('Are you sure you want to move this webinar to live?'),
        actions: [
          TextButton(
            onPressed: () {
              // if the user cancels the operation, nothing happens
              Navigator.pop(dialogContext); // Use the stored dialogContext
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Check if the widget associated with the context is mounted
              if (Navigator.of(dialogContext).canPop()) {
                // update database with new information and pop dialog box off the screen
                await webinarService.setWebinarStatus(post.webinarID, post.youtubeURL, changeToLive: true);
                Navigator.pop(dialogContext); // Use the stored dialogContext
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}


  // prompts the user with an informative summary that a webinar is not yet available to be watched and when they should check
  void _showUpcomingDialog(BuildContext context, String startTime) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Webinar Not Available Yet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('This webinar is scheduled to start at $startTime.'),
              const SizedBox(height: 20),
              const Text('Please come back at the scheduled time to join the webinar.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
