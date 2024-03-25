// ignore_for_file: constant_identifier_names

/*
 * This file contains the theme constants.
 * It contains the light and dark theme data.
 */

// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

// Light theme constant colors
final COLOR_PRIMARY_LIGHT = Colors.red.shade700;
final COLOR_SECONDARY_GREY_LIGHT = Colors.grey.shade300;
final COLOR_SECONDARY_GREY_LIGHT_DARKER = Colors.grey.shade600;
const COLOR_PRIMARY_OFF_WHITE_LIGHT = Color.fromARGB(240, 255, 255, 255);

// Dark theme constant colors
final COLOR_PRIMARY_DARK = Colors.red.shade400;
final COLOR_SECONDARY_GREY_DARK = Colors.grey.shade800;
final COLOR_SECONDARY_GREY_DARK_LIGHTER = Colors.grey.shade400;
const COLOR_PRIMARY_OFF_BLACK_DARK = Color.fromARGB(15, 255, 255, 255);

// Light theme data
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: COLOR_PRIMARY_LIGHT,
  colorScheme: ColorScheme.light(
      primary: COLOR_PRIMARY_LIGHT, background: Colors.grey.shade100),

  // App bar theme
  appBarTheme: AppBarTheme(
    surfaceTintColor: COLOR_SECONDARY_GREY_LIGHT,
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
    tileColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    ),
  ),
  splashColor: COLOR_PRIMARY_LIGHT.withOpacity(0.2),

  // Date picker theme
  datePickerTheme: DatePickerThemeData(
    headerBackgroundColor: COLOR_PRIMARY_LIGHT,
    headerForegroundColor: Colors.white,
    shadowColor: Colors.transparent,
    surfaceTintColor: COLOR_SECONDARY_GREY_LIGHT,
    backgroundColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: COLOR_SECONDARY_GREY_LIGHT_DARKER,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: COLOR_PRIMARY_LIGHT,
          width: 2,
        ),
      ),
    ),
  ),

  // Time picker theme
  timePickerTheme: TimePickerThemeData(
    inputDecorationTheme: InputDecorationTheme(
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: COLOR_SECONDARY_GREY_LIGHT_DARKER,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: COLOR_PRIMARY_LIGHT,
          width: 2,
        ),
      ),
    ),
  ),

  // All text themes
  textTheme: const TextTheme(
    headlineSmall: TextStyle(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontSize: 19,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: Colors.black,
    ),
    bodySmall: TextStyle(
      fontSize: 15,
      color: Colors.black,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(Colors.black),
      textStyle: MaterialStateProperty.all(
        const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
    ),
  ),

  // Text box and field theme
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(
      color: COLOR_PRIMARY_LIGHT,
      fontSize: 16,
    ),
    hintStyle: TextStyle(
      color: COLOR_SECONDARY_GREY_LIGHT_DARKER,
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
    prefixIconColor: COLOR_SECONDARY_GREY_LIGHT_DARKER,
    suffixIconColor: COLOR_SECONDARY_GREY_LIGHT_DARKER,
  ),

  // Dropdown menu theme
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      hoverColor: Colors.transparent,
      labelStyle: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: COLOR_SECONDARY_GREY_LIGHT_DARKER,
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
      backgroundColor: MaterialStateProperty.all(COLOR_PRIMARY_OFF_WHITE_LIGHT),
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
    selectedColor: Colors.black,
    fillColor: COLOR_PRIMARY_LIGHT,
    borderRadius: BorderRadius.circular(10),
    constraints: const BoxConstraints(
      minHeight: 40,
      minWidth: 40,
    ),
  ),

  // Card theme
  cardTheme: const CardTheme(
    color: Colors.transparent,
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
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: COLOR_SECONDARY_GREY_LIGHT,
    contentTextStyle: const TextStyle(
      color: Colors.black,
      fontSize: 16,
    ),
  ),

  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(COLOR_PRIMARY_LIGHT),
    trackColor: MaterialStateProperty.all(COLOR_PRIMARY_OFF_WHITE_LIGHT),
  ),
);

// Dark theme data
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: COLOR_PRIMARY_DARK,
  colorScheme: ColorScheme.dark(
      primary: COLOR_PRIMARY_DARK, background: Colors.grey.shade900),

  // App bar theme
  appBarTheme: AppBarTheme(
    surfaceTintColor: COLOR_SECONDARY_GREY_DARK,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(
      color: COLOR_PRIMARY_DARK,
    ),
    color: Colors.transparent,
  ),
  listTileTheme: const ListTileThemeData(
    tileColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    ),
  ),
  splashColor: COLOR_PRIMARY_DARK.withOpacity(0.2),

  // Date picker theme
  datePickerTheme: DatePickerThemeData(
    headerBackgroundColor: COLOR_PRIMARY_LIGHT,
    headerForegroundColor: Colors.black,
    shadowColor: Colors.transparent,
    surfaceTintColor: COLOR_SECONDARY_GREY_DARK,
    backgroundColor: Colors.black,
    inputDecorationTheme: InputDecorationTheme(
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: COLOR_SECONDARY_GREY_DARK_LIGHTER,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: COLOR_PRIMARY_DARK,
          width: 2,
        ),
      ),
    ),
  ),

  // Time picker theme
  timePickerTheme: TimePickerThemeData(
    inputDecorationTheme: InputDecorationTheme(
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: COLOR_SECONDARY_GREY_DARK_LIGHTER,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: COLOR_PRIMARY_DARK,
          width: 2,
        ),
      ),
    ),
  ),

  // All text themes
  textTheme: const TextTheme(
    headlineSmall: TextStyle(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontSize: 19,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: Colors.white,
    ),
    bodySmall: TextStyle(
      fontSize: 15,
      color: Colors.white,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(Colors.white),
      textStyle: MaterialStateProperty.all(
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
    ),
  ),

  // Text box and field theme
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(
      color: COLOR_PRIMARY_DARK,
      fontSize: 16,
    ),
    hintStyle: TextStyle(
      color: COLOR_SECONDARY_GREY_DARK_LIGHTER,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: COLOR_PRIMARY_DARK,
      ),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: COLOR_PRIMARY_DARK,
        width: 2,
      ),
    ),
    prefixIconColor: COLOR_SECONDARY_GREY_DARK_LIGHTER,
    suffixIconColor: COLOR_SECONDARY_GREY_DARK_LIGHTER,
  ),

  // Dropdown menu theme
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      hoverColor: Colors.transparent,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: COLOR_SECONDARY_GREY_DARK_LIGHTER,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),

  // Elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(Colors.white),
      splashFactory: InkRipple.splashFactory,
      textStyle: MaterialStateProperty.all(
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      side: MaterialStateProperty.all(BorderSide(color: COLOR_PRIMARY_DARK)),
      backgroundColor: MaterialStateProperty.all(COLOR_PRIMARY_OFF_BLACK_DARK),
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
    color: COLOR_PRIMARY_DARK,
    selectedColor: Colors.white,
    fillColor: COLOR_PRIMARY_DARK,
    borderRadius: BorderRadius.circular(10),
    constraints: const BoxConstraints(
      minHeight: 40,
      minWidth: 40,
    ),
  ),

  // Card theme
  cardTheme: const CardTheme(
    color: Colors.transparent,
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
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: COLOR_SECONDARY_GREY_DARK,
    contentTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
  ),

  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.all(COLOR_PRIMARY_DARK),
    trackColor: MaterialStateProperty.all(COLOR_PRIMARY_OFF_BLACK_DARK),
  ),
);
