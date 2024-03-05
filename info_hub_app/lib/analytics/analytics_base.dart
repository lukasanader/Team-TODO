import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/analytics/topics/analytics_topic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AnalyticsBase extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  const AnalyticsBase(
      {super.key, required this.firestore, required this.storage});

  @override
  State<AnalyticsBase> createState() => _AnalyticsTopicView();
}

class _AnalyticsTopicView extends State<AnalyticsBase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("All Analytics")),
        body: Center(
          child: GridView.extent(
            maxCrossAxisExtent: 150,
            shrinkWrap: true,
            crossAxisSpacing: 50.0,
            mainAxisSpacing: 50.0,
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (BuildContext context) {
                            return AnalyticsTopicView(
                              storage: widget.storage,
                              firestore: widget.firestore,
                            );
                          },
                        ),
                      ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.article),
                      Text(
                        "Topics",
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  )),
            ],
          ),
        ));
  }
}
