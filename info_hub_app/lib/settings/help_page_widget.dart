import 'package:flutter/material.dart';

class HelpPageControllers {
  static Widget buildGuideItem({required String title, required String subtitle}) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  static Widget buildFAQItem({required String question, required String answer}) {
    return Column(
      children: [
        ListTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              //color: Colors.black,
            ),
          ),
          subtitle: Text(
            answer,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
