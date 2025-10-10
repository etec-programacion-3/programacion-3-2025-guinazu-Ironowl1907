import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/routine_provider.dart';

class LoggingPage extends StatefulWidget {
  const LoggingPage({super.key, this.currentRoutine});
  final Routine? currentRoutine;

  @override
  State<LoggingPage> createState() => _LoggingPageState();
}

class _LoggingPageState extends State<LoggingPage> {
  List<DetailedRoutineExercise>? routineExercises;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appBar(context), body: _body());
  }

  Widget _body() {
    return;
  }

  Widget _exerciseLogCard(WorkoutExercise exercise) {
    return const Placeholder();
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
