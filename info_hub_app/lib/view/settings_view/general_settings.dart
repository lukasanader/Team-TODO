import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/view/settings_view/app_appearance.dart';
import 'package:info_hub_app/theme/theme_manager.dart';

class GeneralSettings extends StatefulWidget {
  final ThemeManager themeManager;

  const GeneralSettings({required this.themeManager, super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("General"),
      ),
      body: ListTile(
        title: const Text("App Appearance"),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => AppAppearance(
                themeManager: widget.themeManager,
              ),
            ),
          );
        },
      ),
    );
  }
}
