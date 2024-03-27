import 'package:flutter/material.dart';
import 'package:info_hub_app/profile_view/profile_view_controller.dart';
import 'package:info_hub_app/change_profile/change_profile_view.dart';
import 'package:info_hub_app/change_profile/change_profile_controller.dart';
import 'package:info_hub_app/theme/theme_constants.dart';

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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildUserInfoSection(),
                  const SizedBox(height: 20),
                  _buildChangeProfileButton(),
                ],
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
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: _selectedProfilePhoto.startsWith('http')
                    ? NetworkImage(_selectedProfilePhoto)
                    : AssetImage('assets/$_selectedProfilePhoto')
                        as ImageProvider, // Profile photo
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
          widget.controller.getProfileName(),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? COLOR_SECONDARY_GREY_LIGHT
            : COLOR_SECONDARY_GREY_DARK,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

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
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/profile_photo_1.png'),
                  ),
                  title: const Text('Dog'),
                  onTap: () {
                    Navigator.of(context).pop('profile_photo_1.png');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/profile_photo_2.png'),
                  ),
                  title: const Text('Walrus'),
                  onTap: () {
                    Navigator.of(context).pop('profile_photo_2.png');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/profile_photo_3.png'),
                  ),
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
