import 'package:flutter/material.dart';
import 'package:info_hub_app/webinar/webinar_card.dart';

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
                return const WebinarCard();
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
                return const WebinarCard();
              }
            ),
          ],
        ),
      )
    );
  }
}