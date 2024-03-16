import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/models/livestream.dart';
import 'package:info_hub_app/webinar/webinar_card.dart';

class WebinarView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final UserModel user;

  const WebinarView({
    super.key,
    required this.firestore,
    required this.user,
  });

  @override
  State<WebinarView> createState() => _WebinarViewState();
}

class _WebinarViewState extends State<WebinarView> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _webinarStream;

  @override
  void initState() {
    super.initState();
    _webinarStream = widget.firestore.collection('Webinar').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Webinars"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Currently Live"),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: _webinarStream,
              builder: (context, snapshot) {
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
                      user: widget.user); // Removed const
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            const Text("Upcoming Webinars"),
            // ListView.builder(
            //   physics: const NeverScrollableScrollPhysics(),
            //   shrinkWrap: true,
            //   itemCount: 5,
            //   itemBuilder: (context, index) {
            //     return WebinarCard(); // Removed const
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
