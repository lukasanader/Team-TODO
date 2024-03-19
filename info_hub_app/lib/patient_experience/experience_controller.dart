

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
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot user = await _firestore.collection('Users').doc(uid).get();

    newExperience.title = title;
    newExperience.description = description;
    newExperience.userEmail = user['email'];
    newExperience.verified = false;

    CollectionReference db = _firestore.collection('experiences');
    await db.add(newExperience.toJson());
  }

  void deleteExperience(Experience experience) async {
    await _firestore.collection('experiences').doc(experience.id).delete();
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