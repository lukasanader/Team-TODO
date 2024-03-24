import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/controllers/card_controller.dart';
import 'package:info_hub_app/webinar/models/livestream.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';

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
    CardController cardController = CardController(webinarService: webinarService, firestore: firestore);

    return GestureDetector(
      onTap: () async {
        String gestureHandler = await cardController.handleTap(context, post, user);
        if (gestureHandler == "Upcoming") {
          _showUpcomingDialog(context, post.startTime);
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
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showAdminActions(context, cardController),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdminActions(BuildContext context, CardController controller) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            if (post.status != "Archived")
              InkWell(
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  _showArchiveDialog(context, controller);

                },
                child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  height: 80, // Specify the desired height here
                  child: const ListTile(
                    leading: Icon(Icons.archive_outlined),
                    title: Text('Move to Archive'),
                  ),
                ),
              ),
            if (post.status == "Upcoming")
              InkWell(
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _showLiveDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  height: 80, // Specify the desired height here
                  child: const ListTile(
                    leading: Icon(Icons.live_tv_outlined),
                    title: Text('Move to Live'),
                  ),
                ),
              ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context,controller);
              },
              child: Container(
                padding: const EdgeInsets.only(top: 5),
                  height: 65,
                  child: const ListTile(
                    leading: Icon(Icons.delete_outlined),
                    title: Text('Delete Webinar'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  void _showDeleteDialog(BuildContext context, CardController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Webinar'),
          content: const Text('Are you sure you want to delete this webinar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.deleteWebinar(post.webinarID);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // prompts the user with a dialog box to change a webinar from live -> archived
  void _showArchiveDialog(BuildContext context, CardController controller) {
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
                  const Text(
                      'Are you sure you want to move this webinar to the archive?'),
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
                      bool isValidated = await controller.validateCardLogic(post, newURL);
                      if (isValidated) {
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          isValidURL =
                              false; // Set isValidURL to false to trigger error
                        });
                      }
                    } else {
                      setState(() {
                        isValidURL =
                            true; // Reset isValidURL when the text field is empty
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Move to Live'),
          content:
              const Text('Are you sure you want to move this webinar to live?'),
          actions: [
            TextButton(
              onPressed: () {
                // if the user cancels the operation, nothing happens
                Navigator.pop(context); // Use the stored dialogContext
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Check if the widget associated with the context is mounted
                if (Navigator.of(context).canPop()) {
                  // update database with new information and pop dialog box off the screen
                  await webinarService.setWebinarStatus(
                      post.webinarID, post.youtubeURL,
                      changeToLive: true);
                  Navigator.pop(context); // Use the stored dialogContext
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
              const Text(
                  'Please come back at the scheduled time to join the webinar.'),
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
