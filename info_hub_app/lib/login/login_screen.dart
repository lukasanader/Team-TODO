// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/admin/admin_dash.dart';
import 'package:info_hub_app/registration/user_controller.dart';
import 'package:info_hub_app/reset_password/reset_password.dart';
import 'package:info_hub_app/services/auth.dart';
import 'package:info_hub_app/helpers/base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/theme/theme_manager.dart';

class LoginScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;
  final ThemeManager themeManager;
  const LoginScreen(
      {super.key,
      required this.firestore,
      required this.auth,
      required this.storage,
      required this.themeManager});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthService _auth;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _auth = AuthService(
      firestore: widget.firestore,
      auth: widget.auth,
    );
  }

  void toggle () {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Please fill in the login details.'),
              const SizedBox(height: 20),
              buildTextFormField(
                controller: emailController,
                hintText: 'Email',
                labelText: 'Email',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  } else if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              buildTextFormField(
                controller: passwordController,
                hintText: 'Password',
                labelText: 'Password',
                obscureText: _obscureText,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: toggle,
                child: new Text(_obscureText ? "Show" : "Hide"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    User? user = await _auth.signInUser(
                        emailController.text, passwordController.text);
                    if (user != null) {
                      String roleType = await UserController(widget.auth, widget.firestore)
                        .getUserRoleType();
                      Widget nextPage = Base(
                        firestore: widget.firestore,
                        auth: widget.auth,
                        storage: widget.storage,
                        themeManager: widget.themeManager,
                        roleType: roleType,
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => nextPage),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Email or password is incorrect. Please try again.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: 250.0,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPassword(
                          firestore: widget.firestore,
                          auth: widget.auth,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      autofocus: true,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.red),
        hintStyle: const TextStyle(color: Colors.black),
      ),
      style: const TextStyle(color: Colors.black),
      validator: validator,
    );
  }
}
