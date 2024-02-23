/*
 * This is a skeleton home page, which contains an app bar with the 
 * notifications and profile icons. This also contains a placeholder 
 * NotificationPage() and ProfilePage(), which should be replaced with the 
 * genuine article.
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/patient_experience/patient_experience_view.dart';
import 'package:info_hub_app/topics/topics_card.dart';
import 'package:info_hub_app/notifications/notifications.dart';
import 'package:info_hub_app/threads/threads.dart';
import 'package:info_hub_app/services/database.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';


class HomePage extends StatefulWidget {
  FirebaseFirestore firestore;
  //User? user = FirebaseAuth.instance.currentUser;
  HomePage({super.key, required this.firestore});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Object> _topicsList = [];
  int topicLength = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getTopicsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team TODO'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Placeholder method for notification icon
              // Navigate to notification page
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Notifications(
                          currentUser: '1',
                          firestore: widget.firestore,
                        )),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Placeholder method for profile picture icon
              // Navigate to profile page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),

      //below is the floating action button placeholder for thread navigation

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (BuildContext context) =>
                  ThreadApp(firestore: widget.firestore)));
        },
        child: const Icon(FontAwesomeIcons.comment),
      ),

      //above is the floating action button
      body: Center(
        child: Column(children: [
          Expanded(
            child: ListView.builder(
                itemCount: topicLength == 0 ? 0 : topicLength,
                itemBuilder: (context, index) {
                  return TopicCard(
                      _topicsList[index] as QueryDocumentSnapshot<Object>);
                }),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExperienceView(firestore: widget.firestore)),
              );
            },
            child: const Text('Patient Experience'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService(firestore: widget.firestore, uid: '1')
                  .createNotification('Test Notification',
                      'This is a test notification', DateTime.now());
            },
            child: const Text('Create Test Notification'),
          ),
        ]),
      ),
    );
  }

  Future getTopicsList() async {
    QuerySnapshot data = await widget.firestore.collection('topics').get();

    double getTrending(QueryDocumentSnapshot topic) {
      Timestamp timestamp = topic['date'];
      DateTime date = timestamp.toDate();
      int difference = DateTime.now().difference(date).inDays;
      if (difference == 0) {
        difference = 1;
      }
      return topic['views'] / difference;
    }

    setState(() {
      _topicsList = List.from(data.docs);
      _topicsList.sort((b, a) =>
          getTrending(a as QueryDocumentSnapshot<Object?>)
              .compareTo(getTrending(b as QueryDocumentSnapshot<Object?>)));
      topicLength = _topicsList.length;
      if (topicLength > 6) {
        _topicsList.removeRange(6, topicLength);
      }
      topicLength = _topicsList.length;
    });
  }
}

// PlaceHolder for Notification Page
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: const Center(
        child: Text('Notification Page'),
      ),
    );
  }
}

// PlaceHolder for Profile Page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile Page'),
      ),
    );
  }
}