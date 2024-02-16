import 'package:flutter/material.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Help"),
      ),
      body: Column(children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.red,
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            width: 100,
            color: Colors.blue,
            child: Text("fnioaheo"),)
        )
      ],)
    );
  }
}