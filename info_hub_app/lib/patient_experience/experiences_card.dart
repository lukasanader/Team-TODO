import 'package:flutter/material.dart';
import 'package:info_hub_app/patient_experience/patient_experience_model.dart';


class ExperienceCard extends StatelessWidget {
  final Experience _experience;

  const ExperienceCard(this._experience, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(_experience.title.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),),
                )
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(_experience.description.toString()),
                )
              ],
            )
          ]),
      ),
    );
  }
}

class AdminExperienceCard extends StatefulWidget {
  const AdminExperienceCard(this._experience,{super.key});

  final Experience _experience;

  @override
  State<AdminExperienceCard> createState() => _AdminExperienceCardState();
}

class _AdminExperienceCardState extends State<AdminExperienceCard> {
  bool isSwitched = false;


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(widget._experience.title.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),),
                )
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(widget._experience.description.toString()),
                )
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text(widget._experience.verified.toString()),
                ),
                const Spacer(),
                Switch(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;                      
                    });

                  }
                  )
              ],
            )
          ]),
      ),
    );
  }
}