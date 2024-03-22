import 'package:flutter/material.dart';
import 'package:info_hub_app/profile_view/profile_view_controller.dart';
import 'package:info_hub_app/change_profile/change_profile.dart';
import 'package:info_hub_app/change_profile/change_profile_controller.dart';

class ProfileView extends StatefulWidget {
  final ProfileViewController controller;

  const ProfileView({super.key, required this.controller});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Map<String, dynamic>? _currentUser;
  late String _selectedProfilePhoto = 'default_profile_photo.png';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _displayProfile();
  }

  Future<void> _displayProfile() async {
    final currentUser = await widget.controller.getCurrentUser();
    setState(() {
      _currentUser = currentUser;
      _selectedProfilePhoto =
          _currentUser?['selectedProfilePhoto'] ?? 'default_profile_photo.png';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.purple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 20),
                    _buildUserInfoSection(),
                    const SizedBox(height: 100),
                    _buildChangeProfileButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: _showProfilePhotoOptions,
              child: ClipOval(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/$_selectedProfilePhoto'),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                onPressed: _showProfilePhotoOptions,
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Profile Photo',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${_currentUser?['firstName'] ?? 'N/A'} ${_currentUser?['lastName'] ?? 'N/A'}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          _currentUser?['email'] ?? 'N/A',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Your Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildInfoTile('First Name', _currentUser?['firstName']),
        _buildInfoTile('Last Name', _currentUser?['lastName']),
        _buildInfoTile('Role Type', _currentUser?['roleType']),
      ],
    );
  }

  Widget _buildInfoTile(String title, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value ?? 'N/A',
          style: const TextStyle(fontSize: 16),
        ),
        const Divider(),
      ],
    );
  }

  // Widget _buildChangeProfileButton() {
  //   return ElevatedButton(
  //     onPressed: _changeProfile,
  //     child: const Text('Change Profile'),
  //   );
  // }

  Widget _buildChangeProfileButton() {
    return ElevatedButton(
      onPressed: () async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeProfile(
                controller: ChangeProfileController(
                  firestore: widget.controller.firestore,
                  auth: widget.controller.auth,
                ),
              ),
            ));

        // Check if changes were saved
        if (result != null && result) {
          // If changes were saved, update the profile view
          _displayProfile();
        }
      },
      child: const Text('Change Profile'),
    );
  }

  Future<void> _showProfilePhotoOptions() async {
    final selectedPhoto = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Profile Photo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Dog'),
                  onTap: () {
                    Navigator.of(context).pop('profile_photo_1.png');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Walrus'),
                  onTap: () {
                    Navigator.of(context).pop('profile_photo_2.png');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Penguin'),
                  onTap: () {
                    Navigator.of(context).pop('profile_photo_3.png');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedPhoto != null) {
      setState(() {
        _selectedProfilePhoto = selectedPhoto;
      });
      await widget.controller.updateSelectedProfilePhoto(selectedPhoto);
    }
  }
}
