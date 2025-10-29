import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/widgets/muscle_group_chip.dart';

class ExerciseDetailsPage extends StatefulWidget {
  const ExerciseDetailsPage({super.key, required this.exercise});
  final Exercise exercise;

  @override
  State<ExerciseDetailsPage> createState() => _ExerciseDetailsPageState();
}

class _ExerciseDetailsPageState extends State<ExerciseDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.exercise.name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(fontSize: 28),
                  ),
                  const SizedBox.square(dimension: 4),
                  Text(
                    'Muscle Groups',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium!.copyWith(color: Colors.grey),
                  ),
                  const SizedBox.square(dimension: 8),
                  muscleGroupChip(context, widget.exercise),
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(title: Text(widget.exercise.name)),
    );
  }
}
