import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResetPassword extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ResetPassword({
    super.key,
    required this.firestore,
    required this.auth,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailController = TextEditingController();
  String _errorText = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (!_isEmailValid(_emailController.text)) {
                  setState(() {
                    _errorText = 'Invalid email address';
                  });
                  return;
                }
                await _sendPasswordResetEmail(_emailController.text);
              },
              child: const Text('Send Email'),
            ),
            const SizedBox(height: 10),
            Text(
              _errorText,
              style: const TextStyle(color: Colors.red),
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
    final QuerySnapshot<Map<String, dynamic>> result = await widget.firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();

    if (result.docs.isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email does not exist'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await widget.auth.sendPasswordResetEmail(email: email);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email sent'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }
}
