import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/models/livestream.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/webinar-screens/webinar_card.dart';

class WebinarView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final UserModel user;
  final WebinarService webinarService;

  const WebinarView({
    Key? key,
    required this.firestore,
    required this.user,
    required this.webinarService,
  }) : super(key: key);

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
        padding: const EdgeInsets.only(bottom: 16.0), // Adjust the padding as needed
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (!_showArchivedWebinars) ...[
                      const Text("Currently Live"),
                      const SizedBox(height: 20),
                      StreamBuilder<QuerySnapshot>(
                        stream: widget.firestore
                            .collection('Webinar')
                            .where('status', isEqualTo: 'Live')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text(
                              "None of our trusted NHS doctors are live right now \nPlease check later!",
                              textAlign: TextAlign.center,
                            );
                          }
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data?.docs.length ?? 0,
                            itemBuilder: (context, index) {
                              Livestream post = Livestream.fromMap(
                                snapshot.data!.docs[index].data() as Map<String, dynamic>,
                              );
                              return WebinarCard(
                                post: post,
                                firestore: widget.firestore,
                                user: widget.user,
                                webinarService: widget.webinarService,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text("Upcoming Webinars"),
                      StreamBuilder<QuerySnapshot>(
                        stream: widget.firestore
                            .collection('Webinar')
                            .where('status', isEqualTo: 'Upcoming')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text("Seems like all of our trusted doctors are busy \nCheck regularly to see if there have been any changes",
                            textAlign: TextAlign.center,);
                          }
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data?.docs.length ?? 0,
                            itemBuilder: (context, index) {
                              Livestream post = Livestream.fromMap(
                                snapshot.data!.docs[index].data() as Map<String, dynamic>,
                              );
                              return WebinarCard(
                                post: post,
                                firestore: widget.firestore,
                                user: widget.user,
                                webinarService: widget.webinarService,
                              );
                            },
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (_showArchivedWebinars) ...[
                      const Text("Archived Webinars"),
                      StreamBuilder<QuerySnapshot>(
                        stream: widget.firestore
                            .collection('Webinar')
                            .where('status', isEqualTo: 'Archived')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text("Check back here to see any webinars you may have missed!");
                          }
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data?.docs.length ?? 0,
                            itemBuilder: (context, index) {
                              Livestream post = Livestream.fromMap(
                                snapshot.data!.docs[index].data() as Map<String, dynamic>,
                              );
                              return WebinarCard(
                                post: post,
                                firestore: widget.firestore,
                                user: widget.user,
                                webinarService: widget.webinarService,
                              );
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
                _showArchivedWebinars ? 'Show Live and Upcoming Webinars' : 'Archived Webinars',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
