import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
          Container(
            child: ListTile(
              title: Text("TeamTODO Terms of Services"),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (BuildContext context) {
                    return TermsOfServicesPage();
                  }),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class TermsOfServicesPage extends StatelessWidget {
  const TermsOfServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms of Services"),
      ),
      body: const Center(
        child: Text('Placeholder for Terms of Services.'),
      ),
    );
  }
}
