// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/controller/user_controller.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/helpers/test_page.dart';
import 'package:info_hub_app/message_feature/patient_message_view.dart';
import 'package:info_hub_app/experiences/experiences_view.dart';
import 'package:info_hub_app/model/user_model.dart';
import 'package:info_hub_app/notifications/notification_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:info_hub_app/controller/create_topic_controllers/topic_controller.dart';
import 'package:info_hub_app/topics/view_topic/helpers/topics_card.dart';
import 'package:info_hub_app/webinar/controllers/webinar_controller.dart';
import 'package:info_hub_app/webinar/views/webinar-screens/webinar_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:info_hub_app/model/topic_model.dart';

import 'package:info_hub_app/helpers/helper.dart' show getTrending;

class HomePage extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  const HomePage(
      {super.key,
      required this.auth,
      required this.firestore,
      required this.storage});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Topic> _topicsList = [];
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
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => Notifications(
                    auth: widget.auth,
                    firestore: widget.firestore,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.email_outlined),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => PatientMessageView(
                    firestore: widget.firestore,
                    auth: widget.auth,
                  ),
                ),
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
              ),
            ),
          );
        },
        child: const Text('tests'),
      ),
      body: Column(
        children: [
          addVerticalSpace(10),
          const Text(
            "Trending topics",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          addVerticalSpace(10),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: topicLength == 0 ? 0 : topicLength * 2 - 1,
                itemBuilder: (context, index) {
                  if (index.isOdd) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                    );
                  } else {
                    final topicIndex = index ~/ 2;
                    return TopicCard(
                      widget.firestore,
                      widget.auth,
                      widget.storage,
                      _topicsList[topicIndex],
                      "topic",
                    );
                  }
                },
              ),
            ),
          ),
          addVerticalSpace(10),
          const Text(
            "Explore",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          addVerticalSpace(10),
          GridView.extent(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            maxCrossAxisExtent: 150,
            crossAxisSpacing: 50,
            mainAxisSpacing: 50,
            padding: const EdgeInsets.all(20),
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ExperienceView(
                        firestore: widget.firestore,
                        auth: widget.auth,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Shared Experience',
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  UserModel user =
                      await UserController(widget.auth, widget.firestore)
                          .getUser(widget.auth.currentUser!.uid);
                  WebinarController webinarController = WebinarController(
                    firestore: widget.firestore,
                    storage: widget.storage,
                  );
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: WebinarView(
                      firestore: widget.firestore,
                      user: user,
                      webinarController: webinarController,
                    ),
                    withNavBar: false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Webinars',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future getTopicsList() async {
    if (widget.auth.currentUser == null) {
      return;
    }
    _topicsList =
        await TopicController(auth: widget.auth, firestore: widget.firestore)
            .getTopicList();
    if (mounted) {
      setState(() {
        _topicsList.sort((b, a) => getTrending(a).compareTo(getTrending(b)));
        topicLength = _topicsList.length;
        if (topicLength > 6) {
          _topicsList.removeRange(6, topicLength);
        }
        topicLength = _topicsList.length;
      });
    }
  }
}
