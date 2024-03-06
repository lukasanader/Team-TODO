/*
 * This page mainly contains the bottom navigation bar. This file also contains 
 * two additional classes SearchPage() and SettingsPage(), which should be 
 * replaced afterwards.
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/discovery_view/discovery_view.dart';
import 'package:info_hub_app/settings/settings_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:info_hub_app/home_page/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Base extends StatelessWidget {
  FirebaseAuth auth;
  FirebaseFirestore firestore;
  FirebaseStorage storage;
  Base(
      {super.key,
      required this.auth,
      required this.storage,
      required this.firestore});

  @override
  Widget build(BuildContext context) {
    // Bottom Navigation Bar
    List<Widget> buildScreens() {
      return [
        HomePage(
          auth: auth,
          storage: storage,
          firestore: firestore,
        ),
        DiscoveryView(
          auth: auth,
          storage: storage,
          firestore: firestore,
        ), // Should be replaced with the genuine page
         SettingsView(auth: auth,firestore: firestore,storage: storage,), // Should be replaced with the genuine page
      ];
    }

    // Styling for Bottom Navigation Bar
    List<PersistentBottomNavBarItem> navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.home),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.search),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.settings),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
        ),
      ];
    }

    // Controller for Bottom Navigation Bar
    PersistentTabController controller;
    controller = PersistentTabController(initialIndex: 0);

    return PersistentTabView(
      context,
      controller: controller,
      screens: buildScreens(),
      items: navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle:
          NavBarStyle.style5, // Choose the nav bar style with this property.
    );
  }
}
