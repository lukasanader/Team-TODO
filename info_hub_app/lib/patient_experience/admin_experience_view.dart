import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/patient_experience/experience_controller.dart';
import 'package:info_hub_app/patient_experience/experiences_card.dart';
import 'package:info_hub_app/patient_experience/experience_model.dart';

class AdminExperienceView extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const AdminExperienceView({
    super.key,
    required this.firestore,
    required this.auth,
  });

  @override
  State<AdminExperienceView> createState() => _AdminExperienceViewState();
}

class _AdminExperienceViewState extends State<AdminExperienceView> {
  late ExperienceController _experienceController;
  List<Experience> _verifiedExperienceList = [];
  List<Experience> _unverifiedExperienceList = [];

  @override
  void initState() {
    super.initState();
    _experienceController = ExperienceController(widget.auth, widget.firestore);
    updateExperiencesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Submitted Experiences"),
        backgroundColor: Colors.transparent, // Set AppBar color to transparent
        elevation: 0, // Remove shadow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  "Verified experiences",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
            _buildExperienceSection(true),
            addVerticalSpace(10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  "Unverified experiences",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
            _buildExperienceSection(false),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSection(bool verified) {
    return FutureBuilder<List<Experience>>(
      future: _experienceController
          .getAllExperienceListBasedOnVerification(verified),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          var experiences = snapshot.data ?? [];
          return _buildExperienceList(experiences);
        }
      },
    );
  }

  Widget _buildExperienceList(List<Experience> experiences) {
    return experiences.isEmpty
        ? const Text(
            "No experiences available",
          )
        : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: experiences.length * 2 - 1,
            itemBuilder: (context, index) {
              if (index.isOdd) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                );
              } else {
                index = index ~/ 2;
                return displayExperiencesForAdmin(experiences[index]);
              }
            },
          );
  }

  Widget displayExperiencesForAdmin(Experience experience) {
    bool? experienceVerification = experience.verified;
    IconData buttonIcon =
        experienceVerification != null && experienceVerification
            ? Icons.highlight_off_outlined
            : Icons.check_circle_outline;
    Color buttonColor = experienceVerification != null && experienceVerification
        ? Colors.red
        : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ExperienceCard(experience), // Moved this up as requested
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              title: Text(
                experience.userEmail.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(experience.userRoleType.toString(),
                  style: Theme.of(context).textTheme.labelSmall),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => deleteExperienceConfirmation(experience),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  IconButton(
                    onPressed: () {
                      _experienceController.updateVerification(experience);
                      updateExperiencesList();
                    },
                    icon: Icon(buttonIcon, color: buttonColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteExperienceConfirmation(Experience experience) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning!'),
          content: const Text("Are you sure you want to delete?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                _experienceController.deleteExperience(experience);
                updateExperiencesList();
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateExperiencesList() async {
    var verifiedExperiences = await _experienceController
        .getAllExperienceListBasedOnVerification(true);
    var unverifiedExperiences = await _experienceController
        .getAllExperienceListBasedOnVerification(false);
    setState(() {
      _verifiedExperienceList = verifiedExperiences;
      _unverifiedExperienceList = unverifiedExperiences;
    });
  }
}
