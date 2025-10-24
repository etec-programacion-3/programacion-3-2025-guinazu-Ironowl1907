import 'package:flutter/material.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/workout_provider.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/widgets/routine_card.dart';

class ResumeCard extends StatelessWidget {
  const ResumeCard({super.key, required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "There's a workout in progress",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              workout.title ?? 'Unnamed',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    // showDeleteConfirmation(routine, context)
                    context.read<WorkoutProvider>().delete(workout.id!);
                  },
                  child: const Text('Discard'),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: () {}, child: const Text('Resume')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
