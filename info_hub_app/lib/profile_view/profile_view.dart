import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/change_profile/change_profile.dart';
import 'package:info_hub_app/util/helper_widgets.dart';

class ProfileView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ProfileView({Key? key, required this.firestore, required this.auth})
      : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
  // Getter for selectedProfilePhoto
}

class _ProfileViewState extends State<ProfileView> {
  late Map<String, dynamic>? _currentUser; // Store current user data
  late String _selectedProfilePhoto =
      'default_profile_photo.png'; // Store selected profile photo URL
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _displayProfile();
  }

  Future<void> _displayProfile() async {
    final user = widget.auth.currentUser;

    if (user != null) {
      final docRef = widget.firestore.collection('Users');

      final querySnapshot = await docRef.get();
      final userDoc =
          querySnapshot.docs.firstWhere((doc) => doc.id == user.uid);

      setState(() {
        _currentUser = userDoc.data();
        _selectedProfilePhoto = _currentUser?['selectedProfilePhoto'] ??
            'default_profile_photo.png';
        _isLoading = false; // Mark loading as complete
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                children: [
                  addVerticalSpace(20),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProfileHeader(),
                        SizedBox(height: 15),
                        // _buildUserInfoSection(),
                        _buildChangeProfileButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap:
                  _showProfilePhotoOptions, // Show options when tapping the profile photo
              child: ClipOval(
                child: CircleAvatar(
                  radius: 50, // Adjust the radius to your desired size
                  backgroundImage: AssetImage(
                      'assets/$_selectedProfilePhoto'), // Profile photo
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                onPressed: _showProfilePhotoOptions,
                icon: Icon(Icons.edit),
                tooltip: 'Edit Profile Photo',
              ),
            ),
          ],
        ),
        addVerticalSpace(10),
        Text(
          '${_currentUser?['firstName'] ?? 'N/A'} ${_currentUser?['lastName'] ?? 'N/A'}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        addVerticalSpace(4),
        Text(
          '${_currentUser?['roleType'] ?? 'N/A'}',
          style: TextStyle(fontSize: 20),
        ),
        addVerticalSpace(3),
        Text(
          _currentUser?['email'] ?? 'N/A',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${_currentUser?['roleType'] ?? 'N/A'}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        addVerticalSpace(5),
      ],
    );
  }

  Widget _buildInfoTile(String title, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          value ?? 'N/A',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildChangeProfileButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeProfile(
              firestore: widget.firestore,
              auth: widget.auth,
            ),
          ),
        );
      },
      child: Text('Change Profile'),
    );
  }

  Future<void> _showProfilePhotoOptions() async {
    final selectedPhoto = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Profile Photo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Dog'),
                  onTap: () {
                    Navigator.of(context).pop('profile_photo_1.png');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Walrus'),
                  onTap: () {
                    Navigator.of(context).pop('profile_photo_2.png');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Penguin'),
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

      // Update selected profile photo in Firestore
      final user = widget.auth.currentUser;
      if (user != null) {
        final docRef = widget.firestore.collection('Users').doc(user.uid);
        await docRef.update({'selectedProfilePhoto': selectedPhoto});
      }
    }
  }
}
