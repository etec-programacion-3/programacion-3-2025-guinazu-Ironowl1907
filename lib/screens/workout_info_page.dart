import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';

class WorkoutInfoPage extends StatelessWidget {
  const WorkoutInfoPage({super.key, required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(workout.title ?? 'Unamed Workout')),
      body: Expanded(child: Container(color: Colors.red)),
    );
  }
}
