import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeProfile extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ChangeProfile({
    super.key,
    required this.firestore,
    required this.auth,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ChangeProfileState createState() => _ChangeProfileState();
}

class _ChangeProfileState extends State<ChangeProfile> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String _firstNameErrorText = '';
  String _lastNameErrorText = '';
  String _passwordErrorText = '';
  bool _obscureNewPasswordText = true;
  bool _obscureConfirmPasswordText = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void newPasswordToggle() {
    setState(() {
      _obscureNewPasswordText = !_obscureNewPasswordText;
    });
  }

  void confirmPasswordToggle() {
    setState(() {
      _obscureConfirmPasswordText = !_obscureConfirmPasswordText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                errorText:
                    _firstNameErrorText.isNotEmpty ? _firstNameErrorText : null,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                errorText:
                    _lastNameErrorText.isNotEmpty ? _lastNameErrorText : null,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNewPasswordText,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  onPressed: newPasswordToggle,
                  icon: Icon(
                    _obscureNewPasswordText
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  padding: const EdgeInsets.only(top: 15.0),
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPasswordText,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText:
                    _passwordErrorText.isNotEmpty ? _passwordErrorText : null,
                suffixIcon: IconButton(
                  onPressed: confirmPasswordToggle,
                  icon: Icon(
                    _obscureConfirmPasswordText
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  padding: const EdgeInsets.only(top: 15.0),
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    splashFactory: NoSplash.splashFactory,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  // Reset error text
                  _firstNameErrorText = '';
                  _lastNameErrorText = '';
                  _passwordErrorText = '';
                });

                // Validation logic
                if (!_validateInputs()) {
                  return;
                }

                // Update profile
                await _updateProfile();

                // Navigate and show success message
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Changes saved'),
                    duration: Duration(seconds: 5),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(
                'Save Changes',
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateInputs() {
    bool isValid = true;

    // Check first name
    if (!_isAlpha(_firstNameController.text)) {
      setState(() {
        _firstNameErrorText = 'First name must consist of letters only';
      });
      isValid = false;
    }

    // Check last name
    if (!_isAlpha(_lastNameController.text)) {
      setState(() {
        _lastNameErrorText = 'Last name must consist of letters only';
      });
      isValid = false;
    }

    // Check password match
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordErrorText = 'Passwords do not match';
      });
      isValid = false;
    }

    // Check password requirements
    if (!_isPasswordValid(_newPasswordController.text)) {
      setState(() {
        _passwordErrorText = 'Password must contain:\n'
            '- At least one lowercase letter\n'
            '- One uppercase letter\n'
            '- One number\n'
            '- One special character';
      });
      isValid = false;
    }

    return isValid;
  }

  bool _isAlpha(String text) {
    final alphaRegExp = RegExp(r'^[a-zA-Z]+$');
    return alphaRegExp.hasMatch(text);
  }

  bool _isPasswordValid(String password) {
    final passwordRegExp =
        RegExp(r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#$%^&*])');
    return passwordRegExp.hasMatch(password);
  }

  Future<void> _updateProfile() async {
    final user = widget.auth.currentUser;

    if (user != null) {
      // Update first name and last name in Firestore
      final docRef = widget.firestore.collection('Users');

      final querySnapshot = await docRef.get();
      final userDoc =
          querySnapshot.docs.firstWhere((doc) => doc.id == user.uid);

      await docRef.doc(userDoc.id).update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
      });

      // Update password
      await user.updatePassword(_newPasswordController.text);
    }
  }
}
