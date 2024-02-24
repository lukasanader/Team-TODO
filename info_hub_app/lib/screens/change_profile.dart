import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';


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
  String _errorText = '';
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
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
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
                errorText: !_passwordsMatch ? 'Passwords do not match' : null,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                // Check if the first name consists of only letters
                if (!_isAlpha(_firstNameController.text)) {
                  setState(() {
                    _errorText = 'First name must consist of letters only';
                  });
                  return;
                }

                // Check if the last name consists of only letters
                if (!_isAlpha(_lastNameController.text)) {
                  setState(() {
                    _errorText = 'Last name must consist of letters only';
                  });
                  return;
                }

                // Check if the password meets the criteria
                if (!_isPasswordValid(_newPasswordController.text)) {
                  setState(() {
                    _errorText = 'Password must contain:\n'
                        '- At least one lowercase letter\n'
                        '- One uppercase letter\n'
                        '- One number\n'
                        '- One special character';
                  });
                  return;
                }

                // Update first name, last name, and password
                await _updateProfile();

                // Navigate to the RegistrationScreen after changes saved
                _navigatorState.push(MaterialPageRoute(builder: (context) => MainPage(firestore: widget.firestore, auth: widget.auth,)));

                // Show a SnackBar if changes were saved successfully
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Changes saved'),
                    duration: Duration(seconds: 5),
                    backgroundColor: Colors.green, // Set the background color to green
                  ),
                );
              },
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 10),
            Text(
              _errorText,
              style: TextStyle(color: _passwordsMatch ? Colors.green : Colors.red),
            ),
          ],
        ),
      ),
    );
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
      try {
        final docRef = widget.firestore.collection('Users');
        docRef.get().then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            if (doc['uid'] == user.uid) {
              docRef.doc(doc.id).update({
                'firstName': _firstNameController.text,
                'lastName': _lastNameController.text,
              });
            }
          });
        });
      } catch (e) {
        //notification if profile update failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile Update failed. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Update password
      await user.updatePassword(_newPasswordController.text);
    }
  }
}





















