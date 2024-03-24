/*
 * This file contains all helper Widgets.
 */

import 'package:flutter/material.dart';
import 'package:info_hub_app/theme/theme_constants.dart';

Widget addVerticalSpace(double height) {
  return SizedBox(
    height: height,
  );
}

// Widget addHorizontalSpace(double width) {
//   return SizedBox(
//     width: width,
//   );
// }

// Used to display a message in a card
Widget messageCard(String message, String messageKey) {
  return Padding(
    key: ValueKey(messageKey),
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Card(
      surfaceTintColor: COLOR_PRIMARY_LIGHT,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: COLOR_SECONDARY_GREY_LIGHT_DARKER,
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}
