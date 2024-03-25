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
Widget messageCard(String message, String messageKey, context) {
  return Padding(
    key: ValueKey(messageKey),
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Card(
      surfaceTintColor: Theme.of(context).brightness == Brightness.light
          ? COLOR_PRIMARY_LIGHT
          : COLOR_PRIMARY_DARK,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? COLOR_SECONDARY_GREY_LIGHT_DARKER
                : COLOR_SECONDARY_GREY_DARK_LIGHTER,
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}
