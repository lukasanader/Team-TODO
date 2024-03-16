import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:info_hub_app/settings/app_appearance.dart';

class GeneralSettingsView extends StatefulWidget {
  final ThemeManager themeManager;

  const GeneralSettingsView({required this.themeManager, super.key});

  @override
  State<GeneralSettingsView> createState() => _GeneralSettingsViewState();
}

class _GeneralSettingsViewState extends State<GeneralSettingsView> {
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
                builder: (context) => AppAppearanceView(
                  themeManager: widget.themeManager,
                ),
              ),
            );
          },
        ));
    // body: SwitchListTile(
    //   title: const Text("Dark Mode"),
    //   value: widget.themeManager.themeMode == ThemeMode.dark ? true : false,
    //   onChanged: (value) {
    //     setState(() {
    //       widget.themeManager.themeMode == ThemeMode.dark ? true : false;
    //     });
    //     widget.themeManager.toggleTheme(value);
    //   },
    // ));
  }
}
