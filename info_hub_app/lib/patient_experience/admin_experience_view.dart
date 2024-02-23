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
            Expanded(child: ListView.builder(
              itemCount: _experienceList.length,
              itemBuilder: (context, index) {
                return AdminExperienceCard(_experienceList[index]);
              }
              ),
            )
          ],
        )
      )
    );
  }



  Future getExperienceList() async {
    QuerySnapshot data = await widget.firestore.collection('experiences').get();

    setState(() {
      _experienceList = List.from(data.docs.map((doc) => Experience.fromSnapshot(doc)));
    });

  }

}