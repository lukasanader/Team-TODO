import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/change_profile/change_profile.dart';

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
        backgroundColor: Colors.purple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    16, 8, 16, 16), // Adjust top padding here
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileHeader(),
                    SizedBox(height: 20),
                    _buildUserInfoSection(),
                    SizedBox(height: 100),
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
              onTap:
                  _showProfilePhotoOptions, // Show options when tapping the profile photo
              child: ClipOval(
                child: CircleAvatar(
                  radius: 50, // Adjust the radius to your desired size
                  backgroundImage: _selectedProfilePhoto.startsWith('http')
                      ? NetworkImage(_selectedProfilePhoto)
                      : AssetImage('assets/$_selectedProfilePhoto')
                          as ImageProvider, // Profile photo
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
        SizedBox(height: 10),
        Text(
          '${_currentUser?['firstName'] ?? 'N/A'} ${_currentUser?['lastName'] ?? 'N/A'}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
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
          'Your Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          value ?? 'N/A',
          style: TextStyle(fontSize: 16),
        ),
        Divider(),
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
