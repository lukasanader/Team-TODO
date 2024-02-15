import 'package:flutter/material.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: const Text("Help"),
      ),
      body: PageView(
        children: [
          Container(
            height: 100,
            width: 100,
            color: Colors.red,
            child: const Text("Hello"),
          ),
          Container(
            height: 100,
            width: 100,
            color: Colors.blue,
            child: const Text("Hello"),
          ),
        ],)
      
      
      // Column(
      //   children: [
      //     Container(
      //       height: 100,
      //       width: 100,
      //       color: Colors.red,
      //       child: const Text("Hello"),
      //     )
      //   ]),
    );
  }
}