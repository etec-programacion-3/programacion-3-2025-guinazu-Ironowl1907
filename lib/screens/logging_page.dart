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
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Consumer<WorkoutProvider>(
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
              return _exerciseLogCard(provider.currentRoutineExercises![index]);
            },
          );
        },
      ),
    );
  }

  Widget _exerciseLogCard(DetailedRoutineExercise exercise) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  exercise.exercise.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
            TextButton(
              onPressed: () {
                // TODO: Set Timer
              },
              child: const Text('Timer 3min'),
            ),
          ],
        ),
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
