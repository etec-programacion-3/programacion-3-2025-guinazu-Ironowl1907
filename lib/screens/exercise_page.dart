import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/exercise_provider.dart';
import 'package:workout_logger/providers/muscle_group_provider.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ExerciseProvider>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ExerciseProvider provider = context.watch<ExerciseProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: provider.exercises.length,
          itemBuilder: (BuildContext context, int index) {
            return _exerciseCard(provider.exercises[index], context);
          },
        ),
      ),
    );
  }

  Widget _exerciseCard(Exercise exercise, BuildContext context) {
    return FutureBuilder<MuscleGroup?>(
      future: context.read<MuscleGroupProvider>().get(exercise.muscleGroupId!),
      builder:
          (BuildContext context, AsyncSnapshot<MuscleGroup?> asyncSnapshot) {
            String label;
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              label = 'Loading...';
            } else if (asyncSnapshot.hasError) {
              label = 'Error';
            } else if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
              label = asyncSnapshot.data!.name;
            } else {
              label = 'Unknown';
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox.square(dimension: 8),
                        Row(children: <Widget>[_muscleGroupChip(label)]),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }

  Widget _muscleGroupChip(String label) {
    return Chip(label: Text(label));
  }
}
