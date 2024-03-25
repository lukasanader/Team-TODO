import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/controller/user_controller.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/patient_experience/experience_controller.dart';
import 'package:info_hub_app/patient_experience/experience_sharing_controller.dart';
import 'package:info_hub_app/patient_experience/experience_model.dart';
import 'package:info_hub_app/patient_experience/experiences_card.dart';

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
  // ignore: prefer_final_fields

  @override
  void initState() {
    super.initState();
    _experienceController = ExperienceController(widget.auth, widget.firestore);
    _experienceSharingController = ExperienceSharingController(widget.auth, widget.firestore);
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
          title: const Text("Patient Experiences"),
        ),
        body: SafeArea(
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
                _experienceSharingController.hasOptedOutOfExperienceExpectations().then((value) {
                  if (value) {
                    _experienceSharingController.showShareExperienceDialog(context);
                  } else {
                    _experienceSharingController.showExperienceExpectations(context);
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
    String roleType = await UserController(widget.auth, widget.firestore)
      .getUserRoleType();


    List<Experience> data =
        await _experienceController.getVerifiedExperienceListBasedonRole(roleType);

    setState(() {
      _experienceList = data;
    });
  }


}
