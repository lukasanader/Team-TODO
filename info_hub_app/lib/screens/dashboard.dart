import 'package:flutter/material.dart';

// Placeholder page to be implemented at a later date
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NOTE: AppBar shows the <- arrrow, getting rid of the app bar will remove this.
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Center(
        child: Text('Welcome to the Main Page!'),
      ),
    );
  }
}
