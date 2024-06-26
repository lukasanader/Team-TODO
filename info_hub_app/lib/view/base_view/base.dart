/*
 * This page mainly contains the bottom navigation bar. This file also contains 
 * two additional classes SearchPage() and SettingsPage(), which should be 
 * replaced afterwards.
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:info_hub_app/view/discovery_view/discovery_view.dart';
import 'package:info_hub_app/view/settings_view/settings_view.dart';
import 'package:info_hub_app/theme/theme_manager.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:info_hub_app/view/dashboard_view/home_page_view.dart';
import 'package:info_hub_app/view/dashboard_view/admin_dash_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:info_hub_app/theme/theme_constants.dart';

class Base extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final ThemeManager themeManager;
  final String roleType;
  final FirebaseMessaging messaging;
  const Base(
      {super.key,
      required this.auth,
      required this.storage,
      required this.firestore,
      required this.themeManager,
      required this.roleType,
      required this.messaging});

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> {
  List<Widget> getScreenBasedOnUser() {
    Widget userHomePage;
    // if (widget.auth.currentUser!.emailVerified != true){
    //   userHomePage= EmailVerificationScreen(
    //       auth: widget.auth,
    //       firestore: widget.firestore,
    //       storage: widget.storage,
    //       messaging: widget.messaging,
    //       localnotificationsplugin: FlutterLocalNotificationsPlugin(),
    //     );
    // }
    if (widget.roleType == 'admin') {
      userHomePage = AdminHomepage(
        auth: widget.auth,
        storage: widget.storage,
        firestore: widget.firestore,
        themeManager: widget.themeManager,
      );
    } else {
      userHomePage = HomePage(
        auth: widget.auth,
        storage: widget.storage,
        firestore: widget.firestore,
      );
    }
    return [
      userHomePage,
      DiscoveryView(
        auth: widget.auth,
        storage: widget.storage,
        firestore: widget.firestore,
      ),
      SettingsView(
        auth: widget.auth,
        firestore: widget.firestore,
        storage: widget.storage,
        themeManager: widget.themeManager,
        messaging: widget.messaging,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Bottom Navigation Bar
    List<Widget> buildScreens() {
      List<Widget> screens = getScreenBasedOnUser();
      return screens;
    }

    // Styling for Bottom Navigation Bar
    List<PersistentBottomNavBarItem> navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.home_outlined),
          activeColorPrimary: COLOR_PRIMARY_LIGHT,
          inactiveColorPrimary: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.search_outlined),
          activeColorPrimary: COLOR_PRIMARY_LIGHT,
          inactiveColorPrimary: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeColorPrimary: COLOR_PRIMARY_LIGHT,
          inactiveColorPrimary: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
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
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black,
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
          NavBarStyle.style6, // Choose the nav bar style with this property.
    );
  }
}
