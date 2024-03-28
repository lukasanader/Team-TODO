import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/controller/user_controller.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/experiences/experience_controller.dart';
import 'package:info_hub_app/experiences/experience_sharing_controller.dart';
import 'package:info_hub_app/experiences/experience_model.dart';
import 'package:info_hub_app/experiences/experiences_card.dart';

class ExperienceView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const ExperienceView(
      {super.key, required this.firestore, required this.auth});

  @override
  State<ExperienceView> createState() => _ExperienceViewState();
}

class _ExperienceViewState extends State<ExperienceView> {
  late ExperienceController _experienceController;
  late ExperienceSharingController _experienceSharingController;
  List<Experience> _experienceList = [];
  bool pageLoaded = false;
  // ignore: prefer_final_fields

  @override
  void initState() {
    super.initState();
    _experienceController = ExperienceController(widget.auth, widget.firestore);
    _experienceSharingController =
        ExperienceSharingController(widget.auth, widget.firestore);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateExperienceList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Shared Experiences"),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                _showExperienceExpectationDialog(context);
              },
            ),
          ],
        ),
        body: !pageLoaded
        ? const Center(child: CircularProgressIndicator(),) 
        : SafeArea(
            child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _experienceList.length,
                itemBuilder: (context, index) {
                  // Check if it's the last item
                  bool isLastItem = index == _experienceList.length - 1;
                  return Column(
                    children: [
                      ExperienceCard(_experienceList[index]),
                      // Add padding and divider if not the last item
                      if (!isLastItem)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Checks whether the user has previously opted to not view
                // story expectations
                _experienceSharingController
                    .hasOptedOutOfExperienceExpectations()
                    .then((value) {
                  if (value) {
                    _experienceSharingController
                        .showShareExperienceDialog(context);
                  } else {
                    _experienceSharingController
                        .showExperienceExpectations(context);
                  }
                });
              },
              child: const Text("Share your experience!"),
            ),
            addVerticalSpace(20),
          ],
        )));
  }

  Future updateExperienceList() async {
    String roleType =
        await UserController(widget.auth, widget.firestore).getUserRoleType();

    List<Experience> data = await _experienceController
        .getVerifiedExperienceListBasedonRole(roleType);

    setState(() {
      _experienceList = data;
      pageLoaded = true;
    });
  }

  void _showExperienceExpectationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
              child: Text(
            'Experience Help',
            style: TextStyle(fontSize: 23),
          )),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Welcome to the Experience View page, where users share their personal stories related to liver disease.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Feel free to contribute your own experiences by selecting the "Share your experience!" button.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Your submission will undergo professional verification before being published on this platform.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
