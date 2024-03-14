import 'package:flutter/material.dart';
import 'package:info_hub_app/webinar/models/livestream.dart';
/*
 * Will be used to display the webinar live streams as a card 
 * similar to youtube's videos and thumbnails
 */
class WebinarCard extends StatelessWidget {
  Livestream post;

  WebinarCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          
        },
        child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start of the row
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(post.image),
                      ),
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
