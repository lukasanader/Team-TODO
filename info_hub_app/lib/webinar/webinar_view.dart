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
      body: 1 == 1
      ? SafeArea(
        child: Column(
          children: [
            const Text("Currently Live"),
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Card(
                    child: Text(index.toString()),
                  );
                }
              ),
            ),
            const Text("Upcoming Webinars"),
            Expanded(
              flex: 5,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    child: Text(index.toString()),
                  );
                }
              ),
            ),
          ],
        ),
      )
      : SafeArea(
          child: Column(
            children: [
              const Text("Upcoming Webinars"),
              Expanded(
                child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    child: Text(index.toString()),
                  );
                }
              ),
            ),
          ],
        ) 
      )
    );
  }
}