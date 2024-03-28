import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/view/message_view/message_card_helper.dart';
import 'package:info_hub_app/model/user_models/user_model.dart';
import 'package:info_hub_app/model/livestream_models/livestream_model.dart';
import 'package:info_hub_app/controller/webinar_controllers/webinar_controller.dart';
import 'package:info_hub_app/view/webinar_view/webinar-screens/webinar_card.dart';

class WebinarView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final UserModel user;
  final FirebaseAuth auth;
  final WebinarController webinarController;

  const WebinarView({
    super.key,
    required this.firestore,
    required this.auth,
    required this.user,
    required this.webinarController,
  });

  @override
  State<WebinarView> createState() => _WebinarViewState();
}

class _WebinarViewState extends State<WebinarView> {
  late String _selectedCategory;
  bool _showArchivedWebinars = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.user.roleType != 'admin' ? widget.user.roleType : 'Patient';
  }

  Widget buildCards(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: (snapshot.data?.docs.length ?? 0) * 2 - 1,
      itemBuilder: (context, index) {
        if (index.isOdd) {
          // Add Padding and Container between WebinarCards as a separator.
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 1,
              color: Colors.grey,
            ),
          );
        } else {
          // Calculate the actual index of the Livestream post.
          final postIndex = index ~/ 2;
          Livestream post = Livestream.fromMap(
            snapshot.data!.docs[postIndex].data() as Map<String, dynamic>,
          );
          return WebinarCard(
            post: post,
            auth: widget.auth,
            firestore: widget.firestore,
            user: widget.user,
            webinarController: widget.webinarController,
          );
        }
      },
    );
  }

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
                        stream: widget.webinarController.getLiveWebinars(_selectedCategory),
                        builder: (context, snapshot) {
                          // Display data (if any) on the screen or an error message
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.data!.docs.isEmpty) {
                            return messageCard(
                              "Right now, we don't have any live videos streaming. We encourage you to explore other resources available in the app while you wait for the next live event.",
                              'no_live_webinars',
                              context,
                            );
                          }
                          return buildCards(snapshot);
                        },
                      ),
                      addVerticalSpace(10),
                      Text(
                        "Upcoming Webinars",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      addVerticalSpace(10),
                      StreamBuilder<QuerySnapshot>(
                        stream: widget.webinarController.getUpcomingWebinars(_selectedCategory),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.data!.docs.isEmpty) {
                            return messageCard(
                              "At the moment, there aren't any webinars lined up for viewing. We're working on bringing you more informative sessions soon. Thank you for your patience.",
                              'no_upcoming_webinars',
                              context,
                            );
                          }
                          return buildCards(snapshot);
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
                        stream: widget.webinarController.getArchivedWebinars(_selectedCategory),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.data!.docs.isEmpty) {
                            return messageCard(
                              "Missed a webinar? No worries! Keep an eye on this space for any webinars you might have missed. We'll make sure you have access to all the valuable information at your convenience.",
                              'no_archived_webinars',
                              context,
                            );
                          }
                          return buildCards(snapshot);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (widget.user.roleType == 'admin') // Displays dropdown for admin to cycle webinar view between all role types
              DropdownButton<String>(
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                items: <String>['Patient', 'Parent', 'Healthcare Professional']
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
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
