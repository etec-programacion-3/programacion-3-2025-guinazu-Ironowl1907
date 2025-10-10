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
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _setsTable(exercise),
        ],
      ),
    );
  }

  Widget _setsTable(DetailedRoutineExercise exercise) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: const Row(
            children: <Widget>[
              SizedBox(
                width: 40,
                child: Text('#', textAlign: TextAlign.center),
              ),
              Expanded(child: Text('Prev', textAlign: TextAlign.center)),
              Expanded(child: Text('Reps', textAlign: TextAlign.center)),
              Expanded(child: Text('Weight', textAlign: TextAlign.center)),
              SizedBox(width: 40, child: Icon(Icons.check)),
            ],
          ),
        ),
        Container(
          child: Column(
            children: <Widget>[
              ...List.generate(3, (int index) => _setRow(index + 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _setRow(int setNumber) {
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
            width: 40,
            child: Text(
              '$setNumber',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: Text(
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
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.check_circle_outline, size: 24),
              onPressed: () {
                // Mark set as complete
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
