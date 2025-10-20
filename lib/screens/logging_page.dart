import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/workout_provider.dart';
import 'package:workout_logger/widgets/exerise_log_card.dart';

class LoggingPage extends StatefulWidget {
  const LoggingPage({
    super.key,
    this.currentRoutine,
    required this.currentWorkout,
  });
  final Routine? currentRoutine;
  final Workout? currentWorkout;

  @override
  State<LoggingPage> createState() => _LoggingPageState();
}

class _LoggingPageState extends State<LoggingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appBar(context), body: _body());
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Consumer<WorkoutProvider>(
        builder: (BuildContext context, WorkoutProvider provider, _) {
          final List<MapEntry<int, DetailedWorkoutExercise>> exercises =
              provider.workoutExercises.entries.toList()..sort(
                (
                  MapEntry<int, DetailedWorkoutExercise> a,
                  MapEntry<int, DetailedWorkoutExercise> b,
                ) => a.value.workoutExercise.orderIndex.compareTo(
                  b.value.workoutExercise.orderIndex,
                ),
              );

          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (BuildContext context, int index) {
              final MapEntry<int, DetailedWorkoutExercise> entry =
                  exercises[index];
              return ExerciseLogCard(
                workoutExerciseId: entry.value.workoutExercise.id!,
                exercise: entry.value,
                provider: provider,
              );
            },
          );
        },
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.arrow_downward),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextButton(
            onPressed: () async {
              await context.read<WorkoutProvider>().finishWorkout(
                widget.currentWorkout!,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Finish'),
          ),
        ),
      ],
      title: Text(
        widget.currentRoutine != null
            ? widget.currentRoutine!.name
            : 'Logging workout',
      ),
    );
  }
}
