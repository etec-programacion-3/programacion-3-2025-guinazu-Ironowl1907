import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/workout_provider.dart';

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
    return Consumer<WorkoutProvider>(
      builder: (BuildContext context, WorkoutProvider provider, _) {
        if (provider.currentRoutineExercises == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Text('Error')],
            ),
          );
        }
        return ListView.builder(
          itemCount: provider.currentRoutineExercises!.length,
          itemBuilder: (BuildContext context, int index) {
            return _exerciseLogCard(
              provider.currentRoutineExercises![index].routineExercise,
            );
          },
        );
      },
    );
  }

  Widget _exerciseLogCard(RoutineExercise exercise) {
    return Text(exercise.toMap().toString());
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
          child: TextButton(onPressed: () {}, child: const Text('Finish')),
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
