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
              return _exerciseLogCard(
                entry.key, // workout exercise id
                entry.value, // DetailedWorkoutExercise
                provider,
              );
            },
          );
        },
      ),
    );
  }

  Widget _exerciseLogCard(
    int workoutExerciseId,
    DetailedWorkoutExercise exercise,
    WorkoutProvider provider,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  exercise.exercise.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: <Widget>[
                    IconButton(onPressed: () {}, icon: const Icon(Icons.timer)),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          _setsTable(workoutExerciseId, exercise, provider),
        ],
      ),
    );
  }

  Widget _setsTable(
    int workoutExerciseId,
    DetailedWorkoutExercise exercise,
    WorkoutProvider provider,
  ) {
    final List<WorkoutSet> sets =
        provider.workoutSets[workoutExerciseId] ?? <WorkoutSet>[];

    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: const Row(
            children: <Widget>[
              SizedBox(
                width: 30,
                child: Text('#', textAlign: TextAlign.center),
              ),
              Expanded(child: Text('Prev', textAlign: TextAlign.center)),
              Expanded(child: Text('Reps', textAlign: TextAlign.center)),
              Expanded(child: Text('Weight', textAlign: TextAlign.center)),
              SizedBox(width: 30, child: Icon(Icons.check_circle)),
            ],
          ),
        ),
        Column(
          children: sets
              .map(
                (WorkoutSet set) => _setRow(workoutExerciseId, set, provider),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _setRow(
    int workoutExerciseId,
    WorkoutSet set,
    WorkoutProvider provider,
  ) {
    final TextEditingController weightController = TextEditingController(
      text: set.weightKg != null ? set.weightKg.toString() : '',
    );
    final TextEditingController repsController = TextEditingController(
      text: set.reps != null ? set.reps.toString() : '',
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: <Widget>[
          // Set Number
          SizedBox(
            width: 30,
            child: Text(
              '${set.setNumber}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: Text(
              // TODO: Previous numbers from last workout
              '12 × 50kg',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: repsController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onChanged: (String value) {
                  set.reps = int.tryParse(value);
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: weightController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onChanged: (String value) {
                  set.weightKg = double.tryParse(value);
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 30,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                set.completed == 1 ? Icons.check_circle : Icons.check,
                size: 24,
                color: set.completed == 1
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: () async {
                set.completed = set.completed == 1 ? 0 : 1;

                await provider.workoutSetRepo.update(set);

                setState(() {});

                print('Set ${set.setNumber} completed: ${set.completed}');
              },
            ),
          ),
        ],
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
