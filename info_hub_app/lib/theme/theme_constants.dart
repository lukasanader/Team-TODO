/*
 * This file contains the theme constants.
 * It contains the light and dark theme data.
 */

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

// Light theme constant colors
final COLOR_PRIMARY_LIGHT = Colors.red.shade700;
final COLOR_SECONDARY_LIGHT = Colors.grey.shade600;

// Dark theme constant colors
final COLOR_PRIMARY_DARK = Colors.red.shade300;
final COLOR_SECONDARY_DARK = Colors.grey.shade400;

// Get primary color based on brightness
Color getPrimaryColor(Brightness brightness) {
  return brightness == Brightness.light
      ? COLOR_PRIMARY_LIGHT
      : COLOR_PRIMARY_DARK;
}

// Light theme data
ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: COLOR_PRIMARY_LIGHT,
    colorScheme: ColorScheme.light(primary: COLOR_PRIMARY_LIGHT),

    // App bar theme
    appBarTheme: AppBarTheme(
      surfaceTintColor: COLOR_SECONDARY_LIGHT,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: COLOR_PRIMARY_LIGHT,
      ),
      color: Colors.transparent,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.black,
    ),

    // All text themes
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Text box and field theme
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: COLOR_SECONDARY_LIGHT,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: COLOR_PRIMARY_LIGHT,
        ),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: COLOR_PRIMARY_LIGHT,
          width: 2,
        ),
      ),
      prefixIconColor: COLOR_SECONDARY_LIGHT,
    ),

    // Dropdown menu theme
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: COLOR_SECONDARY_LIGHT,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(Colors.black),
        splashFactory: InkRipple.splashFactory,
        textStyle: MaterialStateProperty.all(
          const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        side: MaterialStateProperty.all(BorderSide(color: COLOR_PRIMARY_LIGHT)),
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
        shadowColor: MaterialStateProperty.all(Colors.transparent),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    ),

    // Toggle buttons theme
    toggleButtonsTheme: ToggleButtonsThemeData(
      color: COLOR_PRIMARY_LIGHT,
      selectedColor: Colors.white,
      fillColor: COLOR_PRIMARY_LIGHT,
      borderRadius: BorderRadius.circular(10),
      constraints: const BoxConstraints(
        minHeight: 40,
        minWidth: 40,
      ),
    ),

    // Card theme
    cardTheme: const CardTheme(
      color: Color.fromARGB(220, 255, 255, 255),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(14),
        ),
      ),
    ),

    // Alert dialog theme
    dialogTheme: const DialogTheme(
      // backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),

    // Icon button theme
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
        shadowColor: MaterialStateProperty.all(Colors.transparent),
      ),
    ));

// Dark theme data
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: COLOR_PRIMARY_DARK,
);
