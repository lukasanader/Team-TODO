// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordController {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  final TextEditingController emailController = TextEditingController();
  String errorText = '';

  ResetPasswordController({
    required this.firestore,
    required this.auth,
  });

  bool isEmailValid(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  Future<void> sendPasswordResetEmail(BuildContext context) async {
    final String email = emailController.text;

    final QuerySnapshot<Map<String, dynamic>> result =
        await firestore.collection('Users').where('email', isEqualTo: email).get();

    if (result.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email does not exist'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await auth.sendPasswordResetEmail(email: email);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email sent'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}


