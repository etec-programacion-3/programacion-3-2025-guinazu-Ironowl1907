import 'package:flutter/material.dart';

import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/workout_provider.dart';

class ExerciseLogCard extends StatelessWidget {
  final int workoutExerciseId;
  final DetailedWorkoutExercise exercise;
  final WorkoutProvider provider;

  const ExerciseLogCard({
    super.key,
    required this.workoutExerciseId,
    required this.exercise,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
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
          SetsTable(
            workoutExerciseId: workoutExerciseId,
            exercise: exercise,
            provider: provider,
          ),
        ],
      ),
    );
  }
}

class SetsTable extends StatelessWidget {
  final int workoutExerciseId;
  final DetailedWorkoutExercise exercise;
  final WorkoutProvider provider;

  const SetsTable({
    super.key,
    required this.workoutExerciseId,
    required this.exercise,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
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
                (WorkoutSet set) => SetRow(
                  workoutExerciseId: workoutExerciseId,
                  set: set,
                  provider: provider,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class SetRow extends StatefulWidget {
  final int workoutExerciseId;
  final WorkoutSet set;
  final WorkoutProvider provider;

  const SetRow({
    super.key,
    required this.workoutExerciseId,
    required this.set,
    required this.provider,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late TextEditingController weightController;
  late TextEditingController repsController;

  @override
  void initState() {
    super.initState();
    weightController = TextEditingController(
      text: widget.set.weightKg != null ? widget.set.weightKg.toString() : '',
    );
    repsController = TextEditingController(
      text: widget.set.reps != null ? widget.set.reps.toString() : '',
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              '${widget.set.setNumber}',
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
                  widget.set.reps = int.tryParse(value);
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
                  widget.set.weightKg = double.tryParse(value);
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
                widget.set.completed == 1 ? Icons.check_circle : Icons.check,
                size: 24,
                color: widget.set.completed == 1
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: () async {
                widget.set.completed = widget.set.completed == 1 ? 0 : 1;

                await widget.provider.workoutSetRepo.update(widget.set);

                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
