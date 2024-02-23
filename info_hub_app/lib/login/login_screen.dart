import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/services/auth.dart';
import 'package:info_hub_app/helpers/base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const LoginScreen({super.key, required this.firestore, required this.auth});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthService _auth;

  @override
  void initState() {
    super.initState();
    _auth = AuthService(firestore: widget.firestore, auth: widget.auth);
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
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            User? user = await _auth.signInUser(
                                emailController.text, passwordController.text);
                            if (user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Base(
                                    auth: widget.auth,
                                    firestore: widget.firestore,
                                  ),
                                ),
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
                        child: const Text('Login'))
                  ],
                ))));
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
