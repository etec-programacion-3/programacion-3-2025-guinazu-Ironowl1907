import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/widgets/common/app_line_chart.dart';
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
        child: Column(children: <Widget>[titleCard(context), charts(context)]),
      ),
      appBar: AppBar(title: Text(widget.exercise.name)),
    );
  }

  Card charts(BuildContext context) {
    return const Card(
      child: Padding(padding: EdgeInsets.all(20.0), child: AppLineChart()),
    );
  }

  Card titleCard(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
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
    );
  }
}
