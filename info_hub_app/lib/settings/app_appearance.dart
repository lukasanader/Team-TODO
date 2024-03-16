import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:info_hub_app/theme/theme_constants.dart';
import 'package:info_hub_app/theme/theme_manager.dart';

class AppAppearanceView extends StatefulWidget {
  final ThemeManager themeManager;

  const AppAppearanceView({required this.themeManager, super.key});

  @override
  State<AppAppearanceView> createState() => _AppAppearanceViewState();
}

class _AppAppearanceViewState extends State<AppAppearanceView> {
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
    TextTheme _textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selectable List Tiles'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Match System'),
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
    return CircleAvatar(
      radius: 8.0, // Adjust size as needed
      // backgroundColor: Colors.red.shade700, // Replace with your image
      // Add border
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white, // Border color
            width: 2, // Border width
          ),
        ),
      ),
    );
  }
}
