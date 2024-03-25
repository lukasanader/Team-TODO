import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/patient_experience/experience_controller.dart';

class ExperienceSharingController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  late ExperienceController _experienceController;

  ExperienceSharingController(this._auth,this._firestore) {
    _experienceController = ExperienceController(_auth, _firestore);
  }

  // Patient must read and accept experience expectations dialog
  void showExperienceExpectations(context) {
    bool checkboxValue = false;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Experience Expectations'),
        content: StatefulBuilder(builder:
            (BuildContext context, void Function(void Function()) setState) {
          return SingleChildScrollView(
            child: ListBody(
              children: [
                const Text(
                  'By sharing your experience, you agree to the following terms:',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  '1. You agree to share your experience with the understanding that it will be shared with other users.',
                  style: TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  '2. You affirm that the experience you share is truthful and accurately represents your own perspective.',
                  style: TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  '3. You agree not to include any content that is offensive, harmful, or discriminatory, including but not limited to slurs, hate speech, or derogatory language.',
                  style: TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'By proceeding to share your experience, you acknowledge that you have read, understood, and agree to abide by these terms.',
                  style: TextStyle(fontSize: 15.0),
                ),
                const SizedBox(height: 8.0),
                CheckboxListTile(
                  title: const Text(
                    "Don't show this again",
                    style: TextStyle(fontSize: 14.0),
                  ),
                  value: checkboxValue,
                  onChanged: (bool? value) {
                    setState(() {
                      checkboxValue = value!;
                    });
                  },
                ),
              ],
            ),
          );
        }),
        actions: [
          TextButton(
            child: const Text('I agree'),
            onPressed: () {
              if (checkboxValue) {
                optOutOfStoryExpectations();
              }
              Navigator.of(context).pop();
              showShareExperienceDialog(context);
            },
          ),
          TextButton(
            child: const Text('I disagree'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  // Checks whether the user has previously opted to not view story expectations
  Future<bool> hasOptedOutOfExperienceExpectations() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('Users').doc(user.uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          if (userData['hasOptedOutOfExperienceExpectations'] != null) {
            bool hasOptedOutOfExperienceExpectations =
                userData['hasOptedOutOfExperienceExpectations'];
            if (hasOptedOutOfExperienceExpectations) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  // Adds a field to the user's document in the database to indicate that they
  // have opted out of story expectations
  void optOutOfStoryExpectations() async {
    User? user = _auth.currentUser;

    if (user != null) {
      final userDocRef = _firestore.collection('Users').doc(user.uid);
      await userDocRef.update({'hasOptedOutOfExperienceExpectations': true});
    }
  }

  void showShareExperienceDialog(context) {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController titleController = TextEditingController();

    descriptionController.clear();
    titleController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLines: 1,
                maxLength: 70,
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                maxLines: 5,
                maxLength: 1000,
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Write your experience here',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      descriptionController.text.isEmpty) {
                    return _blankTitleOrExperienceAlert(context);
                  }

                  _experienceController.saveExperience(
                      titleController.text.trim(),
                      descriptionController.text.trim());

                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Thank You!'),
                        content: const Text(
                            'Thank you for sharing your experience.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _blankTitleOrExperienceAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Warning!'),
          content: Text("Please fill out the title and experience!"),
        );
      },
    );
  }

}