import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:info_hub_app/experiences/admin_experience/admin_experience_widgets.dart';
import 'package:info_hub_app/helpers/helper_widgets.dart';
import 'package:info_hub_app/experiences/experience_controller.dart';
import 'package:info_hub_app/experiences/experiences_card.dart';
import 'package:info_hub_app/experiences/experience_model.dart';
import 'package:info_hub_app/topics/create_topic/helpers/transitions/checkmark_transition.dart';

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
  int _currentIndex = 0;
  late PageController _pageController;
  String _verifiedSelectedTag = 'All';
  String _unverifiedSelectedTag = 'All';


  @override
  void initState() {
    super.initState();
    _experienceController = ExperienceController(widget.auth, widget.firestore);
    updateExperiencesList();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Submitted Experiences"),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showAdminExperienceDialog(context);
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildExperienceSectiion(true, _verifiedExperienceList),
          _buildExperienceSectiion(false, _unverifiedExperienceList)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            key: ValueKey<String>('verify_navbar_button'),
            label: 'Verified',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.highlight_off_outlined),
            key: ValueKey<String>('unverify_navbar_button'),
            label: 'Unverified',
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSectiion(bool experienceType, List<Experience> experiences) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: experienceType 
              ? Text(
                  "Verified experiences",
                  style: Theme.of(context).textTheme.headlineLarge,
                )
              : Text(
                  "Unverified experiences",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
            ),
          ),
          DropdownButton<String>(
            value: experienceType 
            ? _verifiedSelectedTag
            : _unverifiedSelectedTag,
            onChanged: (String? newValue) async {

              List<Experience> tempList;

              if (newValue == 'All') {
                tempList = await _experienceController.getAllExperienceListBasedOnVerification(experienceType);
              }
              else {
                if (experienceType) {
                  tempList = await _experienceController.getVerifiedExperienceListBasedonRole(newValue!);
                }
                else {
                  tempList = await _experienceController.getunVerifiedExperienceListBasedonRole(newValue!);
                }                
              }

              setState(() {
                if (experienceType) {
                  _verifiedSelectedTag = newValue!;
                  _verifiedExperienceList = tempList;
                } else {
                  _unverifiedSelectedTag = newValue!;
                  _unverifiedExperienceList = tempList;
                }

              });
            },
            items: <String>['All' ,'Patient', 'Parent', 'Healthcare Professional']
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  key: ValueKey<String>('dropdown_menu_$value'),
                  child: Text(value),
                );
              }).toList(),
          ),
          _buildExperienceList(experiences)
        ],
      )
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
                      key: const ValueKey<String>('between_experience_padding'),
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
                    onPressed: () async {
                      _experienceController.updateVerification(experience);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CheckmarkAnimationScreen(),
                        ),
                      );
                      await Future.delayed(
                          const Duration(seconds: 2));
                      await updateExperiencesList();
                      Navigator.pop(context);
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
              onPressed: () async {
                _experienceController.deleteExperience(experience);
                updateExperiencesList();
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
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
      _unverifiedExperienceList = unverifiedExperiences;
      _verifiedExperienceList = verifiedExperiences;
    });
  }


}
