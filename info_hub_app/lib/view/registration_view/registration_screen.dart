// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:info_hub_app/controller/user_controllers/auth.dart';
import 'package:info_hub_app/model/user_models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:info_hub_app/view/legal_agreement_view/terms_of_services.dart';
import 'package:info_hub_app/view/legal_agreement_view/privacy_policy.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/view/login_view/email_verification_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;
  final FirebaseMessaging messaging;
  final ThemeManager themeManager;
  final FlutterLocalNotificationsPlugin localnotificationsplugin;
  const RegistrationScreen(
      {super.key,
      required this.firestore,
      required this.storage,
      required this.auth,
      required this.messaging,
      required this.themeManager,
      required this.localnotificationsplugin});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late AuthService _auth;
  bool _obscurePasswordText = true;
  bool _obscureConfirmPasswordText = true;

  @override
  void initState() {
    super.initState();
    _auth = AuthService(
        firestore: widget.firestore,
        auth: widget.auth,
        messaging: widget.messaging,
        localnotificationsplugin: widget.localnotificationsplugin);
  }

  void passwordToggle() {
    setState(() {
      _obscurePasswordText = !_obscurePasswordText;
    });
  }

  void confirmPasswordToggle() {
    setState(() {
      _obscureConfirmPasswordText = !_obscureConfirmPasswordText;
    });
  }

  final _formKey = GlobalKey<FormState>();
  String? _selectedRole;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
              const Text('Please fill in the registration details.'),
              const SizedBox(height: 20),
              buildTextFormField(
                controller: firstNameController,
                hintText: 'John',
                labelText: 'First Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  } else if (value.length > 30) {
                    return 'Please shorten this field!';
                  } else if (!RegExp(
                          r"^[A-Za-z][A-Za-z\'\-]+(?: [\ A-Za-z][A-Za-z\'\-]+)*$")
                      .hasMatch(value)) {
                    return 'Please enter only letters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildTextFormField(
                controller: lastNameController,
                hintText: 'Doe',
                labelText: 'Last Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  } else if (value.length > 30) {
                    return 'Please shorten this field!';
                  } else if (!RegExp(
                          r"^[A-Za-z][A-Za-z\'\-]+(?: [\ A-Za-z][A-Za-z\'\-]+)*$")
                      .hasMatch(value)) {
                    return 'Please enter only letters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildTextFormField(
                controller: emailController,
                hintText: 'john.doe@example.org',
                labelText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  } else if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  } else if (!value.contains('@nhs.co.uk') &&
                      _selectedRole == 'Healthcare Professional') {
                    return 'Please enter a valid healthcare professional email.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildTextFormField(
                controller: passwordController,
                hintText: 'Password123!',
                labelText: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  } else if (!RegExp(
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+{}|:"<>?])')
                      .hasMatch(value)) {
                    return 'Password must contain:\n'
                        '- At least one lowercase letter\n'
                        '- One uppercase letter\n'
                        '- One number\n'
                        '- One special character';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              buildTextFormField(
                controller: confirmPasswordController,
                hintText: 'Password123!',
                labelText: 'Confirm Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'I am a...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your role';
                  }
                  return null;
                },
                items: const [
                  DropdownMenuItem(
                    value: 'Patient',
                    child: Text('Patient'),
                  ),
                  DropdownMenuItem(
                    value: 'Parent',
                    child: Text('Parent'),
                  ),
                  DropdownMenuItem(
                    value: 'Healthcare Professional',
                    child: Text('Healthcare Professional'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // RichText widget to display the legal agreements
              RichText(
                key: const Key('legal_agreements'),
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[600]),
                  children: [
                    const TextSpan(
                      text: 'By clicking "Register", you agree to our ',
                    ),
                    TextSpan(
                      text: 'Terms of Service',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to Terms of Service page
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const TermsOfServicesPage(),
                            ),
                          );
                        },
                    ),
                    const TextSpan(
                      text: ' and ',
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to Privacy Policy page
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const PrivacyPolicyPage(),
                            ),
                          );
                        },
                    ),
                    const TextSpan(
                      text: '.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Validation passed, proceed with registration
                    final String firstName = firstNameController.text;
                    final String lastName = lastNameController.text;
                    final String email = emailController.text;
                    final String password = passwordController.text;
                    final String role = _selectedRole ?? '';
                    final List<String> likedTopics = [];
                    final List<String> dislikedTopics = [];

                    // Register user and get the UserModel
                    UserModel? userModel = await _auth.registerUser(
                        firstName,
                        lastName,
                        email,
                        password,
                        role,
                        likedTopics,
                        dislikedTopics,
                        false);

                    if (userModel != null) {
                      // Registration was successful, navigate to the verify email page
                      Widget nextPage = EmailVerificationScreen(
                        firestore: widget.firestore,
                        auth: widget.auth,
                        messaging: widget.messaging,
                        localnotificationsplugin:
                            widget.localnotificationsplugin,
                        themeManager: widget.themeManager,
                        storage: widget.storage,
                      );
                      await widget.auth.currentUser!.sendEmailVerification();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => nextPage),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      // Show error message if anything goes wrong in the auth process
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Registration failed. Please try again.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Register'),
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
        obscureText: _obscurePasswordText,
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
              onPressed: passwordToggle,
              icon: Icon(
                _obscurePasswordText ? Icons.visibility : Icons.visibility_off,
              ),
            )),
        validator: validator,
      );
    } else if (labelText == 'Confirm Password') {
      return TextFormField(
        controller: controller,
        obscureText: _obscureConfirmPasswordText,
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
              onPressed: confirmPasswordToggle,
              icon: Icon(
                _obscureConfirmPasswordText
                    ? Icons.visibility
                    : Icons.visibility_off,
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
