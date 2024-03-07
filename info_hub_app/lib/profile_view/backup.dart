import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:info_hub_app/change_profile/change_profile.dart';
import 'package:info_hub_app/registration/user_model.dart';

class ProfileView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const ProfileView({Key? key, required this.firestore, required this.auth})
      : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late UserModel? _currentUser; // Store current user data
  late String _selectedProfilePhoto = 'default_profile_photo.png'; // Store selected profile photo URL
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
      final userDoc = querySnapshot.docs.firstWhere((doc) => doc.id == user.uid);
      
      final firstName = userDoc['firstName'];
      final lastName = userDoc['lastName'];
      final email = userDoc['email'];
      final roleType = userDoc['roleType'];
      final likedTopicsIds = List<String>.from(userDoc['likedTopics']);
      final dislikedTopicsIds = List<String>.from(userDoc['dislikedTopics']);

      // Fetch topic names from Firestore based on topic IDs
      final likedTopics = await _fetchTopicNames(likedTopicsIds);
      final dislikedTopics = await _fetchTopicNames(dislikedTopicsIds);

      // Create a UserModel object with the retrieved information
      final userModel = UserModel(
        uid: user.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        roleType: roleType,
        likedTopics: likedTopics,
        dislikedTopics: dislikedTopics,
      );

      // Set the _currentUser variable to the userModel
      setState(() {
        _currentUser = userModel;
        _isLoading = false; // Mark loading as complete
      });
    }
  }

  Future<List<String>> _fetchTopicNames(List<String> topicIds) async {
    final topicNames = <String>[];
    final topicRef = widget.firestore.collection('topics');

    for (final id in topicIds) {
      final doc = await topicRef.doc(id).get();
      if (doc.exists) {
        final topicName = doc.get('title');
        topicNames.add(topicName);
      }
    }

    return topicNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  SizedBox(height: 20),
                  _buildUserInfoSection(),
                  SizedBox(height: 20),
                  _buildTopicSection('Liked Topics', _currentUser?.likedTopics),
                  SizedBox(height: 20),
                  _buildTopicSection('Disliked Topics', _currentUser?.dislikedTopics),
                  SizedBox(height: 20),
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
            onTap: _showProfilePhotoOptions, // Show options when tapping the profile photo
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/$_selectedProfilePhoto'), // Profile photo
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
        '${_currentUser?.firstName ?? 'N/A'} ${_currentUser?.lastName ?? 'N/A'}',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      Text(
        _currentUser?.email ?? 'N/A',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    ],
  );
}


  Widget _buildUserInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        _buildInfoTile('First Name', _currentUser?.firstName),
        _buildInfoTile('Last Name', _currentUser?.lastName),
        _buildInfoTile('Role Type', _currentUser?.roleType),
      ],
    );
  }

  Widget _buildTopicSection(String title, List<String>? topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          topics?.join(', ') ?? 'N/A',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  void _showProfilePhotoOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Profile Photo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Profile Photo 1'),
                  onTap: () {
                    setState(() {
                      _selectedProfilePhoto = 'profile_photo_1.png';
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Profile Photo 2'),
                  onTap: () {
                    setState(() {
                      _selectedProfilePhoto = 'profile_photo_2.png';
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Profile Photo 3'),
                  onTap: () {
                    setState(() {
                      _selectedProfilePhoto = 'profile_photo_3.png';
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}