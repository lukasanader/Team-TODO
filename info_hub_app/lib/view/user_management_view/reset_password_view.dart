// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../controller/user_controllers/reset_password_controller.dart';

class ResetPassword extends StatefulWidget {
  final ResetPasswordController controller;

  const ResetPassword({
    super.key,
    required this.controller,
  });

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
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
              controller: widget.controller.emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final email = widget.controller.emailController.text;
                  if (!widget.controller.isEmailValid(email)) {
                    setState(() {
                      widget.controller.errorText = 'Invalid email address';
                    });
                    return;
                  }
                  await widget.controller.sendPasswordResetEmail(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email sent'),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Send Email',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.controller.errorText,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}



