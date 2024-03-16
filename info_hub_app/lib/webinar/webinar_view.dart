import 'package:flutter/material.dart';

class WebinarView extends StatefulWidget {
  const WebinarView({super.key});

  @override
  State<WebinarView> createState() => _WebinarViewState();
}

class _WebinarViewState extends State<WebinarView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Webinars"),
      ),
      body: 
      SingleChildScrollView(
        child: Column(
          children: [
            const Text("Currently Live"),
            const SizedBox(
              height: 20),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 2,
              itemBuilder: (context, index) {
                return Card(
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
                );
              }
            ),
            const SizedBox(
              height: 20),
            const Text("Upcoming Webinars"),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
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
                );
              }
            ),
          ],
        ),
      )
    );
  }
}