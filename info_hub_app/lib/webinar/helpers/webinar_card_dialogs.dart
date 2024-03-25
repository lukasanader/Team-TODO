
import 'package:flutter/material.dart';
import 'package:info_hub_app/webinar/controllers/card_controller.dart';
import 'package:info_hub_app/webinar/models/livestream.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';

class WebinarCardDialogs {
  WebinarService webinarService;

  WebinarCardDialogs({
    required this.webinarService,
  });

  void showDeleteDialog(BuildContext context, CardController controller, Livestream post) {
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

  // allows admin to change webinar card from upcoming to live
  void showLiveDialog(BuildContext context, Livestream post) {
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
  void showUpcomingDialog(BuildContext context, String startTime) {
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

  // prompts the user with a dialog box to change a webinar from live -> archived
  void showArchiveDialog(BuildContext context, CardController controller, Livestream post) {
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
}