import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/patient_experience/experience_controller.dart';
import 'package:info_hub_app/patient_experience/experience_model.dart';
import 'package:info_hub_app/patient_experience/experiences_card.dart';

class ExperienceView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const ExperienceView(
      {super.key, required this.firestore, required this.auth});

  @override
  State<ExperienceView> createState() => _ExperienceViewState();
}

class _ExperienceViewState extends State<ExperienceView> {
  late ExperienceController _experienceController;
  List<Experience> _experienceList = [];
  // ignore: prefer_final_fields




  @override
  void initState() {
    super.initState();
    _experienceController = ExperienceController(
      widget.auth, 
      widget.firestore);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateExperienceList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Patient's Experiences"),
        ),
        body: SafeArea(
            child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: _experienceList.length,
                  itemBuilder: (context, index) {
                    return ExperienceCard(_experienceList[index]);
                  }),
            ),
            ElevatedButton(
              onPressed: () {
                // Checks whether the user has previously opted to not view
                // story expectations
                _hasOptedOutOfExperienceExpectations().then((value) {
                  if (value) {
                    _showPostDialog();
                  } else {
                    _showExperienceExpectations();
                  }
                });
              },
              child: const Text("Share your experience!"),
            )
          ],
        )));
  }

  // Patient must read and accept experience expectations dialog
  void _showExperienceExpectations() {
    bool checkboxValue = false;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Patient Experience Expectations'),
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
                  '1. You agree to share your experience with the understanding that it will be shared with other patients.',
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
                _optOutOfStoryExpectations();
              }
              Navigator.of(context).pop();
              _showPostDialog();
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
  Future<bool> _hasOptedOutOfExperienceExpectations() async {
    User? user = widget.auth.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot =
          await widget.firestore.collection('Users').doc(user.uid).get();

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
  void _optOutOfStoryExpectations() async {
    User? user = widget.auth.currentUser;

    if (user != null) {
      final userDocRef = widget.firestore.collection('Users').doc(user.uid);
      await userDocRef.update({'hasOptedOutOfExperienceExpectations': true});
    }
  }

  void _showPostDialog() {
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
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                maxLines: 5,
                maxLength: 1000,
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Share your experience!',
                  border: OutlineInputBorder(),
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
                    titleController.text,
                    descriptionController.text
                  );

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

  Future updateExperienceList() async {
    List<Experience> data = await _experienceController.getVerifiedExperienceList();

    setState(() {
      _experienceList = data;
    });
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
