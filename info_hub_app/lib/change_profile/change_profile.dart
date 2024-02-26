import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/dashboard.dart';

class ChangeProfile extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ChangeProfile({
    Key? key,
    required this.firestore,
    required this.auth,
  }) : super(key: key);

  @override
  _ChangeProfileState createState() => _ChangeProfileState();
}

class _ChangeProfileState extends State<ChangeProfile> {
  late NavigatorState _navigatorState;

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String _firstNameErrorText = '';
  String _lastNameErrorText = '';
  String _passwordErrorText = '';
  bool _passwordsMatch = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigatorState = Navigator.of(context);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
                errorText: _firstNameErrorText.isNotEmpty ? _firstNameErrorText : null,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
                errorText: _lastNameErrorText.isNotEmpty ? _lastNameErrorText : null,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                errorText: _passwordErrorText.isNotEmpty ? _passwordErrorText : null,
              ),
            ),
            const SizedBox(height: 10),
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
                _navigatorState.push(MaterialPageRoute(builder: (context) => MainPage(firestore: widget.firestore, auth: widget.auth,)));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Changes saved'),
                    duration: Duration(seconds: 5),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save Changes'),
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
    final passwordRegExp = RegExp(r'^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#$%^&*])');
    return passwordRegExp.hasMatch(password);
  }

Future<void> _updateProfile() async {
  final user = widget.auth.currentUser;

  if (user != null) {
    // Update first name and last name in Firestore
    final docRef = widget.firestore.collection('Users');

    final querySnapshot = await docRef.get();
    final userDoc = querySnapshot.docs.firstWhere((doc) => doc.id == user.uid);
    
    await docRef.doc(userDoc.id).update({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
    });

    // Update password
    await user.updatePassword(_newPasswordController.text);
  }
}
}














































