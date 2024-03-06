import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/models/livestream.dart';
import 'package:info_hub_app/models/user_model.dart';
import 'package:info_hub_app/screens/webinar-screens/dashboard.dart';
import 'package:info_hub_app/screens/webinar-screens/webinar_details_screen.dart';
import 'package:info_hub_app/services/database_service.dart';

class FeedScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final UserModel user;

  const FeedScreen({
    super.key,
    required this.firestore,
    required this.user,
  });

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _chatStream;

  @override
  void initState() {
    super.initState();

    // Initialize the Firestore stream
    _chatStream = FirebaseFirestore.instance.collection('Webinar').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Live Users',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _chatStream,
                  builder: (context, snapshot) {
                    return ListView.builder(
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        Livestream post = Livestream.fromMap(
                          snapshot.data!.docs[index].data() as Map<String, dynamic>,
                        );
                        String thumbnailUrl = post.image;

                        return InkWell(
                          onTap: () {},
                          child: Container(
                            height: 100,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(thumbnailUrl),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        'Dr. ${post.lastName}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text('${post.viewers} watching'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await DatabaseService(uid: widget.user.uid, firestore: widget.firestore)
                                        .updateViewCount(post.channelId, true);
                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => BroadcastScreen(
                                          isBroadcaster: false,
                                          channelId: post.uid,
                                          currentUser: widget.user,
                                          firestore: widget.firestore,
                                          title: post.title,
                                        ),
                                      ),
                                    );
                                  },
                                  alignment: Alignment.topRight,
                                  icon: const Icon(Icons.more_vert),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                onPressed: () {
                  // Navigate to the GoLiveScreen when the button is pressed
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GoLiveScreen(user: widget.user, firestore: widget.firestore),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

