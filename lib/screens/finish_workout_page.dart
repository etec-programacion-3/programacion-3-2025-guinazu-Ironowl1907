import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/workout_provider.dart';
import 'package:provider/provider.dart';

class FinishWorkoutPage extends StatefulWidget {
  const FinishWorkoutPage({super.key, required this.workout});
  final Workout workout;

  @override
  State<FinishWorkoutPage> createState() => _FinishWorkoutPageState();
}

class _FinishWorkoutPageState extends State<FinishWorkoutPage> {
  TextEditingController workoutName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    workoutName.text = widget.workout.title ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Finish Workout')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[FinishWorkoutWidget(workout: widget.workout)],
        ),
      ),
    );
  }
}

class FinishWorkoutWidget extends StatelessWidget {
  FinishWorkoutWidget({
    super.key,
    required this.workout,
    this.isEditing = false,
  }) {
    workoutName = TextEditingController(text: workout.title ?? '');
    workoutNote = TextEditingController(text: workout.note ?? '');
  }

  final Workout workout;
  late TextEditingController workoutName;
  late TextEditingController workoutNote;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: workoutName,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              controller: workoutNote,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'How did the workout go?',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FloatingActionButton(
                child: Text(isEditing ? 'Save' : 'Finish'),
                onPressed: () async {
                  if (workoutName.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please give a name'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  workout.title = workoutName.text;
                  workout.note = workoutNote.text;
                  if (isEditing) {
                    await context.read<WorkoutProvider>().update(workout);
                  } else {
                    await context.read<WorkoutProvider>().finishWorkout(
                      workout,
                    );
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
