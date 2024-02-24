import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/patient_experience/experiences_card.dart';
import 'package:info_hub_app/patient_experience/patient_experience_model.dart';

class AdminExperienceView extends StatefulWidget {
  final FirebaseFirestore firestore;
  const AdminExperienceView({super.key, required this.firestore});

  @override
  _AdminExperienceViewState createState() => _AdminExperienceViewState();
}

class _AdminExperienceViewState extends State<AdminExperienceView> {
  List<Experience> _experienceList = [];
  List<Experience> _verifiedExperienceList = [];
  List<Experience> _unverifiedExperienceList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getExperienceList();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Submitted Experiences"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Text("Verified experiences"),
            Expanded(child: ListView.builder(
              itemCount: _verifiedExperienceList.length,
              itemBuilder: (context, index) {
                return AdminExperienceCard(_verifiedExperienceList[index], widget.firestore);
              }
              ),
            ),
            const Text("Unverified experiences"),
            Expanded(child: ListView.builder(
              itemCount: _unverifiedExperienceList.length,
              itemBuilder: (context, index) {
                return AdminExperienceCard(_unverifiedExperienceList[index], widget.firestore);
              }
              ),
            ),
            ElevatedButton(onPressed: () {print(_experienceList);}, child: Text("test"))
          ],
        )
      )
    );
  }



  Future getExperienceList() async {
    QuerySnapshot data = await widget.firestore.collection('experiences').get();

    setState(() {
      _experienceList = List.from(data.docs.map((doc) => Experience.fromSnapshot(doc)));
      _verifiedExperienceList = _experienceList.where((experience) => experience.verified == true).toList();
      _unverifiedExperienceList = _experienceList.where((experience) => experience.verified == false).toList();
    });

  }

}