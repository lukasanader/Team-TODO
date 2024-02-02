// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class Discovery extends StatelessWidget {
  const Discovery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
            },
          ),
          title: TextField(),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
              },
            )
          ],
        ),
        body: ListView(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              height: 100,
              color: Colors.purple,
            ),
            Container(
              margin: EdgeInsets.all(10),
              height: 100,
              color: Colors.purple,
            ),
            Container(
              margin: EdgeInsets.all(10),
              height: 100,
              color: Colors.purple,
            ),
          ]
        ),
      ),
    );
  }
}