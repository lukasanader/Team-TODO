import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChangeProfileController {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChangeProfileController({required this.firestore, required this.auth});

  Future<void> updateProfile(
      TextEditingController firstNameController,
      TextEditingController lastNameController,
      TextEditingController newPasswordController) async {
    final user = auth.currentUser;

    if (user != null) {
      // Update first name and last name in Firestore
      final docRef = firestore.collection('Users');

      final querySnapshot = await docRef.get();
      final userDoc = querySnapshot.docs.firstWhere((doc) => doc.id == user.uid);

      await docRef.doc(userDoc.id).update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
      });

      // Update password
      await user.updatePassword(newPasswordController.text);
    }
  }
  
  bool isAlpha(String text) {
    final alphaRegExp = RegExp(r'^[a-zA-Z]+$');
    return alphaRegExp.hasMatch(text);
  }

  bool validateInputs(
      TextEditingController firstNameController,
      TextEditingController lastNameController,
      TextEditingController newPasswordController,
      TextEditingController confirmPasswordController) {
    bool isValid = true;

    // Check first name
    if (!isAlpha(firstNameController.text)) {
      isValid = false;
    }

    // Check last name
    if (!isAlpha(lastNameController.text)) {
      isValid = false;
    }

    // Check password match
    if (!passwordMatch(newPasswordController.text, confirmPasswordController.text)) {
      isValid = false;
    }

    // Check password requirements
    if (!isPasswordValid(newPasswordController.text)) {
      isValid = false;
    }

    return isValid;
  }


  bool isPasswordValid(String password) {
    final passwordRegExp =
        RegExp(r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#$%^&*])');
    return passwordRegExp.hasMatch(password);
  }

  bool passwordMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }
}


