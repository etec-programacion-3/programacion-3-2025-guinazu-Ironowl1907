import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/routine_provider.dart';
import 'package:workout_logger/providers/workout_provider.dart';
import 'package:workout_logger/screens/logging_page.dart';
import 'package:workout_logger/widgets/delete_confirmation.dart';

class WorkoutRoutineCard extends StatefulWidget {
  final Routine routine;
  const WorkoutRoutineCard({super.key, required this.routine});

  @override
  State<WorkoutRoutineCard> createState() => _WorkoutRoutineCardState();
}

class _WorkoutRoutineCardState extends State<WorkoutRoutineCard> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return FutureBuilder(
      future: Future.wait(<Future<Object?>>[
        context.read<RoutineProvider>().getDetailedRoutineExercisesByRoutine(
          widget.routine.id!,
        ),
        context.read<WorkoutProvider>().getUnfinishedWorkout(),
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> asyncSnapshot) {
        Widget content;
        if (asyncSnapshot.hasData) {
          final List<DetailedRoutineExercise> exercises =
              asyncSnapshot.data![0] as List<DetailedRoutineExercise>;
          final Workout? unfinishedWorkout = asyncSnapshot.data![1];

          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.routine.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              _exerciseList(exercises),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FloatingActionButton(
                  heroTag: widget.routine.id,
                  onPressed: () async {
                    if (unfinishedWorkout != null) {
                      final bool? shouldDiscard = await showDeleteConfirmation(
                        context: context,
                        title: "There's a workout in progress",
                        body:
                            'Do you want to discard ${unfinishedWorkout.title}',
                        deleteLabel: 'Discard',
                        onDelete: () {
                          context.read<WorkoutProvider>().delete(
                            unfinishedWorkout.id!,
                          );
                        },
                      );

                      if (shouldDiscard != true) {
                        return;
                      }
                    }

                    final Workout workout = await context
                        .read<WorkoutProvider>()
                        .initializeWorkout(widget.routine);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoggingPage(
                          currentRoutine: widget.routine,
                          currentWorkout: workout,
                        ),
                      ),
                    );
                  },
                  child: const Text('Start Routine'),
                ),
              ),
            ],
          );
        } else if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          content = const CircularProgressIndicator();
        } else {
          content = Text('Error: ${asyncSnapshot.error}');
        }
        return Card(
          color: theme.colorScheme.surfaceContainerLow,
          child: Padding(padding: const EdgeInsets.all(18.0), child: content),
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
