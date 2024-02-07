import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThreadReplies extends StatefulWidget {
  const ThreadReplies({Key? key}) : super(key: key);

  @override
  State<ThreadReplies> createState() => _ThreadRepliesState();
}

class _ThreadRepliesState extends State<ThreadReplies> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Replies"),
      ),
      body: Center(
        child: Text(
          "In development",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
