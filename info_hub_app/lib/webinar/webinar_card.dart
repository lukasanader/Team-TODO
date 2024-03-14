import 'package:flutter/material.dart';
import 'package:info_hub_app/models/livestream.dart';

/*
 * Will be used to display the webinar live streams as a card 
 * similar to youtube's videos and thumbnails
 */
class WebinarCard extends StatelessWidget {

  const WebinarCard({super.key});

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
                      Image.asset(
                        'assets/base_image.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(width: 12), // Add some spacing between the image and the column
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Title of webinar",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
