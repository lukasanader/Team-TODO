import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/patient_experience/experience_controller.dart';
import 'package:info_hub_app/patient_experience/experiences_card.dart';
import 'package:info_hub_app/patient_experience/experience_model.dart';

class AdminExperienceView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const AdminExperienceView({
    super.key, 
    required this.firestore,
    required this.auth});

  @override
  _AdminExperienceViewState createState() => _AdminExperienceViewState();
}

class _AdminExperienceViewState extends State<AdminExperienceView> {
  late ExperienceController _experienceController;
  List<Experience> _verifiedExperienceList = [];
  List<Experience> _unverifiedExperienceList = [];

  @override
  void initState() {
    super.initState();
    _experienceController = ExperienceController(
      widget.auth, 
      widget.firestore);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateExperiencesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("All Submitted Experiences"),
        ),
        body: SingleChildScrollView(
          child: Column(
          children: [
            const Text("Verified experiences"),
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _verifiedExperienceList.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Flexible(
                          flex: 9,
                          child:
                              ExperienceCard(_verifiedExperienceList[index])),
                      Flexible(
                          flex: 1,
                          child: IconButton(
                              onPressed: () {
                                _experienceController.updateVerification(
                                    _verifiedExperienceList[index]);
                                updateExperiencesList();
                              },
                              icon: const Icon(Icons.close)))
                    ],
                  );
                }),
            const SizedBox(height: 30),
            const Text("Unverified experiences"),
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _unverifiedExperienceList.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Flexible(
                          flex: 9,
                          child:
                              ExperienceCard(_unverifiedExperienceList[index])),
                      Flexible(
                          flex: 1,
                          child: IconButton(
                              onPressed: () {
                                _experienceController.updateVerification(
                                    _unverifiedExperienceList[index]);
                                updateExperiencesList();
                              },
                              icon: const Icon(Icons.check)))
                    ],
                  );
                }),
          ],
        )));
  }

  Future updateExperiencesList() async {
    List<Experience> verifiedExperiences = await _experienceController.getVerifiedExperienceList();
    List<Experience> unverifiedExperiences = await _experienceController.getUnverifiedExperienceList();

    setState(() {
      _verifiedExperienceList = verifiedExperiences;
      _unverifiedExperienceList = unverifiedExperiences;
    });
  }


}
