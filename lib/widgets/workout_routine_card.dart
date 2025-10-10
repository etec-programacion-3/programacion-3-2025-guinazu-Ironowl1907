import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/routine_provider.dart';

class WorkoutRoutineCard extends StatefulWidget {
  const WorkoutRoutineCard({super.key, required this.routine});
  final Routine routine;

  @override
  State<WorkoutRoutineCard> createState() => _WorkoutRoutineCardState();
}

class _WorkoutRoutineCardState extends State<WorkoutRoutineCard> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return FutureBuilder(
      future: context
          .read<RoutineProvider>()
          .getDetailedRoutineExercisesByRoutine(widget.routine.id!),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<DetailedRoutineExercise>> asyncSnapshot,
          ) {
            Widget content;

            if (asyncSnapshot.hasData) {
              content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.routine.name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _exerciseList(asyncSnapshot.data!),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FloatingActionButton(
                      onPressed: () {},
                      child: const Text('Start Routine'),
                    ),
                  ),
                ],
              );
            } else if (asyncSnapshot.connectionState ==
                ConnectionState.waiting) {
              content = const CircularProgressIndicator();
            } else {
              content = Text('Error: ${asyncSnapshot.error}');
            }

            return Card(
              color: theme.colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: content,
              ),
            );
          },
    );
  }

  Text _exerciseList(List<DetailedRoutineExercise> exercises) {
    final String result = exercises
        .map((DetailedRoutineExercise detailedExercise) {
          return detailedExercise.exercise.name;
        })
        .join(', ');
    return Text(result, style: TextStyle(color: Colors.grey[500]));
  }
}
