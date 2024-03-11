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
        title: Text("Privacy"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Terms of Services"),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (BuildContext context) {
                  return TermsOfServicesPage();
                }),
              );
            },
          ),
          ListTile(
            title: Text("Privacy Policy"),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (BuildContext context) {
                  return PrivacyPolicyPage();
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
