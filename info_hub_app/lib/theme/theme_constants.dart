import 'package:flutter/material.dart';

// Light theme colors
final COLOR_PRIMARY_LIGHT = Colors.red.shade700;
final COLOR_SECONDARY_LIGHT = Colors.grey.shade600;

// Dark theme colors
final COLOR_PRIMARY_DARK = Colors.red.shade300;

const COLOR_ACCENT = Color.fromARGB(255, 229, 229, 229);

Color getPrimaryColor(Brightness brightness) {
  return brightness == Brightness.light
      ? COLOR_PRIMARY_LIGHT
      : COLOR_PRIMARY_DARK;
}

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: COLOR_PRIMARY_LIGHT,
    colorScheme: ColorScheme.light(
      primary: COLOR_PRIMARY_LIGHT,
    ),
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

    // Mainly used for topic cards
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

    // Text field theme
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

    // Toggle buttons theme
    toggleButtonsTheme: ToggleButtonsThemeData(
      color: COLOR_PRIMARY_LIGHT,
      selectedColor: Colors.white,
      fillColor: COLOR_PRIMARY_LIGHT,
      borderRadius: BorderRadius.circular(10),
      constraints: BoxConstraints(
        minHeight: 40,
        minWidth: 40,
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

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: COLOR_PRIMARY_DARK,
);
