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
        title: const Text("Upcoming Webinars"),
      ),
    );
  }
}