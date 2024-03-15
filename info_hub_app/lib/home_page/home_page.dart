/*
 * This is a skeleton home page, which contains an app bar with the 
 * notifications and profile icons. This also contains a placeholder 
 * NotificationPage() and ProfilePage(), which should be replaced with the 
 * genuine article.
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/helpers/test_page.dart';
import 'package:info_hub_app/message_feature/patient_message_view.dart';
import 'package:info_hub_app/patient_experience/admin_experience_view.dart';
import 'package:info_hub_app/patient_experience/patient_experience_view.dart';
import 'package:info_hub_app/topics/topics_card.dart';
import 'package:info_hub_app/notifications/notifications.dart';
import 'package:info_hub_app/threads/threads.dart';
import 'package:info_hub_app/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/main.dart';
import 'package:info_hub_app/change_profile/change_profile.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:info_hub_app/webinar/webinar_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import 'package:info_hub_app/profile_view/profile_view.dart';

import 'package:info_hub_app/helpers/helper.dart' show getTrending;

class HomePage extends StatefulWidget {
  FirebaseFirestore firestore;
  FirebaseAuth auth;
  FirebaseStorage storage;

  //User? user = FirebaseAuth.instance.currentUser;
  HomePage(
      {super.key,
      required this.auth,
      required this.firestore,
      required this.storage});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Object> _topicsList = [];
  List<Object> _FiltList = [];
  int topicLength = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getTopicsList();
  }

  @override
  void initState() {
    super.initState();
    widget.firestore.collection('topics').snapshots().listen((snapshot) {
      getTopicsList();
    });
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
                            auth: widget.auth,
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
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (BuildContext context) {
                      return ProfileView(
                        firestore: widget.firestore,
                        auth: widget.auth,
                      );
                    },
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.email),
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: PatientMessageView(
                    firestore: widget.firestore,
                    auth: widget.auth,
                  ),
                  withNavBar: false,
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TestView(
                          firestore: widget.firestore,
                          auth: widget.auth,
                          storage: widget.storage,
                        )));
          },
          child: const Text('tests'),
        ),

        //above is the floating action button
        body: SingleChildScrollView(
          child: Column(children: [
            const Text(
              "Trending topics",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: topicLength == 0 ? 0 : topicLength,
                itemBuilder: (context, index) {
                  return TopicCard(
                      widget.firestore,
                      widget.auth,
                      widget.storage,
                      _topicsList[index] as QueryDocumentSnapshot<Object>);
                }),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Explore",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            GridView.extent(
              shrinkWrap: true,
              maxCrossAxisExtent: 150,
              crossAxisSpacing: 50,
              mainAxisSpacing: 50,
              padding: const EdgeInsets.all(20),
              children: [
                ElevatedButton(
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: ExperienceView(
                        firestore: widget.firestore,
                        auth: widget.auth,
                      ),
                      withNavBar: false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
                  child: const Text(
                    'Patient Experience',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const WebinarView(),
                      withNavBar: false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
                  child: const Text('Webinars'),
                ),
              ],
            ),
          ]),
        ));
  }


  Future getTopicsList() async {

    //added this line to prevent null error

    if (widget.auth.currentUser == null) {
    return;
  }
    String uid = widget.auth.currentUser!.uid;
    DocumentSnapshot user = await widget.firestore.collection('Users').doc(uid).get();
    String role = user['roleType'];
    QuerySnapshot data = await widget.firestore.collection('topics').where('tags', arrayContains: role).get();
    


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

