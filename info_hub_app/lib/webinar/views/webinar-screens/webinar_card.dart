// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/webinar/controllers/card_controller.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/webinar/helpers/webinar_card_dialogs.dart';
import 'package:info_hub_app/webinar/models/livestream.dart';
import 'package:info_hub_app/webinar/controllers/webinar_controller.dart';

/// In control of creating the webinar card and its contents
class WebinarCard extends StatelessWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Livestream post;
  final UserModel user;
  final WebinarController webinarController;

  const WebinarCard({
    super.key,
    required this.post,
    required this.auth,
    required this.firestore,
    required this.user,
    required this.webinarController,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = user.roleType == 'admin'; // Check if user is admin
    CardController cardController = CardController(
        webinarController: webinarController, firestore: firestore);
    WebinarCardDialogs cardDialogs =
        WebinarCardDialogs(auth: auth, webinarController: webinarController);

    return GestureDetector(
      onTap: () async {
        String gestureHandler =
            await cardController.handleTap(context, post, user);
        if (gestureHandler == "Upcoming") {
          cardDialogs.showUpcomingDialog(context, post.startTime);
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
                  onPressed: () =>
                      _showAdminActions(context, cardController, cardDialogs),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays the functions an admin has at their disposal, regarding deleting and moving webinars between states
  void _showAdminActions(BuildContext context, CardController controller,
      WebinarCardDialogs cardDialogs) {
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
                  cardDialogs.showArchiveDialog(context, controller, post);
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
                  cardDialogs.showLiveDialog(context, post);
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
                cardDialogs.showDeleteDialog(context, controller, post);
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
}
