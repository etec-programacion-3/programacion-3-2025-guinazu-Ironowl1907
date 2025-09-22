import 'package:flutter/material.dart';

Widget resumeWorkoutPopup(BuildContext context, ThemeData themeData) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: themeData.colorScheme.secondaryContainer,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Workout in Progress',
            style: TextStyle(color: themeData.colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  // Resume logic here
                },
                style: TextButton.styleFrom(
                  foregroundColor: themeData.colorScheme.onSecondaryContainer,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text("Resume"),
              ),
              TextButton(
                onPressed: () {
                  // Discard logic here
                },
                style: TextButton.styleFrom(
                  foregroundColor: themeData.colorScheme.error,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text("Discard"),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
