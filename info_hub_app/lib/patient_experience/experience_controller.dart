

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/patient_experience/experience_model.dart';

class ExperienceController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ExperienceController(
    this._auth,
    this._firestore
  );

  void saveExperience(String title, String description) async {
    Experience newExperience = Experience();
    // User? user =_auth.currentUser;

    // newExperience.uid = user!.uid;
    newExperience.title = title;
    newExperience.description = description;
    newExperience.verified = false;

    CollectionReference db = _firestore.collection('experiences');
    await db.add(newExperience.toJson());
  }

  Future<List<Experience>> getVerifiedExperienceList() async {
    QuerySnapshot experiencesSnapshot = await _firestore
        .collection('experiences')
        .where('verified', isEqualTo: true)
        .get();

    List<Experience> experienceList = List.from(experiencesSnapshot.docs.map((doc) => Experience.fromSnapshot(doc)));

    return experienceList;
  }

  Future<List<Experience>> getUnverifiedExperienceList() async {
    QuerySnapshot experiencesSnapshot = await _firestore
        .collection('experiences')
        .where('verified', isEqualTo: false)
        .get();

    List<Experience> experienceList = List.from(experiencesSnapshot.docs.map((doc) => Experience.fromSnapshot(doc)));

    return experienceList;
  }

  Future<void> updateVerification(Experience experience) async {
    bool newValue = experience.verified == true ? false : true;

    await _firestore.collection('experiences').doc(experience.id).update({
      'verified': newValue,
    });

  }




}