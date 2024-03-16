import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/registration/user_model.dart';
import 'package:info_hub_app/webinar/models/livestream.dart';
import 'package:info_hub_app/webinar/service/webinar_service.dart';
import 'package:info_hub_app/webinar/webinar-screens/webinar_details_screen.dart';
/*
 * Will be used to display the webinar live streams as a card 
 * similar to youtube's videos and thumbnails
 */
class WebinarCard extends StatelessWidget {
  FirebaseFirestore firestore;
  Livestream post;
  UserModel user;

  WebinarCard({
    super.key,
    required this.post,
    required this.firestore,
    required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          await WebinarService(firestore: firestore).updateViewCount(post.webinarID, true);
          // ignore: use_build_context_synchronously
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
                    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start of the row
                    children: [
                      Image.network(post.image,
                        height:100,
                        width: 100),
                      const SizedBox(width: 12), // Add some spacing between the image and the column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              post.startedBy,
                              style: TextStyle(fontWeight: FontWeight.normal),
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
                            SizedBox(height: 30), // Add some spacing between the title and the date
                            Text(
                              "20/03/2024",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )

    );
  }
}
