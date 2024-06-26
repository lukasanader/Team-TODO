// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/controller/user_controllers/user_controller.dart';
import 'package:info_hub_app/view/user_management_view/reset_password_view.dart';
import 'package:info_hub_app/controller/user_controllers/reset_password_controller.dart';
import 'package:info_hub_app/controller/user_controllers/auth.dart';
import 'package:info_hub_app/view/base_view/base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/view/login_view/email_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;
  final ThemeManager themeManager;
  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin localnotificationsplugin;
  const LoginScreen(
      {super.key,
      required this.firestore,
      required this.auth,
      required this.storage,
      required this.themeManager,
      required this.messaging,
      required this.localnotificationsplugin});

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
      messaging: widget.messaging,
      localnotificationsplugin: widget.localnotificationsplugin,
    );
  }

  void toggle() {
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    User? user = await _auth.signInUser(
                        emailController.text, passwordController.text);
                    if (user != null) {
                      String roleType;
                      Widget nextPage;
                      if (widget.auth.currentUser!.emailVerified != true) {
                        widget.auth.currentUser!.sendEmailVerification();
                        nextPage = EmailVerificationScreen(
                          auth: widget.auth,
                          firestore: widget.firestore,
                          storage: widget.storage,
                          messaging: widget.messaging,
                          themeManager: widget.themeManager,
                          localnotificationsplugin:
                              FlutterLocalNotificationsPlugin(),
                        );
                      } else {
                        roleType =
                            await UserController(widget.auth, widget.firestore)
                                .getUserRoleType();

                        nextPage = Base(
                          firestore: widget.firestore,
                          auth: widget.auth,
                          storage: widget.storage,
                          themeManager: widget.themeManager,
                          roleType: roleType,
                          messaging: widget.messaging,
                        );
                      }
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
              const SizedBox(height: 10.0),
              SizedBox(
                width: 250.0,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPassword(
                            controller: ResetPasswordController(
                          firestore: widget.firestore,
                          auth: widget.auth,
                        )),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField(
      {required TextEditingController controller,
      required String hintText,
      required String labelText,
      bool obscureText = false,
      String? Function(String?)? validator}) {
    if (labelText == 'Password') {
      return TextFormField(
        controller: controller,
        obscureText: obscureText,
        autofocus: true,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            suffixIcon: IconButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
              ),
              padding: const EdgeInsets.only(top: 15.0),
              onPressed: toggle,
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
            )),
        validator: validator,
      );
    } else {
      return TextFormField(
        controller: controller,
        obscureText: obscureText,
        autofocus: true,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
        ),
        validator: validator,
      );
    }
  }
}
