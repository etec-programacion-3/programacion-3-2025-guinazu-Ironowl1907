import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_logger/models/models.dart';
import 'package:workout_logger/providers/exercise_provider.dart';
import 'package:workout_logger/providers/muscle_group_provider.dart';
import 'package:workout_logger/screens/exercise_details.dart';
import 'package:workout_logger/screens/muscle_selector.dart';
import 'package:workout_logger/widgets/muscle_group_chip.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  @override
  Widget build(BuildContext context) {
    final ExerciseProvider provider = context.watch<ExerciseProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrEditExercise(context, null);
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: provider.exercises.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No exercises added yet.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: provider.exercises.length,
                itemBuilder: (BuildContext context, int index) {
                  return _exerciseCard(provider.exercises[index], context);
                },
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ExerciseProvider>(context, listen: false).load();
    });
  }

  Future<void> _addOrEditExercise(
    BuildContext context,
    Exercise? exercise,
  ) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionConroller = TextEditingController();
    List<MuscleGroup> listedMuscleGroups = <MuscleGroup>[];
    if (exercise != null) {
      nameController.text = exercise.name;
      descriptionConroller.text = exercise.description ?? '';
      if (exercise.muscleGroupId != null) {
        final MuscleGroup? muscleGroup = await context
            .read<MuscleGroupProvider>()
            .get(exercise.muscleGroupId!);
        if (muscleGroup != null) {
          listedMuscleGroups = <MuscleGroup>[muscleGroup];
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                exercise == null ? 'Create Exercise' : 'Edit Exercise',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Name',
                        label: Text('Exercise Name'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionConroller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Description',
                        label: Text('Description'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Muscle Groups'),
                    const SizedBox(height: 8),
                    if (listedMuscleGroups.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: listedMuscleGroups
                            .map(
                              (MuscleGroup mg) => Chip(
                                label: Text(mg.name),
                                onDeleted: () {
                                  setState(() {
                                    listedMuscleGroups.remove(mg);
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                        onPressed: () async {
                          final List<MuscleGroup>? result =
                              await Navigator.push(
                                context,
                                MaterialPageRoute<List<MuscleGroup>>(
                                  builder: (BuildContext context) =>
                                      const MuscleGroupSelector(),
                                ),
                              );
                          if (result != null) {
                            setState(() {
                              listedMuscleGroups.clear();
                              listedMuscleGroups.addAll(result);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String name = nameController.text.trim();
                    if (name.isEmpty) return;
                    if (listedMuscleGroups.isEmpty) return;
                    if (exercise == null) {
                      Navigator.of(context).pop();
                      context.read<ExerciseProvider>().add(
                        Exercise(
                          name: name,
                          muscleGroupId: listedMuscleGroups.first.id,
                        ),
                      );
                    } else {
                      Navigator.of(context).pop();
                      context.read<ExerciseProvider>().update(
                        Exercise(
                          name: name,
                          id: exercise.id,
                          muscleGroupId: listedMuscleGroups.first.id,
                        ),
                      );
                    }
                  },
                  child: Text(exercise == null ? 'Create' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _exerciseCard(Exercise exercise, BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _addOrEditExercise(context, exercise);
      },
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) =>
                ExerciseDetailsPage(exercise: exercise),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox.square(dimension: 8),
                  Row(children: <Widget>[muscleGroupChip(context, exercise)]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
