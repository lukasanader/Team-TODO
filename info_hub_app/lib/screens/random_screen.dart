import 'package:flutter/material.dart';

void main() {
  runApp(Random());
}

class Random extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RandomScreen(),
    );
  }
}

class RandomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('In Progress Screen'),
      ),
      body: Center(
        child: Text(
          'In Progress',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
