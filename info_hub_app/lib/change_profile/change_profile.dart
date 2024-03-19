// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:info_hub_app/change_profile/change_profile_controller.dart';

class ChangeProfile extends StatefulWidget {
  final ChangeProfileController controller;

  const ChangeProfile({super.key, required this.controller});

  @override
  _ChangeProfileState createState() => _ChangeProfileState();
}

class _ChangeProfileState extends State<ChangeProfile> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String _firstNameErrorText = '';
  String _lastNameErrorText = '';
  String _passwordErrorText = '';

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
                border: const UnderlineInputBorder(),
                errorText: _firstNameErrorText.isNotEmpty ? _firstNameErrorText : null,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: const UnderlineInputBorder(),
                errorText: _lastNameErrorText.isNotEmpty ? _lastNameErrorText : null,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const UnderlineInputBorder(),
                errorText: _passwordErrorText.isNotEmpty ? _passwordErrorText : null,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() async {
    setState(() {
      // Reset error text
      _firstNameErrorText = '';
      _lastNameErrorText = '';
      _passwordErrorText = '';
    });

    // Validation logic
    if (!widget.controller.validateInputs(
        _firstNameController,
        _lastNameController,
        _newPasswordController,
        _confirmPasswordController)) {
      if (!widget.controller.isAlpha(_firstNameController.text)) {
        setState(() {
          _firstNameErrorText = 'First name must consist of letters only';
        });
      }

      if (!widget.controller.isAlpha(_lastNameController.text)) {
        setState(() {
          _lastNameErrorText = 'Last name must consist of letters only';
        });
      }

      if (!widget.controller.passwordMatch(_newPasswordController.text, _confirmPasswordController.text)) {
        setState(() {
          _passwordErrorText = 'Passwords do not match';
        });
      }

      if (!widget.controller.isPasswordValid(_newPasswordController.text)) {
        setState(() {
          _passwordErrorText = 'Password must contain:\n'
            '- At least one lowercase letter\n'
            '- One uppercase letter\n'
            '- One number\n'
            '- One special character';
        });
      }

      return;
    }

    await widget.controller.updateProfile(
        _firstNameController, _lastNameController, _newPasswordController);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved'),
        duration: Duration(seconds: 5),
        backgroundColor: Colors.green,
      ),
    );
  }
}


