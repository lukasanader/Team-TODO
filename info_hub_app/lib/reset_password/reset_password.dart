import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResetPassword extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ResetPassword({
    Key? key,
    required this.firestore,
    required this.auth,
  }) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  late NavigatorState _navigatorState;

  final TextEditingController _emailController = TextEditingController();
  String _errorText = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigatorState = Navigator.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // Check if the email is valid
                if (!_isEmailValid(_emailController.text)) {
                  setState(() {
                    _errorText = 'Invalid email address';
                  });
                  return;
                }

                // Send password reset email and handle result
                await _sendPasswordResetEmail(_emailController.text);
              },
              child: const Text('Send Email'),
            ),
            const SizedBox(height: 10),
            Text(
              _errorText,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  bool _isEmailValid(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    // Check if the email exists in the Firebase database
    final QuerySnapshot<Map<String, dynamic>> result = await widget.firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();

    if (result.docs.isEmpty) {
      // If the email does not exist in the database, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email does not exist'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // If the email exists, send password reset email
    await widget.auth.sendPasswordResetEmail(email: email);

    // Show a green notification saying "Email sent"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email sent'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to the previous screen
    Navigator.pop(context);
  }
}
