import 'package:flutter/material.dart';
import 'package:info_hub_app/theme/theme_constants.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: COLOR_SECONDARY_GREY_LIGHT,
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }
}
