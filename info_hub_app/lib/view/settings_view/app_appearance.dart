/*
 * This file contains the code for the AppAppearance class. 
 * This class is used to change the appearance of the app, such as the theme mode.
 * The user can choose between the system theme, light theme, and dark theme.
 */

import 'package:flutter/material.dart';
import 'package:info_hub_app/theme/theme_manager.dart';

class AppAppearance extends StatefulWidget {
  final ThemeManager themeManager;

  const AppAppearance({required this.themeManager, super.key});

  @override
  State<AppAppearance> createState() => _AppAppearanceState();
}

class _AppAppearanceState extends State<AppAppearance> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    if (widget.themeManager.themeMode == ThemeMode.system) {
      _selectedIndex = 0;
    } else if (widget.themeManager.themeMode == ThemeMode.light) {
      _selectedIndex = 1;
    } else {
      _selectedIndex = 2;
    }
  }

  void _selectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Appearance'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Match System'),
            trailing: _selectedIndex == 0 ? _buildBulletPoint() : null,
            onTap: () {
              _selectItem(0);
              widget.themeManager.changeTheme('system');
            },
            selected: _selectedIndex == 0,
          ),
          ListTile(
            title: const Text('Always Light'),
            trailing: _selectedIndex == 1 ? _buildBulletPoint() : null,
            onTap: () {
              _selectItem(1);
              widget.themeManager.changeTheme('light');
            },
            selected: _selectedIndex == 1,
          ),
          ListTile(
            title: const Text('Always Dark'),
            trailing: _selectedIndex == 2 ? _buildBulletPoint() : null,
            onTap: () {
              _selectItem(2);
              widget.themeManager.changeTheme('dark');
            },
            selected: _selectedIndex == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint() {
    return const CircleAvatar(radius: 6.0);
  }
}
