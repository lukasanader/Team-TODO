import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/patient_experience/experience_model.dart';
import 'package:info_hub_app/patient_experience/experiences_card.dart';

class ExperienceView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  const ExperienceView(
      {super.key, required this.firestore, required this.auth});

  @override
  _ExperienceViewState createState() => _ExperienceViewState();
}

class _ExperienceViewState extends State<ExperienceView> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final Experience _experience = Experience();
  List<Experience> _experienceList = [];
  // ignore: prefer_final_fields
  bool? _isChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getExperienceList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Paitent's Experiences"),
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
                _hasReadExperienceExpectations().then((value) {
                  if (value) {
                    _showPostDialog();
                  } else {
                    _showStoryToSS();
                  }
                });
              },
              child: const Text("Share your experience!"),
            )
          ],
        )));
  }

  void _showStoryToSS() {
    bool checkboxValue = false;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Patient Experience Expectations'),
              content: StatefulBuilder(builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return SingleChildScrollView(
                    child: ListBody(
                  children: [
                    Text(
                        'By sharing your experience, you agree to the following terms:'),
                    Text(
                        '1. You agree to share your experience with the understanding that it will be shared with other patients.'),
                    Text(
                        '2. You agree to share your experience with the understanding that it will be shared with other patients.'),
                    Text(
                        '3. You agree to share your experience with the understanding that it will be shared with other patients.'),
                    CheckboxListTile(
                        title: const Text(
                            "Tick if you don't want to show this message again."),
                        value: checkboxValue,
                        onChanged: (bool? value) {
                          setState(() {
                            checkboxValue = value!;

                            var isChecked = "";
                            if (checkboxValue) {
                              isChecked = "checked";
                            } else {
                              isChecked = "un-checked";
                            }
                          });
                        }),
                  ],
                ));
              }),
              actions: [
                TextButton(
                  child: const Text('I agree'),
                  onPressed: () {
                    if (checkboxValue) {
                      _enableHasReadExperienceExpectations();
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
            ));
  }

  Future<bool> _hasReadExperienceExpectations() async {
    User? user = widget.auth.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot =
          await widget.firestore.collection('Users').doc(user.uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          bool hasReadPatientExperience =
              userData['hasReadExperienceExpectations'];
          if (hasReadPatientExperience) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _enableHasReadExperienceExpectations() async {
    User? user = widget.auth.currentUser;

    if (user != null) {
      final userDocRef = widget.firestore.collection('Users').doc(user.uid);
      await userDocRef.update({'hasReadExperienceExpectations': true});
    }
  }

  void _showPostDialog() {
    _descriptionController.clear();
    _titleController.clear();

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
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                maxLines: 5,
                maxLength: 1000,
                keyboardType: TextInputType.multiline,
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Share your experience!',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 20,
                width: 100000,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_titleController.text.isEmpty ||
                      _descriptionController.text.isEmpty) {
                    return _blankTitleOrExperienceAlert(context);
                  }

                  _saveExperience();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future getExperienceList() async {
    QuerySnapshot data = await widget.firestore
        .collection('experiences')
        .where('verified', isEqualTo: true)
        .get();

    setState(() {
      _experienceList =
          List.from(data.docs.map((doc) => Experience.fromSnapshot(doc)));
    });
  }

  void _saveExperience() async {
    // FirebaseAuth auth = FirebaseAuth.instance;
    // User? user = auth.currentUser;

    _experience.title = _titleController.text;
    _experience.description = _descriptionController.text;
    // if (user != null) {
    //   _experience.uid = user.uid;
    // }
    _experience.verified = false;

    CollectionReference db = widget.firestore.collection('experiences');
    await db.add(_experience.toJson());
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
