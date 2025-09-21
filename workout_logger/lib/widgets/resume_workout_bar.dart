import 'package:flutter/material.dart';

Widget resumeWorkoutPopup(BuildContext context, ColorScheme colorScheme) {
  return Container(
    height: 80,
    width: double.infinity,
    decoration: BoxDecoration(
      color: colorScheme.secondaryContainer,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 8,
          offset: Offset(0, -2), // Shadow going upward
        ),
      ],
    ),
    child: Center(
      child: Text(
        'Floating Space',
        style: TextStyle(color: colorScheme.onSecondaryContainer),
      ),
    ),
  );
}
