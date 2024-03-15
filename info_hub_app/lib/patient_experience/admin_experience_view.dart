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
                  return displayExperiencesForAdmin(_verifiedExperienceList[index]);
                }),
            const SizedBox(height: 30),
            const Text("Unverified experiences"),
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _unverifiedExperienceList.length,
                itemBuilder: (context, index) {
                  return displayExperiencesForAdmin(_unverifiedExperienceList[index]);
                }),
          ],
        )));
  }

  Widget displayExperiencesForAdmin(Experience experience) {
    bool? experienceVerification = experience.verified;
    late Icon buttonType;

    if (experienceVerification != null && experienceVerification) {
      buttonType = const Icon(Icons.close);
    }
    else {
      buttonType = const Icon(Icons.check);
    }


    return Column(
      children: [
        const SizedBox(height: 10,),
        Row(
          children: [
            const SizedBox(width: 10,),
            Text (
              experience.userEmail.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        const SizedBox(height: 10,),
        Row(
          children: [
            Flexible(
                flex: 9,
                child:
                    ExperienceCard(experience)),
            Flexible(
                flex: 1,
                child: IconButton(
                    onPressed: () {
                      deleteExperienceConfirmation(experience);
                    },
                    icon: const Icon(Icons.delete))),
            Flexible(
                flex: 1,
                child: IconButton(
                    onPressed: () {
                      _experienceController.updateVerification(experience);
                      updateExperiencesList();
                    },
                    icon: buttonType))
          ],
        )
      ],
    );
  }


  Future<void> deleteExperienceConfirmation(Experience experience) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning!'),
          content: const Text("Are you sure you want to delete?"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                _experienceController.deleteExperience(experience);
                updateExperiencesList();
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
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
