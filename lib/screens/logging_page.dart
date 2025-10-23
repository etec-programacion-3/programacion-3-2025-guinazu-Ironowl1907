import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/workout_provider.dart';
import 'package:workout_logger/screens/finish_workout_page.dart';
import 'package:workout_logger/widgets/exerise_log_card.dart';

class LoggingPage extends StatefulWidget {
  const LoggingPage({
    super.key,
    this.currentRoutine,
    required this.currentWorkout,
    this.isEditing = false,
  });
  final Routine? currentRoutine;
  final Workout currentWorkout;
  final bool isEditing;

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

          return Column(
            children: <Widget>[
              FinishWorkoutWidget(
                workout: widget.currentWorkout,
                isEditing: widget.isEditing,
              ),
              exerciseSection(exercises, provider),
            ],
          );
        },
      ),
    );
  }

  Widget exerciseSection(
    List<MapEntry<int, DetailedWorkoutExercise>> exercises,
    WorkoutProvider provider,
  ) {
    if (exercises.isEmpty) {
      return const Column(
        children: <Widget>[Center(child: Text('No exercises'))],
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (BuildContext context, int index) {
          final MapEntry<int, DetailedWorkoutExercise> entry = exercises[index];
          return ExerciseLogCard(
            workoutExerciseId: entry.value.workoutExercise.id!,
            exercise: entry.value,
            provider: provider,
          );
        },
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    late String title;
    if (widget.currentRoutine == null) title = 'Logging Workout';
    if (widget.isEditing) title = 'Editing Workout';
    if (widget.currentRoutine != null) title = widget.currentRoutine!.name;
    late final List<Widget> actions = <Widget>[];
    if (!widget.isEditing) {
      actions.add(
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextButton(
            onPressed: () async {
              print(widget.currentWorkout.id);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      FinishWorkoutPage(workout: widget.currentWorkout),
                ),
              );
            },
            child: const Text('Finish'),
          ),
        ),
      );
    }
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.arrow_downward),
      ),
      actions: actions,
      title: Text(title),
    );
  }
}
