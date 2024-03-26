import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/theme/theme_constants.dart';
import 'package:info_hub_app/webinar/models/livestream.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/views/webinar-screens/webinar_card.dart';

class WebinarView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final UserModel user;
  final WebinarService webinarService;

  const WebinarView({
    super.key,
    required this.firestore,
    required this.user,
    required this.webinarService,
  });

  @override
  State<WebinarView> createState() => _WebinarViewState();
}

class _WebinarViewState extends State<WebinarView> {
  bool _showArchivedWebinars = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Webinars"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (!_showArchivedWebinars) ...[
                      Text(
                        "Currently Live",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: widget.firestore
                            .collection('Webinar')
                            .where('status', isEqualTo: 'Live')
                            .where('selectedtags',
                                arrayContains: widget.user.roleType)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return messageCard(
                                "Right now, we don't have any live videos streaming. We encourage you to explore other resources available in the app while you wait for the next live event.",
                                'no_live_webinars',
                                context);
                          }
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            // Adjust itemCount to account for both Livestream posts and separators.
                            itemCount:
                                (snapshot.data?.docs.length ?? 0) * 2 - 1,
                            itemBuilder: (context, index) {
                              if (index.isOdd) {
                                // Add Padding and Container between WebinarCards as a separator.
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                );
                              } else {
                                // Calculate the actual index of the Livestream post.
                                final postIndex = index ~/ 2;
                                Livestream post = Livestream.fromMap(
                                  snapshot.data!.docs[postIndex].data()
                                      as Map<String, dynamic>,
                                );
                                return WebinarCard(
                                  post: post,
                                  firestore: widget.firestore,
                                  user: widget.user,
                                  webinarService: widget.webinarService,
                                );
                              }
                            },
                          );
                        },
                      ),
                      addVerticalSpace(10),
                      Text(
                        "Upcoming Webinars",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      addVerticalSpace(10),
                      StreamBuilder<QuerySnapshot>(
                        stream: widget.firestore
                            .collection('Webinar')
                            .where('status', isEqualTo: 'Upcoming')
                            .where('selectedtags',
                                arrayContains: widget.user.roleType)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return messageCard(
                                "At the moment, there aren't any webinars lined up for viewing. We're working on bringing you more informative sessions soon. Thank you for your patience.",
                                'no_upcoming_webinars',
                                context);
                          }
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                (snapshot.data?.docs.length ?? 0) * 2 - 1,
                            itemBuilder: (context, index) {
                              // Check if the index is for a separator.
                              if (index.isOdd) {
                                // Return a separator widget.
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                );
                              } else {
                                // Calculate the index for actual Livestream posts.
                                int postIndex = index ~/ 2;
                                Livestream post = Livestream.fromMap(
                                  snapshot.data!.docs[postIndex].data()
                                      as Map<String, dynamic>,
                                );
                                return WebinarCard(
                                  post: post,
                                  firestore: widget.firestore,
                                  user: widget.user,
                                  webinarService: widget.webinarService,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (_showArchivedWebinars) ...[
                      Text(
                        "Archived Webinars",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      addVerticalSpace(10),
                      StreamBuilder<QuerySnapshot>(
                        stream: widget.firestore
                            .collection('Webinar')
                            .where('status', isEqualTo: 'Archived')
                            .where('selectedtags',
                                arrayContains: widget.user.roleType)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return messageCard(
                                "Missed a webinar? No worries! Keep an eye on this space for any webinars you might have missed. We'll make sure you have access to all the valuable information at your convenience.",
                                'no_archived_webinars',
                                context);
                          }
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                (snapshot.data?.docs.length ?? 0) * 2 - 1,
                            itemBuilder: (context, index) {
                              // Check if the index is for a separator.
                              if (index.isOdd) {
                                // Return a separator widget.
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey,
                                  ),
                                );
                              } else {
                                // Calculate the index for actual Livestream posts.
                                int postIndex = index ~/ 2;
                                Livestream post = Livestream.fromMap(
                                  snapshot.data!.docs[postIndex].data()
                                      as Map<String, dynamic>,
                                );
                                return WebinarCard(
                                  post: post,
                                  firestore: widget.firestore,
                                  user: widget.user,
                                  webinarService: widget.webinarService,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showArchivedWebinars = !_showArchivedWebinars;
                });
              },
              child: Text(
                _showArchivedWebinars
                    ? 'Show Live and Upcoming Webinars'
                    : 'Archived Webinars',
              ),
            ),
          ],
        ),
      ),
    );
  }
}