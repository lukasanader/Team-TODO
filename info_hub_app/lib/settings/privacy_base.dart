/*
 * This file is responsible for displaying the different legal agreements.
 * Currently, it only displays the Terms of Service and Privacy Policy pages 
 * in a list view.
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:info_hub_app/legal_agreements/privacy_policy.dart';
import 'package:info_hub_app/legal_agreements/terms_of_services.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Terms of Services"),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (BuildContext context) {
                  return const TermsOfServicesPage();
                }),
              );
            },
          ),
          ListTile(
            title: const Text("Privacy Policy"),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (BuildContext context) {
                  return const PrivacyPolicyPage();
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
