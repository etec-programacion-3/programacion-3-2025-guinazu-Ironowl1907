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
        BoxShadow(
          color: Colors.black26,
          blurRadius: 8,
          offset: Offset(0, -2), // Shadow going upward
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Text(
            'Workout in Progress',
            style: TextStyle(color: themeData.colorScheme.onSecondaryContainer),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(child: Text("Resume"), onPressed: () {}),
              TextButton(child: Text("Discard"), onPressed: () {}),
            ],
          ),
        ],
      ),
    ),
  );
}
