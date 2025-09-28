import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/exercise_provider.dart';
import 'package:workout_logger/providers/muscle_group_provider.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Consumer<ExerciseProvider>(
          builder:
              (
                BuildContext context,
                ExerciseProvider exerciseProvider,
                Widget? child,
              ) {
                if (exerciseProvider.exercises.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No exercises yet.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap + to add your first exercise',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final List<Exercise> exercises = exerciseProvider.exercises;
                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Exercise exercise = exercises[index];
                    return Text(exercise.name);
                  },
                );
              },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _addExerciseDialog(context);
        },
      ),
    );
  }
}

Future<void> _addExerciseDialog(BuildContext context) async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  MuscleGroup? selectedMuscleGroup;

  final List<MuscleGroup> muscleGroups = context
      .read<MuscleGroupProvider>()
      .muscleGroups;

  final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) => StatefulBuilder(
      builder: (BuildContext context, setDialogState) => AlertDialog(
        title: const Text('Add Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'Enter exercise name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              if (muscleGroups.isNotEmpty)
                DropdownButtonFormField<MuscleGroup>(
                  value: selectedMuscleGroup,
                  decoration: const InputDecoration(labelText: 'Muscle Group'),
                  items: muscleGroups.map((MuscleGroup group) {
                    return DropdownMenuItem<MuscleGroup>(
                      value: group,
                      child: Text(group.name),
                    );
                  }).toList(),
                  onChanged: (MuscleGroup? value) {
                    setDialogState(() {
                      selectedMuscleGroup = value;
                    });
                  },
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () {
              final String name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop(<String, Object?>{
                  'name': name,
                  'description': descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  'muscleGroupId': selectedMuscleGroup?.id,
                });
              }
            },
          ),
        ],
      ),
    ),
  );

  if (result != null) {
    final Exercise exercise = Exercise(
      name: result['name'],
      description: result['description'],
      muscleGroupId: result['muscleGroupId'],
    );

    context.read<ExerciseProvider>().add(exercise);
  }
}

Future<void> _editExerciseDialog(
  BuildContext context,
  Exercise exercise,
) async {
  final TextEditingController nameController = TextEditingController(
    text: exercise.name,
  );
  final TextEditingController descriptionController = TextEditingController(
    text: exercise.description,
  );

  MuscleGroup? selectedMuscleGroup = await context
      .read<MuscleGroupProvider>()
      .getFromId(exercise.muscleGroupId!);

  final List<MuscleGroup> muscleGroups = context
      .read<MuscleGroupProvider>()
      .muscleGroups;

  final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) => StatefulBuilder(
      builder: (BuildContext context, setDialogState) => AlertDialog(
        title: const Text('Add Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'Enter exercise name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              if (muscleGroups.isNotEmpty)
                DropdownButtonFormField<MuscleGroup>(
                  value: selectedMuscleGroup,
                  decoration: const InputDecoration(labelText: 'Muscle Group'),
                  items: muscleGroups.map((MuscleGroup group) {
                    return DropdownMenuItem<MuscleGroup>(
                      value: group,
                      child: Text(group.name),
                    );
                  }).toList(),
                  onChanged: (MuscleGroup? value) {
                    setDialogState(() {
                      selectedMuscleGroup = value;
                    });
                  },
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () {
              final String name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop(<String, Object?>{
                  'name': name,
                  'description': descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  'muscleGroupId': selectedMuscleGroup?.id,
                });
              }
            },
          ),
        ],
      ),
    ),
  );

  if (result != null) {
    final Exercise exercise = Exercise(
      name: result['name'],
      description: result['description'],
      muscleGroupId: result['muscleGroupId'],
    );

    context.read<ExerciseProvider>().add(exercise);
  }
}

Dismissible exerciseCard(
  Exercise exercise,
  List<Exercise> exerciseList,
  int index,
  ColorScheme colorScheme,
  BuildContext context,
) {
  return Dismissible(
    key: ValueKey(exercise.id),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    onDismissed: (_) {
      context.read<ExerciseProvider>().delete(exercise);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${exercise.name} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // You could implement undo functionality here
            },
          ),
        ),
      );
    },
    child: GestureDetector(
      onTap: () => _editExerciseDialog(context, exercise),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/edit.svg',
                    width: 24,
                    height: 24,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getMuscleGroupName(exercise.muscleGroupId),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              if (exercise.description != null &&
                  exercise.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    exercise.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
