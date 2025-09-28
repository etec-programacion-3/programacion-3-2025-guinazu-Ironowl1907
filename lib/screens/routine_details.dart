import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';

class RoutineDetailsPage extends StatelessWidget {
  const RoutineDetailsPage({super.key, required this.routine});

  final Routine routine;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Text(routine.name)],
      ),
    );
  }
}
