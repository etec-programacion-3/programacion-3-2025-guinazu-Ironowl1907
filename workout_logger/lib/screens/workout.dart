import 'package:flutter/material.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Workout Page"));
  }
}

PreferredSizeWidget workoutAppBar() {
  return AppBar(
    title: Text("Workout"),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1.0),
      child: Container(color: Colors.grey.shade300, height: 1.0),
    ),
  );
}
